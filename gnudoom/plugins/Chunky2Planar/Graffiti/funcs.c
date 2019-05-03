#include <OSIncludes.h>

#pragma header

#include "graffiti.h"
#include <stabs.h>

static struct ExecBase *SysBase;

#include <stabs.h>
extern struct Custom custom;
ABSDEF(custom, 0x00dff000);

extern struct IntuitionBase *IntuitionBase;
extern struct GfxBase *GfxBase;

static struct Window *window, *commandwindow;
static struct Screen *screen, *commandscreen;
static struct MsgPort *windowport;
static struct ViewPort *viewport;
static struct ColorMap *colormap;
static struct RastPort rastport[2], temprp;
static struct UCopList *coplist1, *coplist2;

static struct ScreenBuffer *screenbuffer[2];

static struct BitMap *MouseBM, bitmap[2], *tempbm;

static APTR Planes1, Planes2, CommandPlanes[4];

ULONG modeid;

static WORD drawbuffer;
static BOOL copliststuffdone;

static APTR setcoloffsets[3 * 256];
static ULONG colortable[3 * 256 + 2];

static Object *MouseObj;

/* Protos */

void Graffiti_Exit(void);
static void InitCommandScreen(void);

extern void ConvertPalette(UBYTE *palette, UBYTE *gammatable, APTR *setcoloff);
extern void ConvertGraphic(UBYTE *chunky, APTR plane1);

/******************************************************/

