
/*-------------------------------------------------------------------- ---------*/
/**/
/* $Id:$*/
/**/
/* Copyright (C) 1993-1996 by id Software, Inc.*/
/**/
/* This source is available for distribution and/or modification*/
/* only under the terms of the DOOM Source Code License as*/
/* published by id Software. All rights reserved.*/
/**/
/* The source is distributed in the hope that it will be useful,*/
/* but WITHOUT ANY WARRANTY; without even the implied warranty of*/
/* FITNESS FOR A PARTICULAR PURPOSE. See the DOOM Source Code License*/
/* for more details.*/
/**/
/* $Log:$*/
/**/
/* DESCRIPTION:*/
/*	System interface for sound.*/
/**/
/*-----------------------------------------------------------------------------*/

static const char rcsid[] = "$Id: i_unix.c,v 1.5 1997/02/03 22:45:10 b1 Exp $";

#include <devices/audio.h>
#include <proto/alib.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/intuition.h>

#ifdef MAXINT
#undef MAXINT
#endif

#ifdef MININT
#undef MININT
#endif

#include <math.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>

#include "z_zone.h"

#include "i_sound.h"
#include "s_sound.h"
#include "i_system.h"
#include "m_argv.h"
#include "m_misc.h"
#include "w_wad.h"

#include "doomdef.h"

#include "DoomAttackMusic.h"

extern int numChannels;

extern struct Library *GfxBase;
extern struct Library *KeymapBase;
extern struct Library *TimerBase;

static struct DAMInitialization daminit;
static BPTR DAMFile;

static struct DAMFile *DAM;
#include "DoomAttackMusicInline.h"

char *MusicPlugin;

/* Update all 30 millisecs, approx. 30fps synchronized.*/
/* Linux resolution is allegedly 10 millisecs,*/
/*  scale is microseconds.*/
#define SOUND_INTERVAL 500

/* A quick hack to establish a protocol between*/
/* synchronous mix buffer updates and asynchronous*/
/* audio writes. Probably redundant with gametic.*/
static int flag = 0;

/* The number of internal mixing channels,*/
/*  the samples calculated for each mixing step,*/
/*  the size of the 16bit, 2 hardware channel (stereo)*/
/*  mixing buffer, and the samplerate of the raw data.*/

/* Needed for calling the actual sound output.*/
#define SAMPLECOUNT 512
#define MAX_CHANNELS 4

/* It is 2 for 16bit, and 2 for two channels.*/
#define BUFMUL 4
#define MIXBUFFERSIZE (SAMPLECOUNT * BUFMUL)

#define SAMPLERATE 11025 /* Hz*/
#define SAMPLESIZE 2     /* 16bit*/

/* The actual lengths of all sound effects.*/
int lengths[NUMSFX];

/* The channel step amount...*/
unsigned int channelstep[MAX_CHANNELS];
/* ... and a 0.16 bit remainder of last step.*/
unsigned int channelstepremainder[MAX_CHANNELS];

/* The channel data pointers, start and end.*/
unsigned char *channels[MAX_CHANNELS];
unsigned char *channelsend[MAX_CHANNELS];

/* Time/gametic that the channel started playing,*/
/*  used to determine oldest, which automatically*/
/*  has lowest priority.*/
/* In case number of active sounds exceeds*/
/*  available channels.*/
int channelstart[MAX_CHANNELS];

/* The sound in channel handles,*/
/*  determined on registration,*/
/*  might be used to unregister/stop/modify,*/
/*  currently unused.*/
int channelhandles[MAX_CHANNELS];

/* SFX id of the playing sound effect.*/
/* Used to catch duplicates (like chainsaw).*/
int channelids[MAX_CHANNELS];

/* Pitch to stepping lookup, unused.*/
int steptable[256];

/* Volume lookups.*/
int vol_lookup[128 * 256];

/* Hardware left and right channel volume lookup.*/
int *channelleftvol_lookup[MAX_CHANNELS];
int *channelrightvol_lookup[MAX_CHANNELS];

int ConfigCacheSound, CacheSound;
int soundfilter, initialsoundfilter;

BOOL NoSound, SoundOK, SoundPlugin, SoundsInFast;

