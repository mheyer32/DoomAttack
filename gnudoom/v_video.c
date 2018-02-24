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
/*	Gamma correction LUT stuff.*/
/*	Functions to draw patches (by post) directly to screen.*/
/*	Functions to blit a block to the screen.*/
/**/
/*-----------------------------------------------------------------------------*/


static const char rcsid[] = "$Id: v_video.c,v 1.5 1997/02/03 22:45:13 b1 Exp $";


#include "i_system.h"
#include "r_local.h"

#include "doomdef.h"
#include "doomdata.h"

#include "m_bbox.h"
#include "m_swap.h"

#include "v_video.h"

#ifdef V_DrawPatchDirect
#undef V_DrawPatchDirect
#endif

#ifdef V_DrawPatchDirect2
#undef V_DrawPatchDirect2
#endif

/* Each screen is [SCREENWIDTH*SCREENHEIGHT]; */
byte*				screens[5];	
 
int				dirtybox[4]; 



/* Now where did these came from?*/
byte gammatable[5][256] =
{
    {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,
     17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,
     33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,
     49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,
     65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,
     81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,
     97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,
     113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,
     128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,
     144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,
     160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,
     176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,
     192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,
     208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,
     224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,
     240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255},

    {2,4,5,7,8,10,11,12,14,15,16,18,19,20,21,23,24,25,26,27,29,30,31,
     32,33,34,36,37,38,39,40,41,42,44,45,46,47,48,49,50,51,52,54,55,
     56,57,58,59,60,61,62,63,64,65,66,67,69,70,71,72,73,74,75,76,77,
     78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,
     99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,
     115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,129,
     130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,
     146,147,148,148,149,150,151,152,153,154,155,156,157,158,159,160,
     161,162,163,163,164,165,166,167,168,169,170,171,172,173,174,175,
     175,176,177,178,179,180,181,182,183,184,185,186,186,187,188,189,
     190,191,192,193,194,195,196,196,197,198,199,200,201,202,203,204,
     205,205,206,207,208,209,210,211,212,213,214,214,215,216,217,218,
     219,220,221,222,222,223,224,225,226,227,228,229,230,230,231,232,
     233,234,235,236,237,237,238,239,240,241,242,243,244,245,245,246,
     247,248,249,250,251,252,252,253,254,255},

    {4,7,9,11,13,15,17,19,21,22,24,26,27,29,30,32,33,35,36,38,39,40,42,
     43,45,46,47,48,50,51,52,54,55,56,57,59,60,61,62,63,65,66,67,68,69,
     70,72,73,74,75,76,77,78,79,80,82,83,84,85,86,87,88,89,90,91,92,93,
     94,95,96,97,98,100,101,102,103,104,105,106,107,108,109,110,111,112,
     113,114,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,
     129,130,131,132,133,133,134,135,136,137,138,139,140,141,142,143,144,
     144,145,146,147,148,149,150,151,152,153,153,154,155,156,157,158,159,
     160,160,161,162,163,164,165,166,166,167,168,169,170,171,172,172,173,
     174,175,176,177,178,178,179,180,181,182,183,183,184,185,186,187,188,
     188,189,190,191,192,193,193,194,195,196,197,197,198,199,200,201,201,
     202,203,204,205,206,206,207,208,209,210,210,211,212,213,213,214,215,
     216,217,217,218,219,220,221,221,222,223,224,224,225,226,227,228,228,
     229,230,231,231,232,233,234,235,235,236,237,238,238,239,240,241,241,
     242,243,244,244,245,246,247,247,248,249,250,251,251,252,253,254,254,
     255},

    {8,12,16,19,22,24,27,29,31,34,36,38,40,41,43,45,47,49,50,52,53,55,
     57,58,60,61,63,64,65,67,68,70,71,72,74,75,76,77,79,80,81,82,84,85,
     86,87,88,90,91,92,93,94,95,96,98,99,100,101,102,103,104,105,106,107,
     108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,
     125,126,127,128,129,130,131,132,133,134,135,135,136,137,138,139,140,
     141,142,143,143,144,145,146,147,148,149,150,150,151,152,153,154,155,
     155,156,157,158,159,160,160,161,162,163,164,165,165,166,167,168,169,
     169,170,171,172,173,173,174,175,176,176,177,178,179,180,180,181,182,
     183,183,184,185,186,186,187,188,189,189,190,191,192,192,193,194,195,
     195,196,197,197,198,199,200,200,201,202,202,203,204,205,205,206,207,
     207,208,209,210,210,211,212,212,213,214,214,215,216,216,217,218,219,
     219,220,221,221,222,223,223,224,225,225,226,227,227,228,229,229,230,
     231,231,232,233,233,234,235,235,236,237,237,238,238,239,240,240,241,
     242,242,243,244,244,245,246,246,247,247,248,249,249,250,251,251,252,
     253,253,254,254,255},

    {16,23,28,32,36,39,42,45,48,50,53,55,57,60,62,64,66,68,69,71,73,75,76,
     78,80,81,83,84,86,87,89,90,92,93,94,96,97,98,100,101,102,103,105,106,
     107,108,109,110,112,113,114,115,116,117,118,119,120,121,122,123,124,
     125,126,128,128,129,130,131,132,133,134,135,136,137,138,139,140,141,
     142,143,143,144,145,146,147,148,149,150,150,151,152,153,154,155,155,
     156,157,158,159,159,160,161,162,163,163,164,165,166,166,167,168,169,
     169,170,171,172,172,173,174,175,175,176,177,177,178,179,180,180,181,
     182,182,183,184,184,185,186,187,187,188,189,189,190,191,191,192,193,
     193,194,195,195,196,196,197,198,198,199,200,200,201,202,202,203,203,
     204,205,205,206,207,207,208,208,209,210,210,211,211,212,213,213,214,
     214,215,216,216,217,217,218,219,219,220,220,221,221,222,223,223,224,
     224,225,225,226,227,227,228,228,229,229,230,230,231,232,232,233,233,
     234,234,235,235,236,236,237,237,238,239,239,240,240,241,241,242,242,
     243,243,244,244,245,245,246,246,247,247,248,248,249,249,250,250,251,
     251,252,252,253,254,254,255,255}
};



