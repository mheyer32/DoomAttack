#include <OSIncludes.h>

#include <stdio.h>

#ifdef __MAXON__
#include <linkerfunc.h>
#endif

#include "DoomAttackMusic.h"
#include "funcs.h"

extern struct ExecBase *SysBase;
extern struct Library *DOSBase;

/*=====================*/

static int *gametic;
static int *snd_MusicVolume;

static char **myargv;
static int myargc;

static void (*I_Error)(char *error, ...);
static int (*M_CheckParm)(char *check);

/*=====================*/

#define SNDSERVERNAME "ADoom_SndSrvr"

static BOOL serverOK;

extern struct Library *DoomSoundBase;
extern BOOL NoMusic;
extern BOOL NoSound;

/*********************************************************/

void C_DAM_Init(struct DAMInitialization *daminit)
{
    InitRuntime();

    // link function pointers to DoomAttack routines
    I_Error = daminit->I_Error;
    M_CheckParm = daminit->M_CheckParm;

    // setups vars
    gametic = daminit->gametic;
    snd_MusicVolume = daminit->snd_MusicVolume;
    myargv = daminit->myargv;
    myargc = daminit->myargc;

    // Tell DoomAttack the informations, it needs
    daminit->numchannels = 16 | DAMF_SOUNDFX | DAMF_FASTRAM;
}

static char *PREFSNAME = "DoomAttackSupport/config/DAMusic_DoomSndLibrary.config";
static char s[202];

#define ARG_TEMPLATE "MUSICONLY/S,SOUNDFXONLY/S"
enum
{
    ARG_MUSONLY,
    ARG_FXONLY,
    NUM_ARGS
};

static LONG Args[NUM_ARGS];

static void LoadSettings(void)
{
    struct RDArgs *MyArgs;
    BPTR MyHandle;
    LONG l;

    if (!(MyHandle = Open(PREFSNAME, MODE_OLDFILE))) {
        printf("DAMusic_DoomSoundLibrary: Could not open config file (%s)!\n", PREFSNAME);
    } else {
        Seek(MyHandle, 0, OFFSET_END);
        l = Seek(MyHandle, 0, OFFSET_BEGINNING);
        if (l < 1 || l > 200) {
            printf("DAMusic_DoomSoundLibrary: Config file has bad size!\n");
        } else {
            if (Read(MyHandle, s, l) == l) {
                s[l++] = '\n';
                s[l++] = '\0';

                if ((MyArgs = AllocDosObject(DOS_RDARGS, 0))) {
                    MyArgs->RDA_Source.CS_Buffer = s;
                    MyArgs->RDA_Source.CS_Length = strlen(s);
                    MyArgs->RDA_Flags = RDAF_NOPROMPT;

                    if (ReadArgs(ARG_TEMPLATE, Args, MyArgs)) {
                        if (Args[ARG_MUSONLY]) {
                            NoSound = TRUE;
                        }
                        if (Args[ARG_FXONLY]) {
                            NoMusic = TRUE;
                        }

                        FreeArgs(MyArgs);
                    }

                    FreeDosObject(DOS_RDARGS, MyArgs);
                }
            }
        }
        Close(MyHandle);
    }

    CacheClearU();
}

/*********************************************************

DAM_InitMusic:

Do initialization and return TRUE if everything went OK.
If you return FALSE you must free already alloced resour-
ces as DoomAttack will not call DAM_ShutdownMusic in this
case!!


*********************************************************/

static struct Library *loadLibrary(const char *libName)
{
    struct Library *lib = NULL;
    char path[128] = "PROGDIR:libs/";
    strcat(path, libName);
    lib = OldOpenLibrary(path);  // Try PROGDIR:libs/ first
    if (!lib) {
        strcpy(path + 8, libName);  // Try PROGDIR: next
        lib = OldOpenLibrary(path);
    }
    if (!lib) {
        lib = OldOpenLibrary(libName);  // Try just the library name
    }
    return lib;
}

int DAM_InitMusic(void)
{
    int rc = FALSE;

    DoomSoundBase = loadLibrary("doomsound_midi.library");
    if (!DoomSoundBase)
        DoomSoundBase = loadLibrary("doomsound.library");

    if (!DoomSoundBase) {
        printf("DAMusic_DoomSoundLibrary: Could not open \"doomsound.library\"!\n");
    } else {
        LoadSettings();
        serverOK = rc = TRUE;
    }
    return rc;
}

/*********************************************************

DAM_ShutdownMusic:

Cleanup routine. Called when the user quits DoomAttack.


*********************************************************/

void DAM_ShutdownMusic(void)
{
    if (serverOK) {
        serverOK = FALSE;
        if (DoomSoundBase) {
            CloseLibrary(DoomSoundBase);
            DoomSoundBase = 0;
        }
    }

    CleanupRuntime();
}
