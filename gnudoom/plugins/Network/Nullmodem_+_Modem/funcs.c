//#define AMIGAAMIGA 1

#include <OSIncludes.h>
#include <string.h>

#include "DoomAttackNet.h"
#include "funcs.h"
#include "nullmodem.h"

/*=====================*/

doomdata_t **netbuffer;  // pointer to variable!!!
doomcom_t *doomcom;

char **myargv;
int myargc;

void (*I_Error)(char *error, ...);
static int (*M_CheckParm)(char *check);

/*=====================*/
static int consoleplayer;
BOOL SerDeviceOpened, SerWriting;
static char s[257], devicename[102];

char buffer[BUFFERLEN];

static char *DEVICENAME = "serial.device";
static LONG DEVICEUNIT = 0;
static LONG DEVICEBAUD = 14400;

static LONG bufferpos;
static BOOL usemodem, modemconnected, pulsedial, quitting;

extern struct ExecBase *SysBase;
extern struct Library *DOSBase;
extern struct IntuitionBase *IntuitionBase;

struct Device *SerialBase;
struct MsgPort *SerWriteMP;
struct MsgPort *SerReadMP;
struct IOExtSer *SerWriteIO;
struct IOExtSer *SerReadIO;

static char modeminit[257];
static char modemexit[257];

/*=====================*/

void DAN_Init(REGA0(struct DANInitialization *daninit))
{
    struct DANInitialization *init = daninit;

    InitRuntime();

    // link function pointers to DoomAttack routines

    I_Error = init->I_Error;
    M_CheckParm = init->M_CheckParm;

    // setups vars
    netbuffer = init->netbuffer;
    doomcom = init->doomcom;
    myargv = init->myargv;
    myargc = init->myargc;

    IntuitionBase = (struct IntuitionBase *)init->IntuitionBase;
}

/**********************************************************************/

static void (*netget)(void);
static void (*netsend)(void);

/**********************************************************************

PacketSend:

Send the netbuffer contents (**netbuffer, because of netbuffer
being a pointer to the real variable) to the player
doomcom->remotenode. doomcom->remontenode is the ID of
the player. For example if DoomAttack was started with
"-net 1 John Peter" than:

 0 is you
 1 is John
 2 is Peter

You need to transfer only doomcom->datalength bytes.

**********************************************************************/
#ifndef __ASM_ROUTINES__
static void PacketSend(char *buffer, LONG len)
{
    int b;
    static char localbuffer[MAXPACKET * 2 + 2];

    if (!len || (len > MAXPACKET))
        return;

    if (SerWriting) {
        WaitIO((struct IORequest *)SerWriteIO);
    }

    b = 0;
    while (len--) {
        if (*buffer == FRAMECHAR)
            localbuffer[b++] = FRAMECHAR;  // escape it for literal
        localbuffer[b++] = *buffer++;
    }

    localbuffer[b++] = FRAMECHAR;
    localbuffer[b++] = 0;

    SerWriteIO->IOSer.io_Command = CMD_WRITE;
    SerWriteIO->IOSer.io_Data = localbuffer;
    SerWriteIO->IOSer.io_Length = b;
    SerWriteIO->IOSer.io_Flags &= (~IOF_QUICK);
    BeginIO((struct IORequest *)SerWriteIO);
    SerWriting = TRUE;
}
#else
void PacketSend(REGA0(char *buffer), REGD0(LONG len));
#endif

/**********************************************************************

PacketGet:

Check if there's any new packet (data) from another
player. If there isn't set doomcom->remotenode to -1.

If there is, then set doomcom->remotnenode to the ID of
the player the packet comes from (see PacketSend).
Set also the length of the data: doomcom->datalength
and then copy the recieved data to the netbuffer
(*netbuffer, because of netbuffer being a pointer to
the real variable).


**********************************************************************/

#ifndef __ASM_ROUTINES__
static LONG len;
static LONG unreadbytes;
static LONG copypos;