int	usegamma;
extern int	REALSCREENHEIGHT;
int	HALFREALSCREENHEIGHT;
extern int	MEDRES,HIGHRES;

static boolean medres;

/**/
/* V_MarkRect */
/* */
void
V_MarkRect
( int		x,
  int		y,
  int		width,
  int		height ) 
{ 
    M_AddToBox (dirtybox, x, y); 
    M_AddToBox (dirtybox, x+width-1, y+height-1); 
} 
 

/**/
/* V_CopyRect */
/* */

#if 0
void V_CopyRect
( int		srcx,
  int		srcy,
  int		srcscrn,
  int		width,
  int		height,
  int		destx,
  int		desty,
  int		destscrn ) 
{ 
    byte*	src;
    byte*	dest; 
	 
#ifdef RANGECHECK 
    if (srcx<0
	||srcx+width >SCREENWIDTH
	|| srcy<0
	|| srcy+height>REALSCREENHEIGHT 
	||destx<0||destx+width >SCREENWIDTH
	|| desty<0
	|| desty+height>REALSCREENHEIGHT 
	|| (unsigned)srcscrn>4
	|| (unsigned)destscrn>4)
    {
	I_Error ("Bad V_CopyRect");
    }
#endif 
    V_MarkRect (destx, desty, width, height); 
	 
    src = screens[srcscrn]+SCREENWIDTH*srcy+srcx; 
    dest = screens[destscrn]+SCREENWIDTH*desty+destx; 


	__asm __volatile
	(
		"sub	#1,%3 \n\t"
		"sub	#1,%2 \n\t"
		"move	#320-1,d3 \n\t"
		"sub	%2,d3 \n"
		
		"1: move	%2,d2 \n"
		"2: move.b	(%0)+,(%1)+ \n\t"
		"dbf	d2,2b \n\t"
		"add.w	d3,%0 \n\t"
		"add.w	d3,%1 \n\t"
		"dbf	%3,1b \n\t"
		
		:
		: "a" (src), "a" (dest), "d" (width), "d" (height)
		: "d2", "d3", "memory"
	);

#if 0
    for ( ; height>0 ; height--) 
    { 
	memcpy (dest, src, width); 
	src += SCREENWIDTH; 
	dest += SCREENWIDTH; 
    }
#endif

} 
 
#endif

/**/
/* V_DrawPatch*/
/* Masks a column based masked pic to the screen. */
/**/