struct MsgPort *AudioPort;
struct IOAudio *AudioRequest;
struct MsgPort *AudioMP[MAX_CHANNELS];
struct IOAudio *Audio[MAX_CHANNELS];
BOOL SoundPlaying[MAX_CHANNELS];
struct Unit *channelunit[MAX_CHANNELS];
struct Unit *InitialAudioUnit;

static struct EasyStruct es;
extern struct IntuitionBase *IntuitionBase;
extern struct Screen *screen;

static WORD NUM_CHANNELS = 4;

#define CHIP_CACHE_SIZE 15 /* number of waveforms allowed in chipmem */

struct chip_cache_info
{
    int id;
    ULONG age;
    char *chip_data;
    int len;
};

static struct chip_cache_info chip_cache_info[CHIP_CACHE_SIZE] = {
    {-1, 0, NULL}, {-1, 0, NULL}, {-1, 0, NULL}, {-1, 0, NULL}, {-1, 0, NULL},
    {-1, 0, NULL}, {-1, 0, NULL}, {-1, 0, NULL}, {-1, 0, NULL}, {-1, 0, NULL},
    {-1, 0, NULL}, {-1, 0, NULL}, {-1, 0, NULL}, {-1, 0, NULL}, {-1, 0, NULL}};

static WORD voltable[16] = {
    0, 5, 10, 15, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 64,
};

/**/
/* This function loads the sound data from the WAD lump,*/
/*  for single sound.*/
/**/

int SoundFilter_Get(void);
void SoundFilter_Set(int state);

static void *getsfx(char *sfxname, int *len)
{
    unsigned char *sfx, *chipsound;
    unsigned char *paddedsfx;
    int i;
    int size;
    int paddedsize;
    char name[20];
    int sfxlump;

    /* Get the sound data from the WAD, allocate lump*/
    /*  in zone memory.*/
    sprintf(name, "ds%s", sfxname);

    /* Now, there is a severe problem with the*/
    /*  sound handling, in it is not (yet/anymore)*/
    /*  gamemode aware. That means, sounds from*/
    /*  DOOM II will be requested even with DOOM*/
    /*  shareware.*/
    /* The sound list is wired into sounds.c,*/
    /*  which sets the external variable.*/
    /* I do not do runtime patches to that*/
    /*  variable. Instead, we will use a*/
    /*  default sound for replacement.*/
    if (W_CheckNumForName(name) == -1)
        sfxlump = W_GetNumForName("dspistol");
    else
        sfxlump = W_GetNumForName(name);

    size = W_LumpLength(sfxlump);

    /* Debug.*/
    /* fprintf( stderr, "." );*/
    /*fprintf( stderr, " -loading  %s (lump %d, %d bytes)\n",*/
    /*	     sfxname, sfxlump, size );*/
    /*fflush( stderr );*/

    sfx = (unsigned char *)W_CacheLumpNum(sfxlump, PU_STATIC);

    while ((chipsound = AllocMem(size, (CacheSound || SoundsInFast) ? 0 : MEMF_CHIP)) == NULL) {
        es.es_StructSize = sizeof(struct EasyStruct);
        es.es_Flags = 0;
        es.es_Title = "DoomAttack";
        es.es_TextFormat = "Could not alloc %s memory for sound effect!";
        es.es_GadgetFormat = "Try again!|Quit DoomAttack";

        i = EasyRequest(NULL, &es, NULL, CacheSound ? (int)"fast" : (int)"chip");
        if (i == 0) {
            I_Error("Aborting DoomAttack because of insufficient free memory!");
        }
    }

    for (i = 0; i < size; i++) {
        chipsound[i] = sfx[i] - 128;
    }

    Z_Free(sfx);

    *len = size;

    return (void *)(chipsound);
}

static unsigned int age;