static BOOL inescape;
static BOOL newpacket;
static LONG packetlen;
#else
extern LONG packetlen;
#endif

char packet[MAXPACKET + 1];

#ifndef __ASM_ROUTINES__
static BOOL PacketGet(void)
{
    int c;

    if (newpacket) {
        packetlen = 0;
        newpacket = FALSE;
    }

    do {
        if (unreadbytes < MAXPACKET) {
            SerReadIO->IOSer.io_Command = SDCMD_QUERY;
            DoIO((struct IORequest *)SerReadIO);

            if ((len = SerReadIO->IOSer.io_Actual)) {
                if ((unreadbytes + len) > BUFFERLEN) {
                    len = BUFFERLEN - unreadbytes;
                }

                if (len > 0) {
                    copypos = bufferpos + unreadbytes;
                    if (copypos >= BUFFERLEN)
                        copypos -= BUFFERLEN;

                    if ((copypos + len) <= BUFFERLEN) {
                        SerReadIO->IOSer.io_Command = CMD_READ;
                        SerReadIO->IOSer.io_Data = &buffer[copypos];
                        SerReadIO->IOSer.io_Length = len;
                        DoIO((struct IORequest *)SerReadIO);

                    } else {
                        SerReadIO->IOSer.io_Command = CMD_READ;
                        SerReadIO->IOSer.io_Data = &buffer[copypos];
                        SerReadIO->IOSer.io_Length = BUFFERLEN - copypos;
                        DoIO((struct IORequest *)SerReadIO);

                        SerReadIO->IOSer.io_Command = CMD_READ;
                        SerReadIO->IOSer.io_Data = &buffer[0];
                        SerReadIO->IOSer.io_Length = (len - (BUFFERLEN - copypos));
                        DoIO((struct IORequest *)SerReadIO);
                    }
                    unreadbytes += len;

                }  // if (len)

            }  // if ((len = SerReadIO-> IOSer.io_Actual))

        }  // if (unreadbytes < BUFFERLEN)

        if (!unreadbytes) {
            bufferpos = 0;
            return FALSE;
        }

        while (unreadbytes) {
            c = buffer[bufferpos++];
            unreadbytes--;

            if (bufferpos == BUFFERLEN)
                bufferpos = 0;

            if (inescape) {
                inescape = FALSE;
                if (c != FRAMECHAR) {
                    newpacket = TRUE;
                    return TRUE;
                }
            } else if (c == FRAMECHAR) {
                inescape = TRUE;
                continue;
            }
            if (packetlen >= MAXPACKET) {
                continue;  // oversize packet
            }
            packet[packetlen] = c;
            packetlen++;
        }

    } while (1);
}
#else
BOOL PacketGet(void);
#endif

/*********************************************************************/

#define ARG_TEMPLATE "DEVICE,UNIT/N,BAUD/N,MODEMINIT,MODEMEXIT,PULSE/S"
enum
{
    ARG_DEVICE,
    ARG_UNIT,
    ARG_BAUD,
    ARG_MODEMINIT,
    ARG_MODEMEXIT,
    ARG_PULSE,
    NUM_ARGS
};

static LONG Args[NUM_ARGS];