#if 0
void V_DrawPatch
( int		x,
  int		y,
  int		scrn,
  patch_t*	patch ) 
{ 

    int		count;
    int		col; 
    column_t*	column; 
    byte*	desttop;
    byte*	dest;
    byte*	source; 
    int		w; 
	 
    y -= SHORT(patch->topoffset); 
    x -= SHORT(patch->leftoffset); 
#ifdef RANGECHECK 
    if (x<0
	||x+SHORT(patch->width) >SCREENWIDTH
	|| y<0
	|| y+SHORT(patch->height)>REALSCREENHEIGHT 
	|| (unsigned)scrn>4)
    {
      fprintf( stderr, "Patch at %d,%d exceeds LFB\n", x,y );
      /* No I_Error abort - what is up with TNT.WAD?*/
      fprintf( stderr, "V_DrawPatch: bad patch (ignored)\n");
      return;
    }
#endif 
 
    if (!scrn)
	V_MarkRect (x, y, SHORT(patch->width), SHORT(patch->height)); 

/*    col = 0; */
    desttop = screens[scrn]+y*SCREENWIDTH+x; 
	
	__asm __volatile
	(
		"move.w	#320,d3 \n\t"			/* screenwidth */
		"moveq	#0,d2 \n\t"					/* col = 0 */
		"move	(%0),d1 \n\t"				/* d1 = w = SHORT(patch->width) */
		"ror.w	#8,d1 \n\t"
		"sub	#1,d1 \n\t"
		"jmi	9f \n"
		
		"1: move.l	%0,a2 \n\t"				/* a2 = patch */
		"move.l	8(%0,d2.w*4),d0 \n\t"		/* patch-> columnofs[col] */
		"ror.w	#8,d0 \n\t"					/* LONG */
		"swap	d0 \n\t"
		"ror.w	#8,d0 \n\t"
		"add.l	d0,a2 \n"					/* column = a2 = patch + colum ... */
		
		"2: cmp.b	#255,(a2) \n\t"			/* while column->topdelta != 0xff */
		"jeq	5f \n\t"
		
		"lea	3(a2),a0 \n\t"				/* source = column + 3 */
		"move.l	%1,a1 \n\t"					/* a1 = dest = desttop + ... */
		"moveq	#0,d0 \n\t"
		"move.b	(a2),d0 \n\t"				/* topdelta */
		"lsl.l	#6,d0 \n\t"					/* x 64        (a x 320 = a x 64 + a x 256) */
		"add.l	d0,a1 \n\t"
		"lsl.l	#2,d0 \n\t"					/* x 256 (8-6=2) */
		"add.l	d0,a1 \n\t"
		"moveq	#0,d0 \n\t"
		"move.b	1(a2),d0 \n\t"				/* count = column->length */
		"sub	#1,d0 \n\t"
		"jmi	4f \n"
		
		"3:		move.b	(a0)+,(a1) \n\t"
		"add.w	d3,a1 \n\t"
		"dbf	d0,3b \n"
		
		"4:	moveq	#0,d0 \n\t"				/* column += column->length + 4 */
		"move.b	1(a2),d0 \n\t"
		"addq.l	#4,d0 \n\t"
		"add.l	d0,a2 \n\t"
		"jra	2b \n"

		"5: addq	#1,d2 \n\t"
		"addq.l	#1,%1 \n\t"
		"dbf	d1,1b \n"
		
		"9: "
		
		:
		: "a" (patch), "a" (desttop)
		: "d0", "d1", "d2", "d3", "a0", "a1", "a2", "memory"
	);

#if 0
    w = SHORT(patch->width); 

    for ( ; col<w ; x++, col++, desttop++)
    { 
	column = (column_t *)((byte *)patch + LONG(patch->columnofs[col])); 
 
	/* step through the posts in a column */
	while (column->topdelta != 0xff ) 
	{ 
	    source = (byte *)column + 3; 
	    dest = desttop + column->topdelta*SCREENWIDTH; 
	    count = column->length; 
			 
	    while (count--) 
	    { 
		*dest = *source++; 
		dest += SCREENWIDTH; 
	    } 
	    column = (column_t *)(  (byte *)column + column->length 
				    + 4 ); 
	} 
    }
#endif

} 
#endif

