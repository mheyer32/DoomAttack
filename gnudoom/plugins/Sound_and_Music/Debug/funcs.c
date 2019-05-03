#include <OSIncludes.h>

#ifdef __MAXON__
#include <linkerfunc.h>
#endif

#include "DoomAttackMusic.h"
#include "funcs.h"
#include "musicIDs.h"

/*=====================*/

static int *gametic;
static int *snd_MusicVolume;

static char **myargv;
static int myargc;

static void (*I_Error)(char *error, ...);
static int (*M_CheckParm)(char *check);

/*=====================*/

struct IntuitionBase *IntuitionBase;

static struct EasyStruct es = {sizeof(struct EasyStruct), 0, "DoomAttack Music Debug", 0, "OK"};

static char *musname[] = {
    "mus_None",   "mus_e1m1",   "mus_e1m2",   "mus_e1m3",   "mus_e1m4",   "mus_e1m5",   "mus_e1m6",   "mus_e1m7",
    "mus_e1m8",   "mus_e1m9",   "mus_e2m1",   "mus_e2m2",   "mus_e2m3",   "mus_e2m4",   "mus_e2m5",   "mus_e2m6",
    "mus_e2m7",   "mus_e2m8",   "mus_e2m9",   "mus_e3m1",   "mus_e3m2",   "mus_e3m3",   "mus_e3m4",   "mus_e3m5",
    "mus_e3m6",   "mus_e3m7",   "mus_e3m8",   "mus_e3m9",   "mus_inter",  "mus_intro",  "mus_bunny",  "mus_victor",
    "mus_introa", "mus_runnin", "mus_stalks", "mus_countd", "mus_betwee", "mus_doom",   "mus_the_da", "mus_shawn",
    "mus_ddtblu", "mus_in_cit", "mus_dead",   "mus_stlks2", "mus_theda2", "mus_doom2",  "mus_ddtbl2", "mus_runni2",
    "mus_dead2",  "mus_stlks3", "mus_romero", "mus_shawn2", "mus_messag", "mus_count2", "mus_ddtbl3", "mus_ampie",
    "mus_theda3", "mus_adrian", "mus_messg2", "mus_romer2", "mus_tense",  "mus_shawn3", "mus_openin", "mus_evil",
    "mus_ultima", "mus_read_m", "mus_dm2ttl", "mus_dm2int",

    "??????????"};

/*********************************************************/

void C_DAM_Init(struct DAMInitialization *daminit)
{
    //		Activate if access to runtime is needed
    //		InitRuntime();

    // link function pointers to DoomAttack routines
    I_Error = daminit->I_Error;
    M_CheckParm = daminit->M_CheckParm;

    // setups vars
    IntuitionBase = (struct IntuitionBase *)daminit->IntuitionBase;

    gametic = daminit->gametic;
    snd_MusicVolume = daminit->snd_MusicVolume;
    myargv = daminit->myargv;
    myargc = daminit->myargc;

    // Tell DoomAttack the informations, it needs

    daminit->numchannels = 0;
}

/*********************************************************/

int C_DAM_InitMusic(void)
{
    return TRUE;
}

/*********************************************************/

void C_DAM_ShutdownMusic(void)
{
    // CleanupModules();
}

/*********************************************************/

void C_DAM_SetMusicVolume(int volume)
{
}

/*********************************************************/

void C_DAM_PauseSong(int handle)
{
}

/*********************************************************/

void C_DAM_ResumeSong(int handle)
{
}

void C_DAM_StopSong(int handle)
{
}

/*********************************************************/

int C_DAM_RegisterSong(void *data, int songnum)
{
    es.es_TextFormat = "Song: \"%s\"";
    EasyRequest(0, &es, 0, (ULONG)&musname[songnum]);

    return 0;
}

/*********************************************************/

void C_DAM_PlaySong(int handle, int looping)
{
}

/*********************************************************/

void C_DAM_UnRegisterSong(int handle)
{
}

/*********************************************************/

int C_DAM_QrySongPlaying(int handle)
{
    return TRUE;
}
