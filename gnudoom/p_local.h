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
/*	Play functions, animation, global header.*/
/**/
/*-----------------------------------------------------------------------------*/


#ifndef __P_LOCAL__
#define __P_LOCAL__

#ifndef __R_LOCAL__
#include "r_local.h"
#endif

#define FLOATSPEED		(FRACUNIT*4)


#define MAXHEALTH		100
#define VIEWHEIGHT		(41*FRACUNIT)

/* mapblocks are used to check movement*/
/* against lines and things*/
#define MAPBLOCKUNITS	128
#define MAPBLOCKSIZE	(MAPBLOCKUNITS*FRACUNIT)
#define MAPBLOCKSHIFT	(FRACBITS+7)
#define MAPBMASK		(MAPBLOCKSIZE-1)
#define MAPBTOFRAC		(MAPBLOCKSHIFT-FRACBITS)


/* player radius for movement checking*/
#define PLAYERRADIUS	16*FRACUNIT

/* MAXRADIUS is for precalculated sector block boxes*/
/* the spider demon is larger,*/
/* but we do not have any moving sectors nearby*/
#define MAXRADIUS		32*FRACUNIT

/*#define GRAVITY		FRACUNIT*/
#define MAXMOVE		(30*FRACUNIT)

#define USERANGE		(64*FRACUNIT)
#define MELEERANGE		(64*FRACUNIT)
#define MISSILERANGE	(32*64*FRACUNIT)

/* follow a player exlusively for 3 seconds*/
#define	BASETHRESHOLD	 	100



/**/
/* P_TICK*/
/**/

/* both the head and tail of the thinker list*/
extern	thinker_t	thinkercap;	


void P_InitThinkers (void);
void P_AddThinker (thinker_t* thinker);
void P_RemoveThinker (thinker_t* thinker);


/**/
/* P_PSPR*/
/**/
void P_SetupPsprites (player_t* curplayer);
void P_MovePsprites (player_t* curplayer);
void P_DropWeapon (player_t* player);


/**/
/* P_USER*/
/**/
void	P_PlayerThink (player_t* player);


/**/
/* P_MOBJ*/
/**/
#define ONFLOORZ		MININT
#define ONCEILINGZ		MAXINT

/* Time interval for item respawning.*/
#define ITEMQUESIZE		128

extern mapthing_t	itemrespawnque[ITEMQUESIZE];
extern int		itemrespawntime[ITEMQUESIZE];
extern int		iquehead;
extern int		iquetail;


void P_RespawnSpecials (void);

mobj_t*
P_SpawnMobj
( fixed_t	x,
  fixed_t	y,
  fixed_t	z,
  mobjtype_t	type );

void 	P_RemoveMobj (mobj_t* th);
boolean	P_SetMobjState (mobj_t* mobj, statenum_t state);
void 	P_MobjThinker (mobj_t* mobj);

void	P_SpawnPuff (fixed_t x, fixed_t y, fixed_t z);
void 	P_SpawnBlood (fixed_t x, fixed_t y, fixed_t z, int damage);
mobj_t* P_SpawnMissile (mobj_t* source, mobj_t* dest, mobjtype_t type);
void	P_SpawnPlayerMissile (mobj_t* source, mobjtype_t type);


/**/
/* P_ENEMY*/
/**/
void P_NoiseAlert (mobj_t* target, mobj_t* emmiter);


/**/
/* P_MAPUTL*/
/**/
typedef struct
{
    fixed_t	x;
    fixed_t	y;
    fixed_t	dx;
    fixed_t	dy;
    
} divline_t;

typedef struct
{
    fixed_t	frac;		/* along trace line*/
    boolean	isaline;
    union {
	mobj_t*	thing;
	line_t*	line;
    }			d;
} intercept_t;

#define MAXINTERCEPTS	128

extern intercept_t	intercepts[MAXINTERCEPTS];
extern intercept_t*	intercept_p;

typedef boolean (*traverser_t) (intercept_t *in);


