/* Emacs style mode select   -*- C++ -*- */
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
/*	DOOM graphics stuff for X11, UNIX.*/
/**/
/*-----------------------------------------------------------------------------*/

static const char rcsid[] = "$Id: i_x.c,v 1.6 1997/02/03 22:45:10 b1 Exp $";

static const char *verstring = "$VER: DoomAttack 0.8 (22.03.98)";
static const char *authstring = "$AUTH: Georg Steger";

#include <clib/alib_protos.h>
#include <devices/gameport.h>
#include <devices/inputevent.h>
#include <graphics/gfx.h>
#include <graphics/modeid.h>
#include <intuition/intuitionbase.h>
#include <intuition/pointerclass.h>
#include <libraries/lowlevel.h>
#include <proto/cybergraphics.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/keymap.h>
#include <proto/lowlevel.h>
#include <proto/timer.h>

#ifdef MAXINT
#undef MAXINT
#endif

#ifdef MININT
#undef MININT
#endif

#include <assert.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define strcasecmp strcmp

#include "d_main.h"
#include "doomstat.h"
#include "i_system.h"
#include "m_argv.h"
#include "m_fixed.h"
#include "v_video.h"
#include "w_wad.h"
#include "z_zone.h"

#include "amiga.h"
#include "amiga_mmu.h"
#include "doomdef.h"

//#define AllocRaster(width,height) AllocMem(RASSIZE(width,height+16)+8192,MEMF_CHIP|MEMF_CLEAR|MEMF_PUBLIC)
//#define FreeRaster(plane,width,height) FreeMem(plane,RASSIZE(width,height+16)+8192)

#define POINTER_WARP_COUNTDOWN 1

extern struct IntuitionBase *IntuitionBase;
extern struct GfxBase *GfxBase;
extern struct Library *KeymapBase;
extern struct Device *TimerBase;
extern struct Task *MainTask;
struct Library *CyberGfxBase = 0;

struct Screen *screen;
struct ViewPort *viewport;
struct ColorMap *colormap;
struct Window *window;
struct RastPort viewrastport, renderrastport;
struct BitMap bitmap1, bitmap2, *MausBM;
struct IntuiMessage *intuimessage;
struct ScreenBuffer *screenbuffer1, *screenbuffer2;
struct MsgPort *JoyMP, *SafePort, *DisplayPort;
struct IOStdReq *JoyIO;

struct Task *FlipTask;
ULONG FlipMask, DoomMask;
LONG DoomSig = -1;

event_t joyevent;

struct GamePortTrigger Joy_gpt = {
    GPTF_UPKEYS | GPTF_DOWNKEYS, /* gpt_Keys */
    0,                           /* gpt_Timeout */
    1,                           /* gpt_XDelta */
    1                            /* gpt_YDelta */
};
struct InputEvent Joy_ie;

Object *MausObj;

int configmodeid = INVALID_ID;

WORD joyport;
ULONG modeid;
UWORD ActQualifier;

void *Planes, *Planes1, *Planes2;
UBYTE *Planes1Mem, *Planes2Mem;

BOOL DoNumericPad;

BOOL DoFPS;
BOOL NoRender;
BOOL JoyOK;
BOOL JoyInAction;
BOOL DoBlitToScreen;
BOOL GfxBoard;
BOOL C2PIsFlipping;
BOOL Video_Display, Video_Safe, Blitting;
BOOL InWindow, DoGraffiti, WantGraffiti;
BYTE JoyType;
BYTE ActBuffer, ActScreen;

int ConfigNoRangeCheck;
int DoFastRemap;

boolean NoRangeCheck;

extern void TextChunky(byte *framebuffer, char *text, int textlen, int posx, int posy, int fg, int bg);
extern void mmu_stuff2(void);
extern void mmu_stuff2_cleanup(void);

extern int cputype;
extern int centery;
extern fixed_t centeryfrac;
extern char english_shiftxform[];

static int xlatetable[128];
static struct InputEvent xie;
static WORD BlitX;
static WORD BlitY;
static WORD Depth = 8;
static BOOL PensAlloced, ReadyForAction;
static BOOL DoMMU1, DoMMU2;
static BOOL ChunkyMMUed, MMU2ed;

static int oldmmu_planes1, oldmmu_planes2, oldmmu_chunky;

int full_keys;
int full_mouse;
int french_keymap;
int usemmu;
int hidemouse;

UBYTE *RemapTable;
UBYTE *RemapTablePTR[14];
LONG *ObtainTable;
UBYTE *RemapBuffer;

/**/
/* D_PostEvent*/
/* Called by the I/O functions when input is detected*/
/**/
void D_PostEvent(event_t *ev)
{
    Forbid();
    events[eventhead] = *ev;
    eventhead = (++eventhead) & (MAXEVENTS - 1);
    Permit();
}