static void LoadConfig(void)
{
    char *mem;
    LONG len;
    BPTR MyHandle;
    struct RDArgs *MyArgs;

    strcpy(modeminit, "ATZ");
    strcpy(modemexit, "ATH0");

    if (!(MyHandle = Open("DoomAttackSupport/config/DANet_Nullmodem.config", MODE_OLDFILE))) {
        printf("DANet_Nullmodem: Could not open config file!\n");
    } else {
        Seek(MyHandle, 0, OFFSET_END);
        len = Seek(MyHandle, 0, OFFSET_BEGINNING);
        if (len < 1) {
            printf("DANet_Nullmodem: Could not get length of config file!\n");
        } else {
            if (!(mem = AllocVec(len + 2, MEMF_CLEAR))) {
                printf("DANet_Nullmodem: Out of memory!\n");
            } else {
                Read(MyHandle, mem, len);
                len = strlen(mem);
                mem[len++] = '\n';
                mem[len++] = '\0';

                if (!(MyArgs = AllocDosObject(DOS_RDARGS, 0))) {
                    printf("DANet_Nullmodem: Out of memory while trying to parse config file!\n");
                } else {
                    MyArgs->RDA_Source.CS_Buffer = mem;
                    MyArgs->RDA_Source.CS_Length = strlen(mem);
                    MyArgs->RDA_Source.CS_CurChr = 0;
                    MyArgs->RDA_Buffer = 0;
                    MyArgs->RDA_BufSiz = 0;
                    MyArgs->RDA_Flags = RDAF_NOPROMPT;

                    if (!ReadArgs(ARG_TEMPLATE, Args, MyArgs)) {
                        Fault(IoErr(), 0, s, 256);
                        printf("DANet_Nullmodem: Error in config file: %s\n", s);
                    } else {
                        if (Args[ARG_DEVICE]) {
                            strncpy(devicename, (char *)Args[ARG_DEVICE], 100);
                            DEVICENAME = devicename;
                        }

                        if (Args[ARG_UNIT])
                            DEVICEUNIT = *(LONG *)Args[ARG_UNIT];
                        if (Args[ARG_BAUD])
                            DEVICEBAUD = *(LONG *)Args[ARG_BAUD];

                        if (Args[ARG_MODEMINIT]) {
                            strncpy(modeminit, (char *)Args[ARG_MODEMINIT], 255);
                        }
                        if (Args[ARG_MODEMEXIT]) {
                            strncpy(modemexit, (char *)Args[ARG_MODEMEXIT], 255);
                        }
                        if (Args[ARG_PULSE])
                            pulsedial = TRUE;

                        FreeArgs(MyArgs);
                    }
                    FreeDosObject(DOS_RDARGS, MyArgs);
                }
                FreeVec(mem);
            }
        }
        Close(MyHandle);
    }
}

static void ModemCommand(char *str)
{
    int i, l;

    printf("DANet_Nullmodem: Modem command: ");
    l = strlen(str);

    for (i = 0; i <= l; i++) {
        SerWriteIO->IOSer.io_Command = CMD_WRITE;
        SerWriteIO->IOSer.io_Data = (i == l ? "\r" : str + i);
        SerWriteIO->IOSer.io_Length = 1;
        SendIO((struct IORequest *)SerWriteIO);

        while (1) {
            Delay(1);
            if (CheckIO((struct IORequest *)SerWriteIO))
                break;
            if (CheckSignal(SIGBREAKF_CTRL_C)) {
                AbortIO((struct IORequest *)SerWriteIO);
                WaitIO((struct IORequest *)SerWriteIO);
                if (!quitting) {
                    I_Error("DANet_Nullmodem: *** Aborted");
                } else
                    return;
            }
        }
        WaitIO((struct IORequest *)SerWriteIO);

        printf("%c", (i == l ? '\n' : str[i]));
    }
}

static void ModemResponse(char *resp)
{
    int respptr;
    char c;
    char response[80];

    do {
        printf("DANet_Nullmodem: Modem response [%s]: ", resp);
        respptr = 0;

        do {
            Delay(1);
            if (CheckSignal(SIGBREAKF_CTRL_C)) {
                if (!quitting) {
                    I_Error("DANet_Nullmodem: *** Aborted");
                } else
                    return;
            }

            SerReadIO->IOSer.io_Command = SDCMD_QUERY;
            DoIO((struct IORequest *)SerReadIO);

            if (!SerReadIO->IOSer.io_Actual)
                continue;

            SerReadIO->IOSer.io_Command = CMD_READ;
            SerReadIO->IOSer.io_Data = &c;
            SerReadIO->IOSer.io_Length = 1;

            DoIO((struct IORequest *)SerReadIO);

            if (c == '\n' || respptr == 79) {
                response[respptr] = 0;
                printf("%s\n", response);
                break;
            }
            if (c >= ' ') {
                response[respptr] = c;
                respptr++;
            }
        } while (1);

    } while (strncmp(response, resp, strlen(resp)));
}

