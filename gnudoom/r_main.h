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
/* DESCRIPTION:*/
/*	System specific interface stuff.*/
/**/
/*-----------------------------------------------------------------------------*/


#ifndef __R_MAIN__
#define __R_MAIN__

#include "d_player.h"
#include "r_data.h"


#ifdef __GNUG__
#pragma interface
#endif


/**/
/* POV related.*/
/**/
extern fixed_t		viewcos;
extern fixed_t		viewsin;

extern int		viewwidth;
extern int		viewheight;
extern int		viewwindowx;
extern int		viewwindowy;



extern int		centerx;
extern int		centery;

extern fixed_t		centerxfrac;
extern fixed_t		centeryfrac;
extern fixed_t		projection;

extern int		validcount;

extern int		linecount;
extern int		loopcount;


/**/
/* Lighting LUT.*/
/* Used for z-depth cuing per column/row,*/
/*  and other lighting effects (sector ambient, flash).*/
/**/

/* Lighting constants.*/
/* Now why not 32 levels here?*/
#define LIGHTLEVELS	        16
#define LIGHTSEGSHIFT	         4

#define MAXLIGHTSCALE		48
#define LIGHTSCALESHIFT		12
#define MAXLIGHTZ	       128
#define LIGHTZSHIFT		20

extern lighttable_t*	scalelight[LIGHTLEVELS][MAXLIGHTSCALE];
extern lighttable_t*	scalelightfixed[MAXLIGHTSCALE];
extern lighttable_t*	zlight[LIGHTLEVELS][MAXLIGHTZ];

extern int		extralight;
extern lighttable_t*	fixedcolormap;


/* Number of diminishing brightness levels.*/
/* There a 0-31, i.e. 32 LUT in the COLORMAP lump.*/
#define NUMCOLORMAPS		32


/* Blocky/low detail mode.*/
/*B remove this?*/
/*  0 = high, 1 = low*/
extern	int		detailshift;	


/**/
/* Function pointers to switch refresh/drawing functions.*/
/* Used to select shadow mode etc.*/
/**/
extern void		(*colfunc) (void);
extern void		(*basecolfunc) (void);
extern void		(*fuzzcolfunc) (void);
extern void		(*transcolfunc) (void);
/* No shadow effects on floors.*/
extern void		(*spanfunc) (void);


/**/
/* Utility functions.*/

/* !!! not used: now in r_engine.asm */
extern __inline int R_PointOnSide
( fixed_t	x,
  fixed_t	y,
  node_t*	node )
{
	register int _res __asm("d0");
	register fixed_t d0 __asm("d0") = x;
	register fixed_t d1 __asm("d1") = y;
	register node_t *a0 __asm("a0") = node;
	
	__asm __volatile
	(
	"tst.l	8(a0) \n\t"
	"jne		1f \n\t"

	"cmp.l	(a0),d0 \n\t"
	"jgt		2f \n\t"

	"tst.l	12(a0) \n\t"
	"jgt	3f \n\t"
	"moveq	#0,d0 \n\t"
	"jra		9f \n"

	"3: moveq	#1,d0 \n\t"
	"jra		9f \n"

	"2: tst.l	12(a0) \n\t"
	"jlt		4f \n\t"
	"moveq	#0,d0 \n\t"
	"jra		9f \n"
	
	"4: moveq	#1,d0 \n\t"
	"jra		9f \n"

	"1: tst.l	12(a0) \n\t"
	"jne		5f \n\t"
	
	"cmp.l	4(a0),d1 \n\t"
	"jgt	6f \n\t"
	
	"tst.l	8(a0) \n\t"
	"jlt	7f \n\t"
	"moveq	#0,d0 \n\t"
	"jra	9f \n"
	
	"7: moveq	#1,d0 \n\t"
	"jra		9f \n"
	
	"6: tst.l	8(a0) \n\t"
	"jgt		8f \n\t"
	"moveq	#0,d0 \n\t"
	"jra		9f \n"
	
	"8: moveq	#1,d0 \n\t"
	"jra		9f \n"

	
	"5: movem.l	d2/d3,-(sp) \n\t"

	"sub.l	(a0),d0 \n\t"
	"sub.l	4(a0),d1 \n\t"
	
	"move.l	d0,d2 \n\t"
	"eor.l	d1,d2 \n\t"
	"move.l	8(a0),d3 \n\t"
	"eor.l	d3,d2 \n\t"
	"move.l	12(a0),d3 \n\t"
	"eor.l	d3,d2 \n\t"
	"jpl	3f \n\t"
	
	"eor.l	d3,d0 \n\t"
	"jpl		1f \n\t"
	
	"movem.l	(sp)+,d2/d3 \n\t"
	"moveq	#1,d0 \n\t"
	"jra		9f \n"

	"1: movem.l	(sp)+,d2/d3 \n\t"
	"moveq	#0,d0 \n\t"
	"jra		9f\n"

	"3: move	12(a0),d2 \n\t"
	"ext.l	d2 \n\t"


#ifndef version060
	"muls.l	d2,d2:d0 \n\t"
	"move	d2,d0 \n\t"
	"swap	d0 \n\t"
#else
	"fmove.l	d0,fp0 \n\t"
	"fmul.l		d2,fp0 \n\t"
	"fmul.x	fp7,fp0 \n\t"
/*	"fintrz.x	fp0,fp0 \n\t"*/
	"fmove.l	fp0,d0 \n\t"
#endif

	"move	8(a0),d2 \n\t"
	"ext.l	d2 \n\t"

#ifndef version060
	"muls.l	d2,d2:d1 \n\t"
	"move	d2,d1 \n\t"
	"swap	d1 \n\t"
#else
	"fmove.l	d1,fp0 \n\t"
	"fmul.l		d2,fp0 \n\t"
	"fmul.x	fp7,fp0 \n\t"
/*	"fintrz.x	fp0,fp0 \n\t"*/
	"fmove.l	fp0,d1 \n\t"
#endif

	"cmp.l	d0,d1 \n\t"
	"jlt		2f \n\t"

	"movem.l	(sp)+,d2/d3 \n\t"
	"moveq	#1,d0 \n\t"
	"jra		9f \n"
	
	"2: movem.l	(sp)+,d2/d3 \n\t"
	"moveq	#0,d0 \n"
	
	"9:"
	
	: "=r" (_res)
	: "r" (d0), "r" (d1), "r" (a0)
	: "d0", "d1"
	);
	
	return _res;
}