/**/
/* V_DrawPatchFlipped */
/* Masks a column based masked pic to the screen.*/
/* Flips horizontally, e.g. to mirror face.*/
/**/
#if 0
void V_DrawPatchFlipped
( int		x,
  int		y,
  int		scrn,
  patch_t*	patch ) 
{ 

    int		count;
    int		col; 
    column_t*	column; 
    byte*	desttop;
    byte*	dest;
    byte*	source; 
    int		w; 
	 
    y -= SHORT(patch->topoffset); 
    x -= SHORT(patch->leftoffset); 
#ifdef RANGECHECK 
    if (x<0
	||x+SHORT(patch->width) >SCREENWIDTH
	|| y<0
	|| y+SHORT(patch->height)>REALSCREENHEIGHT 
	|| (unsigned)scrn>4)
    {
      fprintf( stderr, "Patch origin %d,%d exceeds LFB\n", x,y );
      I_Error ("Bad V_DrawPatch in V_DrawPatchFlipped");
    }
#endif 
 
    if (!scrn)
	V_MarkRect (x, y, SHORT(patch->width), SHORT(patch->height)); 

/*    col = 0; */
    desttop = screens[scrn]+y*SCREENWIDTH+x; 
	 
	__asm __volatile
	(
		"move.w	#320,d4 \n\t"			/* screenwidth */
		"moveq	#0,d2 \n\t"					/* col = 0 */
		"move	(%0),d1 \n\t"				/* d1 = w = SHORT(patch->width) */
		"ror.w	#8,d1 \n\t"
		"sub	#1,d1 \n\t"
		"move	d1,d3 \n\t"					/* d3 = w-1 */
		"jmi	9f \n"
		
		"1: move.l	%0,a2 \n\t"				/* a2 = patch */
		"move	d3,d0 \n\t"					/* w-1-col */
		"sub	d2,d0 \n\t"
		"move.l	8(%0,d0.w*4),d0 \n\t"		/* patch-> columnofs[w-1-col] */
		"ror.w	#8,d0 \n\t"					/* LONG */
		"swap	d0 \n\t"
		"ror.w	#8,d0 \n\t"
		"add.l	d0,a2 \n"					/* column = a2 = patch + colum ... */
		
		"2: cmp.b	#255,(a2) \n\t"			/* while column->topdelta != 0xff */
		"jeq	5f \n\t"
		
		"lea	3(a2),a0 \n\t"				/* source = column + 3 */
		"move.l	%1,a1 \n\t"					/* a1 = dest = desttop + ... */
		"moveq	#0,d0 \n\t"
		"move.b	(a2),d0 \n\t"				/* topdelta */
		"lsl.l	#6,d0 \n\t"					/* x 64        (a x 320 = a x 64 + a x 256) */
		"add.l	d0,a1 \n\t"
		"lsl.l	#2,d0 \n\t"					/* x 256 (8-6=2) */
		"add.l	d0,a1 \n\t"
		"moveq	#0,d0 \n\t"
		"move.b	1(a2),d0 \n\t"				/* count = column->length */
		"sub	#1,d0 \n\t"
		"jmi	4f \n"
		
		"3:		move.b	(a0)+,(a1) \n\t"
		"add.w	d4,a1 \n\t"
		"dbf	d0,3b \n"
		
		"4:	moveq	#0,d0 \n\t"				/* column += column->length + 4 */
		"move.b	1(a2),d0 \n\t"
		"addq.l	#4,d0 \n\t"
		"add.l	d0,a2 \n\t"
		"jra	2b \n"

		"5: addq	#1,d2 \n\t"
		"addq.l	#1,%1 \n\t"
		"dbf	d1,1b \n"
		
		"9: "
		
		:
		: "a" (patch), "a" (desttop)
		: "d0", "d1", "d2", "d3", "d4", "a0", "a1", "a2", "memory"
	);

#if 0
    w = SHORT(patch->width); 

    for ( ; col<w ; x++, col++, desttop++) 
    { 
	column = (column_t *)((byte *)patch + LONG(patch->columnofs[w-1-col])); 
 
	/* step through the posts in a column */
	while (column->topdelta != 0xff ) 
	{ 
	    source = (byte *)column + 3; 
	    dest = desttop + column->topdelta*SCREENWIDTH; 
	    count = column->length; 
			 
	    while (count--) 
	    { 
		*dest = *source++; 
		dest += SCREENWIDTH; 
	    } 
	    column = (column_t *)(  (byte *)column + column->length 
				    + 4 ); 
	} 
    }			 
#endif
} 
#endif