static void Dial(void)
{
    char cmd[80];
    int p;

    usemodem = TRUE;

    ModemCommand(modeminit);
    ModemResponse("OK");

    printf("DANet_Nullmodem: Dialing ...\n\n");
    p = M_CheckParm("-dial");
    sprintf(cmd, pulsedial ? "ATDP%s" : "ATDT%s", myargv[p + 1]);

    ModemCommand(cmd);
    ModemResponse("CONNECT");

    modemconnected = TRUE;
}

static void Answer(void)
{
    usemodem = TRUE;

    ModemCommand(modeminit);
    ModemResponse("OK");

    printf("\nDANet_Nullmodem: Waiting for ring ...\n\n");

    ModemResponse("RING");
    ModemCommand("ATA");
    ModemResponse("CONNECT");
}

static void SetupConnection(void)
{
    ULONG seconds, micros;
    ULONG oldsec;
    int localstage, remotestage;
    char str[20];
    char idstr[7];
    char remoteidstr[7];
    unsigned long idnum;
    //	int			i;

    if (consoleplayer == 0) {
        idnum = 0;
    } else if (consoleplayer == 1) {
        idnum = 999999;
    } else {
        CurrentTime(&seconds, &micros);
        idnum = micros % 1000000;
    }

    idstr[0] = '0' + idnum / 100000l;
    idnum -= (idstr[0] - '0') * 100000l;
    idstr[1] = '0' + idnum / 10000l;
    idnum -= (idstr[1] - '0') * 10000l;
    idstr[2] = '0' + idnum / 1000l;
    idnum -= (idstr[2] - '0') * 1000l;
    idstr[3] = '0' + idnum / 100l;
    idnum -= (idstr[3] - '0') * 100l;
    idstr[4] = '0' + idnum / 10l;
    idnum -= (idstr[4] - '0') * 10l;
    idstr[5] = '0' + idnum;
    idstr[6] = 0;

    //
    // sit in a loop until things are worked out
    //
    // the packet is:  ID000000_0
    // the first field is the idnum, the second is the acknowledge stage
    // ack stage starts out 0, is bumped to 1 after the other computer's id
    // is known, and is bumped to 2 after the other computer has raised to 1
    //
    oldsec = -1;
    localstage = remotestage = 0;

    do {
        if (SetSignal(0, SIGBREAKF_CTRL_C) & SIGBREAKF_CTRL_C) {
            I_Error("DANet_Nullmodem: ***Aborted");
        }

        if (PacketGet()) {
            packet[packetlen] = 0;

            printf("DANet_Nullmodem: Recieved: %s\n", packet);

            if (packetlen != 10)
                continue;
            if (strncmp(packet, "ID", 2))
                continue;
            if (!strncmp(packet + 2, idstr, 6)) {
                I_Error("DAN_Nullmodem: Duplicate id string recieved!?");
            }
            strncpy(remoteidstr, packet + 2, 6);

            remotestage = packet[9] - '0';
            localstage = remotestage + 1;
            oldsec = -1;
        } else
            Delay(5);

        CurrentTime(&seconds, &micros);
        if (seconds != oldsec) {
            oldsec = seconds;
            sprintf(str, "ID%s_%i", idstr, localstage);
            printf("DANet_Nullmodem: Sending: %s\n", str);
            PacketSend(str, strlen(str));
        }

    } while (localstage < 2);

    Delay(50);

    while (PacketGet())
        ;

    if (strcmp(remoteidstr, idstr) > 0)
        doomcom->consoleplayer = consoleplayer = 0;
    else
        doomcom->consoleplayer = consoleplayer = 1;
}

