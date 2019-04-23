
/*-----------------------------------------------------------------------------*/
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
/**/
/*-----------------------------------------------------------------------------*/

static const char rcsid[] = "$Id: m_bbox.c,v 1.1 1997/02/03 22:45:10 b1 Exp $";

#include <clib/alib_protos.h>
#include <devices/input.h>
#include <devices/inputevent.h>
#include <devices/timer.h>
#include <dos/dos.h>
#include <exec/execbase.h>
#include <graphics/gfxbase.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/icon.h>
#include <proto/input.h>
#include <proto/intuition.h>
#include <proto/timer.h>
#include <proto/wb.h>
#include <workbench/startup.h>
#include <workbench/workbench.h>

#include <signal.h>

#ifdef MININT
#undef MININT
#endif

#ifdef MAXINT
#undef MAXINT
#endif

/* Libraries nicht automatisch öffnen! */

extern struct WBStartup *_WBenchMsg;
struct IntuitionBase *IntuitionBase;

struct GfxBase *GfxBase = NULL;
struct Library *KeymapBase = NULL;
struct Library *IFFParseBase = NULL;
struct Library *AslBase = NULL;
struct Library *IconBase = NULL;
struct Library *LowLevelBase = NULL;

struct Device *TimerBase = NULL;
struct Device *InputBase = NULL;

struct timerequest *TimerIO;
struct IOStdReq *InputIO;
struct MsgPort *TimerMP, *InputMP;
struct RastPort TempRP;

UWORD StartQualifier;

BOOL InputHandlerON;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <stdarg.h>
/*#include <sys/time.h>*/
/*#include <unistd.h>*/

#include "doomdef.h"
#include "i_net.h"
#include "i_sound.h"
#include "i_video.h"
#include "m_misc.h"

#include "d_locale.h"
#include "d_net.h"
#include "g_game.h"
#include "m_argv.h"
#include "v_video.h"
#include "w_wad.h"

#include "c2p.h"
#include "amiga.h"

#ifdef __GNUG__
#pragma implementation "i_system.h"
#endif
#include "i_system.h"

char s[501];
char *StartOptions;

/*int	mb_used = 6;*/

int configkb_used = 6 * 1024;
int configfree_fast = 1 * 1024;

int kb_used;
int free_fast;

int joy_pad;
int joy_port;
int cputype;

struct C2PFile *C2P = NULL;
BPTR C2PFile = 0;
BOOL DoC2P = FALSE;
BOOL DoDoubleBuffer = TRUE;
BOOL OS31 = FALSE;
BOOL DoJoyPad = FALSE;
BOOL DoAnalogJoy = FALSE;

struct Task *MainTask, *AnalogJoyTask;

extern BOOL C2PIsFlipping;

extern struct Task *FlipTask;
extern ULONG FlipMask, DoomMask, modeid;
extern WORD joyport;
extern int full_keys;
extern int full_mouse;
extern int usejoystick;
extern char *analog_ERROR;
extern void MyInputHandler(void);
extern void AnalogDriver(void);

static struct Interrupt InputINT;

char *c2p_routine;

