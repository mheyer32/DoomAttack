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
/*	LineOfSight/Visibility checks, uses REJECT Lookup Table.*/
/**/
/*-----------------------------------------------------------------------------*/



#include "doomdef.h"

#include "i_system.h"
#include "p_local.h"

/* State.*/
#include "r_state.h"

/**/
/* P_CheckSight*/
/**/
fixed_t sightzstart; /* eye z of looker*/
fixed_t topslope;
fixed_t bottomslope; /* slopes to top and bottom of target*/

divline_t strace; /* from t1 to t2*/
fixed_t t2x;
fixed_t t2y;

int sightcounts[2];

/**/
/* P_DivlineSide*/
/* Returns side 0 (front), 1 (back), or 2 (on).*/
/**/

static __inline int P_DivlineSide(fixed_t x, fixed_t y, divline_t* node)
{
    register int _res __asm("d0");

    __asm __volatile(

        /*
            if (!node->dx)
            {
            if (x==node->x)
                return 2;

            if (x <= node->x)
                return node->dy > 0;

            return node->dy < 0;
            }
        */

        "movem.l	8(%5),d0/d1 \n\t"

        "tst.l	d0 \n\t"
        "jne		8f \n\t"

        "cmp.l	(%5),%1 \n\t"
        "jlt		1f \n\t"
        "jgt		4f \n\t"
        "moveq	#2,d0 \n\t"
        "jra		9f \n"

        /* x < node->x*/

        "1: tst.l	d1 \n\t"
        "jgt		2f \n\t"
        "moveq	#0,d0 \n\t"
        "jra		9f \n"

        "2: moveq	#1,d0 \n\t"
        "jra		9f \n"

        /* x > node->x */

        "4: tst.l	d1 \n\t"
        "jmi		5f \n\t"
        "moveq	#0,d0 \n\t"
        "jra		9f \n"

        "5: moveq	#1,d0 \n\t"
        "jra		9f \n"

        /*
            if (!node->dy)
            {
            if (y==node->y)
                return 2;

            if (y <= node->y)
                return node->dx < 0;

            return node->dx > 0;
            }
        */

        "8: tst.l d1 \n\t"
        "jne		8f \n\t"

        "cmp.l	4(%5),%2 \n\t"
        "jlt		1f \n\t"
        "jgt		4f \n\t"
        "moveq	#2,d0 \n\t"
        "jra		9f \n"

        /* y < node->y */
        "1:	tst.l	d0 \n\t"
        "jmi		2f \n\t"
        "moveq	#0,d0 \n\t"
        "jra		9f \n"

        "2:	moveq	#1,d0 \n\t"
        "jra		9f \n"

        /* y > node->y */

        "4:	tst.l	d0 \n\t"
        "jgt		5f \n\t"
        "moveq	#0,d0 \n\t"
        "jra		9f \n"

        "5:	moveq	#1,d0 \n\t"
        "jra		9f \n"

        /* node->dx && node->dy */
        "8: sub.l	(%5),%1 \n\t"
        "swap		%1 \n\t"
        "swap		d0 \n\t"
        "sub.l	4(%5),%2 \n\t"
        "swap		%2 \n\t"
        "swap		d1 \n\t"

        "muls.w	d1,%1 \n\t"
        "muls.w	d0,%2 \n\t"
        "cmp.l	%1,%2 \n\t"
        "jlt		1f \n\t"
        "jgt		2f \n\t"
        "moveq	#2,d0 \n\t"
        "jra		9f \n"

        "1: moveq	#0,d0 \n\t"
        "jra		9f \n"

        "2: moveq	#1,d0 \n"
        "9: "

        : "=r"(_res), "=d"(x), "=d"(y)
        : "1"(x), "2"(y), "a"(node)
        : "d1");

    return _res;
}

#if 0
int P_DivlineSide(fixed_t x, fixed_t y, divline_t* node)
{
    fixed_t dx;
    fixed_t dy;
    fixed_t left;
    fixed_t right;

    if (!node->dx) {
        if (x == node->x)
	    return 2;
	
	if (x <= node->x)
	    return node->dy > 0;

	return node->dy < 0;
    }
    
    if (!node->dy) {
    	/* Georg Steger: FIX */
    	
/*	if (x==node->y)
	    return 2;*/

        if (y == node->y)
            return 2;

	if (y <= node->y)
	    return node->dx < 0;

	return node->dx > 0;
    }
	
    dx = (x - node->x);
    dy = (y - node->y);

    left = (node->dy >> FRACBITS) * (dx >> FRACBITS);
    right = (dy >> FRACBITS) * (node->dx >> FRACBITS);
	
    if (right < left)
        return 0; /* front side*/
    
    if (left == right)
	return 2;
    return 1; /* back side*/
}
#endif

/**/
/* P_InterceptVector2*/
/* Returns the fractional intercept point*/
/* along the first divline.*/
/* This is only called by the addthings and addlines traversers.*/
/**/
static fixed_t P_InterceptVector2(divline_t* v2, divline_t* v1)
{
    fixed_t frac;
    fixed_t num;
    fixed_t den;

    den = FixedMul(v1->dy >> 8, v2->dx) - FixedMul(v1->dx >> 8, v2->dy);

    if (den == 0)
        return 0;
    /*	I_Error ("P_InterceptVector: parallel");*/

    num = FixedMul((v1->x - v2->x) >> 8, v1->dy) + FixedMul((v2->y - v1->y) >> 8, v1->dx);
    frac = FixedDiv2(num, den);

    return frac;
}

