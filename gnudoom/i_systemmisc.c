#include <exec/exec.h>
#include <dos/dos.h>
#include <dos/var.h>
#include <intuition/intuition.h>
#include <graphics/gfx.h>
#include <graphics/displayinfo.h>
#include <graphics/videocontrol.h>
#include <libraries/iffparse.h>
#include <libraries/asl.h>
#include <datatypes/pictureclass.h>

#include <inline/graphics.h>
#include <inline/intuition.h>
#include <inline/exec.h>
#include <inline/dos.h>
#include <inline/iffparse.h>
#include <inline/asl.h>

#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>

#include "doomdef.h"
#include "i_system.h"
#include "v_video.h"
#include "info.h"
#include "sounds.h"
#include "d_items.h"
#include "doomstat.h"
#include "p_local.h"

extern struct Screen *screen;
extern struct Window *window;
extern struct ViewPort *viewport;

extern struct IntuitionBase *IntuitionBase;
extern struct GfxBase *GfxBase;
extern struct Library *IFFParseBase;
extern struct Library *AslBase;

static struct DisplayMode mydisplaymode =
{
	/* Node */

	{0,0,0,0,0},

	/* DimensionInfo */
	
	{
		/* QueryHeader */
		{DTAG_DIMS,	/* StructID */
	 	 0xFFFFFFFE,	/* DisplayID */
	 	 TAG_SKIP,	/* SkipID */
	 	 8
	   },				/* Lenght in double long words */
		24,			/* MaxDepth */
	 	 320,			/* MinRasterWidth */
		 200,			/* MinRasterHeight */
		 16384,		/* MaxRasterWidth */
		 16384,		/* MaxRasterHeight */
		 {0,0,319,199},	/* Nominal */
		 {0,0,319,199}, /* MaxOScan */
		 {0,0,319,199}, /* VideoOScan */
		 {0,0,319,199}, /* TxtOScan */
		 {0,0,319,199} /* StdOScan */
		
	},
	
	/* PropertyFlags */
	0
	
};

void I_MakePath(char *dest, char *path, char *file,int len)
{
	strcpy(dest,path);
	AddPart(dest,file,len);
}

boolean I_MakeDir(char *name)
{
	BPTR lock;
	boolean rc=false;

	if ((lock=Lock(name,ACCESS_READ)))
	{
		UnLock(lock);
		rc=true;
	} else {
		if ((lock=CreateDir(name)))
		{
			UnLock(lock);
			rc=true;
		}
	}
	
	return rc;
}

void *mymalloc(unsigned long size)
{
	void *rc;
	BOOL doubletry=FALSE;
	
	struct EasyStruct es;
	
	while((rc=malloc(size)) == NULL)
	{
		if (IntuitionBase)
		{
			es.es_StructSize=sizeof(struct EasyStruct);
			es.es_Flags=0;
			es.es_Title="DoomAttack";
			es.es_TextFormat="Out of memory! Allocation of %ld bytes failed!";
			es.es_GadgetFormat="Try again!|Quit DoomAttack";

			if (EasyRequest(NULL,&es,NULL,(int)size) == 0)
			{
				I_ErrorMem();
			}
		} else {
			I_ErrorMem();
		}
		doubletry=TRUE;
	}
	
	if (doubletry)
	{
		if (screen) ScreenToFront(screen);
		if (window) ActivateWindow(window);
	}

	return rc;
}