static int xlatekey(int taste)
{
    BOOL french;
    int rc;

    unsigned char buff[2];

    /*	rc=intuimessage->Code&(~IECODE_UP_PREFIX);*/

    switch (taste) {
    case 79:
        rc = KEY_LEFTARROW;
        break;
    case 78:
        rc = KEY_RIGHTARROW;
        break;
    case 77:
        rc = KEY_DOWNARROW;
        break;
    case 76:
        rc = KEY_UPARROW;
        break;
    case 69:
        rc = KEY_ESCAPE;
        break;
    case 68:
        rc = KEY_ENTER;
        break;
    case 66:
        rc = KEY_TAB;
        break;
    case 80:
        rc = KEY_F1;
        break;
    case 81:
        rc = KEY_F2;
        break;
    case 82:
        rc = KEY_F3;
        break;
    case 83:
        rc = KEY_F4;
        break;
    case 84:
        rc = KEY_F5;
        break;
    case 85:
        rc = KEY_F6;
        break;
    case 86:
        rc = KEY_F7;
        break;
    case 87:
        rc = KEY_F8;
        break;
    case 88:
        rc = KEY_F9;
        break;
    case 89:
        rc = KEY_F10;
        break;

        /* "~" */
    case 0:
        rc = KEY_F12;
        break;

        /* NUMERICPAD * */
    case 93:
        rc = KEY_F11;
        break;

        /* NUMERICPAD 7 */

        /*	  case 29:
                if (centery>0)
                {
                    centery--;
                    centeryfrac=centery<<FRACBITS;
                    R_SetupPlanes();
                }
                break;*/

        /* NUMERICPAD 1 */

        /*	  case 61:
                if (centery<viewheight-1)
                {
                    centery++;
                    centeryfrac=centery<<FRACBITS;
                    R_SetupPlanes();
                }
                break;*/

    case 65:
        rc = KEY_BACKSPACE;
        break;

    case 70:
        rc = KEY_DEL;
        break;

    case 95:
        rc = KEY_HELP;
        break;

        /* HELP*/
    case 92:
        rc = KEY_PAUSE;
        break;

        /*      case XK_KP_Equal:*/
        /* =*/
    case 12:
        rc = KEY_EQUALS;
        break;

    case 74:
        rc = KEY_MINUS;
        break;

    case 96:
        rc = KEY_LSHIFT;
        break;

    case 97:
        rc = KEY_RSHIFT;
        break;

    case 99:
        rc = KEY_RCTRL;
        break;

    case 100:
        rc = KEY_LALT;
        break;

    case 101:
        rc = KEY_RALT;
        break;

    case 102:
        rc = KEY_LAMIGA;
        break;

    case 103:
        rc = KEY_RAMIGA;
        break;

    case 90:
        if (DoNumericPad)
            rc = KEY_NUMOPEN;
        else
            rc = '(';
        break;

    case 91:
        if (DoNumericPad)
            rc = KEY_NUMCLOSE;
        else
            rc = ')';
        break;

    case 61:
        if (DoNumericPad)
            rc = KEY_NUM7;
        else
            rc = '7';
        break;

    case 62:
        if (DoNumericPad)
            rc = KEY_NUM8;
        else
            rc = '8';
        break;

    case 63:
        if (DoNumericPad)
            rc = KEY_NUM9;
        else
            rc = '9';
        break;

    case 45:
        if (DoNumericPad)
            rc = KEY_NUM4;
        else
            rc = '4';
        break;

    case 46:
        if (DoNumericPad)
            rc = KEY_NUM5;
        else
            rc = '5';
        break;

    case 47:
        if (DoNumericPad)
            rc = KEY_NUM6;
        else
            rc = '6';
        break;

    case 29:
        if (DoNumericPad)
            rc = KEY_NUM1;
        else
            rc = '1';
        break;

    case 30:
        if (DoNumericPad)
            rc = KEY_NUM2;
        else
            rc = '2';
        break;

    case 31:
        if (DoNumericPad)
            rc = KEY_NUM3;
        else
            rc = '3';
        break;

    case 15:
        if (DoNumericPad)
            rc = KEY_NUM0;
        else
            rc = '0';
        break;

    case 60:
        if (DoNumericPad)
            rc = KEY_NUMP;
        else
            rc = '.';
        break;

    case 67:
        if (DoNumericPad)
            rc = KEY_NUMENTER;
        else
            rc = KEY_ENTER;
        break;

    default:
        french = ((taste >= 1) && (taste <= 10) && french_keymap);
        xie.ie_Class = IECLASS_RAWKEY;
        xie.ie_Code = taste;
        xie.ie_Qualifier = french ? IEQUALIFIER_LSHIFT : 0;
        buff[0] = 0;
        MapRawKey(&xie, buff, 1, 0);
        rc = buff[0];

        if (rc >= 'A' && rc <= 'Z')
            rc = rc - 'A' + 'a';

        if (rc > 32 && rc < 127) {
            xie.ie_Qualifier = french ? 0 : IEQUALIFIER_LSHIFT;
            buff[0] = 0;
            MapRawKey(&xie, buff, 1, 0);

            if (buff[0] > 32 && buff[0] < 127) {
                english_shiftxform[rc] = buff[0];
            }
        }

        if (rc > 127)
            rc = 0;
        break;
    }

    if (rc < 0)
        I_Error("Warning!");

    return rc;
}

extern int key_right;
extern int key_left;
extern int key_up;
extern int key_down;
extern int key_strafeleft;
extern int key_straferight;

extern int key_fire;
extern int key_use;
extern int key_strafe;
extern int key_strafe2;
extern int key_speed;
extern int key_speed2;
extern int key_lookup;
extern int key_lookdown;
extern int key_lookcenter;
extern int key_jump;

extern int keyuplook;
extern int keydownlook;
extern int joylookup;
extern int joylookdown;
extern int invertlook;

static int *keyarray[] = {&key_right,  &key_left,     &key_up,         &key_down,    &key_strafeleft, &key_straferight,
                          &key_fire,   &key_use,      &key_strafe,     &key_strafe2, &key_speed,      &key_speed2,
                          &key_lookup, &key_lookdown, &key_lookcenter, &key_jump};

static int cmpkeyarray[] = {KEY_NUM7, KEY_NUM8, KEY_NUM9, KEY_NUM4, KEY_NUM5, KEY_NUM6,
                            KEY_NUM1, KEY_NUM2, KEY_NUM3, KEY_NUM0, KEY_NUMP, KEY_NUMENTER};

static void InitKeys(void)
{
    int i, i2;

    for (i = 0; i < (sizeof(keyarray) / sizeof(int *)); i++) {
        for (i2 = 0; i2 < (sizeof(cmpkeyarray) / sizeof(int)); i2++) {
            if (*keyarray[i] == cmpkeyarray[i2]) {
                DoNumericPad = TRUE;
                break;
            }
        }
        if (DoNumericPad)
            break;
    }

    for (i = 0; i < 128; i++) {
        xlatetable[i] = xlatekey(i);
    }

    if (!invertlook) {
        keyuplook = key_up;
        keydownlook = key_down;
        joylookup = -1;
        joylookdown = 1;
    } else {
        keyuplook = key_down;
        keydownlook = key_up;
        joylookup = 1;
        joylookdown = -1;
    }
}

static void I_FreeAllocedPens(void);