static int cache_chip_data(int id)
{
    int i, mini;
    ULONG minage;
    struct chip_cache_info *c;

    if (age == 0xffffffff) {
        for (i = 0; i < CHIP_CACHE_SIZE; i++) {
            c->age = 0;
        }
        age = 0;
    }

    minage = 0xffffffff;

    mini = 0;
    for (i = 0; i < CHIP_CACHE_SIZE; i++) {
        c = &chip_cache_info[i];
        if (c->id == id) {
            c->age = age++;
            return i;
        }
        if (c->age < minage) {
            minage = c->age;
            mini = i;
        }
    }

    c = &chip_cache_info[mini];
    if (c->chip_data != NULL) {
        FreeMem(c->chip_data, c->len);
        c->chip_data = NULL;
    }

    c->id = id;
    c->age = age++;

    while ((c->chip_data = AllocMem(lengths[id], MEMF_CHIP)) == NULL) {
        es.es_StructSize = sizeof(struct EasyStruct);
        es.es_Flags = 0;
        es.es_Title = "DoomAttack: Out of memory!";
        es.es_TextFormat = "Could not alloc chip memory for sound effect!";
        es.es_GadgetFormat = "Try again|Quit DoomAttack";

        i = EasyRequestArgs(NULL, &es, NULL, NULL);
        if (i == 0) {
            I_Error("Aborting DoomAttack because of insufficient free chip memory!");
        }
        ScreenToFront(screen);
    }

    memcpy(c->chip_data, S_sfx[id].data, lengths[id]);
    c->len = lengths[id];

    return mini;
}

/**/
/* This function adds a sound to the*/
/*  list of currently active sounds,*/
/*  which is maintained as a given number*/
/*  (eight, usually) of internal channels.*/
/* Returns a handle.*/
/**/

static void addsfx(int sfxid, int volume, int slot, int seperation)
{
    if (CacheSound) {
        channels[slot] = &chip_cache_info[cache_chip_data(sfxid)].chip_data[8];
    } else {
        channels[slot] = &((unsigned char *)S_sfx[sfxid].data)[8];
    }

    channelids[slot] = sfxid;

    /* You tell me.*/
}

/**/
/* SFX API*/
/* Note: this was called by S_Init.*/
/* However, whatever they did in the*/
/* old DPMS based DOS version, this*/
/* were simply dummies in the Linux*/
/* version.*/
/* See soundserver initdata().*/
/**/
void I_SetChannels() {}

void I_SetSfxVolume(int volume)
{
    snd_SfxVolume = volume;
    if (SoundPlugin) {
        DASCall_SetVol(volume);
    }
}

/**/
/* Retrieve the raw data lump index*/
/*  for a given SFX name.*/
/**/
int I_GetSfxLumpNum(sfxinfo_t *sfx)
{
    char namebuf[9];
    sprintf(namebuf, "ds%s", sfx->name);
    return W_GetNumForName(namebuf);
}

/**/
/* Starting a sound means adding it*/
/*  to the current list of active sounds*/
/*  in the internal channels.*/
/* As the SFX info struct contains*/
/*  e.g. a pointer to the raw data,*/
/*  it is ignored.*/
/* As our sound handling does not handle*/
/*  priority, it is ignored.*/
/* Pitching (that is, increased speed of playback)*/
/*  is set, but currently not used by mixing.*/
/**/
int I_StartSound(int id, int cnum, int vol, int sep, int pitch, int priority)
{
    if (SoundPlugin) {
        I_StopSound(cnum);
        return DASCall_Start(S_sfx[id].data, cnum, SAMPLERATE, vol, sep, lengths[id]);
    }

    if (NoSound)
        return 0;

    /* UNUSED*/
    priority = 0;

    addsfx(id, vol, cnum, 0 /*sep*/);

    I_StopSound(cnum);

    Audio[cnum]->ioa_Request.io_Command = CMD_WRITE;
    Audio[cnum]->ioa_Request.io_Flags = ADIOF_PERVOL;
    Audio[cnum]->ioa_Data = channels[cnum];
    Audio[cnum]->ioa_Length = (lengths[id] - 8) & (0xFFFFFFFE);
    Audio[cnum]->ioa_Volume = voltable[vol];
    Audio[cnum]->ioa_Period = 100000000UL / 28 / SAMPLERATE;
    Audio[cnum]->ioa_Cycles = 1;

    BeginIO(&Audio[cnum]->ioa_Request);
    SoundPlaying[cnum] = TRUE;

    return cnum;
}

void I_StopSound(int handle)
{
    /* You need the handle returned by StartSound.*/
    /* Would be looping all channels,*/
    /*  tracking down the handle,*/
    /*  an setting the channel to zero.*/

    /* UNUSED.*/
    /*handle = 0;*/

    if (SoundPlugin) {
        DASCall_Stop(handle);
        return;
    }

    if (NoSound)
        return;

    if (SoundPlaying[handle]) {
        AbortIO(&Audio[handle]->ioa_Request);
        WaitPort(AudioMP[handle]);
        GetMsg(AudioMP[handle]);
        SoundPlaying[handle] = FALSE;
    }
}