#if 0
void V_DrawPatch2
( int		x,
  int		y,
  int		scrn,
  patch_t*	patch ) 
{ 

    int		count;
    int		col; 
    column_t*	column; 
    byte*	desttop;
    byte*	dest;
    byte*	source; 
    int		w; 
	 
    y -= SHORT(patch->topoffset); 
    x -= SHORT(patch->leftoffset); 
#ifdef RANGECHECK 
    if (x<0
	||x+SHORT(patch->width) >SCREENWIDTH
	|| y<0
	|| y+SHORT(patch->height)>REALSCREENHEIGHT 
	|| (unsigned)scrn>4)
    {
      fprintf( stderr, "Patch at %d,%d exceeds LFB\n", x,y );
      /* No I_Error abort - what is up with TNT.WAD?*/
      fprintf( stderr, "V_DrawPatch: bad patch (ignored)\n");
      return;
    }
#endif 
 
    if (!scrn)
	V_MarkRect (x, y, SHORT(patch->width), SHORT(patch->height)); 

/*    col = 0; */
    desttop = screens[scrn]+(y << medres)*SCREENWIDTH+x; 
	
	if (!medres)
	{
		__asm __volatile
		(
			"move.w	#320,d3 \n\t"			/* screenwidth */
			"moveq	#0,d2 \n\t"					/* col = 0 */
			"move	(%0),d1 \n\t"				/* d1 = w = SHORT(patch->width) */
			"ror.w	#8,d1 \n\t"
			"sub	#1,d1 \n\t"
			"jmi	9f \n"
			
			"1: move.l	%0,a2 \n\t"				/* a2 = patch */
			"move.l	8(%0,d2.w*4),d0 \n\t"		/* patch-> columnofs[col] */
			"ror.w	#8,d0 \n\t"					/* LONG */
			"swap	d0 \n\t"
			"ror.w	#8,d0 \n\t"
			"add.l	d0,a2 \n"					/* column = a2 = patch + colum ... */
			
			"2: cmp.b	#255,(a2) \n\t"			/* while column->topdelta != 0xff */
			"jeq	5f \n\t"
			
			"lea	3(a2),a0 \n\t"				/* source = column + 3 */
			"move.l	%1,a1 \n\t"					/* a1 = dest = desttop + ... */
			"moveq	#0,d0 \n\t"
			"move.b	(a2),d0 \n\t"				/* topdelta */
			"lsl.l	#6,d0 \n\t"					/* x 64        (a x 320 = a x 64 + a x 256) */
			"add.l	d0,a1 \n\t"
			"lsl.l	#2,d0 \n\t"					/* x 256 (8-6=2) */
			"add.l	d0,a1 \n\t"
			"moveq	#0,d0 \n\t"
			"move.b	1(a2),d0 \n\t"				/* count = column->length */
			"sub	#1,d0 \n\t"
			"jmi	4f \n"
			
			"3:		move.b	(a0)+,(a1) \n\t"
			"add.w	d3,a1 \n\t"
			"dbf	d0,3b \n"
			
			"4:	moveq	#0,d0 \n\t"				/* column += column->length + 4 */
			"move.b	1(a2),d0 \n\t"
			"addq.l	#4,d0 \n\t"
			"add.l	d0,a2 \n\t"
			"jra	2b \n"
	
			"5: addq	#1,d2 \n\t"
			"addq.l	#1,%1 \n\t"
			"dbf	d1,1b \n"
			
			"9: "
			
			:
			: "a" (patch), "a" (desttop)
			: "d0", "d1", "d2", "d3", "a0", "a1", "a2", "memory"
		);
	} else {
		__asm __volatile
		(
			"move.w	#320,d3 \n\t"			/* screenwidth */
			"moveq	#0,d2 \n\t"					/* col = 0 */
			"move	(%0),d1 \n\t"				/* d1 = w = SHORT(patch->width) */
			"ror.w	#8,d1 \n\t"
			"sub	#1,d1 \n\t"
			"jmi	9f \n"
			
			"1: move.l	%0,a2 \n\t"				/* a2 = patch */
			"move.l	8(%0,d2.w*4),d0 \n\t"		/* patch-> columnofs[col] */
			"ror.w	#8,d0 \n\t"					/* LONG */
			"swap	d0 \n\t"
			"ror.w	#8,d0 \n\t"
			"add.l	d0,a2 \n"					/* column = a2 = patch + colum ... */
			
			"2: cmp.b	#255,(a2) \n\t"			/* while column->topdelta != 0xff */
			"jeq	5f \n\t"
			
			"lea	3(a2),a0 \n\t"				/* source = column + 3 */
			"move.l	%1,a1 \n\t"					/* a1 = dest = desttop + ... */
			"moveq	#0,d0 \n\t"
			"move.b	(a2),d0 \n\t"				/* topdelta */
			"lsl.l	#7,d0 \n\t"					/* x 64        (a x 640 = a x 128 + a x 512) */
			"add.l	d0,a1 \n\t"
			"lsl.l	#2,d0 \n\t"					/* x 512 (8-6=2) */
			"add.l	d0,a1 \n\t"
			"moveq	#0,d0 \n\t"
			"move.b	1(a2),d0 \n\t"				/* count = column->length */
			"subq.w	#1,d0 \n\t"
			"jmi	4f \n"
			
			"3:		move.b	(a0),(a1) \n\t"
			"add.w	d3,a1 \n\t"
			"move.b	(a0)+,(a1) \n\t"
			"add.w	d3,a1 \n\t"
			"dbf	d0,3b \n"
			
			"4:	moveq	#0,d0 \n\t"				/* column += column->length + 4 */
			"move.b	1(a2),d0 \n\t"
			"addq.l	#4,d0 \n\t"
			"add.l	d0,a2 \n\t"
			"jra	2b \n"
	
			"5: addq	#1,d2 \n\t"
			"addq.l	#1,%1 \n\t"
			"dbf	d1,1b \n"
			
			"9: "
			
			:
			: "a" (patch), "a" (desttop)
			: "d0", "d1", "d2", "d3", "a0", "a1", "a2", "memory"
		);
	}

#if 0
    w = SHORT(patch->width); 

    for ( ; col<w ; x++, col++, desttop++)
    { 
	column = (column_t *)((byte *)patch + LONG(patch->columnofs[col])); 
 
	/* step through the posts in a column */
	while (column->topdelta != 0xff ) 
	{ 
	    source = (byte *)column + 3; 
	    dest = desttop + column->topdelta*SCREENWIDTH; 
	    count = column->length; 
			 
	    while (count--) 
	    { 
		*dest = *source++; 
		dest += SCREENWIDTH; 
	    } 
	    column = (column_t *)(  (byte *)column + column->length 
				    + 4 ); 
	} 
    }
#endif

} 
#endif

