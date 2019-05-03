
#include <OSIncludes.h>
#include <string.h>

#include "DoomAttackNet.h"
#include "ComPort.h"

/*=====================*/

struct ExecBase *SysBase;

doomdata_t **netbuffer;
doomcom_t *doomcom;

char **myargv;
int myargc;

static void (*I_Error)(char *error, ...);
static int (*M_CheckParm)(char *check);

/*=====================*/

static struct ComPort *comport;
static struct ComMsg sendMsg, *getMsg;
static struct ComMsg fastMsg[NUM_FASTMSG];

static struct List *sendport[MAX_PLAYERS + 1];
static WORD portnode[MAX_PLAYERS + 1];

WORD playerid, consoleplayer;

/*=====================*/

void DAN_Init(REGA0(struct DANInitialization *daninit))
{
    struct DANInitialization *init = daninit;

    // Activate if access to clib is required
    //	InitRuntime();

    // link function pointers to DoomAttack routines
    SysBase = init->SysBase;
    I_Error = init->I_Error;
    M_CheckParm = init->M_CheckParm;

    // setups vars

    netbuffer = init->netbuffer;
    doomcom = init->doomcom;
    myargv = init->myargv;
    myargc = init->myargc;
}

/**********************************************************************/

static void (*netget)(void);
static void (*netsend)(void);

/**********************************************************************/
//
// PacketSend
//
static void PacketSend(void)
{
    struct ComMsg *msg = 0;

    doomdata_t *netbuf = *netbuffer;
    int c;

    for (c = 0; c < NUM_FASTMSG; c++) {
        if (!(fastMsg[c].flags & CMF_MESSAGEUSED)) {
            fastMsg[c].flags |= CMF_MESSAGEUSED;
            msg = &fastMsg[c];
            break;
        }
    }

    // no msg free ==> let's allocate one
    if (!msg) {
        msg = AllocPooled(comport->pool, sizeof(struct ComMsg));
        memset(msg, 0, sizeof(*msg));
        msg->flags = CMF_ALLOCATED;
    }

    msg->dd = *netbuf;

    msg->datalen = doomcom->datalength;
    msg->playerid = playerid;

    Forbid();
    AddTail(sendport[doomcom->remotenode], &msg->node);
    Permit();
}

/**********************************************************************/
//
// PacketGet
//
static void PacketGet(void)
{
    doomdata_t *netbuf = *netbuffer;

    Forbid();
    getMsg = (struct ComMsg *)RemHead(&comport->playerport[playerid].msglist);
    Permit();

    if (!getMsg) {
        doomcom->remotenode = -1;  // no packet
        return;
    }

    doomcom->remotenode = portnode[getMsg->playerid];
    doomcom->datalength = getMsg->datalen;

    if (doomcom->remotenode < 0 || doomcom->remotenode >= MAX_PLAYERS) {
        doomcom->remotenode = -1;
    } else {
        *netbuf = getMsg->dd;
    }

    if (getMsg->flags & CMF_ALLOCATED) {
        FreePooled(comport->pool, getMsg, sizeof(struct ComMsg));
    } else {
        getMsg->flags &= (~CMF_MESSAGEUSED);
    }
}

/**********************************************************************/
//
// I_InitNetwork
//
// change: returns 0 if no netgame, otherwise it returns something != 0

int DAN_InitNetwork(void)
{
    int i, i2;
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

    i = M_CheckParm("-net");

    netsend = PacketSend;
    netget = PacketGet;

    netgame = 1;

    // parse player number and host list
    doomcom->consoleplayer = consoleplayer = myargv[i + 1][0] - '1';

    doomcom->numnodes = 1;  // this node for sure

    i++;
    while (++i < myargc && myargv[i][0] != '-') {
        doomcom->numnodes++;
    }

    doomcom->id = DOOMCOM_ID;
    doomcom->numplayers = doomcom->numnodes;

    Forbid();
    if ((comport = (struct ComPort *)FindSemaphore(COMNAME))) {
        playerid = ++comport->users;
    } else {
        comport = AllocVec(sizeof(struct ComPort), MEMF_PUBLIC | MEMF_CLEAR);
        if (!comport) {
            Permit();
            I_Error("NetPlugin: Out of memory!");
        }
        InitSemaphore(&comport->sem);
        comport->sem.ss_Link.ln_Name = COMNAME;
        comport->sem.ss_Link.ln_Pri = -128;

        comport->pool = CreatePool(MEMF_PUBLIC, sizeof(struct ComMsg) * 20, sizeof(struct ComMsg) * 20);
        if (!comport->pool) {
            Permit();
            FreeVec(comport);
            comport = 0;

            I_Error("NetPlugin: Out of memory!");
        }

        AddSemaphore(&comport->sem);

        for (i = 1; i <= MAX_PLAYERS; i++) {
            NewList(&comport->playerport[i].msglist);
        }

        playerid = comport->users = 1;
    }

    playerid = consoleplayer + 1;

    Permit();

    sendMsg.playerid = playerid;

    for (i = 0; i < doomcom->numplayers; i++) {
        portnode[i] = -1;
    }

    i2 = 1;
    for (i = 1; i < doomcom->numplayers; i++) {
        if (i == playerid)
            i2++;
        portnode[i2] = i;
        sendport[i] = &comport->playerport[i2].msglist;
        i2++;
    }

    return netgame;
}

/**********************************************************************/

void DAN_NetCmd(void)
{
    if (doomcom->command == CMD_SEND) {
        netsend();
    } else if (doomcom->command == CMD_GET) {
        netget();
    } else
        I_Error("Bad net cmd: %i\n", doomcom->command);
}

/**********************************************************************/

void DAN_CleanupNetwork(void)
{
    Forbid();
    {
        if (comport) {
            if (playerid > 0) {
                comport->playerport[playerid].inuse = FALSE;
            }

            comport->users--;

            if (comport->users == 0) {
                RemSemaphore(&comport->sem);
                if (comport->pool)
                    DeletePool(comport->pool);
                FreeVec(comport);
            }
        }
    }
    Permit();

    // CleanupRuntime();
}

/**********************************************************************/