extern __inline int R_PointOnSegSide
( fixed_t	x,
  fixed_t	y,
  seg_t*	line )
 
{
	register int _res __asm("d0");

	register fixed_t d0 __asm("d0") = x;
	register fixed_t d1 __asm("d1") = y;
	register seg_t *a0 __asm("a0") = line;
	
	__asm __volatile
	(
	/* d4=lx d5=ly */

	"move.l	(a0),a1 \n\t"
	"movem.l (a1),d4-d5 \n\t"
	"move.l 4(a0),a1 \n\t"
	"movem.l (a1),d6-d7 \n\t"

	/* d6=ldx d7 = ldy */
	
	"sub.l	d4,d6 \n\t"
	"sub.l	d5,d7 \n\t"

	/* if (!ldx) */

	"tst.l	d6 \n\t"
	"jne		1f \n\t"

	/* if (x <= lx) */

	"cmp.l	d4,d0 \n\t"
	"jgt		2f \n\t"

	"tst.l	d7 \n\t"
	"jgt	3f \n\t"
	"moveq	#0,d0 \n\t"
	"jra		9f \n"

	"3: moveq	#1,d0 \n\t"
	"jra		9f \n"

	"2: tst.l	d7 \n\t"
	"jlt		4f \n\t"
	"moveq	#0,d0 \n\t"
	"jra		9f \n"
	
	"4: moveq	#1,d0 \n\t"
	"jra		9f \n"

	"1: tst.l	d7 \n\t"
	"jne		5f \n\t"
	
	"cmp.l	d5,d1 \n\t"
	"jgt	6f \n\t"
	
	"tst.l	d6 \n\t"
	"jlt	7f \n\t"
	"moveq	#0,d0 \n\t"
	"jra	9f \n"
	
	"7: moveq	#1,d0 \n\t"
	"jra		9f \n"
	
	"6: tst.l	d6 \n\t"
	"jgt		8f \n\t"
	"moveq	#0,d0 \n\t"
	"jra		9f \n"
	
	"8: moveq	#1,d0 \n\t"
	"jra		9f \n"

	
	"5: movem.l	d2/d3,-(sp) \n\t"

	"sub.l	d4,d0 \n\t"
	"sub.l	d5,d1 \n\t"
	
	"move.l	d0,d2 \n\t"
	"eor.l	d1,d2 \n\t"
	"eor.l	d6,d2 \n\t"
	"eor.l	d7,d2 \n\t"
	"jpl	3f \n\t"
	
	"eor.l	d7,d0 \n\t"
	"jpl		1f \n\t"
	
	"movem.l	(sp)+,d2/d3 \n\t"
	"moveq	#1,d0 \n\t"
	"jra		9f \n"

	"1: movem.l	(sp)+,d2/d3 \n\t"
	"moveq	#0,d0 \n\t"
	"jra		9f\n"

	"3: swap	d7 \n\t"
	"ext.l	d7 \n\t"

#ifndef version060
	"muls.l	d7,d7:d0 \n\t"
	"move	d7,d0 \n\t"
	"swap	d0 \n\t"
#else
	"fmove.l	d7,fp0 \n\t"
	"fmul.l		d0,fp0 \n\t"
	"fmul.x	fp7,fp0 \n\t"
/*	"fintrz.x	fp0,fp0 \n\t"*/
	"fmove.l	fp0,d0 \n\t"
#endif

	"swap 	d6 \n\t"
	"ext.l	d6 \n\t"

#ifndef version060
	"muls.l	d6,d6:d1 \n\t"
	"move	d6,d1 \n\t"
	"swap	d1 \n\t"
#else
	"fmove.l	d6,fp0 \n\t"
	"fmul.l		d1,fp0 \n\t"
	"fmul.x	fp7,fp0 \n\t"
/*	"fintrz.x	fp0,fp0 \n\t"*/
	"fmove.l	fp0,d1 \n\t"
#endif

	"cmp.l	d0,d1 \n\t"
	"jlt		2f \n\t"

	"movem.l	(sp)+,d2/d3 \n\t"
	"moveq	#1,d0 \n\t"
	"jra		9f \n"
	
	"2: movem.l	(sp)+,d2/d3 \n\t"
	"moveq	#0,d0 \n"
	
	"9:"
	
	: "=r" (_res)
	: "r" (d0), "r" (d1), "r" (a0)
	: "d0", "d1", "d4", "d5", "d6", "d7", "a1"
	);
	
	
	return _res;
}