int I_SoundIsPlaying(int handle)
{
    if (SoundPlugin) {
        return DASCall_Done(handle);
    }

    if (NoSound)
        return 0;

    /* Ouch.*/

    if (SoundPlaying[handle]) {
        if (CheckIO(&Audio[handle]->ioa_Request)) {
            /* sound hat aufgehört */
            WaitPort(AudioMP[handle]); /* clears signal & returns immediately */
            GetMsg(AudioMP[handle]);
            SoundPlaying[handle] = FALSE;
            return 0;
        } else {
            return 1;
        }
    }
    return 0;
}

/**/
/* This function loops all active (internal) sound*/
/*  channels, retrieves a given number of samples*/
/*  from the raw sound data, modifies it according*/
/*  to the current (internal) channel parameters,*/
/*  mixes the per channel samples into the global*/
/*  mixbuffer, clamping it to the allowed range,*/
/*  and sets up everything for transferring the*/
/*  contents of the mixbuffer to the (two)*/
/*  hardware channels (left and right, that is).*/
/**/
/* This function currently supports only 16bit.*/
/**/
void I_UpdateSound(void) {}

/* */
/* This would be used to write out the mixbuffer*/
/*  during each game loop update.*/
/* Updates sound buffer and audio device at runtime. */
/* It is called during Timer interrupt with SNDINTR.*/
/* Mixing now done synchronous, and*/
/*  only output be done asynchronous?*/
/**/
void I_SubmitSound(void)
{
    /* Write it to DSP device.*/
    /* write(audio_fd, mixbuffer, SAMPLECOUNT*BUFMUL);*/
}

void I_UpdateSoundParams(int handle, int vol, int sep, int pitch)
{
    /* I fail too see that this is used.*/
    /* Would be using the handle to identify*/
    /*  on which channel the sound might be active,*/
    /*  and resetting the channel parameters.*/

    /* UNUSED.*/

    if (SoundPlugin) {
        DASCall_Update((APTR)handle, handle, SAMPLERATE, vol, sep);
        return;
    }
    if (SoundPlaying[handle]) {
        AudioRequest->ioa_Request.io_Command = ADCMD_PERVOL;
        AudioRequest->ioa_Request.io_Flags = ADIOF_PERVOL;
        AudioRequest->ioa_Request.io_Unit = channelunit[handle];
        AudioRequest->ioa_Period = 100000000UL / 28 / SAMPLERATE;
        AudioRequest->ioa_Volume = voltable[vol];
        BeginIO(&AudioRequest->ioa_Request);
        WaitPort(AudioPort);
        GetMsg(AudioPort);
    }
}

void I_ShutdownSound(void)
{
    int i;

    /* Wait till all pending sounds are finished.*/
    int done = 0;

    if (SoundOK) {
        for (i = 0; i < NUM_CHANNELS; i++) {
            I_StopSound(i);
        }
    }

    if (AudioRequest) {
        AudioRequest->ioa_Request.io_Unit = InitialAudioUnit;
        CloseDevice(&AudioRequest->ioa_Request);
        DeleteIORequest(AudioRequest);
    }

    if (AudioPort)
        DeleteMsgPort(AudioPort);

    for (i = 0; i < NUM_CHANNELS; i++) {
        if (Audio[i])
            DeleteIORequest(Audio[i]);
        if (AudioMP[i])
            DeleteMsgPort(AudioMP[i]);
    }

    for (i = 1; i < NUMSFX; i++) {
        /* Alias? Example is the chaingun sound linked to pistol.*/
        if (!S_sfx[i].link) {
            if (S_sfx[i].data)
                FreeMem(S_sfx[i].data, lengths[i]);
        }
    }

    for (i = 0; i < CHIP_CACHE_SIZE; i++) {
        if (chip_cache_info[i].chip_data != NULL) {
            FreeMem(chip_cache_info[i].chip_data, chip_cache_info[i].len);
            chip_cache_info[i].chip_data = NULL;
        }
    }

    /* I_ShutdownMusic(); wird von i_system aufgerufen! */

    if (soundfilter) {
        SoundFilter_Set(initialsoundfilter);
    }

    return;
}

