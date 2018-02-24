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
/*	Here is a core component: drawing the floors and ceilings,*/
/*	 while maintaining a per column clipping list only.*/
/*	Moreover, the sky areas have to be determined.*/
/**/
/*-----------------------------------------------------------------------------*/


static const char
rcsid[] = "$Id: r_plane.c,v 1.4 1997/02/03 16:47:55 b1 Exp $";

#include <stdlib.h>

#include "i_system.h"
#include "z_zone.h"
#include "w_wad.h"

#include "doomdef.h"
#include "doomstat.h"

#include "r_local.h"
#include "r_sky.h"
#include "v_video.h"



planefunction_t		floorfunc;
planefunction_t		ceilingfunc;

/**/
/* opening*/
/**/

/* Here comes the obnoxious "visplane".*/

/* #define MAXVISPLANES	128 */

/*visplane_t		visplanes[MAXVISPLANES];*/
extern visplane_t	*visplanes;

extern visplane_t*		lastvisplane;
/*visplane_t*		floorplane;
visplane_t*		ceilingplane;*/
extern visplane_t*		maxvisplane;		/*exclusive!!*/


/* ?*/
#define MAXOPENINGS	MAXSCREENWIDTH*64
short			openings[MAXOPENINGS];
extern short*			lastopening;


/**/
/* Clip values are the solid pixel bounding the range.*/
/*  floorclip starts out SCREENHEIGHT*/
/*  ceilingclip starts out -1*/
/**/
short			floorclip[MAXSCREENWIDTH];
short			ceilingclip[MAXSCREENWIDTH];

/**/
/* spanstart holds the start of a plane span*/
/* initialized to 0 at start*/
/**/
int			spanstart[MAXSCREENHEIGHT];
int			spanstop[MAXSCREENHEIGHT];

/**/
/* texture mapping*/
/**/

/*
lighttable_t**		planezlight;
fixed_t			planeheight;
*/

extern fixed_t			basexscale;
extern fixed_t			baseyscale;


fixed_t			distscale[MAXSCREENWIDTH];
fixed_t			realyslope[MAXSCREENHEIGHT*3];
fixed_t			cachedheight[MAXSCREENHEIGHT];
fixed_t			cacheddistance[MAXSCREENHEIGHT];
fixed_t			cachedxstep[MAXSCREENHEIGHT];
fixed_t			cachedystep[MAXSCREENHEIGHT];

extern fixed_t *yslope;

int maxvisplanes;

/**/
/* R_InitPlanes*/
/* Only at game startup.*/
/**/

void *mymalloc(unsigned long size);

void R_SetupPlanes(void)
{
	visplanes = (visplane_t *)mymalloc(maxvisplanes*sizeof(visplane_t));
	memset(visplanes,0,maxvisplanes*sizeof(visplane_t));
}

void R_InitPlanes (void)
{
	maxvisplane=&visplanes[maxvisplanes];
  /* Doh!*/
}


/**/
/* R_MapPlane*/
/**/
/* Uses global vars:*/
/*  planeheight*/
/*  ds_source*/
/*  basexscale*/
/*  baseyscale*/
/*  viewx*/
/*  viewy*/
/**/
/* BASIC PRIMITIVE*/
/**/

#if 0
void R_MapPlane
( int		y,
  int		x1,
  int		x2 )
{
    angle_t	angle;
    fixed_t	distance;
    fixed_t	length;
    unsigned	index;
	
#ifdef RANGECHECK
    if (x2 < x1
	|| x1<0
	|| x2>=viewwidth
	|| (unsigned)y>viewheight)
    {
		/* hallohallohallo*/
		/* I_Error ("R_MapPlane: %i, %i at %i",x1,x2,y);*/
		return;
    }
#endif

    if (planeheight != cachedheight[y])
    {
	cachedheight[y] = planeheight;
	distance = cacheddistance[y] = FixedMul (planeheight, yslope[y]);
	ds_xstep = cachedxstep[y] = FixedMul (distance,basexscale);
	ds_ystep = cachedystep[y] = FixedMul (distance,baseyscale);
    }
    else
    {
	distance = cacheddistance[y];
	ds_xstep = cachedxstep[y];
	ds_ystep = cachedystep[y];
    }
	
    length = FixedMul (distance,distscale[x1]);
    angle = (viewangle + xtoviewangle[x1])>>ANGLETOFINESHIFT;
    ds_xfrac = viewx + FixedMul(finecosine[angle], length);
    ds_yfrac = -viewy - FixedMul(finesine[angle], length);

    if (fixedcolormap)
	ds_colormap = fixedcolormap;
    else
    {
	index = distance >> LIGHTZSHIFT;
	
	if (index >= MAXLIGHTZ )
	    index = MAXLIGHTZ-1;

	ds_colormap = planezlight[index];
    }
	
    ds_y = y;
    ds_x1 = x1;
    ds_x2 = x2;

    /* high or low detail*/
    spanfunc ();	
}
#endif

