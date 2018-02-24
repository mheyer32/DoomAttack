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
/*	Endianess handling, swapping 16bit and 32bit.*/
/**/
/*-----------------------------------------------------------------------------*/


#ifndef __M_SWAP__
#define __M_SWAP__


#ifdef __GNUG__
#pragma interface
#endif


/* Endianess handling.*/
/* WAD files are stored little endian.*/


extern __inline short SwapSHORT(short val)
{
	__asm __volatile
	(
		"ror.w	#8,%0"

		: "=d" (val)
		: "0" (val)
	);
	
	return val;
}

extern __inline long SwapLONG(long val)
{
	__asm __volatile
	(
		"ror.w	#8,%0 \n\t"
		"swap	%0 \n\t"
		"ror.w	#8,%0"
		
		: "=d" (val)
		: "0" (val)
	);
	
	return val;
}

#define SHORT(x) SwapSHORT(x)
#define LONG(x) SwapLONG(x)

#if 0

unsigned short	SwapSHORT(unsigned short);
unsigned long	SwapLONG(unsigned long);

#define SHORT(x)	((short)SwapSHORT((unsigned short) (x)))
#define LONG(x)         ((long)SwapLONG((unsigned long) (x)))
#endif

#endif

/*-----------------------------------------------------------------------------*/
/**/
/* $Log:$*/
/**/
/*-----------------------------------------------------------------------------*/