void I_ShutdownGraphics(void)
{
    WORD i, i2;

    if (RemapTable)
        FreeVec(RemapTable);
    if (RemapBuffer)
        FreeVec(RemapBuffer);
    if (ObtainTable) {
        I_FreeAllocedPens();
        FreeVec(ObtainTable);
    }
    // Wait for the last blit+flip to finish
    if (Blitting) {
        Wait(DoomMask);
        Blitting = FALSE;
    }

    if (FlipTask) {
        SetSignal(0, SIGBREAKF_CTRL_E);
        Signal(FlipTask, SIGBREAKF_CTRL_C);
        Wait(SIGBREAKF_CTRL_E);
        Forbid();
        DeleteTask(FlipTask);
        Permit();
    }

    if (DoomSig != -1)
        FreeSignal(DoomSig);

    if (!DoGraffiti) {
        if (window) {
            SetWindowPointerA(window, 0);
            CloseWindow(window);
        }
        if (screenbuffer1)
            FreeScreenBuffer(screen, screenbuffer1);
        if (screenbuffer2)
            FreeScreenBuffer(screen, screenbuffer2);

        if (screen) {
            if (!InWindow) {
                CloseScreen(screen);
            } else {
                UnlockPubScreen(0, screen);
            }
        }
    }

    window = 0;
    screen = 0;

    // Round up height so that we can place the planes page-aligned
    const ULONG rasterheight = REALSCREENHEIGHT * Depth + (4096 * 8 + REALSCREENWIDTH - 1) / REALSCREENWIDTH;

    if (Planes1Mem) {
        WaitBlit();
        if (DoMMU1)
            mmu_mark(Planes1, (REALSCREENWIDTH / 8 * REALSCREENHEIGHT * Depth + 4095) & (~0xFFF), oldmmu_planes1,
                     SysBase);
        FreeRaster(Planes1Mem, REALSCREENWIDTH, rasterheight);
    }

    if (Planes2Mem) {
        WaitBlit();
        if (DoMMU1)
            mmu_mark(Planes2, (REALSCREENWIDTH / 8 * REALSCREENHEIGHT * Depth + 4095) & (~0xFFF), oldmmu_planes2,
                     SysBase);
        FreeRaster(Planes2Mem, REALSCREENWIDTH, rasterheight);
    }

    if (ChunkyMMUed && screens[0]) {
        mmu_mark(screens[0], (REALSCREENWIDTH * REALSCREENHEIGHT + 4095) & (~0xFFF), oldmmu_chunky, SysBase);
    }

    if (MMU2ed) {
        mmu_stuff2_cleanup();
    }

    if (MausObj)
        DisposeObject(MausObj);
    if (MausBM)
        FreeBitMap(MausBM);

    if (JoyInAction) {
        AbortIO((struct IORequest *)JoyIO);
        WaitIO((struct IORequest *)JoyIO);

        JoyInAction = FALSE;
        JoyType = GPCT_NOCONTROLLER;

        JoyIO->io_Command = GPD_SETCTYPE;
        JoyIO->io_Length = 1;
        JoyIO->io_Data = &JoyType;
        DoIO((struct IORequest *)JoyIO);
    }

    if (JoyIO) {
        CloseDevice((struct IORequest *)JoyIO);
        DeleteIORequest((struct IORequest *)JoyIO);
        JoyIO = 0;
    }

    if (JoyMP) {
        while (GetMsg(JoyMP))
            ;
        DeleteMsgPort(JoyMP);
        JoyMP = 0;
    }
}

static void InactiveSleep(void)
{
    static char *text = "*** SLEEPING ***";

    struct IntuiMessage *msg;
    BOOL ok = FALSE;
    LONG i, len;

    if (!DoGraffiti) {
        SetDrMd(&viewrastport, JAM2);
        SetAPen(&viewrastport, FindColor(colormap, 0, 0, 0, ~0));
        SetBPen(&viewrastport, FindColor(colormap, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, ~0));

        i = TextLength(&viewrastport, text, len = strlen(text));

        Move(&viewrastport, (REALSCREENWIDTH - i) / 2,
             (REALSCREENHEIGHT - viewrastport.TxHeight) / 2 + viewrastport.TxBaseline);
        Text(&viewrastport, text, len);
    }

    while (!ok) {
        WaitPort(window->UserPort);
        while ((msg = (struct IntuiMessage *)GetMsg(window->UserPort))) {
            if (msg->Class == IDCMP_ACTIVEWINDOW) {
                ok = TRUE;
            } else if (msg->Class == IDCMP_INACTIVEWINDOW) {
                ok = FALSE;
            }
            ReplyMsg((struct Message *)msg);
        }
    }
}

void I_StartFrame(void)
{
    /* er?*/
}

static int lastmousex = 0;
static int lastmousey = 0;
boolean mousemoved = false;
boolean shmFinished;

extern BOOL DoJoyPad;
extern BOOL DoAnalogJoy;
extern int joybstrafe;

ULONG JoyPos;
ULONG PreviousJoyPos;

extern void M_QuitDOOM(int choice);

