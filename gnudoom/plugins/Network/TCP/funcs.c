#define DBUG(x) x
#define FAST 1

#include <OSIncludes.h>

#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <sys/filio.h>

#include "DoomAttackNet.h"

struct Library *SocketBase;
extern struct ExecBase *SysBase;
extern struct Library *DOSBase;

doomdata_t **netbuffer;
doomcom_t *doomcom;

char **myargv;
int myargc;

static void (*I_Error)(char *error, ...);
static int (*M_CheckParm)(char *check);

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
}

/**********************************************************************/

static int DOOMPORT = (IPPORT_USERRESERVED + 0x1d);

static int sendsocket = -1;
static int insocket = -1;

static struct sockaddr_in sendaddress[MAXNETNODES];

static void (*netget)(void);
static void (*netsend)(void);

/**********************************************************************/
//
// UDPsocket
//
static int UDPsocket(void)
{
    int s;

    // allocate a socket
    s = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (s < 0)
        I_Error("DANet_TCP: Can't create socket: %s", strerror(errno));

    return s;
}

/**********************************************************************/
//
// BindToLocalPort
//
static void BindToLocalPort(int s, int port)
{
    int v;
    struct sockaddr_in address;

    memset(&address, 0, sizeof(address));
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = port;

    v = bind(s, (void *)&address, sizeof(address));
    if (v == -1)
        I_Error("DANet_TCP: bind failed: %s", strerror(errno));
}

/**********************************************************************/
//
// PacketSend
//
static void PacketSend(void)
{
    doomdata_t *netbuf = *netbuffer;
    int c;

#ifdef FAST
    c = sendto(sendsocket, (UBYTE *)netbuf, doomcom->datalength, 0, (void *)&sendaddress[doomcom->remotenode],
               sizeof(sendaddress[doomcom->remotenode]));
#else
    doomdata_t sw;

    // byte swap
    sw.checksum = htonl(netbuf->checksum);
    sw.player = netbuf->player;
    sw.retransmitfrom = netbuf->retransmitfrom;
    sw.starttic = netbuf->starttic;
    sw.numtics = netbuf->numtics;
    for (c = 0; c < netbuf->numtics; c++) {
        sw.cmds[c].forwardmove = netbuf->cmds[c].forwardmove;
        sw.cmds[c].sidemove = netbuf->cmds[c].sidemove;
        sw.cmds[c].angleturn = htons(netbuf->cmds[c].angleturn);
        sw.cmds[c].consistancy = htons(netbuf->cmds[c].consistancy);
        sw.cmds[c].chatchar = netbuf->cmds[c].chatchar;
        sw.cmds[c].buttons = netbuf->cmds[c].buttons;
    }

    // printf ("sending %i\n",gametic);
    c = sendto(sendsocket, (UBYTE *)&sw, doomcom->datalength, 0, (void *)&sendaddress[doomcom->remotenode],
               sizeof(sendaddress[doomcom->remotenode]));
#endif

    if (c == -1)
        /* why does AmiTCP 4.3 return EINVAL instead of EWOULDBLOCK ??? */
        if (errno != EWOULDBLOCK && errno != EINVAL)
            I_Error("DANet_TCP: SendPacket error %ld: %s", errno, strerror(errno));
}

/**********************************************************************/
//
// PacketGet
//
static void PacketGet(void)
{
    doomdata_t *netbuf = *netbuffer;
    int i, c;
    struct sockaddr_in fromaddress;
    LONG fromlen;

#ifndef FAST
    doomdata_t sw;
#endif

    fromlen = sizeof(fromaddress);

#ifdef FAST
    c = recvfrom(insocket, (UBYTE *)netbuf, sizeof(doomdata_t), 0, (struct sockaddr *)&fromaddress, &fromlen);
#else
    c = recvfrom(insocket, (UBYTE *)&sw, sizeof(sw), 0, (struct sockaddr *)&fromaddress, &fromlen);
#endif

    if (c == -1) {
        /* why does AmiTCP 4.3 return EINVAL instead of EWOULDBLOCK ??? */
        if (errno != EWOULDBLOCK && errno != EINVAL)
            I_Error("DANet_TCP: GetPacket error %ld: %s", errno, strerror(errno));
        doomcom->remotenode = -1;  // no packet
        return;
    }

    {
        static int first = 1;

#ifdef FAST
        if (first)
            printf("DANet_TCP: len=%d:p=[0x%x 0x%x] \n", c, *(int *)netbuf, *((int *)netbuf + 1));
#else
        if (first)
            printf("DANet_TCP: len=%d:p=[0x%x 0x%x] \n", c, *(int *)&sw, *((int *)&sw + 1));
#endif

        first = 0;
    }

    // find remote node number
    for (i = 0; i < doomcom->numnodes; i++)
        if (fromaddress.sin_addr.s_addr == sendaddress[i].sin_addr.s_addr)
            break;

    if (i == doomcom->numnodes) {
        // packet is not from one of the players (new game broadcast)
        doomcom->remotenode = -1;  // no packet
        return;
    }

    doomcom->remotenode = i;  // good packet from a game player
    doomcom->datalength = c;

// byte swap

#ifndef FAST
    netbuf->checksum = ntohl(sw.checksum);
    netbuf->player = sw.player;
    netbuf->retransmitfrom = sw.retransmitfrom;
    netbuf->starttic = sw.starttic;
    netbuf->numtics = sw.numtics;

    for (c = 0; c < netbuf->numtics; c++) {
        netbuf->cmds[c].forwardmove = sw.cmds[c].forwardmove;
        netbuf->cmds[c].sidemove = sw.cmds[c].sidemove;
        netbuf->cmds[c].angleturn = ntohs(sw.cmds[c].angleturn);
        netbuf->cmds[c].consistancy = ntohs(sw.cmds[c].consistancy);
        netbuf->cmds[c].chatchar = sw.cmds[c].chatchar;
        netbuf->cmds[c].buttons = sw.cmds[c].buttons;
    }
#endif
}