static __inline fixed_t P_AproxDistance (fixed_t dx, fixed_t dy)
{
	register fixed_t _res __asm("d0");
	register fixed_t d0 __asm("d0") = dx;
	register fixed_t d1 __asm("d1") = dy;
	
	__asm __volatile
	(
	 	/*		dx = abs(dx); */
	 	"tst.l	d0 \n\t"
	 	"jpl		1f \n\t"
	 	"neg.l	d0 \n"
	 	
	 	"1: \n\t"
	 	/*		dy = abs(dy)	*/
		"tst.l	d1 \n\t"
		"jpl		2f \n\t"
		"neg.l	d1 \n"
		
		"2: \n\t"
		
    	/*		if (dx < dy) return dx+dy-(dx>>1); */
    	"cmp.l	d1,d0 \n\t"
    	"bge.s	3f \n\t"
    	
/*    	"move.l	d0,d2 \n\t"
    	"add.l	d1,d0 \n\t"
    	"lsr.l	#1,d2 \n\t"
    	"sub.l	d2,d0 \n\t"
    	"jra		9f \n"*/
    	"exg		d0,d1 \n"
    	
    	/* return dx+dy-(dy>>1); */    	
		"3: \n\t"
    	"add.l	d1,d0 \n\t"
    	"lsr.l	#1,d1 \n\t"
    	"sub.l	d1,d0 \n"
    	
    	"9:"
    	
		
		: "=r" (_res)
		: "r" (d0), "r" (d1)
		: "d0", "d1"
	);
	
	return _res;
};

static __inline int P_PointOnLineSide (fixed_t x, fixed_t y, line_t* line)
{
	register int _res __asm("d0");
	register fixed_t d0 __asm("d0") = x;
	register fixed_t d1 __asm("d1") = y;
	register line_t *a0 __asm("a0") = line;
	
	__asm __volatile
	(
		"move.l	(a0),a1 \n\t"
		"movem.l	(a1),d4/d5 \n\t"		/* d4 = line->v1->x */
												/* d5 = line->v1->y */
		"movem.l	8(a0),d2-d3 \n\t"
		
    	/* if (!line->dx) */
    	"tst.l	d2 \n\t"
    	"jne		1f \n\t"
    	
    	/* { */
		/*	if (x <= line->v1->x) */
	   /* return line->dy > 0; */
		/* return line->dy < 0; */
		/* } */
		"cmp.l	d4,d0 \n\t"
		"jgt		2f \n\t"
		
		"tst.l	d3 \n\t"
		"jgt		3f \n\t"
		"moveq	#0,d0 \n\t"
		"jra		9f \n"
		
		"3: \n\t"
		"moveq	#1,d0 \n\t"
		"jra		9f \n"
		
		"2: \n\t"
		"tst.l	d3 \n\t"
		"jlt		3b \n\t"
		"moveq	#0,d0 \n\t"
		"jra		9f \n"
		
		"1: \n\t"
		/*	if (!line->dy) */
	   /* { */
		/*	if (y <= line->v1->y) */
	   /* 	return line->dx < 0; */
		/*	return line->dx > 0; */
		/*    } */
		"tst.l	d3 \n\t"
		"jne		5f \n\t"
		"cmp.l	d5,d1 \n\t"
		"jgt		6f \n\t"
		"tst.l	d2 \n\t"
		"jlt		3b \n\t"
		"moveq	#0,d0 \n\t"
		"jra		9f \n"
		
		"6: \n\t"
		"tst.l	d2 \n\t"
		"jgt		3b \n\t"
		"moveq	#0,d0 \n\t"
		"jra		9f \n"
		
		"5: \n\t"
    	/* dx = (x - line->v1->x); */
    	"sub.l	d4,d0 \n\t"
    	
 	   /* dy = (y - line->v1->y); */
 	   "sub.l	d5,d1 \n\t"
	
    	/* left = FixedMul ( line->dy>>FRACBITS , dx );*/
    	"swap		d3 \n\t"
    	"ext.l	d3 \n\t"
    	
#ifndef version060
		"muls.l	d3,d3:d0 \n\t"
		"move		d3,d0 \n\t"
		"swap		d0 \n\t"
#else
		"fmove.l	d3,fp0 \n\t"
		"fmul.l	d0,fp0 \n\t"
		"fmul.x	fp7,fp0 \n\t"
		"fmove.l	fp0,d0 \n\t"
#endif
		
    	/* right = FixedMul ( dy , line->dx>>FRACBITS ); */
		"swap		d2 \n\t"
		"ext.l	d2 \n\t"
		
#ifndef version060
		"muls.l	d2,d2:d1 \n\t"
		"move		d2,d1 \n\t"
		"swap		d1 \n\t"
#else
		"fmove.l	d2,fp0 \n\t"
		"fmul.l	d1,fp0 \n\t"
		"fmul.x	fp7,fp0 \n\t"
		"fmove.l	fp0,d1 \n\t"
#endif

   	/* if (right < left) */
		/* return 0;		 front side */
   	/* return 1;			 back side */
   	"cmp.l	d0,d1 \n\t"
   	"jge		3b \n\t"
   	"moveq	#0,d0 \n\t"
   	
   	"9:"
   	
   	: "=r" (_res)
   	: "r" (a0), "r" (d0), "r" (d1)
   	: "a1","d0","d1","d2","d3","d4","d5"
   );
   
   return _res;
}