void GetC2P(void)
{
    struct C2PInit init;

    static char *routine = "PROGDIR:DoomAttackSupport/c2p/c2p";
    int p;
    char id[5];

    if (!M_CheckParm("-rtg")) {
        if (c2p_routine) {
            if (c2p_routine[0]) {
                routine = c2p_routine;
            }
        }

        p = M_CheckParm("-c2proutine");
        if (p && p < myargc - 1) {
            routine = myargv[p + 1];
        }

        /*		if (C2P) C2P->EndChunky2Planar(); ??????:????? */

        C2P = NULL;
        C2PFile = LoadSeg(routine);  // FIXME: where's the UnloadSeg for that?
        if (C2PFile) {
            C2P = (struct C2PFile *)BADDR(C2PFile);
            while (C2P) {
                memcpy(id, C2P->id, 4);
                id[4] = '\0';
                if (!strcmp(id, "C2P")) {
                    if (C2P->Flags & C2PF_SIGNALFLIP)
                        C2PIsFlipping = TRUE;
                    if (C2P->Flags & C2PF_GRAFFITI)
                        DoGraffiti = TRUE;

                    init.DOSBase = (struct Library *)DOSBase;
                    init.GfxBase = (struct Library *)GfxBase;
                    init.IntuitionBase = (struct Library *)IntuitionBase;
                    init.FlipTask = FlipTask;
                    init.FlipMask = FlipMask;
                    init.DoomTask = MainTask;
                    init.DoomMask = DoomMask;
                    init.DisplayID = modeid;

                    if (((REALSCREENHEIGHT != 200) && (!(C2P->Flags & C2PF_VARIABLEHEIGHT))) ||
                        ((REALSCREENWIDTH != 320) && (!(C2P->Flags & C2PF_VARIABLEWIDTH)))) {
                        fprintf(stderr,
                                "I_Init: The selected C2P routine does not support %ld x %ld resolutions.\n"
                                "        DoomAttack will work in RTG mode!\n",
                                REALSCREENWIDTH, REALSCREENHEIGHT);
                        getchar();
                    } else {
                        if (C2P->InitChunky2Planar(REALSCREENWIDTH, REALSCREENHEIGHT,
                                                   REALSCREENWIDTH * REALSCREENHEIGHT / 8, &init)) {
                            DoC2P = TRUE;
                            if ((C2P->Flags & C2PF_NODOUBLEBUFFER) || M_CheckParm("-nodoublebuffer")) {
                                DoDoubleBuffer = FALSE;
                            }
                        } else {
                            DoGraffiti = FALSE;
                            C2PIsFlipping = FALSE;
                            fprintf(stderr,
                                    "I_Init: Initialization of Chunky2Planar routine failed!\n"
                                    "        DoomAttack will work in RTG mode!\n");
                            getchar();
                        }
                    }
                    break;
                }
                C2P = BADDR(C2P->NextSeg);
            }
            if (!C2P || !DoC2P) {
                fprintf(stderr, "I_Init: The selected C2P file is not compatible.\n");
            }
        } else {
            fprintf(stderr, "I_Init: The selected C2P file could not be opened %s.\n", routine);
        }
    }
}

void I_Tactile(int on, int off, int total)
{
    /* UNUSED.*/
    on = off = total = 0;
}

ticcmd_t emptycmd;

ticcmd_t *I_BaseTiccmd(void)
{
    return &emptycmd;
}

int I_GetHeapSize(void)
{
    return kb_used * 1024L;
}

byte *I_ZoneBase(int *size)
{
    byte *rc;
    LONG l;
    int p;

    kb_used = configkb_used;
    free_fast = configfree_fast;

    p = M_CheckParm("-zonesize");
    if (p && (p < myargc - 1)) {
        kb_used = atoi(myargv[p + 1]);
    }

    p = M_CheckParm("-freefast");
    if (p && (p < myargc - 1)) {
        free_fast = atoi(myargv[p + 1]);
    }

    l = (AvailMem(MEMF_FAST) / 1024) - free_fast;
    if (l < 1024)
        l = 1024;
    if (l < kb_used)
        kb_used = l;

    do {
        *size = kb_used * 1024L;
        rc = (byte *)malloc(*size);
        if (!rc) {
            kb_used -= 50;
        }
    } while (!rc);

    return rc;
}

/**/
/* I_GetTime*/
/* returns time in 1/70th second tics*/
/**/
int I_GetTime(void)
{
    struct timeval tp;
    /*    struct timezone	tzp;*/
    int newtics;
    static int basetime = 0;

    /*    gettimeofday(&tp, &tzp);
        if (!basetime)
        basetime = tp.tv_sec;
        newtics = (tp.tv_sec-basetime)*TICRATE + tp.tv_usec*TICRATE/1000000;
        return newtics;*/

    GetSysTime(&tp);
    if (!basetime)
        basetime = tp.tv_secs;

#ifndef mc68060
    newtics = (tp.tv_secs - basetime) * TICRATE + tp.tv_micro * TICRATE / 1000000;
#else
    newtics = (tp.tv_secs - basetime) * TICRATE + ULongDiv(tp.tv_micro * TICRATE, 1000000);
#endif

    return newtics;
}

