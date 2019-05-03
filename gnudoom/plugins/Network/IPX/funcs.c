#include <clib/alib_protos.h>
#include <exec/memory.h>
#include <exec/ports.h>
#include <exec/types.h>

#ifdef __MAXON__
#include <linkerfunc.h>
#endif

#pragma header

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

//#include <libraries/amiamipx.h>
//#include <pragma/amipx_lib.h>

#include "doom.h"

#include "DoomAttackNet.h"

struct AMIPX_Library *AMIPX_Library;

/*=====================*/

doomdata_t *netbuffer;  // pointer to variable!!!
doomcom_t *doomcom;

char **myargv;
int myargc;

static void (*I_Error)(char *error, ...);
static int (*M_CheckParm)(char *check);

extern LONG SwapLONG(REGD0(LONG val));
extern WORD SwapWORD(REGD0(WORD val));

#define MYLONG(x) (SwapLONG(x))
#define MYSHORT(x) (SwapWORD(x))
#define IPX_PacketGet PacketGet
#define IPX_PacketSend PacketSend

#define MAXPLAYERS 4
#define MAXLONG 0x7FFFFFFF

/*=====================*/

// WORD playerid,consoleplayer;

/*=====================*/

void DAN_Init(REGA0(struct DANInitialization *daninit))
{
    struct DANInitialization *init = daninit;

#ifdef __MAXON__
    InitModules();
#endif

    // link function pointers to DoomAttack routines

    I_Error = init->I_Error;
    M_CheckParm = init->M_CheckParm;

    // setups vars

    netbuffer = *init->netbuffer;
    doomcom = init->doomcom;
    myargv = init->myargv;
    myargc = init->myargc;
}

/**********************************************************************/

static void (*netget)(void);
static void (*netsend)(void);

#define IPX_NUMPACKETS 10  // max outstanding packets before loss

// setupdata_t is used as doomdata_t during setup
typedef struct
{
    WORD gameid;       // so multiple games can setup at once
    WORD drone;        // You must take care to make gameid LSB first - GJP
    WORD nodesfound;   // these two are only compared to each other so it
    WORD nodeswanted;  // does not matter what internal storage you use
} setupdata_t;

typedef struct
{
    UBYTE network[4]; /* high-low */
    UBYTE node[6];    /* high-low */
} localadr_t;

typedef struct
{
    UBYTE node[6]; /* high-low */
} nodeadr_t;

// I think a version I downloaded in late 1997, used just one fragment,
// but multiple fragments is supported by AMIPX, I even endorse it - GJP

// time is used by the communication driver to sequence packets returned
// to DOOM when more than one is waiting
// this is were the 68k has to be very careful to store the time LSB first- GJP

typedef struct
{
    struct AMIPX_ECB ecb;        /* too small!!!  need space for 2 fragments !!! */
    struct AMIPX_Fragment dummy; /* maybe this will fix it */
    struct AMIPX_PacketHeader ipx;
    long time;
    doomdata_t data;
} packet_t;

struct AMIPX_Library *AMIPX_Library = NULL;
static packet_t IPX_packets[IPX_NUMPACKETS];
static nodeadr_t IPX_nodeadr[MAXNETNODES + 1];  // first is local, last is broadcast
static nodeadr_t IPX_remoteadr;                 // set by each GetPacket
static localadr_t IPX_localadr;                 // set at startup
static UWORD IPX_socketid = 0;
static long IPX_localtime;  // for time stamp in packets
static long IPX_remotetime;
static BOOL IPX_got_a_packet;

/**********************************************************************/
static int IPX_OpenSocket(WORD socketNumber)
{
    int outsock;

    if ((outsock = AMIPX_OpenSocket(socketNumber)) == 0)
        I_Error("AMIPX_OpenSocket() failed");
    return outsock;
}

/**********************************************************************/
static void IPX_ListenForPacket(struct AMIPX_ECB *ecb)
{
    int retval;

    if ((retval = AMIPX_ListenForPacket(ecb)))
        I_Error("ListenForPacket: 0x%x", retval);
}

/**********************************************************************/

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