/**/
/* V_DrawPatchFlipped */
/* Masks a column based masked pic to the screen.*/
/* Flips horizontally, e.g. to mirror face.*/
/**/

#if 0
void V_DrawPatchFlipped2
( int		x,
  int		y,
  int		scrn,
  patch_t*	patch ) 
{ 

    int		count;
    int		col; 
    column_t*	column; 
    byte*	desttop;
    byte*	dest;
    byte*	source; 
    int		w; 
	 
    y -= SHORT(patch->topoffset); 
    x -= SHORT(patch->leftoffset); 
#ifdef RANGECHECK 
    if (x<0
	||x+SHORT(patch->width) >SCREENWIDTH
	|| y<0
	|| y+SHORT(patch->height)>REALSCREENHEIGHT 
	|| (unsigned)scrn>4)
    {
      fprintf( stderr, "Patch origin %d,%d exceeds LFB\n", x,y );
      I_Error ("Bad V_DrawPatch in V_DrawPatchFlipped");
    }
#endif 
 
    if (!scrn)
	V_MarkRect (x, y, SHORT(patch->width), SHORT(patch->height)); 

/*    col = 0; */
    desttop = screens[scrn]+(y << medres)*SCREENWIDTH+x; 
	 
	if (!medres)
	{
		__asm __volatile
		(
			"move.w	#320,d4 \n\t"			/* screenwidth */
			"moveq	#0,d2 \n\t"					/* col = 0 */
			"move	(%0),d1 \n\t"				/* d1 = w = SHORT(patch->width) */
			"ror.w	#8,d1 \n\t"
			"sub	#1,d1 \n\t"
			"move	d1,d3 \n\t"					/* d3 = w-1 */
			"jmi	9f \n"
			
			"1: move.l	%0,a2 \n\t"				/* a2 = patch */
			"move	d3,d0 \n\t"					/* w-1-col */
			"sub	d2,d0 \n\t"
			"move.l	8(%0,d0.w*4),d0 \n\t"		/* patch-> columnofs[w-1-col] */
			"ror.w	#8,d0 \n\t"					/* LONG */
			"swap	d0 \n\t"
			"ror.w	#8,d0 \n\t"
			"add.l	d0,a2 \n"					/* column = a2 = patch + colum ... */
			
			"2: cmp.b	#255,(a2) \n\t"			/* while column->topdelta != 0xff */
			"jeq	5f \n\t"
			
			"lea	3(a2),a0 \n\t"				/* source = column + 3 */
			"move.l	%1,a1 \n\t"					/* a1 = dest = desttop + ... */
			"moveq	#0,d0 \n\t"
			"move.b	(a2),d0 \n\t"				/* topdelta */
			"lsl.l	#6,d0 \n\t"					/* x 64        (a x 320 = a x 64 + a x 256) */
			"add.l	d0,a1 \n\t"
			"lsl.l	#2,d0 \n\t"					/* x 256 (8-6=2) */
			"add.l	d0,a1 \n\t"
			"moveq	#0,d0 \n\t"
			"move.b	1(a2),d0 \n\t"				/* count = column->length */
			"sub	#1,d0 \n\t"
			"jmi	4f \n"
			
			"3:		move.b	(a0)+,(a1) \n\t"
			"add.w	d4,a1 \n\t"
			"dbf	d0,3b \n"
			
			"4:	moveq	#0,d0 \n\t"				/* column += column->length + 4 */
			"move.b	1(a2),d0 \n\t"
			"addq.l	#4,d0 \n\t"
			"add.l	d0,a2 \n\t"
			"jra	2b \n"
	
			"5: addq	#1,d2 \n\t"
			"addq.l	#1,%1 \n\t"
			"dbf	d1,1b \n"
			
			"9: "
			
			:
			: "a" (patch), "a" (desttop)
			: "d0", "d1", "d2", "d3", "d4", "a0", "a1", "a2", "memory"
		);

	} else {
		__asm __volatile
		(
			"move.w	#320,d4 \n\t"			/* screenwidth */
			"moveq	#0,d2 \n\t"					/* col = 0 */
			"move	(%0),d1 \n\t"				/* d1 = w = SHORT(patch->width) */
			"ror.w	#8,d1 \n\t"
			"sub	#1,d1 \n\t"
			"move	d1,d3 \n\t"					/* d3 = w-1 */
			"jmi	9f \n"
			
			"1: move.l	%0,a2 \n\t"				/* a2 = patch */
			"move	d3,d0 \n\t"					/* w-1-col */
			"sub	d2,d0 \n\t"
			"move.l	8(%0,d0.w*4),d0 \n\t"		/* patch-> columnofs[w-1-col] */
			"ror.w	#8,d0 \n\t"					/* LONG */
			"swap	d0 \n\t"
			"ror.w	#8,d0 \n\t"
			"add.l	d0,a2 \n"					/* column = a2 = patch + colum ... */
			
			"2: cmp.b	#255,(a2) \n\t"			/* while column->topdelta != 0xff */
			"jeq	5f \n\t"
			
			"lea	3(a2),a0 \n\t"				/* source = column + 3 */
			"move.l	%1,a1 \n\t"					/* a1 = dest = desttop + ... */
			"moveq	#0,d0 \n\t"
			"move.b	(a2),d0 \n\t"				/* topdelta */
			"lsl.l	#7,d0 \n\t"					/* x 64        (a x 320 = a x 64 + a x 256) */
			"add.l	d0,a1 \n\t"
			"lsl.l	#2,d0 \n\t"					/* x 256 (8-6=2) */
			"add.l	d0,a1 \n\t"
			"moveq	#0,d0 \n\t"
			"move.b	1(a2),d0 \n\t"				/* count = column->length */
			"sub	#1,d0 \n\t"
			"jmi	4f \n"
			
			"3:		move.b	(a0),(a1) \n\t"
			"add.w	d4,a1 \n\t"
			"move.b	(a0)+,(a1) \n\t"
			"add.w	d4,a1 \n\t"
			"dbf	d0,3b \n"
			
			"4:	moveq	#0,d0 \n\t"				/* column += column->length + 4 */
			"move.b	1(a2),d0 \n\t"
			"addq.l	#4,d0 \n\t"
			"add.l	d0,a2 \n\t"
			"jra	2b \n"
	
			"5: addq	#1,d2 \n\t"
			"addq.l	#1,%1 \n\t"
			"dbf	d1,1b \n"
			
			"9: "
			
			:
			: "a" (patch), "a" (desttop)
			: "d0", "d1", "d2", "d3", "d4", "a0", "a1", "a2", "memory"
		);
	}

#if 0
    w = SHORT(patch->width); 

    for ( ; col<w ; x++, col++, desttop++) 
    { 
	column = (column_t *)((byte *)patch + LONG(patch->columnofs[w-1-col])); 
 
	/* step through the posts in a column */
	while (column->topdelta != 0xff ) 
	{ 
	    source = (byte *)column + 3; 
	    dest = desttop + column->topdelta*SCREENWIDTH; 
	    count = column->length; 
			 
	    while (count--) 
	    { 
		*dest = *source++; 
		dest += SCREENWIDTH; 
	    } 
	    column = (column_t *)(  (byte *)column + column->length 
				    + 4 ); 
	} 
    }			 
#endif
} 
 
