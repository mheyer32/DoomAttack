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
/*	Refresh, visplane stuff (floor, ceilings).*/
/**/
/*-----------------------------------------------------------------------------*/


#ifndef __R_PLANE__
#define __R_PLANE__


#include "r_data.h"
#include "r_draw.h"

#ifdef __GNUG__
#pragma interface
#endif


/* Visplane related.*/
extern  short*		lastopening;


typedef void (*planefunction_t) (int top, int bottom);

extern planefunction_t	floorfunc;
extern planefunction_t	ceilingfunc_t;

extern short		floorclip[MAXSCREENWIDTH];
extern short		ceilingclip[MAXSCREENWIDTH];

/*extern fixed_t		yslope[MAXSCREENHEIGHT];*/
extern fixed_t realyslope[MAXSCREENHEIGHT*3];
extern fixed_t 	*yslope;
extern fixed_t		distscale[MAXSCREENWIDTH];

void R_InitPlanes(void);
void R_SetupPlanes(void);
void R_ClearPlanes (void);

/*
void
R_MapPlane
( int		y,
  int		x1,
  int		x2 );
*/

#ifdef 0
extern __inline void R_MapPlane(int y,int x1,int x2)
{
/*    angle_t	angle;
    fixed_t	distance;
    fixed_t	length;
    unsigned	index;*/
	
	ds_y = y;
	ds_x1 = x1;
	ds_x2 = x2;

	asm __volatile
	(
/*    if (planeheight != cachedheight[y])*/
		
		"lea		_cachedheight,a0 \n\t"
		"move.l	_planeheight,d0 \n\t"
		"cmp.l	(a0,%0.w*4),d0 \n\t"
		"jeq		1f \n\t"
		
		/*	cachedheight[y] = planeheight; */
		"move.l	d0,(a0,%0.w*4) \n\t"

		/*distance = cacheddistance[y] = FixedMul (planeheight, yslope[y]);*/
		"lea		_yslope,a0 \n\t"
		"move.l	(a0,%0.w*4),d1 \n\t"

#ifndef version060
		"muls.l	d1,d3:d0 \n\t"
		"move		d3,d0 \n\t"
		"swap		d0 \n\t"				/* d0 = distance */
#else
		"fmove.l	d0,fp0 \n\t"
		"fmul.l	d1,fp0 \n\t"
		"fmul.x	fp7,fp0 \n\t"
		"fmove.l	fp0,d0 \n\t"		/* d0 = distance */
#endif
		
		"lea		_cacheddistance,a0 \n\t"
		"move.l	d0,(a0,%0.w*4) \n\t"
		
		/* ds_xstep = cachedxstep[y] = FixedMul (distance,basexscale); */
		
#ifndef version060
		"move.l	_basexscale,d1 \n\t"
		"muls.l	d0,d3:d1 \n\t"
		"move		d3,d1 \n\t"
		"swap		d1 \n\t"				/* d1 = ds_xstep */
#else
		"fmove.l	_basexscale,fp0 \n\t"
		"fmul.l	d0,fp0 \n\t"
		"fmul.x	fp7,fp0 \n\t"
		"fmove.l	fp0,d1 \n\t"		/* d1 = ds_xstep */
#endif

		"lea		_cachedxstep,a0 \n\t"
		"move.l	d1,(a0,%0.w*4) \n\t"
		"move.l	d1,_ds_xstep \n\t"

		/*	ds_ystep = cachedystep[y] = FixedMul (distance,baseyscale); */

#ifndef version060
		"move.l	_baseyscale,d1 \n\t"
		"muls.l	d0,d3:d1 \n\t"
		"move		d3,d1 \n\t"
		"swap		d1 \n\t"				/* d1 = ds_ystep */
#else
		"fmove.l	_baseyscale,fp0 \n\t"
		"fmul.l	d0,fp0 \n\t"
		"fmul.x	fp7,fp0 \n\t"
		"fmove.l	fp0,d1 \n\t"		/* d1 = ds_ystep */
#endif

		"lea		_cachedystep,a0 \n\t"
		"move.l	d1,(a0,%0.w*4) \n\t"
		"move.l	d1,_ds_ystep \n\t"

		"jra		2f \n"

		/* === CACHED ==== */

		"1: \n\t"
		"lea		_cacheddistance,a0 \n\t"
		"move.l	(a0,%0.w*4),d0 \n\t"		/* d0 = distance */

		"lea		_cachedxstep,a0 \n\t"
		"move.l	(a0,%0.w*4),_ds_xstep \n\t"		/* ds_xstep */
		
		"lea		_cachedystep,a0 \n\t"
		"move.l	(a0,%0.w*4),_ds_ystep \n\t"		/* ds_ystep */
		
		/* ============== */
		
		"2: \n\t"
	   /* length = FixedMul (distance,distscale[x1]); */
	   
		"lea		_distscale,a0 \n\t"
		"move.l	(a0,%1.w*4),d1 \n\t"

#ifndef version060
		"muls.l	d0,d3:d1 \n\t"
		"move		d3,d1 \n\t"
		"swap		d1 \n\t"			/* d1 = length */
#else
		"fmove.l	d1,fp0 \n\t"
		"fmul.l	d0,fp0 \n\t"
		"fmul.x	fp7,fp0 \n\t"
		"fmove.l	fp0,d1 \n\t"	/* d1 = length */
#endif
		
	   /* angle = (viewangle + xtoviewangle[x1])>>19; */

		"lea		_xtoviewangle,a0 \n\t"
		"move.l	(a0,%1.w*4),d2 \n\t"
		"add.l	_viewangle,d2 \n\t"
		"moveq	#19,d3 \n\t"
		"lsr.l	d3,d2 \n\t"		/* d2 = angle */

	   /* ds_xfrac = viewx + FixedMul(finecosine[angle], length); */

		"move.l	_finecosine,a0 \n\t"
		"move.l	(a0,d2.w*4),d4 \n\t"

#ifndef version060
		"muls.l	d1,d3:d4 \n\t"
		"move		d3,d4 \n\t"
		"swap		d4 \n\t"
#else
		"fmove.l	d4,fp0 \n\t"
		"fmul.l	d1,fp0 \n\t"
		"fmul.x	fp7,fp0 \n\t"
		"fmove.l	fp0,d4 \n\t"
#endif

		"add.l	_viewx,d4 \n\t"
		"move.l	d4,_ds_xfrac \n\t"

    	/* ds_yfrac = -viewy - FixedMul(finesine[angle], length); */


		"lea		_finesine,a0 \n\t"		/* lea!!! */
		"move.l	(a0,d2.w*4),d4 \n\t"

#ifndef version060
		"muls.l	d1,d3:d4 \n\t"
		"move		d3,d4 \n\t"
		"swap		d4 \n\t"
#else
		"fmove.l	d4,fp0 \n\t"
		"fmul.l	d1,fp0 \n\t"
		"fmul.x	fp7,fp0 \n\t"
		"fmove.l	fp0,d4 \n\t"
#endif

		"add.l	_viewy,d4 \n\t"
		"neg.l	d4 \n\t"
		"move.l	d4,_ds_yfrac \n\t"
				
    	/* if (fixedcolormap)
			ds_colormap = fixedcolormap; */
			
		"move.l	_fixedcolormap,d4 \n\t"
		"jeq		1f \n\t"
		"move.l	d4,_ds_colormap \n\t"
		"jra		8f \n"
		
		"1: \n\t"
		/*	index = distance >> LIGHTZSHIFT; */
		"moveq	#20,d3 \n\t"
		"lsr.l	d3,d0 \n\t"
		/*	if (index >= MAXLIGHTZ ) index = MAXLIGHTZ-1;*/
		"moveq	#127,d3 \n\t"
		"and.w	d3,d0 \n\t"
		
		"move.l	_planezlight,a0 \n\t"
		"move.l	(a0,d0.w*4),_ds_colormap \n"
		
		"8: \n\t"

		"move.l	_spanfunc,a0 \n\t"
		"jsr		(a0) \n"

		: "=d" (y), "=d" (x1)
		: "0" (y), "1" (x1)
		: "d0", "d1", "d2", "d3", "d4", "a0", "a1", "memory"
	);
	
}
#endif

void
R_MakeSpans
( int		x,
  int		t1,
  int		b1,
  int		t2,
  int		b2 );

void R_DrawPlanes (void);

visplane_t*
R_FindPlane
( fixed_t	height,
  int		picnum,
  int		lightlevel );

visplane_t*
R_CheckPlane
( visplane_t*	pl,
  int		start,
  int		stop );



#endif
/*-----------------------------------------------------------------------------*/
/**/
/* $Log:$*/
/**/
/*-----------------------------------------------------------------------------*/