angle_t
R_PointToAngle
( fixed_t	x,
  fixed_t	y );

extern __inline angle_t
R_PointToAngle2
( fixed_t	x1,
  fixed_t	y1,
  fixed_t	x2,
  fixed_t	y2 )
{
    viewx = x1;
    viewy = y1;
    
    return R_PointToAngle (x2, y2);
}


extern __inline fixed_t
R_PointToDist
( fixed_t	x,
  fixed_t	y )
{
	register fixed_t _res __asm ("d0");
	register fixed_t d0 __asm("d0") = x;
	register fixed_t d1 __asm("d1") = y;


	__asm __volatile
	(
	
	"sub.l	_viewx,d0 \n\t"
	"jpl		1f \n\t"
	
	"neg.l	d0 \n"
	
	"1: sub.l	_viewy,d1 \n"
	"jpl		2f \n\t"
	
	"neg.l	d1 \n"
	
	"2: cmp.l	d0,d1 \n\t"
	"jlt		3f \n\t"
	
	"exg	d0,d1 \n"
	
	"3: tst.l d0 \n\t"
	"jne		4f \n\t"
	"moveq	#0,d0 \n\t"
	"jra		9f \n"

	"4:\n\t"
	
#ifndef version060
	"swap	d1 \n\t"
	"move.w	d1,d2 \n\t"
	"ext.l	d2 \n\t"
	"clr.w	d1 \n\t"
	"divs.l	d0,d2:d1 \n\t"
#else
	"fmove.l d1,fp0 \n\t"
	"fdiv.l	d0,fp0 \n\t"
	"fmul.x fp6,fp0 \n\t"
/*	"fintrz.x  fp0 \n\t"*/
	"fmove.l	fp0,d1 \n\t"
#endif

	"asrl	#5,d1 \n\t"
	
	"lea		_tantoangle,a0 \n\t"
	"move.l	(a0,d1.l*4),d1 \n\t"
	"add.l	#0x40000000,d1 \n\t"
	"swap   d1\n\t"
	"asr.w	#3,d1 \n\t"
	"ext.l	d1 \n\t"
	
	"lea		_finesine,a0 \n\t"
	"move.l	(a0,d1.l*4),d1 \n\t"
	
#ifndef version060
	"swap	d0 \n\t"
	"move	d0,d2 \n\t"
	"ext.l	d2 \n\t"
	"clr.w	d0 \n\t"
	"divs.l	d1,d2:d0 \n\t"
#else
	"fmove.l d0,fp0 \n\t"
	"fdiv.l	d1,fp0 \n\t"
	"fmul.x  fp6,fp0 \n\t"
/*	"fintrz.x  fp0 \n\t"*/
	"fmove.l	fp0,d0 \n\t"
#endif

	"9:"
	
	: "=r" (_res)
	: "r" (d0), "r" (d1)
#ifndef version060
	: "d0", "d1", "d2", "a0");
#else
	: "d0", "d1", "d2", "a0", "fp0");