void I_StartTic(void)
{
    event_t event;

    if (!ReadyForAction)
        return;

    while ((intuimessage = (struct IntuiMessage *)GetMsg(window->UserPort))) {
        ActQualifier = intuimessage->Qualifier;

        switch (intuimessage->Class) {
        case IDCMP_CLOSEWINDOW:
            M_QuitDOOM('q');
            break;

        case IDCMP_INACTIVEWINDOW:
            InactiveSleep();
            break;

        case IDCMP_RAWKEY:
            if (intuimessage->Code & IECODE_UP_PREFIX) {
                event.type = ev_keyup;
            } else {
                event.type = ev_keydown;
            }

            if ((event.data1 = xlatetable[intuimessage->Code & (~IECODE_UP_PREFIX)])) {
                D_PostEvent(&event);
            }
            break;

        case IDCMP_MOUSEBUTTONS:
            event.type = ev_mouse;
            event.data1 = 0;

            if (ActQualifier & IEQUALIFIER_LEFTBUTTON)
                event.data1 |= 1;
            if (ActQualifier & IEQUALIFIER_MIDBUTTON)
                event.data1 |= 2;
            if (ActQualifier & IEQUALIFIER_RBUTTON)
                event.data1 |= 4;

            event.data2 = event.data3 = 0;
            D_PostEvent(&event);
            /* fprintf(stderr, "b");*/
            break;

        case IDCMP_MOUSEMOVE:

            event.type = ev_mouse;
            event.data1 = 0;

            if (ActQualifier & IEQUALIFIER_LEFTBUTTON)
                event.data1 |= 1;
            if (ActQualifier & IEQUALIFIER_MIDBUTTON)
                event.data1 |= 2;
            if (ActQualifier & IEQUALIFIER_RBUTTON)
                event.data1 |= 4;

            event.data2 = (intuimessage->MouseX) << 3;
            event.data3 = (-intuimessage->MouseY) << 3;

            if (event.data2 || event.data3) {
                /*				    lastmousex = window->MouseX;*/
                /*				    lastmousey = window->MouseY;*/
                /*				    if ((lastmousex != X_width/2) &&*/
                /*						  (lastmousey != X_height/2))*/
                /*					{*/
                D_PostEvent(&event);

                mousemoved = false;

                /*			   	} else*/
                /*			   	{*/
                /*						mousemoved = true;*/
                /*			   	}*/
            }
            break;

        } /* switch(intuimessage->Class)*/

        ReplyMsg(&intuimessage->ExecMessage);

    } /* while ((intuimessage=(struct IntuiMessage *)GetMsg(window->UserPort))) */

    if (JoyOK) {
        while (GetMsg(JoyMP)) {
            switch (Joy_ie.ie_Code) {
            case IECODE_LBUTTON:
                joyevent.data1 |= 1;
                break;

            case IECODE_LBUTTON | IECODE_UP_PREFIX:
                joyevent.data1 &= ~1;
                break;

            case IECODE_RBUTTON:
                joyevent.data1 |= 2;
                break;

            case IECODE_RBUTTON | IECODE_UP_PREFIX:
                joyevent.data1 &= ~2;
                break;

            case IECODE_MBUTTON:
                joyevent.data1 |= 4;
                break;

            case IECODE_MBUTTON | IECODE_UP_PREFIX:
                joyevent.data1 &= ~4;
                break;

            case IECODE_NOBUTTON:
                joyevent.data2 = Joy_ie.ie_X;
                joyevent.data3 = Joy_ie.ie_Y;
                break;

            default:
                break;
            }
            joyevent.type = ev_joystick;
            D_PostEvent(&joyevent);

            JoyIO->io_Command = GPD_READEVENT;
            JoyIO->io_Length = sizeof(struct InputEvent);
            JoyIO->io_Data = &Joy_ie;
            SendIO((struct IORequest *)JoyIO);
        }
    } else if (DoJoyPad) {
        JoyPos = ReadJoyPort(joyport);

        if (JoyPos == PreviousJoyPos)
            return;

        if ((JoyPos & JP_TYPE_MASK) == JP_TYPE_NOTAVAIL)
            return;

        joyevent.type = ev_joystick;
        joyevent.data1 = joyevent.data2 = joyevent.data3 = 0;

        if (JoyPos & JPF_BUTTON_RED)
            joyevent.data1 |= 1;
        else
            joyevent.data1 &= ~1;

        if (JoyPos & JP_DIRECTION_MASK) {
            if (JoyPos & JPF_JOY_LEFT) {
                joyevent.data2 = -1;
            } else if (JoyPos & JPF_JOY_RIGHT) {
                joyevent.data2 = 1;
            }

            if (JoyPos & JPF_JOY_UP) {
                joyevent.data3 = -1;
            } else if (JoyPos & JPF_JOY_DOWN) {
                joyevent.data3 = 1;
            }
        }

        if (JoyPos & JP_TYPE_GAMECTLR) {
            /* Play/Pause = ESC (Menu) */

            if ((JoyPos & JPF_BUTTON_PLAY) && !(PreviousJoyPos & JPF_BUTTON_PLAY)) {
                event.type = ev_keydown;
                event.data1 = KEY_ESCAPE;
                D_PostEvent(&event);

            } else if (PreviousJoyPos & JPF_BUTTON_PLAY) {
                event.type = ev_keyup;
                event.data1 = KEY_ESCAPE;
                D_PostEvent(&event);
            }

            /* YELLOW = SHIFT (button 2) (Run) */

            if (JoyPos & JPF_BUTTON_YELLOW)
                joyevent.data1 |= 4;
            else
                joyevent.data1 &= ~4;

            /* BLUE = SPACE (button 3) (Open/Operate) */

            if (JoyPos & JPF_BUTTON_BLUE)
                joyevent.data1 |= 8;
            else
                joyevent.data1 &= ~8;

            /* GREEN = RETURN (show msg) */

            if ((JoyPos & JPF_BUTTON_GREEN) && !(PreviousJoyPos & JPF_BUTTON_GREEN)) {
                event.type = ev_keydown;
                event.data1 = 13;
                D_PostEvent(&event);
            } else if (PreviousJoyPos & JPF_BUTTON_GREEN) {
                event.type = ev_keyup;
                event.data1 = 13;
                D_PostEvent(&event);
            }

            /* FORWARD & REVERSE - ALT (Button1) Strafe left/right */

            if (JoyPos & JPF_BUTTON_FORWARD) {
                joyevent.data1 |= (1 << joybstrafe);
                joyevent.data2 = 1;
            } else if (JoyPos & JPF_BUTTON_REVERSE) {
                joyevent.data1 |= (1 << joybstrafe);
                joyevent.data2 = -1;
            } else {
                joyevent.data1 &= ~(1 << joybstrafe);
            }

        } /* if (JoyPos & JP_TYPE_GAMECTLR) */

        D_PostEvent(&joyevent);

        PreviousJoyPos = JoyPos;

    } /* else if (DoJoyPad) */
}

void I_UpdateNoBlit(void)
{
    /* what is this?*/
}

static void ShowFPS(void)
{
    static struct timeval tvold;
    static struct timeval tvnow;
    static struct timeval tvdiff;
    static char s[8];
    static int color = -1;

    ULONG l, fps;

    GetSysTime(&tvnow);
    tvdiff = tvnow;

    SubTime(&tvdiff, &tvold);

    l = tvdiff.tv_secs * 1000000L + tvdiff.tv_micro;
    if (!l)
        l = 1000000;

#ifndef mc68060
    fps = 1000000L / l;

    s[2] = fps % 10 + '0';
    fps /= 10;
    s[1] = fps % 10 + '0';
    fps /= 10;
    s[0] = fps % 10 + '0';
#else
    fps = LongDiv(1000000L, l);

    s[2] = LongRest(fps, 10) + '0';
    fps = LongDiv(fps, 10);
    s[1] = LongRest(fps, 10) + '0';
    fps = LongDiv(fps, 10);
    s[0] = LongRest(fps, 10) + '0';
#endif

    if (color == -1) {
        color = FindColor(colormap, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, -1);
        SetAPen(&renderrastport, color);
        SetAPen(&viewrastport, color);
    }

    if (DoBlitToScreen) {
        TextChunky(screens[0], s, 3, 2, 2, color, 0);
    } else if (!DoGraffiti) {
        Move(&renderrastport, BlitX + 2, BlitY + renderrastport.TxBaseline + 2);
        Text(&renderrastport, s, 3);
    }

    tvold = tvnow;
}

static void FlipBuffer(void)
{
    if (DoDoubleBuffer) {
        ActBuffer = 1 - ActBuffer;
        if (ActBuffer == 0) {
            Planes = Planes1;
        } else {
            Planes = Planes2;
        }
    }
}

extern ULONG C2PMask;

extern void RemapScreen(UBYTE *screen, UBYTE *remapbuffer, LONG bytes);