/**/
/* I_Init*/
/**/
void I_Init(void)
{
    int p;

    if (!IntuitionBase)
        IntuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library", 39);
    if (!GfxBase)
        GfxBase = (struct GfxBase *)OpenLibrary("graphics.library", 39);
    if (!KeymapBase)
        KeymapBase = OpenLibrary("keymap.library", 36);

    if (!IntuitionBase || !GfxBase || !KeymapBase)
        I_Error("Can't open library!");
    if (GfxBase->LibNode.lib_Version < 39)
        I_Error("You need Amiga OS3.0!");

    TimerMP = CreateMsgPort();
    TimerIO = (struct timerequest *)CreateIORequest(TimerMP, sizeof(struct timerequest));
    OpenDevice("timer.device", UNIT_VBLANK, &TimerIO->tr_node, 0);
    TimerBase = TimerIO->tr_node.io_Device;

    if (!TimerBase)
        I_Error("Can't open timer.device!");

    if (GfxBase->LibNode.lib_Version >= 40) {
        OS31 = TRUE;
    } else {
        InitRastPort(&TempRP);
        if (!(TempRP.BitMap = AllocBitMap(REALSCREENWIDTH + 16, 1, 8, BMF_CLEAR, 0))) {
            I_Error("Can't create temporary RastPort!");
        }
    }

    joyport = joy_port;
    p = M_CheckParm("-joyport");
    if (p && (p < myargc - 1)) {
        joyport = atoi(myargv[p + 1]) - 1;
    }

    DoJoyPad = ((joy_pad == 1) && usejoystick);

    if (M_CheckParm("-joypad"))
        DoJoyPad = TRUE;

    if (DoJoyPad) {
        if (!LowLevelBase)
            LowLevelBase = OpenLibrary("lowlevel.library", 0);

        if (!LowLevelBase) {
            fprintf(stderr, "I_Init: Could not open lowlevel.library. Joypad will not be available!\n");
            DoJoyPad = FALSE;
        }
    }

    if ((joy_pad == 2) && usejoystick) {
        AnalogJoyTask = CreateTask("DoomAttack Analog Joystick driver", 20, AnalogDriver, 4096);
        Wait(SIGBREAKF_CTRL_F);

        if (!analog_ERROR) {
            DoAnalogJoy = TRUE;
        } else {
            DeleteTask(AnalogJoyTask);
            AnalogJoyTask = 0;
            fprintf(stderr, analog_ERROR);
        }
    }

    if ((!M_CheckParm("-noinputhack")) && (full_keys || full_mouse)) {
        if (!(InputMP = CreateMsgPort())) {
            fprintf(stderr, "I_Init: Can't create MsgPort for input.device!\n");
        } else {
            if (!(InputIO = (struct IOStdReq *)CreateIORequest(InputMP, sizeof(struct IOStdReq)))) {
                fprintf(stderr, "I_Init: Can't create IORequest for input.device!\n");
            } else {
                if (OpenDevice("input.device", 0, (struct IORequest *)InputIO, 0)) {
                    fprintf(stderr, "I_Init: Can't open input.device!\n");
                } else {
                    InputINT.is_Node.ln_Type = NT_UNKNOWN;
                    InputINT.is_Node.ln_Name = "DoomAttack Warp Core";
                    InputINT.is_Node.ln_Pri = 55;
                    InputINT.is_Code = MyInputHandler;

                    InputIO->io_Command = IND_ADDHANDLER;
                    InputIO->io_Data = &InputINT;

                    DoIO((struct IORequest *)InputIO);

                    InputHandlerON = TRUE;
                }
            }
        }
    }

    I_InitGraphics();
    I_InitSound();
    I_InitLocale();
}

void I_QuitAmiga(void)
{
    if (DoAnalogJoy) {
        SetSignal(0, SIGBREAKF_CTRL_F);
        Signal(AnalogJoyTask, SIGBREAKF_CTRL_C);
        Wait(SIGBREAKF_CTRL_F);

        Forbid();
        DeleteTask(AnalogJoyTask);
        Permit();
        AnalogJoyTask = 0;
    }

    if (InputHandlerON) {
        InputIO->io_Command = IND_REMHANDLER;
        InputIO->io_Data = &InputINT;
        DoIO((struct IORequest *)InputIO);
    }

    if (InputIO) {
        if (InputIO->io_Device)
            CloseDevice((struct IORequest *)InputIO);
        DeleteIORequest((struct IORequest *)InputIO);
    }

    if (InputMP)
        DeleteMsgPort(InputMP);

    if (TimerIO) {
        CloseDevice(&TimerIO->tr_node);
        DeleteIORequest(&TimerIO->tr_node);
    }
    if (TimerMP)
        DeleteMsgPort(TimerMP);

    if (TempRP.BitMap)
        FreeBitMap(TempRP.BitMap);

    if (C2PFile) {
        if (C2P)
            C2P->EndChunky2Planar();
        UnLoadSeg(C2PFile);
    }

    I_CleanupNetwork();
    I_CleanupLocale();

    if (IntuitionBase)
        CloseLibrary((struct Library *)IntuitionBase);
    IntuitionBase = NULL;
    if (GfxBase)
        CloseLibrary((struct Library *)GfxBase);
    GfxBase = NULL;
    if (KeymapBase)
        CloseLibrary(KeymapBase);
    KeymapBase = NULL;
    if (IFFParseBase)
        CloseLibrary(IFFParseBase);
    IFFParseBase = NULL;
    if (AslBase)
        CloseLibrary(AslBase);
    AslBase = NULL;
    if (IconBase)
        CloseLibrary(IconBase);
    IconBase = NULL;
    if (LowLevelBase)
        CloseLibrary(LowLevelBase);
    LowLevelBase = NULL;
}