/**********************************************************************

DAN_InitNetwork:

Do our init stuff and return TRUE if everything is OK.
If something went wrong cleanup and return FALSE - in
this case DoomAttack won't call DAN_CleanupNetwork.

If you return TRUE you must set doomcom->numplayers
and doomcom->numnodes to the number of players.
Further you have to set doomcom->consoleplayer to
the id of the "locale" player. All player ids are
in the range between 0 and <num players-1>. For example
if DoomAttack was started with "-net 3 Joe" then you
would set doomcom->consoleplayer to 2! This is not
the same as in PacketSend/PacketGet!

I nearly forgot! You must also set doomcom->id to
DOOMCOM_ID. Doom uses this to check whether the
different players are using the same version of Doom
(different version will not be accepted).

**********************************************************************/

int DAN_InitNetwork(void)
{
    int i;
    int netgame = 0;

    char trueval = true;

    // set up for network
    i = M_CheckParm("-dup");
    if (i && i < myargc - 1) {
        doomcom->ticdup = myargv[i + 1][0] - '0';
        if (doomcom->ticdup < 1)
            doomcom->ticdup = 1;
        if (doomcom->ticdup > 9)
            doomcom->ticdup = 9;
    } else
        doomcom->ticdup = 1;

    if (M_CheckParm("-extratic"))
        doomcom->extratics = 1;
    else
        doomcom->extratics = 0;

    // parse network game options,
    //  -net <consoleplayer> <host> <host> ...

    // don't need to check if "-net" option is present.
    // DoomAttack does this for you and if it isn't
    // present, it does not call DAM_InitNetwork

    consoleplayer = -1;
    i = M_CheckParm("-net");

    if (i && i < myargc - 1) {
        i = myargv[i + 1][0];
        if ((i >= '1') && (i <= '2')) {
            consoleplayer = i - '1';
        }
    }

    doomcom->numnodes = 2;
    doomcom->numplayers = 2;
    doomcom->id = DOOMCOM_ID;

    /*===========*/

    LoadConfig();

    if (!(SerWriteMP = CreateMsgPort()))
        I_Error("DANet_Nullmodem: Can't create Write MsgPort!");
    if (!(SerReadMP = CreateMsgPort())) {
        DAN_CleanupNetwork();
        I_Error("DANet_Nullmodem: Can't create Read MsgPort!");
    }

    if (!(SerWriteIO = (struct IOExtSer *)CreateIORequest(SerWriteMP, sizeof(struct IOExtSer)))) {
        DAN_CleanupNetwork();
        I_Error("DANet_Nullmodem: Can't create Write IORequest!");
    }

    if (!(SerReadIO = (struct IOExtSer *)CreateIORequest(SerReadMP, sizeof(struct IOExtSer)))) {
        DAN_CleanupNetwork();
        I_Error("DANet_Nullmodem: Can't create Read IORequestt!");
    }

    SerWriteIO->io_SerFlags = SERF_7WIRE;
    if (OpenDevice(DEVICENAME, DEVICEUNIT, (struct IORequest *)SerWriteIO, 0)) {
        DAN_CleanupNetwork();
        I_Error("DANet_Nullmodem: Can't open %s unit %d!", DEVICENAME, DEVICEUNIT);
    }
    SerialBase = SerWriteIO->IOSer.io_Device;
    SerDeviceOpened = TRUE;

    SerWriteIO->io_Baud = DEVICEBAUD;
    SerWriteIO->io_ReadLen = 8;
    SerWriteIO->io_WriteLen = 8;
    SerWriteIO->io_StopBits = 1;
    SerWriteIO->io_SerFlags |= SERF_7WIRE | SERF_XDISABLED | SERF_RAD_BOOGIE;
    SerWriteIO->io_SerFlags &= (~SERF_PARTY_ON);
    SerWriteIO->io_RBufLen = 65536;
    SerWriteIO->IOSer.io_Command = SDCMD_SETPARAMS;

    if (DoIO((struct IORequest *)SerWriteIO)) {
        DAN_CleanupNetwork();
        I_Error("DANet_Nullmodem: SETPARAMS command failed!");
    }

    CopyMem(SerWriteIO, SerReadIO, sizeof(struct IOExtSer));

    SerReadIO->IOSer.io_Message.mn_ReplyPort = SerReadMP;

    SerReadIO->IOSer.io_Command = CMD_CLEAR;
    DoIO((struct IORequest *)SerReadIO);

    if (M_CheckParm("-dial")) {
        Dial();
    } else if (M_CheckParm("-answer")) {
        Answer();
    }

    SetupConnection();

    /*===========*/

    return TRUE;
}