void I_FinishUpdate(void)
{
    static int lasttic;
    int tics;
    int i;
    /* UNUSED static unsigned char *bigscreen=0;*/

    /* draws little dots on the bottom of the screen*/

    if (devparm) {
        i = I_GetTime();
        tics = i - lasttic;
        lasttic = i;
        if (tics > 20)
            tics = 20;

        for (i = 0; i < tics * 2; i += 2)
            screens[0][(REALSCREENHEIGHT - 1) * REALSCREENWIDTH + i] = 0xff;
        for (; i < 20 * 2; i += 2)
            screens[0][(REALSCREENHEIGHT - 1) * REALSCREENWIDTH + i] = 0x0;
    }

    /* draw the image*/

    DoBlitToScreen = (!NoRender || (!(ActQualifier & IEQUALIFIER_CAPSLOCK)));

    if (DoFPS && DoBlitToScreen)
        ShowFPS();

    if (Blitting) {
        Wait(DoomMask);
        Blitting = FALSE;
    }
    if (DoDoubleBuffer) {
        Wait(SIGBREAKF_CTRL_F);
    }

    if (DoBlitToScreen) {
        if (InWindow)
            RemapScreen(screens[0], RemapBuffer, REALSCREENWIDTH * REALSCREENHEIGHT);

        if (DoC2P) {
            C2P->Chunky2Planar(InWindow ? RemapBuffer : screens[0], Planes);
            if (C2PIsFlipping)
                Blitting = TRUE;

            if (InWindow) {
                BltBitMapRastPort(&bitmap1, 0, 0, &viewrastport, BlitX, BlitY, REALSCREENWIDTH, REALSCREENHEIGHT, 192);
            }

        } else {
            if (OS31) {
                WriteChunkyPixels(&renderrastport, BlitX, BlitY, BlitX + REALSCREENWIDTH - 1,
                                  BlitY + REALSCREENHEIGHT - 1, InWindow ? RemapBuffer : screens[0], REALSCREENWIDTH);
            } else {
                WritePixelArray8(&renderrastport, BlitX, BlitY, BlitX + REALSCREENWIDTH - 1,
                                 BlitY + REALSCREENHEIGHT - 1, InWindow ? RemapBuffer : screens[0], &TempRP);
            }
        }
    }

    if (DoFPS && !DoBlitToScreen)
        ShowFPS();

    FlipBuffer();
    if (DoDoubleBuffer) {
        if (!C2PIsFlipping || !DoBlitToScreen)
            Signal(FlipTask, FlipMask);
    }
}

void I_ReadScreen(byte *scr)
{
    memcpy(scr, screens[0], REALSCREENWIDTH * REALSCREENHEIGHT);
}

ULONG coltable[3 * 256 + 4];

UBYTE *colpointer = (BYTE *)&coltable[1];

#define RGB32(x) (ULONG)((((ULONG)x) << 24L) | (((ULONG)x) << 16L) | (((ULONG)x) << 8L) | (x))

static void UploadNewPalette(struct ViewPort *viewport, byte *palette)
{
    /*	UBYTE *cols;

        UBYTE r,g,b;

        register int	i;
        register int	c;
        static BOOL firstcall = TRUE;*/

    __asm __volatile(
        "move.l	%0,-(sp) \n\t"

        "lea		_gammatable,a0 \n\t"
        "move.l	_usegamma,d0 \n\t"
        "lsl.l	#8,d0 \n\t"
        "lea		(a0,d0.l),a0 \n\t" /* a0 = gamma */
        "move.l	_colpointer,a1 \n\t"   /* a1 = colpointer */

        "move.w	#256*3-1,d0 \n\t" /* d0 = loop counter */
        "moveq	#0,d1 \n"

        "1: \n\t"
        "move.b	(%0)+,d1 \n\t"     /* col */
        "move.b	(a0,d1.w),d1 \n\t" /* gamma corrected col */
        "move.b	d1,d2 \n\t"
        "lsl.w	#8,d2 \n\t"
        "move.b	d1,d2 \n\t"
        "move		d2,d3 \n\t"
        "swap		d2 \n\t"
        "move		d3,d2 \n\t"
        "move.l	d2,(a1)+ \n\t"
        "dbf		d0,1b \n\t"

        "move.l	(sp)+,%0 \n\t"

        :
        : "a"(palette)
        : "d0", "d1", "d2", "d3", "a0", "a1", "memory");

    /*	    cols=colpointer;
            for (i=0 ; i<256 ; i++)
            {
                r = gammatable[usegamma][*palette++];
                g = gammatable[usegamma][*palette++];
                b = gammatable[usegamma][*palette++];

                *cols++=r;*cols++=r;*cols++=r;*cols++=r;
                *cols++=g;*cols++=g;*cols++=g;*cols++=g;
                *cols++=b;*cols++=b;*cols++=b;*cols++=b;
            }*/

    LoadRGB32(viewport, coltable);
}

static void I_FreeAllocedPens(void)
{
    WORD i;

    if (PensAlloced) {
        for (i = 0; i < 14 * 256; i++) {
            if (ObtainTable[i] != -1)
                ReleasePen(colormap, ObtainTable[i]);
        }
    }
}

static void I_InitRemap(UBYTE *palette)
{
    LONG col;
    WORD i, i2, i3;
    UBYTE r, g, b;
    UBYTE *rt;

    for (i = 0; i < 14 * 256; i++) {
        r = gammatable[usegamma][*palette++];
        g = gammatable[usegamma][*palette++];
        b = gammatable[usegamma][*palette++];

        col = ObtainBestPen(colormap, RGB32(r), RGB32(g), RGB32(b), OBP_Precision, PRECISION_EXACT, OBP_FailIfBad,
                            FALSE, TAG_DONE);

        ObtainTable[i] = col;
    }

    if (DoFastRemap) {
        rt = (UBYTE *)((ULONG)(RemapTable + 65535) & ~65535);
    } else {
        rt = (UBYTE *)((ULONG)(RemapTable + 255) & ~255);
    }

    for (i3 = 0; i3 < 14; i3++) {
        RemapTablePTR[i3] = rt;

        if (DoFastRemap) {
            for (i = 0; i < 256; i++) {
                for (i2 = 0; i2 < 256; i2++) {
                    *rt++ = ObtainTable[i3 * 256 + i];
                    *rt++ = ObtainTable[i3 * 256 + i2];
                }
            }
        } else {
            for (i = 0; i < 256; i++) {
                *rt++ = ObtainTable[i3 * 256 + i];
            }
        }
    }

    PensAlloced = TRUE;
}

int paletteindex = 0;

void I_SetPalette(byte *palette, int index)
{
    static int oldgamma = -123;

    paletteindex = index;
    if (InWindow) {
        if (usegamma != oldgamma) {
            I_FreeAllocedPens();
            I_InitRemap(palette - (index * 768));
            oldgamma = usegamma;
        }
    } else if (!DoGraffiti) {
        UploadNewPalette(viewport, palette);
    } else {
        C2P->Graffiti_SetPalette(palette, (UBYTE *)gammatable[usegamma]);
    }
}

