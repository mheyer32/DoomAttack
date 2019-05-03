#define NUM_FASTMSG 20

#define MAX_PLAYERS 4
#define COMNAME "DOOMCOM"

struct PlayerPort
{
    struct List msglist;
    BOOL inuse;
};

struct ComPort
{
    struct SignalSemaphore sem;
    struct PlayerPort playerport[MAX_PLAYERS + 1];
    APTR pool;
    WORD users;
};

struct ComMsg
{
    struct Node node;
    WORD flags;
    WORD playerid;
    WORD datalen;
    doomdata_t dd;
};

#define CMF_ALLOCATED 1
#define CMF_MESSAGEUSED 2