static void PacketSend(void)
{
    int j, c, retval;
    int destination;
    int len;
    doomdata_t sw;

    // byte swap if not in setup
    if (IPX_localtime != -1) {
        sw.checksum = MYLONG(netbuffer->checksum);
        sw.player = netbuffer->player;
        sw.retransmitfrom = netbuffer->retransmitfrom;
        sw.starttic = netbuffer->starttic;
        sw.numtics = netbuffer->numtics;

        for (c = 0; c < netbuffer->numtics; c++) {
            sw.cmds[c].forwardmove = netbuffer->cmds[c].forwardmove;
            sw.cmds[c].sidemove = netbuffer->cmds[c].sidemove;
            sw.cmds[c].angleturn = MYSHORT(netbuffer->cmds[c].angleturn);
            sw.cmds[c].consistancy = MYSHORT(netbuffer->cmds[c].consistancy);
            sw.cmds[c].chatchar = netbuffer->cmds[c].chatchar;
            sw.cmds[c].buttons = netbuffer->cmds[c].buttons;
        }
        IPX_packets[0].ecb.Fragment[1].FragData = (UBYTE *)&sw;
    } else
        IPX_packets[0].ecb.Fragment[1].FragData = (UBYTE *)&doomcom->data;

    destination = doomcom->remotenode;

    // set the time
    IPX_packets[0].time = MYLONG(IPX_localtime);  // Amiga puts MSB first

    // set the address
    for (j = 0; j < 6; j++)
        IPX_packets[0].ipx.Dst.Node[j] = IPX_packets[0].ecb.ImmedAddr[j] = IPX_nodeadr[destination].node[j];

    // set the length (ipx + time + datalength)
    len = sizeof(struct AMIPX_PacketHeader) + sizeof(long) + doomcom->datalength + 4;
    IPX_packets[0].ipx.Checksum = 0xffff;
    IPX_packets[0].ipx.Length = len;
    IPX_packets[0].ipx.Type = 4;
    IPX_packets[0].ecb.Fragment[0].FragSize = sizeof(struct AMIPX_PacketHeader) + sizeof(long);
    IPX_packets[0].ecb.Fragment[1].FragSize = doomcom->datalength + 4;

    // send the packet
    /*
      printf ("Sending ");
      print_ecb (&(IPX_packets[0].ecb));
      printf ("with IPX header ");
      print_ipx ((struct AMIPX_PacketHeader *)
                 IPX_packets[0].ecb.Fragment[0].FragData);
    */
    if ((retval = AMIPX_SendPacket(&(IPX_packets[0].ecb))) != 0)
        I_Error("SendPacket: 0x%x", retval);

    while (IPX_packets[0].ecb.InUse != 0) {
        // IPX Relinquish Control - polled drivers MUST have this here!
        AMIPX_RelinquishControl();
    }
}

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

static void PacketGet(void)
{
    int packetnum;
    int i, c;
    long besttic;
    packet_t *packet;
    doomdata_t *sw;

    // if multiple packets are waiting, return them in order by time

    IPX_got_a_packet = FALSE;
    besttic = MAXLONG;
    packetnum = -1;
    doomcom->remotenode = -1;

    /* printf ("Looking for received packets...\n"); */

    for (i = 1; i < IPX_NUMPACKETS; i++)
        if (!IPX_packets[i].ecb.InUse) {
            /* printf ("\nGOT A PACKET!!!\n"); */

            if ((IPX_localtime != -1 && IPX_packets[i].time == -1))
                IPX_ListenForPacket(&IPX_packets[i].ecb);  // unwanted packet
            else if (MYLONG(IPX_packets[i].time) < besttic) {
                besttic = MYLONG(IPX_packets[i].time);
                packetnum = i;
            }
        }

    if (besttic == MAXLONG)
        return;  // no packets

    //
    // got a good packet
    //
    IPX_got_a_packet = TRUE;
    packet = &IPX_packets[packetnum];
    IPX_remotetime = besttic;

    if (packet->ecb.CompletionCode)
        I_Error("IPX_PacketGet: ecb.CompletionCode = 0x%x", packet->ecb.CompletionCode);
    // corrected that ancient typo, sorry - GJP
    // set IPX_remoteadr to the sender of the packet
    memcpy(&IPX_remoteadr, packet->ipx.Src.Node, sizeof(IPX_remoteadr));
    for (i = 0; i < doomcom->numnodes; i++)
        if (!memcmp(&IPX_remoteadr, &IPX_nodeadr[i], sizeof(IPX_remoteadr)))
            break;
    if (i < doomcom->numnodes)
        doomcom->remotenode = i;
    else {
        if (IPX_localtime != -1) {  // this really shouldn't happen
            IPX_ListenForPacket(&packet->ecb);
            return;
        }
    }

    // copy out the data
    doomcom->datalength = packet->ipx.Length - sizeof(struct AMIPX_PacketHeader) - sizeof(long) - 4;
    // byte swap if not in setup time
    if (IPX_localtime != -1) {
        sw = &packet->data;
        netbuffer->checksum = MYLONG(sw->checksum);
        netbuffer->player = sw->player;
        netbuffer->retransmitfrom = sw->retransmitfrom;
        netbuffer->starttic = sw->starttic;
        netbuffer->numtics = sw->numtics;

        for (c = 0; c < netbuffer->numtics; c++) {
            netbuffer->cmds[c].forwardmove = sw->cmds[c].forwardmove;
            netbuffer->cmds[c].sidemove = sw->cmds[c].sidemove;
            netbuffer->cmds[c].angleturn = MYSHORT(sw->cmds[c].angleturn);
            netbuffer->cmds[c].consistancy = MYSHORT(sw->cmds[c].consistancy);
            netbuffer->cmds[c].chatchar = sw->cmds[c].chatchar;
            netbuffer->cmds[c].buttons = sw->cmds[c].buttons;
        }
    } else
        memcpy(&doomcom->data, &packet->data, doomcom->datalength);

    // repost the ECB
    IPX_ListenForPacket(&packet->ecb);
}