extern ULONG GetScreenMode(char *title, ULONG modeid);
extern struct Device *InputBase;

extern UWORD StartQualifier;

extern int usemouse;
extern int usejoystick;

extern void GetC2P(void);

static void ScreenFlipper(void);

static void MakeFlipTask(void)
{
    if (!(FlipTask = CreateTask("DoomAttack Screen Flipper", 21, ScreenFlipper, 4096))) {
        I_Error("I_Video: Can't create Screen Flipping Task!");
    }

    Wait(SIGBREAKF_CTRL_F);

    if (!FlipMask) {
        I_Error("I_Video: Screen Flipping Task couldn't initialize!");
    }
}

void I_InitGraphics(void)
{
    static struct Rectangle rect;
    static int firsttime = 1;

    void *mem;
    char *d;
    int n, p;
    int pnum;
    int x = 0;
    int y = 0;

    /* warning: char format, different type arg*/

    ULONG flags, idcmp, smode;

    if (!firsttime)
        return;
    firsttime = 0;

    coltable[0] = 256 << 16;

    if (cputype >= 68040) {
        if ((usemmu & 1) || M_CheckParm("-mmu"))
            DoMMU1 = TRUE;
        if ((usemmu & 2) || M_CheckParm("-mmu2"))
            DoMMU2 = TRUE;
    }

    DoomSig = AllocSignal(-1);
    DoomMask = 1L << DoomSig;

    /*    signal(SIGINT, (void (*)(int)) I_Quit);*/

    if (usejoystick && !DoJoyPad && !DoAnalogJoy) {
        if ((JoyMP = CreateMsgPort())) {
            if ((JoyIO = (struct IOStdReq *)CreateIORequest(JoyMP, sizeof(struct IOStdReq)))) {
                if (!OpenDevice("gameport.device", joyport, (struct IORequest *)JoyIO, 0)) {
                    Forbid();

                    JoyIO->io_Command = GPD_ASKCTYPE;
                    JoyIO->io_Length = 1;
                    JoyIO->io_Data = &JoyType;
                    DoIO((struct IORequest *)JoyIO);

                    if (JoyType == GPCT_NOCONTROLLER) {
                        JoyType = GPCT_ABSJOYSTICK;
                        JoyIO->io_Command = GPD_SETCTYPE;
                        JoyIO->io_Length = 1;
                        JoyIO->io_Data = &JoyType;
                        DoIO((struct IORequest *)JoyIO);
                        Permit();

                        JoyIO->io_Command = GPD_SETTRIGGER;
                        JoyIO->io_Length = sizeof(struct GamePortTrigger);
                        JoyIO->io_Data = &Joy_gpt;
                        DoIO((struct IORequest *)JoyIO);

                        JoyIO->io_Command = GPD_READEVENT;
                        JoyIO->io_Length = sizeof(struct InputEvent);
                        JoyIO->io_Data = &Joy_ie;
                        SendIO((struct IORequest *)JoyIO);
                        JoyInAction = JoyOK = TRUE;

                    } else {
                        Permit();
                        CloseDevice((struct IORequest *)JoyIO);
                        DeleteIORequest((struct IORequest *)JoyIO);
                        JoyIO = 0;
                        DeleteMsgPort(JoyMP);
                        JoyMP = 0;

                        fprintf(stderr, "I_Amiga: Joystick seems to be in use by another program!\n");
                    }
                } else {
                    fprintf(stderr, "I_Amiga: Could not open gameport.device. Joystick will not be available!\n");
                }
            }
        }
    }

    if (M_CheckParm("-fps"))
        DoFPS = TRUE;
    if (M_CheckParm("-rendercontrol"))
        NoRender = TRUE;

    NoRangeCheck = (boolean)ConfigNoRangeCheck;
    if (M_CheckParm("-norangecheck"))
        NoRangeCheck = TRUE;

    modeid = (ULONG)configmodeid;

    p = M_CheckParm("-displayid");

    if (p && p < myargc - 1) {
        modeid = strtol(myargv[p + 1], 0, 0);
    }

    if (InputBase) {
        if (StartQualifier & (IEQUALIFIER_LSHIFT | IEQUALIFIER_RSHIFT))
            modeid = INVALID_ID;
    }

    if (modeid == INVALID_ID) {
        modeid = GetScreenMode("DoomAttack", modeid);
        if (modeid == INVALID_ID)
            modeid = 0;
    }

    if ((modeid == 0xFFFFFFFE) || (modeid == 0xFFFFFFFD)) {
        InWindow = TRUE;

        if (DoFastRemap) {
            RemapTable = AllocVec(14L * 65536L * sizeof(UWORD) + 65536L + 2L, 0);
        } else {
            RemapTable = AllocVec(14 * 256 * sizeof(UBYTE) + 256 + 1, 0);
        }
        ObtainTable = AllocVec(256 * 14 * sizeof(LONG), 0);
        RemapBuffer = AllocVec(REALSCREENWIDTH * (REALSCREENHEIGHT + 5), 0);

        if (!RemapTable || !ObtainTable || !RemapBuffer)
            I_Error("I_Video: Out of memory (Remaptable/ObtainTable/RemapBuffer)");

        memset(ObtainTable, 0xFF, 14 * 256 * sizeof(LONG));

        DoDoubleBuffer = FALSE;

        screen = LockPubScreen(modeid == 0xFFFFFFFE ? "Workbench" : 0);
        if (!screen)
            I_Error("I_Video: Can't lock screen!");

    } else if ((modeid == 0xFFFFFFFC) || (modeid == 0xFFFFFFFB)) {
        if ((modeid == 0xFFFFFFFC)) {
            modeid = PAL_MONITOR_ID | HIRES_KEY;
        } else {
            modeid = NTSC_MONITOR_ID | HIRES_KEY;
        }
        WantGraffiti = TRUE;

        if (InWindow)
            I_Error("I_Video: Window mode is not possible with Graffiti!");
    }

    if (!WantGraffiti && !M_CheckParm("-c2p")) {
        if ((CyberGfxBase = OpenLibrary("cybergraphics.library", 0))) {
            if (InWindow) {
                if ((smode = GetVPModeID(&screen->ViewPort)) != INVALID_ID) {
                    if (IsCyberModeID(smode))
                        GfxBoard = TRUE;
                }
            } else {
                if (IsCyberModeID(modeid))
                    GfxBoard = TRUE;
            }
            CloseLibrary(CyberGfxBase);
            CyberGfxBase = 0;
        }
    }

    if (!GfxBoard && !InWindow)
        MakeFlipTask();
    if (!GfxBoard)
        GetC2P();

    if (WantGraffiti && !DoGraffiti) {
        I_Error("I_Video: Graffiti mode needs a (working) special Graffiti C2P Routine!");
    }

    InitBitMap(&bitmap1, 8, REALSCREENWIDTH, REALSCREENHEIGHT);
    InitBitMap(&bitmap2, 8, REALSCREENWIDTH, REALSCREENHEIGHT);

    // Round up height so that we can place the planes page-aligned
    // REALSCREENWIDTH must be WORD-aligned.
    assert(!(REALSCREENWIDTH & 0xF));
    const ULONG rasterheight = REALSCREENHEIGHT * Depth + (4096 * 8 + REALSCREENWIDTH - 1) / REALSCREENWIDTH;

    if (DoC2P && !DoGraffiti) {
        Planes1Mem = AllocRaster(REALSCREENWIDTH, rasterheight);
        if (!Planes1Mem)
            I_Error("I_Video: Can't alloc chip memory for BitMap");

        Planes1 = (void *)((ULONG)(Planes1Mem + 4095) & (~0xFFF));

        if (DoMMU1)
            oldmmu_planes1 = mmu_mark(Planes1, (REALSCREENWIDTH / 8 * REALSCREENHEIGHT * Depth + 4095) & (~0xFFF),
                                      CM_IMPRECISE, SysBase);

        for (y = 0; y < 8; y++) {
            bitmap1.Planes[y] = (byte *)Planes1 + y * (((REALSCREENWIDTH + 15) & (~15)) * REALSCREENHEIGHT / 8);
        }

        if (DoDoubleBuffer) {
            Planes2Mem = AllocRaster(REALSCREENWIDTH, rasterheight);

            if (!Planes2Mem) {
                DoDoubleBuffer = FALSE;
                fprintf(stderr, "Failed to allocate double buffered bitmap.");
            } else {
                Planes2 = (void *)((ULONG)(Planes2Mem + 4095) & (~0xFFF));

                if (DoMMU1)
                    oldmmu_planes2 =
                        mmu_mark(Planes2, (REALSCREENWIDTH / 8 * REALSCREENHEIGHT * Depth + 4095) & (~0xFFF),
                                 CM_IMPRECISE, SysBase);

                for (y = 0; y < 8; y++) {
                    bitmap2.Planes[y] = (byte *)Planes2 + y * (((REALSCREENWIDTH + 15) & (~15)) * REALSCREENHEIGHT / 8);
                }
            }
        }
    }

    if (DoMMU1 && screens[0]) {
        oldmmu_chunky =
            mmu_mark(screens[0], (REALSCREENWIDTH * REALSCREENHEIGHT + 4095) & (~0xFFF), CM_WRITETHROUGH, SysBase);
        ChunkyMMUed = TRUE;
    }

    if (DoMMU2) {
        mmu_stuff2();
        MMU2ed = TRUE;
    }

    if (hidemouse) {
        if ((MausBM = AllocBitMap(16, 16, 2, BMF_CLEAR, 0))) {
            MausObj = NewObject(0, "pointerclass", POINTERA_BitMap, (int)MausBM, TAG_DONE);
        }
    }

    rect.MinX = 0;
    rect.MaxX = REALSCREENWIDTH - 1;
    rect.MinY = 0;
    rect.MaxY = REALSCREENHEIGHT - 1;

    if (!InWindow) {
        if (!DoGraffiti) {
            screen = OpenScreenTags(0, SA_Width, REALSCREENWIDTH, SA_Height, REALSCREENHEIGHT, SA_Depth, 8, SA_Behind,
                                    TRUE, SA_Quiet, TRUE, SA_DisplayID, modeid, DoC2P ? SA_DClip : TAG_IGNORE,
                                    (int)&rect, DoC2P ? SA_BitMap : TAG_IGNORE, (int)&bitmap1, TAG_DONE);

            if (!screen)
                I_Error("Can't open screen!");
        } else {
            C2P->Graffiti_GetInformation(&window, &screenbuffer1, &screenbuffer2);
            screen = window->WScreen;
        }
    }

    viewport = &screen->ViewPort;
    colormap = viewport->ColorMap;

    if (DoDoubleBuffer && !DoGraffiti) {
        screenbuffer1 = AllocScreenBuffer(screen, &bitmap1, 0);
        screenbuffer2 = AllocScreenBuffer(screen, &bitmap2, 0);

        if (!screenbuffer1 || !screenbuffer2) {
            DoDoubleBuffer = FALSE;
        }
    }

    flags = WFLG_BORDERLESS | WFLG_ACTIVATE | WFLG_RMBTRAP;
    if (usemouse)
        flags |= WFLG_REPORTMOUSE;
    if (InWindow) {
        flags |= WFLG_CLOSEGADGET | WFLG_DEPTHGADGET | WFLG_DRAGBAR;
        flags &= (~WFLG_BORDERLESS);
    }

    idcmp = IDCMP_RAWKEY | IDCMP_ACTIVEWINDOW | IDCMP_INACTIVEWINDOW;
    if (usemouse)
        idcmp |= (IDCMP_MOUSEMOVE | IDCMP_MOUSEBUTTONS | IDCMP_DELTAMOVE);
    if (InWindow)
        idcmp |= IDCMP_CLOSEWINDOW;

    if (M_CheckParm("-nosleep"))
        idcmp &= (~(IDCMP_ACTIVEWINDOW | IDCMP_INACTIVEWINDOW));

    if (!DoGraffiti) {
        window = OpenWindowTags(
            0, InWindow ? WA_PubScreen : WA_CustomScreen, (int)screen, InWindow ? WA_Title : TAG_IGNORE,
            (int)"DoomAttack", WA_Left,
            InWindow ? (screen->Width - REALSCREENWIDTH - screen->WBorLeft - screen->WBorRight) / 2 : 0, WA_Top,
            InWindow ? (screen->Height - REALSCREENHEIGHT - screen->WBorTop - screen->WBorBottom -
                        screen->Font->ta_YSize - 1) /
                           2
                     : 0,
            InWindow ? WA_InnerWidth : WA_Width, REALSCREENWIDTH, InWindow ? WA_InnerHeight : WA_Height,
            REALSCREENHEIGHT, WA_Flags, flags, WA_IDCMP, idcmp, WA_AutoAdjust, TRUE, MausObj ? WA_Pointer : TAG_IGNORE,
            (int)MausObj, TAG_DONE);
    } else {
        ModifyIDCMP(window, idcmp);
    }

    if (!window)
        I_Error("I_Video: Can't open window!");

    if (!InWindow) {
        viewrastport = screen->RastPort;
        renderrastport = screen->RastPort;

        BlitX = 0;
        BlitY = 0;
    } else {
        viewrastport = *window->RPort;
        renderrastport = *window->RPort;

        BlitX = window->BorderLeft;
        BlitY = window->BorderTop;
    }

    if (DoDoubleBuffer && DoC2P) {
        Planes = Planes2;
        ActBuffer = 1;
        ActScreen = 0;
    } else {
        Planes = Planes1;
        ActBuffer = ActScreen = 0;
    }

    if (DoDoubleBuffer) {
        renderrastport.BitMap = &bitmap2;
    }

    /*	screens[0] = (unsigned char *) malloc (SCREENWIDTH * REALSCREENHEIGHT);*/

    if (DoC2P) {
        if (!DoGraffiti) {
            if (DoDoubleBuffer) {
                fprintf(stderr, "Amiga_Video: Using C2P conversion with double buffering. DisplayID: 0x%X\n", modeid);
            } else {
                fprintf(stderr, "Amiga_Video: Using C2P conversion with single buffering. DisplayID: 0x%X %s\n", modeid,
                        InWindow ? "(Window)" : "");
            }
        } else {
            fprintf(stderr, "Amiga_Video: Working in Graffiti mode (%s)\n",
                    (modeid & MONITOR_ID_MASK) == PAL_MONITOR_ID ? "PAL" : "NTSC");
        }
    } else {
        fprintf(stderr, "Amiga_Video: Working in RTG mode with single buffering. DisplayID: 0x%X %s\n", modeid,
                InWindow ? "(Window)" : "");
    }

    InitKeys();

    I_SetPalette(W_CacheLumpName("PLAYPAL", PU_CACHE), 0);

    Delay(50);
    ScreenToFront(screen);

    if (DoDoubleBuffer) {
        SetSignal(SIGBREAKF_CTRL_F, SIGBREAKF_CTRL_F);
    }
    ReadyForAction = TRUE;
}