/**/
/* I_Quit*/
/**/
void I_Quit(void)
{
    // FIXME: bug in noixemul SIG_IGN not declared with __stdargs in front
    signal(SIGINT, SIG_IGN);

    D_QuitNetGame();
    I_ShutdownSound();
    I_ShutdownMusic();
    M_SaveDefaults();
    I_ShutdownGraphics();
    W_Cleanup();
    I_QuitAmiga();

    exit(0);
}

void I_WaitVBL(int count)
{
    Delay(count);
}

void I_BeginRead(void) {}

void I_EndRead(void) {}

byte *I_AllocLow(int length)
{
    byte *mem;

    mem = (byte *)malloc(length + 4096);
    mem += 4096;
    mem = (byte *)(((size_t)mem) & (~0xFFF));
    memset(mem, 0, length);

    return mem;
}

/**/
/* I_Error*/
/**/
extern boolean demorecording;

void I_Error(char *error, ...)
{
    struct EasyStruct es = {sizeof(struct EasyStruct), 0, "DoomAttack", NULL, "OK"};

    va_list argptr;

    if (!_WBenchMsg || !IntuitionBase) {
        /* Message first.*/
        va_start(argptr, error);
        fprintf(stderr, "Error: ");
        vfprintf(stderr, error, argptr);
        fprintf(stderr, "\n");
        va_end(argptr);
        fflush(stderr);
    } else {
        va_start(argptr, error);
        vsprintf(s, error, argptr);
        va_end(argptr);
        es.es_TextFormat = s;
        EasyRequestArgs(NULL, &es, NULL, NULL);
    }

    /* Shutdown. Here might be other errors.*/
    if (demorecording)
        G_CheckDemoStatus();

    D_QuitNetGame();
    I_ShutdownGraphics();
    I_ShutdownSound();
    I_ShutdownMusic();
    W_Cleanup();
    I_QuitAmiga();

    exit(RETURN_WARN);
}

void I_ErrorMem(void)
{
    I_Error("Out of memory! Try using \"-zonesize 2500\" - see DoomAttack.readme!");
}

extern void Chunky2Planar(void *Quelle, void *Ziel, int bytes, int planes);
extern struct ViewPort *viewport;
extern struct Screen *screen;
extern struct Window *window;

static boolean ArgsAlloced;