void CalcVisibleSize(struct Screen *scr,WORD *width, WORD *height)
{
	struct TagItem cmtags[]={VTAG_VIEWPORTEXTRA_GET,0,
									 TAG_DONE};

	struct Rectangle myrect;
	struct ViewPortExtra *vpe;
	ULONG displayid;
	WORD x,y;

	if(!VideoControl(scr->ViewPort.ColorMap,cmtags))
	{
		vpe=(struct ViewPortExtra *)cmtags[0].ti_Data;
	} else {
		vpe=scr->ViewPort.ColorMap->cm_vpe;
		if(!vpe)
		{
			vpe=(struct ViewPortExtra *)GfxLookUp(&scr->ViewPort);
		}
	}

	if(vpe && ((displayid=GetVPModeID(&scr->ViewPort)) != INVALID_ID))
	{
		QueryOverscan(displayid,&myrect,OSCAN_TEXT);

		x=vpe->DisplayClip.MaxX - vpe->DisplayClip.MinX + 1;
		y=vpe->DisplayClip.MaxY - vpe->DisplayClip.MinY + 1;

		if(x < (myrect.MaxX - myrect.MinX + 1))
		{
			x=myrect.MaxX - myrect.MinX + 1;
		}
		
		if(y < (myrect.MaxY - myrect. MinY + 1))
		{
			y=myrect.MaxY - myrect.MinY + 1;
		}
		
	} else {

		x=scr->Width;
		y=scr->Height;

	}
	
	*width = x;
	*height = y;

}

void CalcCenteredWin(struct Screen *scr,WORD winwidth,WORD winheight,WORD *left,WORD *top)
{
	WORD x,y;

	CalcVisibleSize(scr,&x,&y);
	
	x=(x - winwidth) / 2;
	y=(y - winheight) / 2;

	x -= scr->LeftEdge;
	y -= scr->TopEdge;

	if (x<0) x=0;
	if (y<0) y=0;
	
	*left=x;
	*top=y;
}

BOOL GetFile(STRPTR title,char *initial,char *dest)
{
	struct Screen *scr;
	struct FileRequester *FileReq;
	WORD wx,wy,sx,sy;
	BOOL rc=FALSE;

	if (!AslBase) AslBase=OpenLibrary("asl.library",39);
		
	if (AslBase)
	{
		if ((scr=LockPubScreen(NULL)))
		{
			CalcVisibleSize(scr,&sx,&sy);
			sx = sx / 2;
			sy = sy * 3 / 4;
			CalcCenteredWin(scr,sx,sy,&wx,&wy);

			if ((FileReq=AllocAslRequest(ASL_FileRequest,NULL)))
			{
				ScreenToFront(scr);
				rc=AslRequestTags(FileReq,ASLFR_TitleText,(int)title,
												  ASLFR_Screen,(int)scr,
												  ASLFR_InitialLeftEdge,wx,
												  ASLFR_InitialTopEdge,wy,
												  ASLFR_InitialWidth,sx,
												  ASLFR_InitialHeight,sy,
												  ASLFR_InitialFile,(int)initial,
												  ASLFR_DoPatterns,TRUE,
												  ASLFR_InitialPattern,(int)"~(#?.info)",
												  ASLFR_DoSaveMode,TRUE,
												  TAG_DONE);
				if (rc)
				{
					strcpy(dest,FileReq->fr_Drawer);
					AddPart(dest,FileReq->fr_File,300);
				}
				FreeAslRequest(FileReq);
				ScreenToFront(screen);
			}
			UnlockPubScreen(NULL,scr);
		}
		CloseLibrary(AslBase);AslBase=NULL;
	}
	return rc;
}