/**/
/* P_CrossSubsector*/
/* Returns true*/
/*  if strace crosses the given subsector successfully.*/
/**/
static boolean P_CrossSubsector(int num)
{
    seg_t* seg;
    line_t* line;
    int s1;
    int s2;
    int count;
    subsector_t* sub;
    sector_t* front;
    sector_t* back;
    fixed_t opentop;
    fixed_t openbottom;
    divline_t divl;
    vertex_t* v1;
    vertex_t* v2;
    fixed_t frac;
    fixed_t slope;

#ifdef RANGECHECK
    if (num >= numsubsectors)
        I_Error("P_CrossSubsector: ss %i with numss = %i", num, numsubsectors);
#endif

    sub = &subsectors[num];

    /* check lines*/
    count = sub->numlines;
    seg = &segs[sub->firstline];

    for (; count; seg++, count--) {
        line = seg->linedef;

        /* allready checked other side?*/
        if (line->validcount == validcount)
            continue;

        line->validcount = validcount;

        v1 = line->v1;
        v2 = line->v2;
        s1 = P_DivlineSide(v1->x, v1->y, &strace);
        s2 = P_DivlineSide(v2->x, v2->y, &strace);

        /* line isn't crossed?*/
        if (s1 == s2)
            continue;

        divl.x = v1->x;
        divl.y = v1->y;
        divl.dx = v2->x - v1->x;
        divl.dy = v2->y - v1->y;
        s1 = P_DivlineSide(strace.x, strace.y, &divl);
        s2 = P_DivlineSide(t2x, t2y, &divl);

        /* line isn't crossed?*/
        if (s1 == s2)
            continue;

        /* stop because it is not two sided anyway*/
        /* might do this after updating validcount?*/
        if (!(line->flags & ML_TWOSIDED))
            return false;

        /* crosses a two sided line*/
        front = seg->frontsector;
        back = seg->backsector;

        /* no wall to block sight with?*/
        if (front->floorheight == back->floorheight && front->ceilingheight == back->ceilingheight)
            continue;

        /* possible occluder*/
        /* because of ceiling height differences*/
        if (front->ceilingheight < back->ceilingheight)
            opentop = front->ceilingheight;
        else
            opentop = back->ceilingheight;

        /* because of ceiling height differences*/
        if (front->floorheight > back->floorheight)
            openbottom = front->floorheight;
        else
            openbottom = back->floorheight;

        /* quick test for totally closed doors*/
        if (openbottom >= opentop)
            return false; /* stop*/

        frac = P_InterceptVector2(&strace, &divl);

        if (front->floorheight != back->floorheight) {
            slope = FixedDiv(openbottom - sightzstart, frac);
            if (slope > bottomslope)
                bottomslope = slope;
        }

        if (front->ceilingheight != back->ceilingheight) {
            slope = FixedDiv(opentop - sightzstart, frac);
            if (slope < topslope)
                topslope = slope;
        }

        if (topslope <= bottomslope)
            return false; /* stop				*/
    }
    /* passed the subsector ok*/
    return true;
}

/**/
/* P_CrossBSPNode*/
/* Returns true*/
/*  if strace crosses the given node successfully.*/
/**/
static boolean P_CrossBSPNode(int bspnum)
{
    node_t* bsp;
    int side;

    if (bspnum & NF_SUBSECTOR) {
        if (bspnum == -1)
            return P_CrossSubsector(0);
        else
            return P_CrossSubsector(bspnum & (~NF_SUBSECTOR));
    }

    bsp = &nodes[bspnum];

    /* decide which side the start point is on*/
    side = P_DivlineSide(strace.x, strace.y, (divline_t*)bsp);
    if (side == 2)
        side = 0; /* an "on" should cross both sides*/

    /* cross the starting side*/
    if (!P_CrossBSPNode(bsp->children[side]))
        return false;

    /* the partition plane is crossed here*/
    if (side == P_DivlineSide(t2x, t2y, (divline_t*)bsp)) {
        /* the line doesn't touch the other side*/
        return true;
    }

    /* cross the ending side		*/
    return P_CrossBSPNode(bsp->children[side ^ 1]);
}

/**/
/* P_CheckSight*/
/* Returns true*/
/*  if a straight line between t1 and t2 is unobstructed.*/
/* Uses REJECT.*/
/**/
boolean P_CheckSight(mobj_t* t1, mobj_t* t2)
{
    int s1;
    int s2;
    int pnum;
    int bytenum;
    int bitnum;

    /* First check for trivial rejection.*/

    /* Determine subsector entries in REJECT table.*/
    s1 = (t1->subsector->sector - sectors);
    s2 = (t2->subsector->sector - sectors);
    pnum = s1 * numsectors + s2;
    bytenum = pnum >> 3;
    bitnum = 1 << (pnum & 7);

    /* Check in REJECT table.*/
    if (rejectmatrix[bytenum] & bitnum) {
        sightcounts[0]++;

        /* can't possibly be connected*/
        return false;
    }

    /* An unobstructed LOS is possible.*/
    /* Now look from eyes of t1 to any part of t2.*/
    sightcounts[1]++;

    validcount++;

    sightzstart = t1->z + t1->height - (t1->height >> 2);
    topslope = (t2->z + t2->height) - sightzstart;
    bottomslope = (t2->z) - sightzstart;

    strace.x = t1->x;
    strace.y = t1->y;
    t2x = t2->x;
    t2y = t2->y;
    strace.dx = t2->x - t1->x;
    strace.dy = t2->y - t1->y;

    /* the head node is the last node output*/
    return P_CrossBSPNode(numnodes - 1);
}