/**********************************************************************

DAN_NetCmd:

If doomcom->command == CMD_SEND call netsend()
If doomcom->command == CMD_GET call netget()

You don't need to change this

**********************************************************************/

#ifndef __ASM_ROUTINES__
void DAN_NetCmd(void)
{
    static doomdata_t sw;

#ifdef AMIGAAMIGA
    if (doomcom->command == CMD_SEND) {
        memcpy(&sw, *netbuffer, doomcom->datalength);
        PacketSend(&sw, doomcom->datalength);
    } else if (doomcom->command == CMD_GET) {
        if (PacketGet() && (packetlen <= sizeof(sw))) {
            doomcom->remotenode = 1;
            doomcom->datalength = packetlen;
            memcpy(*netbuffer, packet, packetlen);
        } else {
            doomcom->remotenode = -1;
        }
    } else {
        I_Error("DANet_Nullmodem: Bad net cmd: %i\n", doomcom->command);
    }
#else
    doomdata_t *netbuf;

    int c;

    if (doomcom->command == CMD_SEND) {
        memcpy(&sw, *netbuffer, doomcom->datalength);
        sw.checksum = SwapLONG(sw.checksum);

        for (c = 0; c < sw.numtics; c++) {
            sw.cmds[c].angleturn = SwapWORD(sw.cmds[c].angleturn);
            sw.cmds[c].consistancy = SwapWORD(sw.cmds[c].consistancy);
        }

        PacketSend((char *)&sw, doomcom->datalength);
    } else if (doomcom->command == CMD_GET) {
        if (PacketGet() && (packetlen <= sizeof(sw))) {
            doomcom->remotenode = 1;
            doomcom->datalength = packetlen;

            netbuf = *netbuffer;

            memcpy(netbuf, packet, packetlen);
            netbuf->checksum = SwapLONG(netbuf->checksum);

            for (c = 0; c < netbuf->numtics; c++) {
                netbuf->cmds[c].angleturn = SwapWORD(netbuf->cmds[c].angleturn);
                netbuf->cmds[c].consistancy = SwapWORD(netbuf->cmds[c].consistancy);
            }

        } else {
            doomcom->remotenode = -1;
        }
    } else {
        I_Error("DANet_Nullmodem: Bad net cmd: %i\n", doomcom->command);
    }

#endif
}
#endif

/**********************************************************************

DAN_CleanupNetwork:

Called when the user quits DoomAttack. Cleanup everything.

**********************************************************************/

void DAN_CleanupNetwork(void)
{
    static BOOL alreadydone = FALSE;

    if (alreadydone)
        return;
    alreadydone = TRUE;
    quitting = TRUE;

    if (SerDeviceOpened) {
        if (SerWriting) {
            AbortIO((struct IORequest *)SerWriteIO);
            WaitIO((struct IORequest *)SerWriteIO);
        }

        if (modemconnected) {
            Delay(50 * 2);
            ModemCommand("+++");
            Delay(50 * 2);
        }
        if (usemodem) {
            ModemCommand(modemexit);
            Delay(50 * 2);
        }
        CloseDevice((struct IORequest *)SerWriteIO);
    }

    if (SerWriteIO)
        DeleteIORequest((struct IORequest *)SerWriteIO);
    if (SerReadIO)
        DeleteIORequest((struct IORequest *)SerReadIO);

    if (SerWriteMP)
        DeleteMsgPort(SerWriteMP);
    if (SerReadMP)
        DeleteMsgPort(SerReadMP);

    CleanupRuntime();
}

/**********************************************************************/