/**/
/* R_ClearPlanes*/
/* At begining of frame.*/
/**/
void R_ClearPlanes (void)
{
    int		i;
    angle_t	angle;
    
    /* opening / clipping determination*/

	__asm __volatile
	(
		"lea		_floorclip,a0 \n\t"
		"lea		_ceilingclip,a1 \n\t"
		
		"move.l	_viewwidth,d0 \n\t"
		"lsr.w	#4,d0 \n\t"			/* / 16 */
		"sub		#1,d0 \n\t"			/* d0 = loop counter */
		"move.l	_viewheight,d1 \n\t"
		"move		d1,d2 \n\t"
		"swap		d1 \n\t"
		"move		d2,d1 \n\t"

		"moveq	#-1,d2 \n"
		
		"1: \n\t"
		"move.l		d1,(a0)+ \n\t"
		"move.l		d1,(a0)+ \n\t"
		"move.l		d1,(a0)+ \n\t"
		"move.l		d1,(a0)+ \n\t"
		"move.l		d1,(a0)+ \n\t"
		"move.l		d1,(a0)+ \n\t"
		"move.l		d1,(a0)+ \n\t"
		"move.l		d1,(a0)+ \n\t"

		"move.l		d2,(a1)+ \n\t"
		"move.l		d2,(a1)+ \n\t"
		"move.l		d2,(a1)+ \n\t"
		"move.l		d2,(a1)+ \n\t"
		"move.l		d2,(a1)+ \n\t"
		"move.l		d2,(a1)+ \n\t"
		"move.l		d2,(a1)+ \n\t"
		"move.l		d2,(a1)+ \n\t"
		"dbf		d0,1b"
		
		: /* no result */
		: /* no input */
		: "a0", "a1", "d0", "d1", "d2", "memory"
	);
	
/*    for (i=0 ; i<viewwidth ; i++)
    {
	floorclip[i] = viewheight;
	ceilingclip[i] = -1;
    }*/

    lastvisplane = visplanes;
    lastopening = openings;
    
    /* texture calculation*/
    
    __asm __volatile
    (
    	"lea		_cachedheight,a0 \n\t"
    	"move.l	_viewheight,d0 \n\t"
    	"lsr.w	#3,d0 \n\t"			/* / 8 */
    	"sub		#1,d0 \n"
    	
    	"1: clr.l	(a0)+ \n\t"		/* 1 */
    	"clr.l	(a0)+ \n\t"			/* 2 */
    	"clr.l	(a0)+ \n\t"			/* 3 */
    	"clr.l	(a0)+ \n\t"			/* 4 */
    	"clr.l	(a0)+ \n\t"			/* 5 */
    	"clr.l	(a0)+ \n\t"			/* 6 */
    	"clr.l	(a0)+ \n\t"			/* 7 */
    	"clr.l	(a0)+ \n\t"			/* 8 */
    	"dbf		d0,1b"
    	
    	: /* no result */
    	: /* no input */
    	: "a0", "d0", "memory"
    );
    
/*    
    memset (cachedheight, 0, sizeof(cachedheight));
*/
    /* left to right mapping*/
    angle = (viewangle-ANG90)>>ANGLETOFINESHIFT;
	
    /* scale will be unit scale at SCREENWIDTH/2 distance*/
    basexscale = FixedDiv2 (finecosine[angle],centerxfrac);
    baseyscale = -FixedDiv2 (finesine[angle],centerxfrac);
}




/**/
/* R_FindPlane*/
/**/

#if 0
visplane_t* R_FindPlane
( fixed_t	height,
  int		picnum,
  int		lightlevel )
{
    visplane_t*	check;
	
    if (picnum == skyflatnum)
    {
	height = 0;			/* all skys map together*/
	lightlevel = 0;
    }
	
    for (check=visplanes; check<lastvisplane; check++)
    {
	if (height == check->height
	    && picnum == check->picnum
	    && lightlevel == check->lightlevel)
	{
	    break;
	}
    }
    
			
    if (check < lastvisplane)
	return check;
		
    if (lastvisplane - visplanes == MAXVISPLANES)
	I_Error ("R_FindPlane: no more visplanes");
		
    lastvisplane++;

    check->height = height;
    check->picnum = picnum;
    check->lightlevel = lightlevel;
    check->minx = SCREENWIDTH;
    check->maxx = -1;
    
    memset (check->top,0xff,sizeof(check->top));
		
    return check;
}
#endif