LONG Graffiti_Init(void)
{
    SysBase = *(struct ExecBase **)4;

    LONG i, rc = FALSE;
    UWORD bplcon0 = GENLOCK_AUDIO | HIRES | 0x0201 | (4 << 12) | GfxBase->system_bplcon0;

    colortable[0] = 256L << 16;

    if ((windowport = CreateMsgPort())) {
        if ((Planes1 = AllocMem(320 * 222, MEMF_CHIP | MEMF_CLEAR))) {
            if ((Planes2 = AllocMem(320 * 222, MEMF_CHIP | MEMF_CLEAR))) {
                InitBitMap(&bitmap[0], 4, 640, 200);
                InitBitMap(&bitmap[1], 4, 640, 200);

                for (i = 0; i < 8; i++) {
                    bitmap[0].Planes[i] = (UBYTE *)Planes1 + (11 * 320) + i * (640 * 200 / 8);
                    bitmap[1].Planes[i] = (UBYTE *)Planes2 + (11 * 320) + i * (640 * 200 / 8);
                }

                InitRastPort(&rastport[0]);
                InitRastPort(&rastport[1]);

                rastport[0].BitMap = &bitmap[0];
                rastport[1].BitMap = &bitmap[1];

                if ((commandscreen = OpenScreenTags(0, SA_Left, 0, SA_Top, 0, SA_Width, 640, SA_Height, 7, SA_Depth, 4,
                                                    SA_Interleaved, FALSE, SA_ShowTitle, FALSE, SA_Quiet, TRUE,
                                                    SA_Behind, TRUE, SA_Type, CUSTOMSCREEN, SA_DisplayID, modeid,
                                                    SA_Colors, (Tag)Colortable_320, TAG_DONE))) {
                    if ((commandwindow =
                             OpenWindowTags(0, WA_Left, 0, WA_Top, 0, WA_Width, 640, WA_Height, 7, WA_CustomScreen,
                                            (Tag)commandscreen, WA_Borderless, TRUE, WA_NoCareRefresh, TRUE,
                                            WA_SimpleRefresh, TRUE, WA_IDCMP, 0L, TAG_DONE))) {
                        commandwindow->UserPort = windowport;
                        ModifyIDCMP(commandwindow, IDCMP_RAWKEY);

                        if ((screen = OpenScreenTags(0, SA_Left, 0, SA_Top, 10, SA_Width, 640, SA_Height, 200, SA_Depth,
                                                     4, SA_DisplayID, modeid, SA_Behind, TRUE, SA_Quiet, TRUE,
                                                     SA_ShowTitle, FALSE, SA_Colors, (Tag)Colortable_320,
                                                     SA_MinimizeISG, TRUE, SA_Draggable, FALSE, SA_BitMap,
                                                     (Tag)&bitmap[0], SA_Parent, (Tag)commandscreen, TAG_DONE))) {
                            ScreenDepth(screen, SDEPTH_TOFRONT | SDEPTH_INFAMILY, 0);

                            if ((MouseBM = AllocBitMap(16, 16, 2, BMF_CLEAR, 0))) {
                                MouseObj = NewObject(0, "pointerclass", POINTERA_BitMap, (int)MouseBM, TAG_DONE);
                            }

                            if ((window = OpenWindowTags(
                                     0, WA_CustomScreen, (Tag)screen, WA_Left, 0, WA_Top, 0, WA_Width, 640, WA_Height,
                                     200, WA_SimpleRefresh, TRUE, WA_NoCareRefresh, TRUE, WA_Flags,
                                     WFLG_BORDERLESS | WFLG_ACTIVATE | WFLG_RMBTRAP | WFLG_REPORTMOUSE, WA_IDCMP, 0,
                                     MouseObj ? WA_Pointer : TAG_IGNORE, (Tag)MouseObj, TAG_DONE))) {
                                window->UserPort = windowport;
                                ModifyIDCMP(window, IDCMP_RAWKEY);

                                viewport = ViewPortAddress(window);
                                colormap = viewport->ColorMap;

                                if ((screenbuffer[0] = AllocScreenBuffer(screen, &bitmap[0], 0))) {
                                    if ((screenbuffer[1] = AllocScreenBuffer(screen, &bitmap[1], 0))) {
                                        if ((tempbm = AllocBitMap(640, 1, 8, BMF_STANDARD, 0))) {
                                            InitRastPort(&temprp);
                                            temprp.BitMap = tempbm;
                                            rc = TRUE;

                                        }  // if ((tempbm=AllocBitMap(640,1,8,BMF_STANDARD,0)))

                                    }  // if ((screenbuffer[1]=AllocScreenBuffer(screen,&bitmap[1],0)))

                                }  // if ((screenbuffer[0]=AllocScreenBuffer(screen,&bitmap[0],0)))

                            }  // if ((window=OpenWindowTags(0,

                        }  // if ((screen=OpenScreenTags(0,

                    }  // if ((commandwindow=OpenWindowTags (0,

                }  // if ((commandscreen=OpenScreenTags(0,

            }  // if (Planes1=AllocMem(320*200,MEMF_CHIP|MEMF_CLEAR))

        }  // if (Planes2=AllocMem(320*200,MEMF_CHIP|MEMF_CLEAR))

    }  // if ((windowport=CreateMsgPort)))

    if (!rc) {
        Graffiti_Exit();

    } else {
        InitCommandScreen();

        /* If this fails, it is worth crashing ;-) */

        coplist1 = AllocMem(sizeof(struct UCopList), MEMF_PUBLIC | MEMF_CLEAR);
        coplist2 = AllocMem(sizeof(struct UCopList), MEMF_PUBLIC | MEMF_CLEAR);

// There is a problem with the NDK. custom.h defines all custom chip registers
// as volatile, but CMove takes a non-volatile pointer, resulting in
// "error: initialization discards 'volatile' qualifier from pointer target type "
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdiscarded-qualifiers"
        /* COPPERLIST for command screen */

        CINIT(coplist1, 256); /* Some space for what we need */
        /* Attach our command at the end of the systems' list. */
        CWAIT(coplist1, -2, 0);
        /* write value for Hires/Audio/4bpl into bplcon0 */
        CMOVE(coplist1, custom.bplcon0, 0xC301);
        CEND(coplist1);

        /* COPPERLIST for main screen */

        CINIT(coplist2, 4); /* Some space for what we need */
        /* Wait for first line of graphics screen */
        CWAIT(coplist2, -1, 0);
        CMOVE(coplist2, custom.bplcon0, bplcon0); /* write new value for bplcon0 into register */
        CEND(coplist2);
#pragma GCC diagnostic pop

        Forbid();
        commandscreen->ViewPort.UCopIns = coplist1;
        screen->ViewPort.UCopIns = coplist2;
        Permit();

        VideoControlTags(commandscreen->ViewPort.ColorMap, VTAG_USERCLIP_SET, 0, TAG_DONE);
        VideoControlTags(screen->ViewPort.ColorMap, VTAG_USERCLIP_SET, 0, VC_NoColorPaletteLoad, TRUE, TAG_DONE);

        ScreenToFront(commandscreen);
        RethinkDisplay();

        copliststuffdone = TRUE;
    }

    return rc;
}