void I_InitWBArgs(void)
{
    char *argstring, *argstringpos, ing, **argpos, **myargvpos, *arg, c;
    struct DiskObject *progicon;
    struct MsgPort *mp;
    struct IORequest *ior;
    struct Task *progtask;

    BPTR olddir;
    WORD i;
    BOOL splitted;

    if (SysBase->AttnFlags & AFF_68060) {
        cputype = 68060;
    } else if (SysBase->AttnFlags & AFF_68040) {
        cputype = 68040;
    } else if (SysBase->AttnFlags & AFF_68030) {
        cputype = 68030;
    } else {
        cputype = 68020;
    }

    if (M_CheckParm("-68030"))
        cputype = 68030;
    if (M_CheckParm("-68040"))
        cputype = 68040;
    if (M_CheckParm("-68060"))
        cputype = 68060;

    signal(SIGINT, (STDARGS void (*)(int))I_Quit);

    MainTask = FindTask(0);

    if ((mp = CreateMsgPort())) {
        if ((ior = CreateIORequest(mp, sizeof(struct IOStdReq)))) {
            if (!OpenDevice("input.device", 0, ior, 0)) {
                InputBase = ior->io_Device;
                StartQualifier = PeekQualifier();
                CloseDevice(ior);
            }
            DeleteIORequest(ior);
        }
        DeleteMsgPort(mp);
    }

    progtask = FindTask(NULL);
    if ((((unsigned long)progtask->tc_SPUpper) - (unsigned long)progtask->tc_SPLower + 1) < 20000) {
        if (_WBenchMsg) {
            I_Error("The minimum stack size is 20000.\nCorrect it in the icon information window!");
        } else {
            I_Error("The minimum stack size is 20000.\nUse the shell command \"stack\"!");
        }
    }

#ifdef version060

    Disable();

    __asm(
        "move.l		d0,-(sp) \n\t"

        "fmove.l	#65536,fp6 \n\t"
        "fmove.l	#1,fp7 \n\t"
        "fdiv.l		#65536,fp7 \n\t"

        /*		"fmove.l	#16,fp6 \n\t"
                "fmove.l	#-16,fp7 \n\t"*/

        "fmove.l	fpcr,d0 \n\t"
        "or.b		#0x20,d0 \n\t" /* runden gegen -unendlich */
        "or.b		#0x80,d0 \n\t" /* runden auf double */
        "and.b	#0xFF-0x10-0x40,d0 \n\t"
        "fmove.l	d0,fpcr \n\t"

        "move.l		(sp)+,d0 \n\t");

    Enable();

#endif

    if (!_WBenchMsg)
        return;

    if (!IconBase)
        IconBase = OpenLibrary("icon.library", 0);

    if (IconBase) {
        olddir = CurrentDir(_WBenchMsg->sm_ArgList[0].wa_Lock);
        progicon = GetDiskObject(_WBenchMsg->sm_ArgList[0].wa_Name);
        CurrentDir(olddir);

        if (progicon) {
            // allocate 1000 byte to hold all command line
            if ((argstring = malloc(1000))) {
                argstringpos = argstring;
                if ((myargv = malloc(100 * sizeof(void *)))) {
                    ArgsAlloced = true;
                    memset(myargv, 0, 100 * sizeof(void *));
                    myargvpos = myargv + 1;

                    // go through all tooltypes and tranlsate them into 'regular'
                    // commandline parameters
                    myargc = 1;
                    argpos = (char **)progicon->do_ToolTypes;
                    while ((arg = *argpos++)) {
                        myargc++;
                        *myargvpos++ = argstringpos;
                        // skip leading '-'
                        while(*arg == '-') {
                            arg++;
                         }
                        //  start a new parameter
                        *argstringpos++ = '-';
                        splitted = FALSE;
                        do {
                            c = *arg++;
                            switch (c) {
                            case '=':
                            case ' ':
                            case '\t':
                                if (!splitted) {
                                    while (*arg && ((*arg == ' ') || (*arg == '\t'))) {
                                        arg++;
                                    }
                                    if (*arg) {
                                        splitted = TRUE;
                                        myargc++;
                                        *argstringpos++ = '\0';
                                        *argstringpos++ = *arg;
                                        *myargvpos++ = argstringpos;
                                    }
                                }
                                break;

                            default:
                                *argstringpos++ = c;
                                break;
                            }
                        } while (c);
                    } /* while ((arg = *argpos++)) */

                } else
                    free(argstring);
            }
            FreeDiskObject(progicon);
        }
        CloseLibrary(IconBase);
        IconBase = NULL;
    }
}

void I_InitConfigArgs(void)
{
    char **newargv, *sp, c;
    int i, state = 0;

    if (StartOptions) {
        if (StartOptions[0]) {
            if (!(sp = malloc(strlen(StartOptions) + 2)))
                return;
            strcpy(sp, StartOptions);

            if (!ArgsAlloced) {
                if (!(newargv = malloc(100 * sizeof(void *))))
                    return;

                memset(newargv, 0, 100 * sizeof(void *));
                memcpy(newargv, myargv, myargc * sizeof(void *));
                myargv = newargv;
            }

            while ((c = *sp++)) {
                switch (state) {
                case 0:
                    switch (c) {
                    case ' ':
                    case '\t':
                        break;

                    default:
                        myargv[myargc++] = sp - 1;
                        state = 1;
                        break;
                    }
                    break;

                case 1:
                    switch (c) {
                    case ' ':
                    case '\t':
                        sp[-1] = '\0';
                        state = 0;
                        break;

                    default:
                        break;
                    }
                    break;
                }
            }
        }
    }
}
