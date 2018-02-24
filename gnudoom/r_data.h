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
/*  Refresh module, data I/O, caching, retrieval of graphics*/
/*  by name.*/
/**/
/*-----------------------------------------------------------------------------*/


#ifndef __R_DATA__
#define __R_DATA__

#include "r_defs.h"
#include "r_state.h"

#ifdef __GNUG__
#pragma interface
#endif

/* Retrieve column data for span blitting.*/
/*byte*
R_GetColumn
( int		tex,
  int		col );
*/

extern __inline byte *R_GetColumn(int tex,int col)
{
	register int _res __asm("d0");

	__asm __volatile
	(
		/* col &= texturewidthmask[tex] */
		"move.l	_texturewidthmask,a0 \n\t"
		"and.l	(a0,%1.w*4),%2 \n\t"

		/* ofs = texturecolumnofs[tex][col] */
		"move.l	_texturecolumnofs,a0 \n\t"
		"move.l	(a0,%1.w*4),a0 \n\t"
		"moveq	#0,d2 \n\t"
		"move.w	(a0,%2.w*2),d2 \n\t"
		/* d2 = ofs */

		/* lump = texturecolumnlump[tex][col] */
		"move.l	_texturecolumnlump,a0 \n\t"		
		"move.l	(a0,%1.w*4),a0 \n\t"
		"moveq	#0,d3 \n\t"
		"move.w	(a0,%2.w*2),d3 \n\t"
		/* d3 = lump */
		
		/* lump >0 ? */
		"jle		1f \n\t"
		
		/* return W_CacheLumpNum(lump,PU_CACHE)+ofs */
		
		"move.l	_lumpcache,a0 \n\t"
		"move.l	(a0,d3.w*4),d0 \n\t"
		"jeq		3f \n\t"

		"move.l	d0,a0 \n\t"
		"moveq	#101,d1 \n\t"
		"move.l	d1,-16(a0) \n\t"		/* tag -> PU_CACHE */
		"add.l	d2,d0 \n\t"				/* + ofs */
		"jra		9f \n"
		

		/* nicht gecached -> richtige (langsame) Funktion aufrufen */
		"3: moveq	#101,d0 \n\t"
		"move.l	d0,-(sp) \n\t"
		"move.l	d3,-(sp) \n\t"
		"jsr		_WW_CacheLumpNum \n\t"
		"add.l	#8,sp \n\t"
		"add.l	d2,d0 \n\t"
		
		"jra		9f \n"
		
		/* <0: texturecomposite[tex] ? */
		"1: move.l	_texturecomposite,a2 \n\t"
		"move.l	(a2,%1.w*4),d0 \n\t"
		"jeq		2f \n\t"
		
		/* return texturecomposite[tex] + ofs */
		"add.l	d2,d0 \n\t"
		"jra		9f \n"
		
		/* !texturecomposite[tex]: */
		"2: move.l	%1,-(sp) \n\t"
		"lsl.w	#2,%1 \n\t"
		"add.w	%1,a2 \n\t"
		"jsr		_R_GenerateComposite \n\t"
		"add.l	#4,sp \n\t"
		
		"move.l	(a2),d0 \n\t"
		"add.l	d2,d0 \n\t"

		"9:"
		
		: "=r" (_res), "=d" (tex), "=d" (col)
		: "1" (tex), "2" (col)
		: "d1", "d2", "d3",  "a0", "a1", "a2"
	);
	
	return (byte *)_res;
}

/* I/O, setting up the stuff.*/
void R_InitData (void);
void R_PrecacheLevel (void);


/* Retrieval.*/
/* Floor/ceiling opaque texture tiles,*/
/* lookup by name. For animation?*/
int R_FlatNumForName (char* name);


/* Called by P_Ticker for switches and animations,*/
/* returns the texture number for the texture name.*/
int R_TextureNumForName (char *name);
int R_CheckTextureNumForName (char *name);

#endif
/*-----------------------------------------------------------------------------*/
/**/
/* $Log:$*/
/**/
/*-----------------------------------------------------------------------------*/