#endif

	return _res;
}



extern __inline fixed_t R_ScaleFromGlobalAngle (angle_t visangle)
{
	register fixed_t _res __asm("d0");
	register angle_t d0 __asm("d0") = visangle;
	
	__asm __volatile
	(
		/* d1=angleb */
		
		"move.l	d0,d1 \n\t"
		"sub.l	_rw_normalangle,d1 \n\t"
		"move.l	#0x40000000,d2 \n\t"
		"add.l	d2,d1 \n\t"
		
		/* d0=anglea */

		"sub.l	_viewangle,d0 \n\t"
		"add.l	d2,d0 \n\t"
		
		"lea		_finesine,a0 \n\t"

		/* d0=sinea */

		"moveq	#19,d2 \n\t"
		"lsr.l	d2,d0 \n\t"

		"move.l	(a0,d0.l*4),d0 \n\t"
		
		/* d1=sineb */

		"lsr.l	d2,d1 \n\t"
		
		"move.l	(a0,d1.l*4),d1 \n\t"
		
		/* d1=num */
		
#ifndef version060
		"muls.l	_projection,d2:d1 \n\t"
		"move	d2,d1 \n\t"
		"swap	d1 \n\t"
#else
		"fmove.l	_projection,fp0 \n\t"
		"fmul.l		d1,fp0 \n\t"
		"fmul.x	fp7,fp0 \n\t"
/*		"fintrz.x	fp0,fp0 \n\t"*/
		"fmove.l	fp0,d1 \n\t"
#endif

		"move.l _detailshift,d2 \n\t"
		"asl.l	d2,d1 \n\t"
		
		/* d0=den */

#ifndef version060
		"muls.l	_rw_distance,d2:d0 \n\t"
		"move	d2,d0 \n\t"
		"swap	d0 \n\t"
#else
		"fmove.l	_rw_distance,fp0 \n\t"
		"fmul.l		d0,fp0 \n\t"
		"fmul.x	fp7,fp0 \n\t"
/*		"fintrz.x	fp0,fp0 \n\t"*/
		"fmove.l	fp0,d0 \n\t"
#endif

		"move.l	d1,d2 \n\t"
		"swap	d2 \n\t"
		"ext.l	d2 \n\t"
		
		"cmp.l	d2,d0 \n\t"
		"jgt		1f \n\t"
		
		"moveq	#64,d0 \n\t"
		"swap	d0 \n\t"
		"jra	9f \n"
		
		"1:\n\t"
		
#ifndef version060
		"swap d1 \n\t"
		"move	d1,d2 \n\t"
		"ext.l	d2 \n\t"
		"clr.w	d1 \n\t"
		"divs.l	d0,d2:d1 \n\t"
#else
		"fmove.l d1,fp0 \n\t"
		"fdiv.l	d0,fp0 \n\t"
		"fmul.x  fp6,fp0 \n\t"
/*		"fintrz.x  fp0 \n\t"*/
		"fmove.l	fp0,d1 \n\t"
#endif

		"cmp.l	#255,d1 \n\t"
		"jgt	2f \n\t"
		"move.l	#256,d0 \n\t"
		"jra	9f \n"
		
		"2: move.l d1,d0 \n\t"
		"moveq	#64,d2 \n\t"
		"swap	d2 \n\t"
		"cmp.l	d2,d0 \n\t"
		"ble.s	9f \n\t"
		"move.l	d2,d0 \n"
		
		"9:"
		
		: "=r" (_res)
		: "r" (d0)
		: "d0", "d1", "d2", "a0"
		
	);
	
	return _res;
}

subsector_t*
R_PointInSubsector
( fixed_t	x,
  fixed_t	y );

void
R_AddPointToBox
( int		x,
  int		y,
  fixed_t*	box );



/**/
/* REFRESH - the actual rendering functions.*/
/**/

/* Called by G_Drawer.*/
void R_RenderPlayerView (player_t *player);

/* Called by startup code.*/
void R_Init (void);

void R_PatchEngine(void);

/* Called by M_Responder.*/
void R_SetViewSize (int blocks, int detail);

#endif
/*-----------------------------------------------------------------------------*/
/**/
/* $Log:$*/
/**/
/*-----------------------------------------------------------------------------*/
