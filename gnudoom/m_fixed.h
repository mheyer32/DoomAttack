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
/*	Fixed point arithemtics, implementation.*/
/**/
/*-----------------------------------------------------------------------------*/


#ifndef __M_FIXED__
#define __M_FIXED__


/*#ifdef __GNUG__*/
/*#pragma interface*/
/*#endif*/


/**/
/* Fixed point, 32bit as 16.16.*/
/**/
#define FRACBITS		16
#define FRACUNIT		(1<<FRACBITS)

typedef int fixed_t;

/* hallohallohallo */

/*	fixed_t FixedMul	(fixed_t a,fixed_t b); */

extern __inline fixed_t FixedMul(fixed_t eins,fixed_t zwei)
{
	
#ifndef version060

	__asm __volatile
	("muls.l %1,%1:%0 \n\t"
	 "move %1,%0 \n\t"
	 "swap %0 "
					 
	  : "=d" (eins), "=d" (zwei)
	  : "0" (eins), "1" (zwei)
	);

	return eins;

#else
	__asm __volatile
	("fmove.l	%0,fp0 \n\t"
	 "fmul.l	%2,fp0 \n\t"
	 "fmul.x	fp7,fp0 \n\t"

/*	 "fintrz.x	fp0,fp0 \n\t"*/
	 "fmove.l	fp0,%0"
					 
	  : "=d" (eins)
	  : "0" (eins), "d" (zwei)
	  : "fp0"
	);

	return eins;

#endif

}

#define FixedMulFast(a,b) FixedMul(a,b)


/*	fixed_t FixedDiv	(fixed_t a,fixed_t b);
	fixed_t FixedDiv2	(fixed_t a,fixed_t b);*/ 

	int LEFTSHIFT (int a,int b);
	int RIGHTSHIFT (int a,int b);

extern __inline fixed_t FixedDiv(fixed_t eins,fixed_t zwei)
{
	__asm __volatile

#ifndef version060
	("move.l	%0,d3\n\t"
	 "swap      %0\n\t"
	 "move.w    %0,d2\n\t"
	 "ext.l		d2\n\t"
	 "clr.w		%0\n\t"
	 "tst.l		%1\n\t"
	 "jeq		3f\n\t"
	 "divs.l	%1,d2:%0\n\t"
	 "jvc		1f\n"

	 "3: eor.l %1,d3\n\t"
	 "jmi       2f\n\t"
	 "move.l	#0x7FFFFFFF,%0\n\t"
	 "jra		1f\n"

	 "2: move.l #0x80000000,%0\n"
	 "1:\n"
	 
	 : "=d" (eins), "=d" (zwei)
	 : "0" (eins), "1" (zwei)
	 : "d2","d3"
	);
#else
	("tst.l		%1\n\t"
	 "jne		1f\n\t"

	 "eor.l		 %1,%0\n\t"
	 "jmi       2f\n\t"
	 "move.l	#0x7FFFFFFF,%0\n\t"
	 "jra		9f\n"

	 "2: move.l #0x80000000,%0\n\t"
     "jra		9f\n"
     
	 "1: fmove.l %0,fp0 \n\t"
	 "fdiv.l	%2,fp0 \n\t"
	 "fmul.x		fp6,fp0 \n\t"
/*	 "fintrz.x  fp0\n\t"*/
	 "fmove.l	fp0,%0\n"

	 "9:\n"
	 
	 : "=d" (eins)
	 : "0" (eins), "d" (zwei)
	 : "fp0"
	);
#endif
	return eins;
}


#define FixedDivFast(a,b) FixedDiv(a,b)


/* testet nicht auf 0 Divisor !!! */

extern __inline fixed_t FixedDiv2(fixed_t eins,fixed_t zwei)
{
	__asm __volatile

#ifndef version060
	("swap      %0\n\t"
	 "move.w    %0,d2\n\t"
	 "ext.l		d2\n\t"
	 "clr.w		%0\n\t"
	 "divs.l	%1,d2:%0\n\t"

     : "=d" (eins), "=d" (zwei)
     : "0" (eins), "1" (zwei)
     : "d2"
	);
#else
	("fmove.l %0,fp0 \n\t"
	 "fdiv.l	%2,fp0 \n\t"
	 "fmul.x	fp6,fp0 \n\t"
/*	 "fintrz.x  fp0\n\t"*/
	 "fmove.l	fp0,%0 \n"

	 : "=d" (eins)
	 : "0" (eins), "d" (zwei)
	 : "fp0"
	);
#endif

	return eins;
}

#define FixedDiv2Fast(a,b) FixedDiv2(a,b)

extern __inline int LongDiv(int eins,int zwei)
{
	__asm __volatile
	(
		"divsl.l %2,%0:%0\n\t"
		
		: "=d" (eins)
		: "0" (eins), "d" (zwei)
	);

	return eins;
}

extern __inline int ULongDiv(int eins,int zwei)
{
	__asm __volatile
	(
		"divul.l %2,%0:%0\n\t"
		
		: "=d" (eins)
		: "0" (eins), "d" (zwei)
	);

	return eins;
}

extern __inline int LongRest(int eins,int zwei)
{
	__asm __volatile
	(
		"divsl.l	%2,d2:%0\n\t"
		"move.l 	d2,%0\n\t"
		
		: "=d" (eins)
		: "0" (eins), "d" (zwei)
		: "d2"
	);

	return eins;
}

extern __inline int ULongRest(int eins,int zwei)
{
	__asm __volatile
	(
		"divul.l %2,d2:%0\n\t"
		"move.l d2,%0\n\t"
		
		: "=d" (eins)
		: "0" (eins), "d" (zwei)
		: "d2"
	);

	return eins;
}
		
#endif

/*-----------------------------------------------------------------------------*/
/**/
/* $Log:$*/
/**/
/*-----------------------------------------------------------------------------*/