#endif

#if 0
/**/
/* V_DrawPatchDirect*/
/* Draws directly to the screen on the pc. */
/**/
void V_DrawPatchDirect
( int		x,
  int		y,
  int		scrn,
  patch_t*	patch ) 
{

    int		count;
    int		col; 
    column_t*	column; 
    byte*	desttop;
    byte*	dest;
    byte*	source; 
    int		w; 
	 
    V_DrawPatch (x,y,scrn, patch); 

#ifdef 0
    y -= SHORT(patch->topoffset); 
    x -= SHORT(patch->leftoffset); 

#ifdef RANGECHECK 
    if (x<0
	||x+SHORT(patch->width) >SCREENWIDTH
	|| y<0
	|| y+SHORT(patch->height)>REALSCREENHEIGHT 
	|| (unsigned)scrn>4)
    {
	I_Error ("Bad V_DrawPatchDirect");
    }
#endif 
 
    /*	V_MarkRect (x, y, SHORT(patch->width), SHORT(patch->height)); */
    desttop = destscreen + y*SCREENWIDTH/4 + (x>>2); 
	 
    w = SHORT(patch->width); 
    for ( col = 0 ; col<w ; col++) 
    { 
	outp (SC_INDEX+1,1<<(x&3)); 
	column = (column_t *)((byte *)patch + LONG(patch->columnofs[col])); 
 
	/* step through the posts in a column */
	 
	while (column->topdelta != 0xff ) 
	{ 
	    source = (byte *)column + 3; 
	    dest = desttop + column->topdelta*SCREENWIDTH/4; 
	    count = column->length; 
 
	    while (count--) 
	    { 
		*dest = *source++; 
		dest += SCREENWIDTH/4; 
	    } 
	    column = (column_t *)(  (byte *)column + column->length 
				    + 4 ); 
	} 
	if ( ((++x)&3) == 0 ) 
	    desttop++;	/* go to next byte, not next plane */
    }
#endif

} 