/**********************************************************************/

static void IPX_LookForNodes(int numnetnodes)
{
    int i;
    clock_t oldsec, newsec;
    setupdata_t *dest;
    int total, console;
    static setupdata_t nodesetup[MAXNETNODES];

    //
    // wait until we get [numnetnodes] packets, then start playing
    // the playernumbers are assigned by netid
    //
    printf(
        "Attempting to find all players for %i player net play. "
        "Press CTRL/C to exit.\n",
        numnetnodes);

    printf("Looking for a node...\n");

    oldsec = clock();
    IPX_localtime = -1;  // in setup time, not game time

    //
    // build local setup info
    //
    nodesetup[0].nodesfound = 1;
    nodesetup[0].nodeswanted = numnetnodes;
    doomcom->numnodes = 1;

    for (;;) {
        //
        // check for aborting
        //
        // chkabort ();

        //
        // listen to the network
        //
        for (;;) {
            IPX_PacketGet();

            if (!IPX_got_a_packet)
                break;

            if (doomcom->remotenode == -1) {  // it's from a new address
                dest = &nodesetup[doomcom->numnodes];
            } else {  // it's from a node we already know about
                dest = &nodesetup[doomcom->remotenode];
            }

            if (IPX_remotetime != -1) {  // an early game packet, not a setup packet
                if (doomcom->remotenode == -1)
                    I_Error("Got an unknown game packet during setup");
                // if it allready started, it must have found all nodes
                dest->nodesfound = dest->nodeswanted;  // both swapped
                continue;
            }

            // update setup info
            memcpy(dest, &doomcom->data, sizeof(*dest));

            if (doomcom->remotenode == -1) {  // it's from a new address

                memcpy(&IPX_nodeadr[doomcom->numnodes], &IPX_remoteadr, sizeof(IPX_nodeadr[doomcom->numnodes]));
                //
                // if this node has a lower address, take all startup info
                //
                if (memcmp(&IPX_remoteadr, &IPX_nodeadr[0], sizeof(&IPX_remoteadr)) < 0) {
                }  // No action ?!
                   // You could call this a bug - how does one DOOM know
                   // whether everyone wants the same number of players?
                   // However, because of this, using internal storage for
                   // these setup packets actually works.
                   // (which saves the Mac version, because if this was not
                   // ignored, the PC would start looking for a multiple of
                   // 256 players) - GJP

                doomcom->numnodes++;

                printf("\nFound node [%02x:%02x:%02x:%02x:%02x:%02x]\n", IPX_remoteadr.node[0], IPX_remoteadr.node[1],
                       IPX_remoteadr.node[2], IPX_remoteadr.node[3], IPX_remoteadr.node[4], IPX_remoteadr.node[5]);

                if (doomcom->numnodes < numnetnodes)
                    printf("Looking for a node...\n");

            } /* end if (doomcom->remotenode == -1) */

        } /* end for (;;) until no more packets received */

        //
        // we are done if all nodes have found all other nodes
        //
        for (i = 0; i < doomcom->numnodes; i++)
            if (nodesetup[i].nodesfound != nodesetup[i].nodeswanted)  // both swapped
                break;

        // You will notice that nodesetup[0].nodesfound is never compared to
        // nodesetup[i].nodeswanted
        if (i == nodesetup[0].nodeswanted)
            break;  // got them all

        //
        // send out a broadcast packet every second
        //
        newsec = clock() - oldsec;
        if (newsec >= CLOCKS_PER_SEC) {
            oldsec = newsec;
            printf(".");
            fflush(stdout);

            nodesetup[0].nodesfound = doomcom->numnodes;
            memcpy(&doomcom->data, &nodesetup[0], sizeof(setupdata_t));
            doomcom->remotenode = MAXNETNODES;
            doomcom->datalength = sizeof(setupdata_t);
            IPX_PacketSend();  // send to all
        }

    } /* end for (;;) until all nodes have found all other nodes */

    //
    // count players
    //
    total = 0;
    console = 0;

    for (i = 0; i < numnetnodes; i++) {
        if (nodesetup[i].drone)
            continue;
        total++;
        if (total > MAXPLAYERS)
            I_Error("More than %i players specified!", MAXPLAYERS);
        if (memcmp(&IPX_nodeadr[i], &IPX_nodeadr[0], sizeof(IPX_nodeadr[0])) < 0)
            console++;
    }

    if (!total)
        I_Error("No players specified for game!");

    doomcom->consoleplayer = console;
    doomcom->numplayers = total;

    printf("Console is player %i of %i\n", console + 1, total);
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
    int i, p, socket;
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

    p = M_CheckParm("-net");

    netsend = PacketSend;
    netget = PacketGet;

    //
    // get IPX function address
    //
    if ((AMIPX_Library = (struct AMIPX_Library *)OpenLibrary("amipx.library", 0L)) == NULL)
        I_Error("Can't open amipx.library");

    //
    // allocate a socket for sending and receiving
    //

    fprintf(stderr, "I_Init: Using IPX Network\n");

    socket = 0x869b;
    i = M_CheckParm("-socket");
    if (i && i < myargc - 1) {
        socket = atoi(myargv[i + 1]);
    }
    IPX_socketid = IPX_OpenSocket(socket);
    printf("Using IPX socket 0x%04x\n", IPX_socketid);

    AMIPX_GetLocalAddr((BYTE *)&IPX_localadr);
    printf("Local address is [%02x:%02x:%02x:%02x:%02x:%02x]\n", IPX_localadr.node[0], IPX_localadr.node[1],
           IPX_localadr.node[2], IPX_localadr.node[3], IPX_localadr.node[4], IPX_localadr.node[5]);

    //
    // set up several receiving ECBs
    //
    memset(IPX_packets, 0, IPX_NUMPACKETS * sizeof(packet_t));

    for (i = 1; i < IPX_NUMPACKETS; i++) {
        IPX_packets[i].ecb.Socket = IPX_socketid;
        IPX_packets[i].ecb.FragCount = 2;
        IPX_packets[i].ecb.Fragment[0].FragData = (BYTE *)&IPX_packets[i].ipx;
        IPX_packets[i].ecb.Fragment[0].FragSize = sizeof(struct AMIPX_PacketHeader) + sizeof(long);
        IPX_packets[i].ecb.Fragment[1].FragData = (BYTE *)&IPX_packets[i].data;
        IPX_packets[i].ecb.Fragment[1].FragSize = sizeof(doomdata_t);
        IPX_ListenForPacket(&IPX_packets[i].ecb);
    }

    //
    // set up a sending ECB
    //
    memset(&IPX_packets[0], 0, sizeof(IPX_packets[0]));

    IPX_packets[0].ecb.Socket = IPX_socketid;
    IPX_packets[0].ecb.FragCount = 2;
    IPX_packets[0].ecb.Fragment[0].FragData = (BYTE *)&IPX_packets[0].ipx;
    IPX_packets[0].ecb.Fragment[1].FragData = (BYTE *)&doomcom->data;
    memcpy(IPX_packets[0].ipx.Dst.Network, IPX_localadr.network, 4);
    IPX_packets[0].ipx.Dst.Socket = IPX_socketid;

    /* why doesn't amipx.library fill in ipx.Src? */
    memcpy(&IPX_packets[0].ipx.Src, &IPX_localadr, 4 + 6);
    IPX_packets[0].ipx.Src.Socket = IPX_socketid;

    // known local node at 0
    memcpy(IPX_nodeadr[0].node, IPX_localadr.node, 6);

    // broadcast node at MAXNETNODES
    memset(IPX_nodeadr[MAXNETNODES].node, 0xff, 6);

    netgame = TRUE;

    // parse player number and host list

    IPX_LookForNodes(myargv[p + 1][0] - '0');

    IPX_localtime = 0;

    doomcom->id = DOOMCOM_ID;

    return netgame;
}

/**********************************************************************

DAN_NetCmd:

If doomcom->command == CMD_SEND call netsend()
If doomcom->command == CMD_GET call netget()

You don't need to change this

**********************************************************************/

void DAN_NetCmd(void)
{
    IPX_localtime++;

    if (doomcom->command == CMD_SEND) {
        netsend();
    } else if (doomcom->command == CMD_GET) {
        netget();
    } else
        I_Error("Bad net cmd: %i\n", doomcom->command);
}

/**********************************************************************

DAN_CleanupNetwork:

Called when the user quits DoomAttack. Cleanup everything.

**********************************************************************/

void DAN_CleanupNetwork(void)
{
    if (IPX_socketid != 0) {
        printf("IPX_Shutdown: Closing socket and library\n");
        AMIPX_CloseSocket(IPX_socketid);
        IPX_socketid = 0;
    }
    if (AMIPX_Library != NULL) {
        CloseLibrary((struct Library *)AMIPX_Library);
        AMIPX_Library = NULL;
    }

#ifdef __MAXON__
    CleanupModules();
#endif
}

/**********************************************************************/