#if 0
/**/
/* R_CheckPlane*/
/**/
visplane_t* R_CheckPlane
( visplane_t*	pl,
  int		start,
  int		stop )
{
    int		intrl;
    int		intrh;
    int		unionl;
    int		unionh;
    int		x;
	
    if (start < pl->minx)
    {
	intrl = pl->minx;
	unionl = start;
    }
    else
    {
	unionl = pl->minx;
	intrl = start;
    }
	
    if (stop > pl->maxx)
    {
	intrh = pl->maxx;
	unionh = stop;
    }
    else
    {
	unionh = pl->maxx;
	intrh = stop;
    }

    for (x=intrl ; x<= intrh ; x++)
	if (pl->top[x] != 0xffff)
	    break;

    if (x > intrh)
    {
	pl->minx = unionl;
	pl->maxx = unionh;

	/* use the same one*/
	return pl;		
    }
	
    /* make a new visplane*/
    lastvisplane->height = pl->height;
    lastvisplane->picnum = pl->picnum;
    lastvisplane->lightlevel = pl->lightlevel;
    
    pl = lastvisplane++;
    pl->minx = start;
    pl->maxx = stop;

    memset (pl->top,0xff,sizeof(pl->top));
		
    return pl;
}
#endif

/**/
/* R_MakeSpans*/
/**/
#if 0
void R_MakeSpans
( int		x,
  int		t1,
  int		b1,
  int		t2,
  int		b2 )
{
    while (t1 < t2 && t1<=b1)
    {
	R_MapPlane (t1,spanstart[t1],x-1);
	t1++;
    }
    while (b1 > b2 && b1>=t1)
    {
	R_MapPlane (b1,spanstart[b1],x-1);
	b1--;
    }
	
    while (t2 < t1 && t2<=b2)
    {
	spanstart[t2] = x;
	t2++;
    }
    while (b2 > b1 && b2>=t2)
    {
	spanstart[b2] = x;
	b2--;
    }
}
#endif


/**/
/* R_DrawPlanes*/
/* At the end of each frame.*/
/**/

#if 0
void R_DrawPlanes (void)
{
    visplane_t*		pl;
    int			light;
    int			x;
    int			stop;
    int			angle;
			
#ifdef RANGECHECK
    if (ds_p - drawsegs > MAXDRAWSEGS)
	I_Error ("R_DrawPlanes: drawsegs overflow (%i)",
		 ds_p - drawsegs);
    
    if (lastvisplane - visplanes > MAXVISPLANES)
	I_Error ("R_DrawPlanes: visplane overflow (%i)",
		 lastvisplane - visplanes);
    
    if (lastopening - openings > MAXOPENINGS)
	I_Error ("R_DrawPlanes: opening overflow (%i)",
		 lastopening - openings);
#endif

    for (pl = visplanes ; pl < lastvisplane ; pl++)
    {
	if (pl->minx > pl->maxx)
	    continue;

	
	/* sky flat*/
	if (pl->picnum == skyflatnum)
	{
	    dc_iscale = pspriteiscale>>detailshift;
	    
	    /* Sky is allways drawn full bright,*/
	    /*  i.e. colormaps[0] is used.*/
	    /* Because of this hack, sky is not affected*/
	    /*  by INVUL inverse mapping.*/
	    dc_colormap = colormaps;
	    dc_texturemid = skytexturemid;
	    for (x=pl->minx ; x <= pl->maxx ; x++)
	    {
		dc_yl = pl->top[x];
		dc_yh = pl->bottom[x];

		if (dc_yl <= dc_yh)
		{
		    angle = (viewangle + xtoviewangle[x])>>ANGLETOSKYSHIFT;
		    dc_x = x;
		    dc_source = R_GetColumn(skytexture, angle);
		    colfunc ();
		}
	    }
	    continue;
	}
	
;	/* regular flat*/
	ds_source = W_CacheLumpNum(firstflat +
				   flattranslation[pl->picnum],
				   PU_STATIC);
	
	planeheight = abs(pl->height-viewz);
	light = (pl->lightlevel >> LIGHTSEGSHIFT)+extralight;

	if (light >= LIGHTLEVELS)
	    light = LIGHTLEVELS-1;

	if (light < 0)
	    light = 0;

	planezlight = zlight[light];

	pl->top[pl->maxx+1] = 0xffff;
	pl->top[pl->minx-1] = 0xffff;
		
	stop = pl->maxx + 1;

	for (x=pl->minx ; x<= stop ; x++)
	{
	    R_MakeSpans(x,pl->top[x-1],
			pl->bottom[x-1],
			pl->top[x],
			pl->bottom[x]);
	}
	
	Z_ChangeTag (ds_source, PU_CACHE);
    }
}
#endif