ULONG GetScreenMode(char *title)
{
	struct DisplayMode mydisplaymode2;
	struct DisplayMode mydisplaymode3;
	struct DisplayMode mydisplaymode4;
	struct DisplayMode mydisplaymode5;
	struct List mydisplaylist;

	struct Screen *scr;
	struct ScreenModeRequester *req;
	ULONG rc=INVALID_ID;
	ULONG propertymask;
	WORD wx,wy,sx,sy;

	mydisplaymode2=mydisplaymode;
	mydisplaymode3=mydisplaymode;
	mydisplaymode4=mydisplaymode;
	mydisplaymode5=mydisplaymode;

	mydisplaymode.dm_Node.ln_Name=" *** WINDOW ON WORKBENCH SCREEN ***";
	mydisplaymode2.dm_Node.ln_Name=" *** WINDOW ON DEF. PUB. SCREEN ***";
	mydisplaymode3.dm_Node.ln_Name="GRAFFITI: PAL";
	mydisplaymode4.dm_Node.ln_Name="GRAFFITI: NTSC";
	mydisplaymode5.dm_Node.ln_Name="  ";
	mydisplaymode5.dm_Node.ln_Name[1] = (char)160;
	
	mydisplaymode2.dm_DimensionInfo.Header.DisplayID=0xFFFFFFFD;
	mydisplaymode3.dm_DimensionInfo.Header.DisplayID=0xFFFFFFFC;
	mydisplaymode4.dm_DimensionInfo.Header.DisplayID=0xFFFFFFFB;
			
	NewList(&mydisplaylist);
	AddTail(&mydisplaylist,(struct Node *)&mydisplaymode);
	AddTail(&mydisplaylist,(struct Node *)&mydisplaymode2);
	AddTail(&mydisplaylist,(struct Node *)&mydisplaymode3);
	AddTail(&mydisplaylist,(struct Node *)&mydisplaymode4);
	AddTail(&mydisplaylist,(struct Node *)&mydisplaymode5);

	if (!AslBase) AslBase=OpenLibrary("asl.library",39);
	
	if (AslBase)
	{
		if ((req=AllocAslRequest(ASL_ScreenModeRequest,NULL)))
		{
			if ((scr=LockPubScreen(0)))
			{
				CalcVisibleSize(scr,&sx,&sy);
				sx = sx / 2;
				sy = sy * 3 / 4;
				CalcCenteredWin(scr,sx,sy,&wx,&wy);
				
				propertymask=DIPF_IS_EXTRAHALFBRITE|DIPF_IS_DUALPF|DIPF_IS_HAM;
				rc=BestModeID(BIDTAG_NominalWidth,SCREENWIDTH,
							  BIDTAG_NominalHeight,REALSCREENHEIGHT,
							  BIDTAG_Depth,8,
							  BIDTAG_DIPFMustNotHave,propertymask,
							  TAG_DONE);
	
				if (AslRequestTags(req,ASLSM_TitleText,(int)title,
									ASLSM_Screen,(int)scr,
									ASLSM_InitialLeftEdge,wx,
									ASLSM_InitialTopEdge,wy,
									ASLSM_InitialWidth,sx,
									ASLSM_InitialHeight,sy,
								   ASLSM_InitialDisplayID,rc,
								   ASLSM_MinWidth,SCREENWIDTH,
								   ASLSM_MinHeight,SCREENHEIGHT,
								   ASLSM_MinDepth,8,
								   ASLSM_MaxDepth,8,
								   ASLSM_PropertyFlags,0,
								   ASLSM_PropertyMask,propertymask,
								   ASLSM_CustomSMList,(int)&mydisplaylist,
								   TAG_DONE))
				{
					rc=req->sm_DisplayID;
				}
				UnlockPubScreen(0,scr);
			}
			FreeAslRequest(req);
		}
		CloseLibrary(AslBase);AslBase=NULL;
	}

	return rc;
}

extern UWORD ActQualifier;

