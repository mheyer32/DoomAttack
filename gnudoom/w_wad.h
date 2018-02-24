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
/*	WAD I/O functions.*/
/**/
/*-----------------------------------------------------------------------------*/


#ifndef __W_WAD__
#define __W_WAD__


#ifdef __GNUG__
#pragma interface
#endif


/**/
/* TYPES*/
/**/
typedef struct
{
    /* Should be "IWAD" or "PWAD".*/
    char		identification[4];		
    int			numlumps;
    int			infotableofs;
    
} wadinfo_t;


typedef struct
{
    int			filepos;
    int			size;
    char		name[8];
    
} filelump_t;

/**/
/* WADFILE I/O related stuff.*/
/**/
typedef struct
{
    char	name[8];
    int		handle;
    int		position;
    int		size;
} lumpinfo_t;


extern	void**		lumpcache;
extern	lumpinfo_t*	lumpinfo;
extern	int		numlumps;

void    W_InitMultipleFiles (char** filenames);
void    W_Reload (void);

int	W_CheckNumForName (char* name);
int	W_GetNumForName (char* name);

int	W_LumpLength (int lump);
void    W_ReadLump (int lump, void *dest);

#ifdef 0
void*	W_CacheLumpNum (int lump, int tag);
#endif

extern __inline void* W_CacheLumpNum(int lump, int tag)
{
	register void* _res __asm ("a0");
	
	__asm __volatile
	(
		"cmp.l	_numlumps,%1 \n\t"
 		"jlt		2f \n\t"

		"move.l	%1,-(sp) \n\t"
		"pea		_ERRTEXT_CacheLumpNum \n\t"
		"jsr		_I_Error \n"
		/* kommt nicht zurueck! */
		
		"2: move.l	_lumpcache,a1 \n\t"
		"lea		(a1,%1.w*4),a2 \n\t"
		"tst.l	(a2) \n\t"
		"jne		3f \n\t"
		
		/* nicht gecached: */
		/*	ptr = Z_Malloc (W_LumpLength (lump), tag, &lumpcache[lump]);
	    	W_ReadLump (lump, lumpcache[lump]);*/

		"move.l	a2,-(sp) \n\t"		/* &lumpcache[lump] */
		"move.l	%2,-(sp) \n\t"		/* tag */

		"move.l	%1,-(sp) \n\t"
		"jsr		_W_LumpLength \n\t"
		/*"add.l	#4,sp \n\t"*/
		"move.l	d0,(sp) \n\t"		/* W_LumpLength(lump) */
		"jsr		_Z_Malloc \n\t"
		"lea		12(sp),sp \n\t"
		
		"move.l	(a2),-(sp) \n\t"	/* lumpcache[lump] */
		"move.l	%1,-(sp) \n\t"		/* lump */
		"jsr		_W_ReadLump \n\t"
		"add.l	#8,sp \n\t"
		"move.l	(a2),a0 \n\t"
		"jra		9f \n"
		
		
		/*3: schon gecached */
		/* Z_ChangeTag(lumpcache[lump],tag */
		"3: 		move.l	(a2),a0 \n\t"
		"move.l	%2,-16(a0) \n"
		
		"9:"
		
		: "=r" (_res), "=d" (lump), "=d" (tag)
		: "1" (lump), "2" (tag)
		: "d0", "d1", "a0", "a1", "a2", "memory"
	);
	
	return _res;
}


void*	W_CacheLumpName (char* name, int tag);

void W_Cleanup(void);


#endif
/*-----------------------------------------------------------------------------*/
/**/
/* $Log:$*/
/**/
/*-----------------------------------------------------------------------------*/