static void ScreenFlipper(void)
{
    BOOL done = FALSE, first = TRUE;
    LONG sig = -1;
    ULONG sigs;

    DisplayPort = CreateMsgPort();
    SafePort = CreateMsgPort();

    if (!DisplayPort || !SafePort) {
        done = TRUE;
    } else {
        sig = AllocSignal(-1);
        if (sig != -1) {
            FlipMask = 1L << sig;
        } else {
            done = TRUE;
        }
    }

    if (done) {
        FlipMask = 0;
    }
    Signal(MainTask, SIGBREAKF_CTRL_F);

    Video_Safe = TRUE;
    Video_Display = TRUE;
    while (!done) {
        sigs = Wait(FlipMask | SIGBREAKF_CTRL_C);

        if (sigs & SIGBREAKF_CTRL_C) {
            done = TRUE;
        }

        if (sigs & FlipMask) {
            if (first) {
                screenbuffer1->sb_DBufInfo->dbi_SafeMessage.mn_ReplyPort = SafePort;
                screenbuffer1->sb_DBufInfo->dbi_DispMessage.mn_ReplyPort = DisplayPort;
                screenbuffer2->sb_DBufInfo->dbi_SafeMessage.mn_ReplyPort = SafePort;
                screenbuffer2->sb_DBufInfo->dbi_DispMessage.mn_ReplyPort = DisplayPort;
                first = FALSE;
            }

            ActScreen = 1 - ActScreen;
            if (ActScreen == 0) {
                renderrastport.BitMap = &bitmap2;
                viewrastport.BitMap = &bitmap1;
                if (ChangeScreenBuffer(screen, screenbuffer1)) {
                    Video_Safe = FALSE;
                    Video_Display = FALSE;
                }
            } else {
                renderrastport.BitMap = &bitmap1;
                viewrastport.BitMap = &bitmap2;
                if (ChangeScreenBuffer(screen, screenbuffer2)) {
                    Video_Safe = FALSE;
                    Video_Display = FALSE;
                }
            }

            if (!Video_Safe) {
                WaitPort(SafePort);
                while (GetMsg(SafePort))
                    ;
                Video_Safe = TRUE;
            }

            Signal(MainTask, SIGBREAKF_CTRL_F);

            if (!Video_Display) {
                WaitPort(DisplayPort);
                while (GetMsg(DisplayPort))
                    ;
                Video_Display = TRUE;
            }

        } /* if (sigs&FlipMask) */

    } /* while (!done) */

    if (DisplayPort) {
        if (!Video_Display) {
            WaitPort(DisplayPort);
            while (GetMsg(DisplayPort))
                ;
        }
        DeleteMsgPort(DisplayPort);
    }

    if (SafePort) {
        if (!Video_Safe) {
            WaitPort(SafePort);
            while (GetMsg(SafePort))
                ;
        }
        DeleteMsgPort(SafePort);
    }

    if (sig != -1)
        FreeSignal(sig);

    Signal(MainTask, SIGBREAKF_CTRL_E);
    Wait(0);
}