void I_IFFScreenShot(char *name,byte *data,int width,int height,byte *palette)
{
	struct IFFHandle *myiffhandle;
	struct BitMapHeader bmh;
	byte *buffer,*datapos;
	byte *realpalette,*bp;
	char s[300];

	ULONG modeid;
	int i;

	if (ActQualifier & (IEQUALIFIER_LSHIFT|IEQUALIFIER_RSHIFT))
	{
		strcpy(s,"SCREENSHOT.IFF");
		if (!(GetFile("Save Screenshot",s,s))) return;
		name=s;
	}

	if (!IFFParseBase)
	{
		IFFParseBase=OpenLibrary("iffparse.library",39);
		if (!IFFParseBase) return;
	}
	
	if ((realpalette=AllocVec(256*3,MEMF_ANY|MEMF_PUBLIC)))
	{
		bp=realpalette;
		for(i=0;i<256;i++)
		{
			*bp++ = gammatable[usegamma][*palette++];
			*bp++ = gammatable[usegamma][*palette++];
			*bp++ = gammatable[usegamma][*palette++];
		}
		
		if ((buffer=AllocVec(width*3,MEMF_ANY|MEMF_PUBLIC|MEMF_CLEAR)))
		{
			if ((myiffhandle=AllocIFF()))
			{
				if ((myiffhandle->iff_Stream=Open(name,MODE_NEWFILE)))
				{
					InitIFFasDOS(myiffhandle);
					if (!OpenIFF(myiffhandle,IFFF_WRITE))
					{
						/* Push brauch Pop, auch wenn fehlgeschlagen!?!?!? */
						PushChunk(myiffhandle,ID_ILBM,ID_FORM,IFFSIZE_UNKNOWN);
	
							/* BMHD */
	
							PushChunk(myiffhandle,ID_ILBM,ID_BMHD,sizeof(bmh));
							
							bmh.bmh_Width=width;
							bmh.bmh_Height=height;
							bmh.bmh_Left=0;
							bmh.bmh_Top=0;
							bmh.bmh_Depth=8;
							bmh.bmh_Masking=0;
							bmh.bmh_Compression=0;
							bmh.bmh_Pad=128;	/*	BMHDF_CMAPOK */
							bmh.bmh_Transparent=0;
							bmh.bmh_XAspect=11;
							bmh.bmh_YAspect=11;
							bmh.bmh_PageWidth=width;
							bmh.bmh_PageHeight=height;
							WriteChunkBytes(myiffhandle,&bmh,sizeof(bmh));
	
							PopChunk(myiffhandle);
							
							/* CAMG */
	
							if ((modeid=GetVPModeID(viewport)) != INVALID_ID)
							{
								PushChunk(myiffhandle,ID_ILBM,ID_CAMG,sizeof(modeid));
								WriteChunkBytes(myiffhandle,&modeid,sizeof(modeid));
								PopChunk(myiffhandle);
							}
							
							/* CMAP */
							
							PushChunk(myiffhandle,ID_ILBM,ID_CMAP,768);
							WriteChunkBytes(myiffhandle,realpalette,768);
							PopChunk(myiffhandle);
							
							/* ANNO */
							

							bp="Created with DoomAttack (C) 1997-1998 by Georg Steger\0";
							PushChunk(myiffhandle,ID_ILBM,MAKE_ID('A','N','N','O'),IFFSIZE_UNKNOWN);
							WriteChunkBytes(myiffhandle,bp,strlen(bp)+1);
							PopChunk(myiffhandle);

							/* BODY */
	
							PushChunk(myiffhandle,ID_ILBM,ID_BODY,IFFSIZE_UNKNOWN);
							datapos=data;
							for(i=0;i<height;i++)
							{
								Chunky2Planar(datapos,buffer,width,8);
								WriteChunkBytes(myiffhandle,buffer,width);
								datapos+=width;
							}
							PopChunk(myiffhandle);
	
						PopChunk(myiffhandle);
	
						CloseIFF(myiffhandle);

					} /* if (!OpenIFF(myiffhandle,IFFF_WRITE)) */
					Close(myiffhandle->iff_Stream);

				} /* if ((myiffhandle->iff_Stream=Open(name,MODE_NEWFILE))) */
				FreeIFF(myiffhandle);

			} /* if ((myiffhandle=AllocIFF())) */
			FreeVec(buffer);

		} /* if ((buffer=AllocVec(width*3,MEMF_ANY|MEMF_PUBLIC|MEMF_CLEAR))) */
		FreeVec(realpalette);

	} /* if ((realpalette=AllocVec(256*3,MEMF_ANY|MEMF_PUBLIC))) */
}

char *I_GetCommentConfig(void)
{
	char s[40],*rc=0;
	struct FileInfoBlock *fib;
	BPTR olddir,lock;
	
	if ((fib=AllocDosObject(DOS_FIB,0)))
	{
		olddir=CurrentDir(GetProgramDir());
		if (GetProgramName(s,40))
		{
			if ((lock=Lock(s,SHARED_LOCK)))
			{
				if (Examine(lock,fib))
				{
					if (fib->fib_Comment)
					{
						if (fib->fib_Comment[0] == '#')
						{
							if ((rc=(char *)malloc(strlen(fib->fib_Comment)+5)))
							{
								strcpy(rc,fib->fib_Comment+1);
							}
						}
					}
				}
				
				UnLock(lock);
			}
		}
		CurrentDir(olddir);

		FreeDosObject(DOS_FIB,fib);
	}
	
	return rc;
}