BYTE channel_map[] = {0xC};

void I_InitSound()
{
    int i, i2;

    I_InitMusic();

    CacheSound = ConfigCacheSound;

    NoSound = TRUE;
    if (SoundPlugin) {
        I_SetSfxVolume(snd_SfxVolume);
        I_SetMusicVolume(snd_MusicVolume);
    } else {
        numChannels = NUM_CHANNELS;

        if (M_CheckParm("-nosound") || (numChannels < 1))
            return;

        if (M_CheckParm("-cachesound"))
            CacheSound = TRUE;

        channel_map[0] = (0xF << (4 - NUM_CHANNELS)) & 0xF;

        i2 = 0;
        for (i = 0; i < MAX_CHANNELS; i++) {
            if (channel_map[0] & (1L << i)) {
                channelunit[i2++] = (struct Unit *)(1L << i);
            }
        }

        AudioPort = CreateMsgPort();
        if (!AudioPort)
            return;
        AudioPort->mp_Node.ln_Pri = 127;

        AudioRequest = (struct IOAudio *)CreateIORequest(AudioPort, sizeof(struct IOAudio));

        if (!AudioRequest)
            return;

        for (i = 0; i < NUM_CHANNELS; i++) {
            AudioMP[i] = CreateMsgPort();
            if (!AudioMP[i]) {
                fprintf(stderr, "I_InitSound: Allocation of MsgPort for Sound IORequest number %ld failed!\n", i + 1);
                return;
            }

            Audio[i] = (struct IOAudio *)CreateIORequest(AudioMP[i], sizeof(struct IOAudio));
            if (!Audio[i]) {
                fprintf(stderr, "I_InitSound: Allocation of Sound IORequest number %d failed!\n", i + 1);
                return;
            }
        }

        AudioRequest->ioa_Request.io_Command = ADCMD_ALLOCATE;
        AudioRequest->ioa_Data = channel_map;
        AudioRequest->ioa_Length = sizeof(channel_map);
        AudioRequest->ioa_Request.io_Flags = ADIOF_NOWAIT;

        if (OpenDevice("audio.device", 0, &AudioRequest->ioa_Request, 0)) {
            fprintf(stderr, "I_InitSound: Could not open audio.device!\n");
            return;
        }

        SoundOK = TRUE;
        InitialAudioUnit = AudioRequest->ioa_Request.io_Unit;

        AudioRequest->ioa_Request.io_Message.mn_Node.ln_Type = 0;
        for (i = 0; i < NUM_CHANNELS; i++) {
            memcpy(Audio[i], AudioRequest, sizeof(struct IOAudio));
            Audio[i]->ioa_Request.io_Message.mn_ReplyPort = AudioMP[i];
            Audio[i]->ioa_Request.io_Unit = channelunit[i];
        }
    } /* if (!soundplugin) */

    for (i = 1; i < NUMSFX; i++) {
        /* Alias? Example is the chaingun sound linked to pistol.*/
        if (!S_sfx[i].link) {
            /* Load data from WAD file.*/
            S_sfx[i].data = getsfx(S_sfx[i].name, &lengths[i]);
        } else {
            /* Previously loaded already?*/
            S_sfx[i].data = S_sfx[i].link->data;

#ifndef mc68060
            lengths[i] = lengths[(S_sfx[i].link - S_sfx) / sizeof(sfxinfo_t)];
#else
            lengths[i] = lengths[ULongDiv((S_sfx[i].link - S_sfx), sizeof(sfxinfo_t))];
#endif
        }
    }

    /*  fprintf( stderr, " pre-cached all sound data\n"); */

    if (soundfilter) {
        initialsoundfilter = SoundFilter_Get();

        SoundFilter_Set(2 - soundfilter);
    }

    fprintf(stderr, "I_InitSound: sound module ready\n");

    NoSound = FALSE;
}

/**/
/* MUSIC API.*/
/* Still no music done.*/
/* Remains. Dummies.*/
/**/

static LONG oldfpustate;