/*static int 	P_PointOnDivlineSide (fixed_t x, fixed_t y, divline_t* line);*/
static void 	P_MakeDivline (line_t* li, divline_t* dl);
fixed_t P_InterceptVector (divline_t* v2, divline_t* v1);
int 	P_BoxOnLineSide (fixed_t* tmbox, line_t* ld);

extern fixed_t		opentop;
extern fixed_t 		openbottom;
extern fixed_t		openrange;
extern fixed_t		lowfloor;

void 	P_LineOpening (line_t* linedef);

boolean P_BlockLinesIterator (int x, int y, boolean(*func)(line_t*) );
boolean P_BlockThingsIterator (int x, int y, boolean(*func)(mobj_t*) );

#define PT_ADDLINES		1
#define PT_ADDTHINGS	2
#define PT_EARLYOUT		4

extern divline_t	trace;

boolean
P_PathTraverse
( fixed_t	x1,
  fixed_t	y1,
  fixed_t	x2,
  fixed_t	y2,
  int		flags,
  boolean	(*trav) (intercept_t *));

void P_UnsetThingPosition (mobj_t* thing);
void P_SetThingPosition (mobj_t* thing);


/**/
/* P_MAP*/
/**/

/* If "floatok" true, move would be ok*/
/* if within "tmfloorz - tmceilingz".*/
extern boolean		floatok;
extern fixed_t		tmfloorz;
extern fixed_t		tmceilingz;


extern	line_t*		ceilingline;

boolean P_CheckPosition (mobj_t *thing, fixed_t x, fixed_t y);
boolean P_TryMove (mobj_t* thing, fixed_t x, fixed_t y);
boolean P_TeleportMove (mobj_t* thing, fixed_t x, fixed_t y);
void	P_SlideMove (mobj_t* mo);
boolean P_CheckSight (mobj_t* t1, mobj_t* t2);
void 	P_UseLines (player_t* player);

boolean P_ChangeSector (sector_t* sector, boolean crunch);

extern mobj_t*	linetarget;	/* who got hit (or NULL)*/

fixed_t
P_AimLineAttack
( mobj_t*	t1,
  angle_t	angle,
  fixed_t	distance );

void
P_LineAttack
( mobj_t*	t1,
  angle_t	angle,
  fixed_t	distance,
  fixed_t	slope,
  int		damage );

void
P_RadiusAttack
( mobj_t*	spot,
  mobj_t*	source,
  int		damage );



/**/
/* P_SETUP*/
/**/
extern byte*		rejectmatrix;	/* for fast sight rejection*/
extern short*		blockmaplump;	/* offsets in blockmap are from here*/
extern short*		blockmap;
extern int		bmapwidth;
extern int		bmapheight;	/* in mapblocks*/
extern fixed_t		bmaporgx;
extern fixed_t		bmaporgy;	/* origin of block map*/
extern mobj_t**		blocklinks;	/* for thing chains*/



/**/
/* P_INTER*/
/**/
extern int		maxammo[NUMAMMO];
extern int		clipammo[NUMAMMO];

void
P_TouchSpecialThing
( mobj_t*	special,
  mobj_t*	toucher );

void
P_DamageMobj
( mobj_t*	target,
  mobj_t*	inflictor,
  mobj_t*	source,
  int		damage );


/**/
/* P_SPEC*/
/**/
#include "p_spec.h"


#endif	/* __P_LOCAL__*/
/*-----------------------------------------------------------------------------*/
/**/
/* $Log:$*/
/**/
/*-----------------------------------------------------------------------------*/


