#include <OSIncludes.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "DoomAttackMusic.h"
#include "funcs.h"
#include "musicIDs.h"

extern struct ExecBase *SysBase;
extern struct Library *DOSBase;
static struct GfxBase *GfxBase;

/*=====================*/

int *gametic;
static int *snd_MusicVolume;

static char **myargv;
static int myargc;

void (*I_Error)(char *error, ...);
static int (*M_CheckParm)(char *check);

// Implemented in assembly
// >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
extern struct Task *AudioTask;
extern struct IOAudio AudioIO;
extern WORD per, per2;
extern WORD AudioCh2Vol, AudioCh3Vol;
extern UBYTE AudioOK;
extern UBYTE AudioCh;

extern void Midi_StopSong(void);
extern void Midi_PauseSong(void);
extern void Midi_ResumeSong(void);
extern int Midi_RegisterSong(REGA0(void *data));
extern void Midi_UnRegisterSong(void);
extern void Midi_PlaySong(void);
extern void Midi_FreeChannels(void);
extern int Midi_AllocChannels(void);
// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

static WORD voltable[16] = {
    0, 5, 10, 15, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 64,
};

/*********************************************************/

void C_DAM_Init(struct DAMInitialization *daminit)
{
    InitRuntime();

    // link function pointers to DoomAttack routines
    I_Error = daminit->I_Error;
    M_CheckParm = daminit->M_CheckParm;

    // setups vars
    GfxBase = (struct GfxBase *)daminit->GfxBase;
    gametic = daminit->gametic;
    snd_MusicVolume = daminit->snd_MusicVolume;
    myargv = daminit->myargv;
    myargc = daminit->myargc;

    // Tell DoomAttack the informations, it needs
    daminit->numchannels = 2;

    if (GfxBase->DisplayFlags & PAL) {
        // PAL
        per = 161;
        per2 = 322;
    } else {
        // NTSC
        per = 162;
        per2 = 325;
    }
}

/*********************************************************

DAM_InitMusic:

Do initialization and return TRUE if everything went OK.
If you return FALSE you must free already alloced resour-
ces as DoomAttack will not call DAM_ShutdownMusic in this
case!!


*********************************************************/

int C_DAM_InitMusic(void)
{
    int rc = FALSE;

    AudioTask = FindTask(0);

    AudioIO.ioa_Length = 0;
    if (OpenDevice("audio.device", 0, (struct IORequest *)&AudioIO, 0)) {
        fprintf(stderr, "DAMusic_Midi: Can't open audio.device!\n");
    } else {
        AudioIO.ioa_Request.io_Command = ADCMD_ALLOCATE;

        if (!Midi_AllocChannels()) {
            CloseDevice((struct IORequest *)&AudioIO);
            fprintf(stderr, "DAMusic_Midi: Can't allocate channels!\n");
        } else {
            AudioOK = 0xFF;
            rc = TRUE;
        }
    }

    return rc;
}

/*********************************************************

DAM_ShutdownMusic:

Cleanup routine. Called when the user quits DoomAttack.


*********************************************************/

void C_DAM_ShutdownMusic(void)
{
    if (AudioOK) {
        Midi_StopSong();
        Midi_UnRegisterSong();
        Midi_FreeChannels();

        AudioCh = AudioOK = 0;

        CloseDevice((struct IORequest *)&AudioIO);
    }

    CleanupRuntime();
}

/*********************************************************

DAM_SetMusicVolume:

Volume is between 0 (min. volume) and 15 (max. volume).
There's a volume table used in the P61 plugin. Use this
if you want.


*********************************************************/

void C_DAM_SetMusicVolume(int volume)
{
    if (AudioOK) {
        AudioCh2Vol = AudioCh3Vol = voltable[volume];

        *snd_MusicVolume = volume;
    }
}

/*********************************************************

DAM_PauseSong:

Stop playing of the song. DAM_ResumeSong will be called
later = playing should continue from where it was paused,
then.

*********************************************************/

void C_DAM_PauseSong(int handle)
{
    if (AudioOK)
        Midi_PauseSong();
}

/*********************************************************

DAM_ResumeSong:

Resume playing of a former paused song.

*********************************************************/

void C_DAM_ResumeSong(int handle)
{
    if (AudioOK)
        Midi_ResumeSong();
}

/*********************************************************

DAM_StopSong:

Stop playing the song.

*********************************************************/

void C_DAM_StopSong(int handle)
{
    if (AudioOK)
        Midi_StopSong();
}

/*********************************************************

DAM_RegisterSong:

To switch between different songs, DoomAttack uses

 DAM_RegisterSong

 DAM_PlaySong

 ...

 DAM_UnRegisterSong

<data> points to the MIDI music data in the WAD file
which was orignally meant to be used. <songnum> is
the music ID (see musicids.h). You can use <songnum>
in combination with a configuration file to allow the
user to change the songs/mods as shown in the P61A
plugin.

The routine can return a handle which other routines
such as DAM_PauseSong, DAM_UnRegisterSong, ... will
then get as parameter. Usually you can ignore this
handle as after a RegisterSong call there will never
be a second RegisterSong without a prior UnRegisterSong
call.

*********************************************************/

int C_DAM_RegisterSong(void *data, int songnum)
{
    return AudioOK ? Midi_RegisterSong(data) : 0;
}

/*********************************************************

DAM_PlaySong:

Start playing the song. Have not yet checked if this
looping parameter is really used and what it is for ...

*********************************************************/

void C_DAM_PlaySong(int handle, int looping)
{
    if (AudioOK)
        Midi_PlaySong();
}

/*********************************************************

DAM_UnRegisterSong:

You usually will unload/free the actual song here.

*********************************************************/

void C_DAM_UnRegisterSong(int handle)
{
    if (AudioOK)
        Midi_UnRegisterSong();
}

/*********************************************************

DAM_QrySongPlaying:

Return TRUE if the song is actually playing.
This routine does not seem to be used, but
implement it anyway.

*********************************************************/

int C_DAM_QrySongPlaying(int handle)
{
    return 1;
}