struct InputEvent *C_MyInputHandler(struct InputEvent *ie)
{
    static event_t event;
    UWORD code;

    if (window && (IntuitionBase->ActiveWindow == window)) {
        if ((ie->ie_Class == IECLASS_RAWKEY) && full_keys && (gamestate == GS_LEVEL) && !paused && !menuactive) {
            ActQualifier = ie->ie_Qualifier;
            code = ie->ie_Code;
            if (code & IECODE_UP_PREFIX) {
                code &= (~IECODE_UP_PREFIX);
                event.type = ev_keyup;
            } else {
                event.type = ev_keydown;
            }
            if ((event.data1 = xlatetable[code])) {
                D_PostEvent(&event);

                ie = 0;
            }
        } else if ((ie->ie_Class == IECLASS_RAWMOUSE) && usemouse && full_mouse && (gamestate == GS_LEVEL) && !paused &&
                   !menuactive) {
            code = ie->ie_Code;
            ActQualifier = ie->ie_Qualifier;

            event.type = ev_mouse;
            event.data1 = 0;

            if (ActQualifier & IEQUALIFIER_LEFTBUTTON)
                event.data1 |= 1;
            if (ActQualifier & IEQUALIFIER_MIDBUTTON)
                event.data1 |= 2;
            if (ActQualifier & IEQUALIFIER_RBUTTON)
                event.data1 |= 4;

            event.data2 = (ie->ie_position.ie_xy.ie_x << 3);
            event.data3 = (-ie->ie_position.ie_xy.ie_y << 3);

            D_PostEvent(&event);

            ie = 0;
        }
    }

    return ie;
}