#endif

/**/
/* V_DrawBlock*/
/* Draw a linear block of pixels into the view buffer.*/
/**/

#if 0
void V_DrawBlock
( int		x,
  int		y,
  int		scrn,
  int		width,
  int		height,
  byte*		src ) 
{ 
    byte*	dest; 
	 
#ifdef RANGECHECK 
    if (x<0
	||x+width >SCREENWIDTH
	|| y<0
	|| y+height>REALSCREENHEIGHT 
	|| (unsigned)scrn>4 )
    {
	I_Error ("Bad V_DrawBlock");
    }
#endif 
 
    V_MarkRect (x, y, width, height); 
 
    dest = screens[scrn] + y*SCREENWIDTH+x; 


	__asm __volatile
	(
		"sub	#1,%3 \n\t"
		"sub	#1,%2 \n\t"
		"move	#320-1,d3 \n\t"
		"sub	%2,d3 \n"
		
		"1: move	%2,d2 \n"
		"2: move.b	(%0)+,(%1)+ \n\t"
		"dbf	d2,2b \n\t"
		"add.w	d3,%1 \n\t"
		"dbf	%3,1b \n\t"
		
		:
		: "a" (src), "a" (dest), "d" (width), "d" (height)
		: "d2", "d3", "memory"
	);
	
#if 0
    while (height--) 
    { 
	memcpy (dest, src, width); 
	src += width; 
	dest += SCREENWIDTH; 
    } 

#endif
} 
 

#endif
/**/
/* V_GetBlock*/
/* Gets a linear block of pixels from the view buffer.*/
/**/

/* hallohallo: nicht benutzt!?!?!? */

#if 0
void V_GetBlock
( int		x,
  int		y,
  int		scrn,
  int		width,
  int		height,
  byte*		dest ) 
{ 
    byte*	src; 
	 
#ifdef RANGECHECK 
    if (x<0
	||x+width >SCREENWIDTH
	|| y<0
	|| y+height>REALSCREENHEIGHT 
	|| (unsigned)scrn>4 )
    {
	I_Error ("Bad V_DrawBlock");
    }
#endif 
 
    src = screens[scrn] + y*SCREENWIDTH+x; 


	__asm __volatile
	(
		"sub	#1,%3 \n\t"
		"sub	#1,%2 \n\t"
		"move	#320-1,d3 \n\t"
		"sub	%2,d3 \n"

		"1: move	%2,d2 \n"
		"2: move.b	(%0)+,(%1)+ \n\t"
		"dbf	d2,2b \n\t"
		"add.w	d3,%0 \n\t"
		"dbf	%3,1b \n\t"
		
		:
		: "a" (src), "a" (dest), "d" (width), "d" (height)
		: "d2", "d3", "memory"
	);

#if 0
    while (height--) 
    { 
	memcpy (dest, src, width); 
	src += SCREENWIDTH; 
	dest += width; 
    }
#endif

} 


#endif

/**/
/* V_Init*/
/* */

void V_Init (void) 
{ 
    int		i,o;
    byte*	base;
	size_t  m;

    /* stick these in low dos memory on PCs*/
	/* hallohallohallo: added some security space at the beginning and at the end */

	if ((REALSCREENHEIGHT > MAXSCREENHEIGHT) ||
		 ((REALSCREENWIDTH != 320) && (REALSCREENWIDTH != 640)) ||
		 (REALSCREENWIDTH > 320 && REALSCREENHEIGHT < 400))
	{
		I_Error("Resolution %ld x %ld is not supported!",REALSCREENWIDTH,REALSCREENHEIGHT);
	}

    base = I_AllocLow (REALSCREENWIDTH*REALSCREENHEIGHT*4 + 8*REALSCREENWIDTH);

    for (i=0 ; i<4 ; i++)
	screens[i] = base + i*REALSCREENWIDTH*REALSCREENHEIGHT + 4*REALSCREENWIDTH;
	
	if ((REALSCREENHEIGHT >= 400) && (REALSCREENWIDTH == 320))
	{
		MEDRES=medres=true;
	} else if (REALSCREENWIDTH>320)
	{
		HIGHRES=true;
	}
	
	HALFREALSCREENHEIGHT = (REALSCREENHEIGHT >> medres);
	
	o=0;
	for(i=0;i<REALSCREENHEIGHT;i++)
	{
		yoffsettable[i] = o;
		o += REALSCREENWIDTH;
	}
	
}