void I_SetDoomVar(char **var)
{
	char	s[257];
	BOOL ok=FALSE;
	BPTR lk;
	
	if ((lk=Lock("PROGDIR:",ACCESS_READ)))
	{
		if (NameFromLock(lk,s,256))
		{
			*var = malloc(strlen(s)+2);
			strcpy(*var,s);
			ok=TRUE;
		}
		UnLock(lk);
	}
	
	if (!ok)
	{
		*var=malloc(10);
		strcpy(*var,"PROGDIR:");
	}
	
	SetVar("DOOMHOME",*var,strlen(*var),LV_VAR|GVF_GLOBAL_ONLY);
}

boolean I_Exists(char *file)
{
	BPTR lk;
	boolean rc=false;

	if ((lk=Lock(file,ACCESS_READ)))
	{
		rc=true;
		UnLock(lk);
	}
	
	return rc;
}

boolean I_CheckBreak(void)
{
	return (SetSignal(0,SIGBREAKF_CTRL_C) & SIGBREAKF_CTRL_C) ? true : false;
}

struct DEHInit
{
	APTR	dehi_things;
	APTR	dehi_sounds;
	APTR	dehi_frames;
	APTR	dehi_weapons;
	APTR	dehi_maxammo;
	APTR	dehi_perammo;
	APTR	dehi_sprites;
	
	LONG	dehi_NUMTHINGS;
	LONG	dehi_NUMSOUNDS;
	LONG	dehi_NUMFRAMES;
	LONG	dehi_NUMWEAPONS;
	LONG	dehi_NUMAMMOS;
	LONG	dehi_NUMSPRITES;
};

struct DEHPlugin
{
	APTR	deh_nextseg;
	WORD	deh_moveq;
	WORD	deh_rts;
	char	deh_id[4];
	long	(*deh_DeHackEd)(char *file,struct DEHInit *i);
};

static LONG oldfpustate;

void I_DeHackEd(char *file)
{
	struct DEHInit init;
	struct DEHPlugin *deh;
	char *pluginname="DoomAttackSupport/plugin/DeHackEd.plugin";
	BPTR	seg;
	long	rc;

	if (!(seg=LoadSeg(pluginname)))
	{
		printf("I_DeHackED: Could not open DeHackEd plugin (\"%s\")\n",pluginname);
	} else {
		deh=(struct DEHPlugin *)(BADDR(seg));

		init.dehi_things = (APTR)mobjinfo;
		init.dehi_sounds = (APTR)S_sfx;
		init.dehi_frames = (APTR)states;
		init.dehi_weapons = (APTR)weaponinfo;
		init.dehi_maxammo = (APTR)maxammo;
		init.dehi_perammo = (APTR)clipammo;
		init.dehi_sprites = (APTR)sprnames;
	
		init.dehi_NUMTHINGS = NUMMOBJTYPES;	
		init.dehi_NUMSOUNDS = 109;
		init.dehi_NUMFRAMES = NUMSTATES;
		init.dehi_NUMWEAPONS = NUMWEAPONS;
		init.dehi_NUMAMMOS = NUMAMMO;
		init.dehi_NUMSPRITES = NUMSPRITES;

		#ifdef version060
		__asm __volatile
		(
			"move.l	d0,-(sp) \n\t"
			"fmove.l	fpcr,d0 \n\t"
			"move.l	d0,_oldfpustate \n\t"
			"move.l	(sp)+,d0"
			:
			:
			: "memory"
		);
		#endif
			
		deh->deh_DeHackEd(file,&init);
			
		#ifdef version060
		__asm __volatile
		(
			"move.l	d0,-(sp) \n\t"
			"move.l	_oldfpustate,d0 \n\t"
			"fmove.l	d0,fpcr \n\t"
			"move.l	(sp)+,d0"
			:
			:
			: "memory"
		);
		#endif
		
		UnLoadSeg(seg);
	}
}