/**********************************************************************/
#if 0
static int GetLocalAddress (void)
{
  char hostname[1024];
  struct hostent* hostentry; // host information entry
  int v;

  // get local address
  v = gethostname (hostname, sizeof(hostname));
  if (v == -1)
    I_Error ("DANet_TCP: GetLocalAddress : gethostname: errno %d",errno);

  hostentry = gethostbyname (hostname);
  if (!hostentry)
    I_Error ("DANet_TCP: GetLocalAddress : gethostbyname: couldn't get local host");

  return *(int *)hostentry->h_addr_list[0];
}
#endif

/**********************************************************************/
//
// I_InitNetwork
//
// change: returns 0 if no netgame, otherwise it returns something != 0

int DAN_InitNetwork(void)
{
    struct TagItem inittags[] = {SBTM_SETVAL(SBTC_ERRNOLONGPTR), (LONG)&errno, TAG_DONE};

    struct hostent *hostentry;  // host information entry
    int i;
    int p;
    int netgame = 0;

    int trueval = 1;

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

    p = M_CheckParm("-port");
    if (p && p < myargc - 1) {
        DOOMPORT = atoi(myargv[p + 1]);
        printf("DANet_TCP: Using alternate port %i\n", DOOMPORT);
    }

    // parse network game options,
    //  -net <consoleplayer> <host> <host> ...
    i = M_CheckParm("-net");
    if (!i) {
        // single player game

        doomcom->id = DOOMCOM_ID;
        doomcom->numplayers = doomcom->numnodes = 1;
        doomcom->deathmatch = false;
        doomcom->consoleplayer = 0;
        return 0;
    }

    if ((SocketBase = OpenLibrary("bsdsocket.library", 0)) == NULL)
        I_Error("DANet_TCP: OpenLibrary(\"bsdsocket.library\") failed");

    if (SocketBaseTagList(inittags) != 0) {
        I_Error("DANet_TCP: SocketBaseTags failed!");
    }

    netsend = PacketSend;
    netget = PacketGet;

    netgame = 1;

    // parse player number and host list
    doomcom->consoleplayer = myargv[i + 1][0] - '1';

    doomcom->numnodes = 1;  // this node for sure

    i++;
    while (++i < myargc && myargv[i][0] != '-') {
        sendaddress[doomcom->numnodes].sin_family = AF_INET;
        sendaddress[doomcom->numnodes].sin_port = htons(DOOMPORT);
        if (myargv[i][0] == '.') {
            sendaddress[doomcom->numnodes].sin_addr.s_addr = inet_addr(myargv[i] + 1);
        } else {
            hostentry = gethostbyname(myargv[i]);
            if (!hostentry)
                I_Error("DANet_TCP: Gethostbyname: couldn't find %s", myargv[i]);
            sendaddress[doomcom->numnodes].sin_addr.s_addr = *(int *)hostentry->h_addr_list[0];
        }
        doomcom->numnodes++;
    }

    doomcom->id = DOOMCOM_ID;
    doomcom->numplayers = doomcom->numnodes;

    // build message to receive
    insocket = UDPsocket();
    sendsocket = UDPsocket();

    BindToLocalPort(insocket, htons(DOOMPORT));

    /* set both sockets to non-blocking */
    if ((IoctlSocket(insocket, FIONBIO, (char *)&trueval) == -1) ||
        (IoctlSocket(sendsocket, FIONBIO, (char *)&trueval) == -1))
        I_Error("DANet_TCP: IoctlSocket() failed: %s", strerror(errno));

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
        I_Error("DANet_TCP: Bad net cmd: %i\n", doomcom->command);
}

/**********************************************************************/
void DAN_CleanupNetwork(void)
{
    if (insocket != -1) {
        CloseSocket(insocket);
        insocket = -1;
    }
    if (sendsocket != -1) {
        CloseSocket(sendsocket);
        sendsocket = -1;
    }
    if (SocketBase != NULL) {
        CloseLibrary(SocketBase);
        SocketBase = NULL;
    }

    CleanupRuntime();
}

/**********************************************************************/