/******************************************************/

static void InitCommandScreen(void)
{
#define COMMAND(a) *(planeptr[(planeindex++) & 3]++) = a

    struct BitMap *bm;
    APTR *sco = setcoloffsets;
    WORD i, planeindex = 0;
    UBYTE *planeptr[4];

    bm = commandscreen->RastPort.BitMap;

    for (i = 0; i < 4; i++) {
        CommandPlanes[i] = planeptr[i] = bm->Planes[i];
    }

    COMMAND(GCMD_SET_COLMASK);
    COMMAND(255);

    for (i = 0; i < 256; i++) {
        COMMAND(GCMD_SET_COLOR);
        COMMAND(i);

        COMMAND(GCMD_SET_RGB);
        *sco++ = planeptr[planeindex & 3];
        COMMAND(0);
        COMMAND(GCMD_SET_RGB);
        *sco++ = planeptr[planeindex & 3];
        COMMAND(0);
        COMMAND(GCMD_SET_RGB);
        *sco++ = planeptr[planeindex & 3];
        COMMAND(0);
    }
    COMMAND(GCMD_START_LORES);
    COMMAND(0);
}

/******************************************************/

void Graffiti_SetPalette(UBYTE *pal, UBYTE *gamma)
{
    ConvertPalette(pal, gamma, setcoloffsets);
    //	LoadRGB32(viewport,colortable);
}

/******************************************************/

void Graffiti_GetInformation(struct Window **win, struct ScreenBuffer **buf1, struct ScreenBuffer **buf2)
{
    *win = window;
    *buf1 = screenbuffer[0];
    *buf2 = screenbuffer[1];
}

/******************************************************/

void Graffiti_Convert(UBYTE *chunkybuffer)
{
    //	WriteChunkyPixels(&rastport[drawbuffer],0,0,319,199,chunkybuffer,320);

    drawbuffer = 1 - drawbuffer;

    ConvertGraphic(chunkybuffer, bitmap[drawbuffer].Planes[0]);

    //	WritePixelArray8(&rastport[drawbuffer],0,0,319,199,chunkybuffer,&temprp);
}

/******************************************************/

static void CloseWindowSafely(struct Window *win)
{
    struct IntuiMessage *msg, *succ;

    Forbid();

    for (msg = (struct IntuiMessage *)win->UserPort->mp_MsgList.lh_Head;
         (succ = (struct IntuiMessage *)msg->ExecMessage.mn_Node.ln_Succ); msg = succ) {
        if (msg->IDCMPWindow == win) {
            Remove((struct Node *)msg);

            ReplyMsg((struct Message *)msg);
        }
    }

    win->UserPort = NULL;

    ModifyIDCMP(win, 0L);

    Permit();

    CloseWindow(win);
} /* CloseWindowSafely */

/******************************************************/

void Graffiti_Exit(void)
{
    if (copliststuffdone) {
        FreeVPortCopLists(&commandscreen->ViewPort);
        FreeVPortCopLists(&screen->ViewPort);
    }

    if (tempbm) {
        WaitBlit();
        FreeBitMap(tempbm);
    }

    if (screenbuffer[0])
        FreeScreenBuffer(screen, screenbuffer[0]);
    if (screenbuffer[1])
        FreeScreenBuffer(screen, screenbuffer[1]);

    if (window)
        CloseWindowSafely(window);
    if (MouseObj)
        DisposeObject(MouseObj);
    if (MouseBM)
        FreeBitMap(MouseBM);

    if (screen)
        CloseScreen(screen);

    if (commandwindow)
        CloseWindowSafely(commandwindow);
    if (commandscreen)
        CloseScreen(commandscreen);

    WaitBlit();
    if (Planes1)
        FreeMem(Planes1, 320 * 222);
    if (Planes2)
        FreeMem(Planes2, 320 * 222);

    if (windowport)
        DeleteMsgPort(windowport);
}