static void GetDAMPlugin(void)
{
    int p;
    char id[5];

    DAMFile = LoadSeg(MusicPlugin);

    if (!DAMFile) {
        fprintf(stderr, "I_Sound: Couldn't load plugin \"%s\"!\n", MusicPlugin);
    } else {
        DAM = (struct DAMFile *)BADDR(DAMFile);
        memcpy(id, DAM->id, 4);
        id[4] = '\0';
        if (strcmp(id, "DAMS")) {
            fprintf(stderr, "I_Sound: Invalid plugin \"%s\"!\n", MusicPlugin);
            DAM = 0;
        } else {
            daminit.I_Error = I_Error;
            daminit.M_CheckParm = M_CheckParm;

            daminit.SysBase = SysBase;
            daminit.DOSBase = (struct Library *)DOSBase;
            daminit.IntuitionBase = (struct Library *)IntuitionBase;
            daminit.GfxBase = (struct Library *)GfxBase;
            daminit.KeymapBase = KeymapBase;
            daminit.TimerBase = (struct Device*)TimerBase;

            daminit.gametic = &gametic;
            daminit.snd_MusicVolume = &snd_MusicVolume;
            daminit.myargv = myargv;
            daminit.myargc = myargc;

            daminit.numchannels = 0;

#ifdef version060
            __asm __volatile(
                "move.l	d0,-(sp) \n\t"
                "fmove.l	fpcr,d0 \n\t"
                "move.l	d0,_oldfpustate \n\t"
                "move.l	(sp)+,d0"
                :
                :
                : "memory");
#endif

            DAMCall_Init(&daminit);

#ifdef version060
            __asm __volatile(
                "move.l	d0,-(sp) \n\t"
                "move.l	_oldfpustate,d0 \n\t"
                "fmove.l	d0,fpcr \n\t"
                "move.l	(sp)+,d0"
                :
                :
                : "memory");
#endif

            p = daminit.numchannels;
            if (p & DAMF_FASTRAM) {
                SoundsInFast = TRUE;
                p &= (~DAMF_FASTRAM);
            }
            if (p & DAMF_SOUNDFX) {
                SoundPlugin = TRUE;
                NUM_CHANNELS = 0;
                numChannels = p & (~DAMF_SOUNDFX);
            } else {
                NUM_CHANNELS = 4 - p;
                if (NUM_CHANNELS < 0)
                    NUM_CHANNELS = 0;
            }
        }
    }
}

/****************************************************
 *                                                   *
 *                   M U S I C                       *
 *                                                   *
 ****************************************************/

void I_InitMusic(void)
{
    if (M_CheckParm("-nomusic"))
        return;
    if (!MusicPlugin)
        return;
    if (!(*MusicPlugin))
        return;

    GetDAMPlugin();

    if (DAM) {
        if (!(DAM->DAM_InitMusic())) {
            SoundPlugin = FALSE;
            NUM_CHANNELS = 4;
            DAM = 0;
        }
    }
}

void I_ShutdownMusic(void)
{
    S_StopMusic();

    if (DAM) {
        DAM->DAM_ShutdownMusic();
    }

    if (DAMFile)
        UnLoadSeg(DAMFile);
}

static int looping = 0;
static int musicdies = -1;

/* MUSIC API - dummy. Some code from DOS version.*/
void I_SetMusicVolume(int volume)
{
    if (DAM)
        DAMCall_SetMusicVolume(volume);
}

void I_PlaySong(int handle, int looping)
{
    if (DAM)
        DAMCall_PlaySong(handle, looping);
}

void I_PauseSong(int handle)
{
    if (DAM)
        DAMCall_PauseSong(handle);
}

void I_ResumeSong(int handle)
{
    if (DAM)
        DAMCall_ResumeSong(handle);
}

void I_StopSong(int handle)
{
    if (DAM)
        DAMCall_StopSong(handle);
}

void I_UnRegisterSong(int handle)
{
    if (DAM)
        DAMCall_UnRegisterSong(handle);
}

int I_RegisterSong(void *data, int musicnum)
{
    if (DAM) {
        return DAMCall_RegisterSong(data, musicnum);
    } else {
        return 0;
    }
}

/* Is the song playing?*/
int I_QrySongPlaying(int handle)
{
    if (DAM) {
        return DAMCall_QrySongPlaying(handle);
    } else {
        return looping || musicdies > gametic;
    }
}
