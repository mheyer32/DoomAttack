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
/*	Handles WAD file header, directory, lump I/O.*/
/**/
/*-----------------------------------------------------------------------------*/

#define MAXWADFILES 20

#define alloca(x) mymalloc(x)
#define freea(x) free(x)

static const char
rcsid[] = "$Id: w_wad.c,v 1.5 1997/02/03 16:47:57 b1 Exp $";

/*#ifdef NORMALUNIX*/

/*#include <ctype.h>*/
/*#include <sys/types.h>*/
/*#include <string.h>*/
/*#include <unistd.h>*/
/*#include <malloc.h>*/
/*#include <fcntl.h>*/
/*#include <sys/stat.h>*/
/*#include <alloca.h>*/
/*#define O_BINARY		0*/

#include <exec/exec.h>
#include <dos/dos.h>
#include <dos/dosextens.h>
#include <inline/dos.h>

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>

/*#endif*/

#ifdef MAXINT
#undef MAXINT
#endif

#ifdef MININT
#undef MININT
#endif

#include "doomtype.h"
#include "m_swap.h"
#include "i_system.h"
#include "z_zone.h"

#ifdef __GNUG__
#pragma implementation "w_wad.h"
#endif
#include "w_wad.h"






/**/
/* GLOBALS*/
/**/

/* Location of each lump on disk.*/
lumpinfo_t*		lumpinfo;		
int			numlumps;

void **			lumpcache;


static int numopenfiles;
BPTR filehandles[MAXWADFILES];

#define strcmpi stricmp

#ifndef strupr
void strupr (char* s)
{
    while (*s) { *s = toupper(*s); s++; }
}
#endif

static int filelength (BPTR handle) 
{ 
	struct FileInfoBlock *fib;
	BPTR lock;

	LONG oldpos;
	int rc=-1;
	
	if ((fib=AllocDosObject(DOS_FIB,NULL)))
	{
		if ((lock=DupLockFromFH(handle)))
		{
			if (Examine(lock,fib))
			{
				rc=fib->fib_Size;
			}
			UnLock(lock);
		}	
		FreeDosObject(DOS_FIB,fib);
	}
	
	if (rc== -1)
	{
		oldpos=Seek(handle,0,OFFSET_END);
		rc=Seek(handle,oldpos,OFFSET_BEGINNING);
	}
  	
    return rc;
}


static void ExtractFileBase
( char*		path,
  char*		dest )
{
    char*	src;
    int		length;

    src = path + strlen(path) - 1;
    
    /* back up until a \ or the start*/
    while (src != path
	   && *(src-1) != '\\'
	   && *(src-1) != '/')
    {
	src--;
    }
    
    /* copy up to eight characters*/
    memset (dest,0,8);
    length = 0;
    
    while (*src && *src != '.')
    {
		if (++length == 9)
	    I_Error ("Filename base of %s >8 chars",path);

		*dest++ = toupper((int)*src);
		src++;
    }
}





/**/
/* LUMP BASED ROUTINES.*/
/**/

/**/
/* W_AddFile*/
/* All files are optional, but at least one file must be*/
/*  found (PWAD, if all required lumps are present).*/
/* Files with a .wad extension are wadlink files*/
/*  with multiple lumps.*/
/* Other files are single lumps with the base filename*/
/*  for the lump name.*/
/**/
/* If filename starts with a tilde, the file is handled*/
/*  specially to allow map reloads.*/
/* But: the reload feature is a fragile hack...*/

int			reloadlump;
char*			reloadname;


void W_AddFile (char *filename)
{
    wadinfo_t		header;
    lumpinfo_t*		lump_p;
    unsigned		i,i2;
    BPTR			handle;
    int			length;
    int			startlump;
    filelump_t*		fileinfo,*fileinfomem=0;
    filelump_t		singleinfo;
    BPTR 		storehandle;
    
    /* open the file and add to directory*/

    /* handle reload indicator.*/
    if (filename[0] == '~')
    {
	filename++;
	reloadname = filename;
	reloadlump = numlumps;
    }
		
    if ( (handle = Open (filename,MODE_OLDFILE)) == NULL)
    {
	printf (" couldn't open %s\n",filename);
	return;
    }

	filehandles[numopenfiles++] = handle;
	
    printf (" adding %s\n",filename);
    startlump = numlumps;
	
    if (stricmp (filename+strlen(filename)-3 , "wad" ) )
    {
	/* single lump file*/
	fileinfo = &singleinfo;
	singleinfo.filepos = 0;
	singleinfo.size = LONG(filelength(handle));
	ExtractFileBase (filename, singleinfo.name);
	numlumps++;
    }
    else 
    {
	/* WAD file*/
	Read (handle,&header,sizeof(header));
	if (strncmp(header.identification,"IWAD",4))
	{
	    /* Homebrew levels?*/
	    if (strncmp(header.identification,"PWAD",4))
	    {
		I_Error ("Wad file %s doesn't have IWAD "
			 "or PWAD id\n", filename);
	    }
	    
	    /* ???modifiedgame = true;		*/
	}
	header.numlumps = LONG(header.numlumps);
	header.infotableofs = LONG(header.infotableofs);
	length = header.numlumps*sizeof(filelump_t);
	
	fileinfomem = fileinfo = alloca (length);
	
	Seek (handle, header.infotableofs, OFFSET_BEGINNING);
	Read (handle,fileinfo,length);
	numlumps += header.numlumps;
    }

    
    /* Fill in lumpinfo*/
    lumpinfo = realloc (lumpinfo, numlumps*sizeof(lumpinfo_t));

    if (!lumpinfo)
	I_Error ("Couldn't realloc lumpinfo");

    lump_p = &lumpinfo[startlump];
	
    storehandle = reloadname ? (BPTR)-1 : handle;
	
    for (i=startlump ; i<numlumps ; i++,lump_p++, fileinfo++)
    {
	lump_p->handle = storehandle;
	lump_p->position = LONG(fileinfo->filepos);
	lump_p->size = LONG(fileinfo->size);

/* hallohallohallo*/

	i2=strlen(fileinfo->name);
	memcpy(lump_p->name,fileinfo->name,8);
	if (i2<8)
	{
		memset(lump_p->name+i2,0,8-i2);
	}
	
/*	strncpy (lump_p->name, fileinfo->name, 8);*/
	
/*		printf("Lump %ld (%s) at offset %ld and size %ld\n",i,lump_p->name,lump_p->position,lump_p->size);*/
    }
	
    if (reloadname) Close (handle);
    
    if (fileinfomem) freea(fileinfomem);
}




/**/
/* W_Reload*/
/* Flushes any of the reloadable lumps in memory*/
/*  and reloads the directory.*/
/**/
void W_Reload (void)
{
    wadinfo_t		header;
    int			lumpcount;
    lumpinfo_t*		lump_p;
    unsigned		i;
    BPTR			handle;
    int			length;
    filelump_t*		fileinfo,*fileinfomem;
	
    if (!reloadname)
	return;
		
    if ( (handle = Open (reloadname,MODE_OLDFILE)) == NULL)
	I_Error ("W_Reload: couldn't open %s",reloadname);

    Read (handle,&header,sizeof(header));
    lumpcount = LONG(header.numlumps);
    header.infotableofs = LONG(header.infotableofs);
    length = lumpcount*sizeof(filelump_t);
    fileinfo = fileinfomem = alloca (length);
    
    Seek (handle, header.infotableofs,OFFSET_BEGINNING);
    Read (handle,fileinfo,length);
    
    /* Fill in lumpinfo*/
    lump_p = &lumpinfo[reloadlump];
	
    for (i=reloadlump ;
	 i<reloadlump+lumpcount ;
	 i++,lump_p++, fileinfo++)
    {
	if (lumpcache[i])
	    Z_Free (lumpcache[i]);

	lump_p->position = LONG(fileinfo->filepos);
	lump_p->size = LONG(fileinfo->size);
    }
	
    Close (handle);
    
    freea(fileinfomem);
}



/**/
/* W_InitMultipleFiles*/
/* Pass a null terminated list of files to use.*/
/* All files are optional, but at least one file*/
/*  must be found.*/
/* Files with a .wad extension are idlink files*/
/*  with multiple lumps.*/
/* Other files are single lumps with the base filename*/
/*  for the lump name.*/
/* Lump names can appear multiple times.*/
/* The name searcher looks backwards, so a later file*/
/*  does override all earlier ones.*/
/**/

typedef struct
{
    long		name1,name2;
    int		handle;
    int		position;
    int		size;
} mylumpinfo_t;

static void W_FindAndDeleteLump(
   mylumpinfo_t* first,    /* first lump in list - stop when get to it */
   mylumpinfo_t* lump_p,   /* lump just after one to start at          */
   mylumpinfo_t *check)  /* name of lump to remove if found          */
/*
 Find lump by name, starting before specifed pointer.
 Overwrite name with nulls if found. This is used to remove
 the originals of sprite entries duplicated in a PWAD, the
 sprite code doesn't like two sprite lumps of the same name
 existing in the sprites list. It may also speed things up
 slightly where flats and ptches are concerned. */

{
    int		v1=check->name1;
    int		v2=check->name2;

    do {
        lump_p--;
    } while ((lump_p != first)
             && ((lump_p->name1 != v1)
                 || (lump_p->name2 != v2)));

    if (lump_p->name1 == v1 &&
    	  lump_p->name2 == v2) memset(lump_p,0,sizeof(lumpinfo_t));
}

static void W_Group(char *startname1,char *startname2,char *endname1,char *endname2)
{
	#define comparename(eins,zwei,drei) ( (((eins)->name1 == zwei[0]) && ((eins)->name2 == zwei[1])) || \
										  			  (((eins)->name1 == drei[0]) && ((eins)->name2 == drei[1])) )
	
	long startmatch[2]={0,0},startmatch2[2]={0,0},endmatch[2]={0,0},endmatch2[2]={0,0};
	long l,newnumlumps=0;
	mylumpinfo_t *source,*lumpinfo2,*dest,*temp;
	
	memcpy(startmatch,startname1,strlen(startname1));
	memcpy(startmatch2,startname2,strlen(startname2));
	memcpy(endmatch,endname1,strlen(endname1));
	memcpy(endmatch2,endname2,strlen(endname2));
	
	source = (mylumpinfo_t *)lumpinfo;
	lumpinfo2 = dest = mymalloc(numlumps * sizeof(mylumpinfo_t));
	
	/* ersten start lump finden */

	for (l=0;l<numlumps;l++,source++)
	{
		if (comparename(source,startmatch,startmatch2))
		{
			break;
		}
	}
	
	if (l<numlumps)
	{
		memcpy(dest++,source,sizeof(mylumpinfo_t));
		
		dest++;
		do
		{ /* skip through entries */
			if (!comparename(source,startmatch,startmatch2))
      {
         source++;
      }
      else
      {
        dest--; /* skip back to overwrite previous s_end */
        memset(source++,0,sizeof(mylumpinfo_t)); /* zap S_START, go to next */
        /* copy rest of this sprite group, including the s_end */

		  for(;;)
		  {
          /* for each sprite, remove the original if it exists */
          W_FindAndDeleteLump(lumpinfo2,dest,source);
          /* copy it */
          memcpy(dest,source,sizeof(mylumpinfo_t));
          /* zap the lump in the original list */
          memset(source++,0,sizeof(lumpinfo_t));
          
          if (comparename(dest,endmatch,endmatch2))
          {
          	memcpy(&dest->name1,endmatch,8);
          	dest++;
          	break;
          }
          dest++;
        }
		}
		
    } while (source < (mylumpinfo_t *)lumpinfo+numlumps);

    /* now copy other, non-sprite entries */
	 source = (mylumpinfo_t *)lumpinfo;

/*  lump_d = at next free slot in lumpinfo_copy */

    while (source < (mylumpinfo_t *)lumpinfo+numlumps)  /* MAJOR CHANGE: this is now a while loop */
    { /* skip through entries */        /* instead of a DO loop */
      if (source->name1 || source->name2)
      {
        memcpy(dest++,source,sizeof(lumpinfo_t));
      }
      source++;
    };

    /* now replace original lumpinfo, squeezing out blanked sprites */
	 /*  lump_d = at next "free slot" in lumpinfo_copy */

    temp=(mylumpinfo_t *)lumpinfo;
    source=lumpinfo2;
    while (source < dest) /* MINOR CHANGE: condition was (lump_s != lump_d) */
    { 
    	if (source->name1 || source->name2)
      {
        newnumlumps++;
        memcpy(temp++,source,sizeof(mylumpinfo_t));
      }
      source++;
    }

/*    printf("Grouped %s: old numlumps=%d, new numlumps=%d\n",
            listtype,numlumps,newnumlumps);
	   getchar();
*/

    numlumps=newnumlumps;
    free(lumpinfo2);

/*
    realloc(lumpinfo,numlumps*sizeof(lumpinfo_t));
    if (!lumpinfo) I_Error ("Out of memory: Couldn't realloc lumpinfo");
*/

	} /* if (l<numlumps) */
}

boolean fixrot;

static void W_GroupPatches(void)
{
	boolean fixsprites=false;
	boolean fixflats=false;
	boolean fixpatches=false;
	
	if (M_CheckParm("-fixall"))
	{
		fixsprites=fixflats=fixpatches=fixrot=true;
	}
	
	if (M_CheckParm("-fixsprites")) fixsprites=true;
	if (M_CheckParm("-fixflats")) fixflats=true;
	if (M_CheckParm("-fixpatches")) fixpatches=true;
	if (M_CheckParm("-fixspriterot")) fixrot=true;
	
	if (fixsprites) W_Group("S_START","SS_START","S_END","SS_END");
	if (fixflats) W_Group("F_START","FF_START","F_END","FF_END");
	if (fixpatches) W_Group("P_START","PP_START","P_END","PP_END");
}

void W_InitMultipleFiles (char** filenames)
{	
    int		size;
    
    /* open all the files, load headers, and count lumps*/
    numlumps = 0;

    /* will be realloced as lumps are added*/
    lumpinfo = mymalloc(1);	

    for ( ; *filenames ; filenames++)
	W_AddFile (*filenames);

    if (!numlumps)
	I_Error ("W_InitFiles: no files found");

	W_GroupPatches();
    
    /* set up caching*/
    size = numlumps * sizeof(*lumpcache);
    lumpcache = mymalloc (size);
    
    if (!lumpcache)
	I_Error ("Couldn't allocate lumpcache");

    memset (lumpcache,0, size);
}




/**/
/* W_InitFile*/
/* Just initialize from a single file.*/
/**/
void W_InitFile (char* filename)
{
    char*	names[2];

    names[0] = filename;
    names[1] = NULL;
    W_InitMultipleFiles (names);
}



/**/
/* W_NumLumps*/
/**/
int W_NumLumps (void)
{
    return numlumps;
}



/**/
/* W_CheckNumForName*/
/* Returns -1 if name not found.*/
/**/

int W_CheckNumForName (char* name)
{
    union {
	char	s[9];
	int	x[2];
	
    } name8;
    
    int		v1;
    int		v2;
    lumpinfo_t*	lump_p;

    /* make the name into two integers for easy compares*/
    

    strncpy (name8.s,name,8);

    /* in case the name was a fill 8 chars*/
    name8.s[8] = 0;

    /* case insensitive*/
    strupr (name8.s);		

    v1 = name8.x[0];
    v2 = name8.x[1];


    /* scan backwards so patch lump files take precedence*/
    lump_p = lumpinfo + numlumps;

    while (lump_p-- != lumpinfo)
    {
	if ( *(int *)lump_p->name == v1
	     && *(int *)&lump_p->name[4] == v2)
	{
	    return lump_p - lumpinfo;
	}
    }

    /* TFB. Not found.*/
    return -1;
}




/**/
/* W_GetNumForName*/
/* Calls W_CheckNumForName, but bombs out if not found.*/
/**/
int W_GetNumForName (char* name)
{
    int	i;

    i = W_CheckNumForName (name);
    
    if (i == -1)
      I_Error ("W_GetNumForName: %s not found!", name);
      
    return i;
}


/**/
/* W_LumpLength*/
/* Returns the buffer size needed to load the given lump.*/
/**/
int W_LumpLength (int lump)
{
    if (lump >= numlumps)
	I_Error ("W_LumpLength: %i >= numlumps",lump);

    return lumpinfo[lump].size;
}



/**/
/* W_ReadLump*/
/* Loads the lump into the given buffer,*/
/*  which must be >= W_LumpLength().*/
/**/
void W_ReadLump
( int		lump,
  void*		dest )
{
    int		c;
    lumpinfo_t*	l;
    BPTR handle;
	
	
    if (lump >= numlumps)
	I_Error ("W_ReadLump: %i >= numlumps",lump);

    l = lumpinfo+lump;
	
    /* ??? I_BeginRead ();*/
	
    if (l->handle == (BPTR)-1)
    {
	/* reloadable file, so use open / read / close*/
	if ( (handle = Open (reloadname,MODE_OLDFILE)) == NULL)
	    I_Error ("W_ReadLump: couldn't open %s",reloadname);
    }
    else
	handle = (BPTR)l->handle;

/*	printf("Reading lump %ld at offset %ld and size %ld\n",lump,l->position,l->size);*/
		
    Seek (handle, l->position, OFFSET_BEGINNING);
/*    c = read (handle, dest, l->size);*/
	 c = Read(handle,dest,l->size);
	 
    if (c < l->size)
	I_Error ("W_ReadLump: only read %i of %i on lump %i",
		 c,l->size,lump);	

    if (l->handle == (BPTR)-1)
	Close (handle);
		
    /* ??? I_EndRead ();*/
}




/**/
/* W_CacheLumpNum*/
/**/

void* WW_CacheLumpNum
( int		lump,
  int		tag )
{
    byte*	ptr;

    if ((unsigned)lump >= numlumps)
	I_Error ("W_CacheLumpNum: %i >= numlumps",lump);
		
    if (!lumpcache[lump])
    {
	/* read the lump in*/
	
	/*printf ("cache miss on lump %i\n",lump);*/
	ptr = Z_Malloc (W_LumpLength (lump), tag, &lumpcache[lump]);
	W_ReadLump (lump, lumpcache[lump]);
    }
    else
    {
	/*printf ("cache hit on lump %i\n",lump);*/
	Z_ChangeTag (lumpcache[lump],tag);
    }
	
    return lumpcache[lump];
}


/**/
/* W_CacheLumpName*/
/**/
void* W_CacheLumpName
( char*		name,
  int		tag )
{
    return W_CacheLumpNum (W_GetNumForName(name), tag);
}


/**/
/* W_Profile*/
/**/
int		info[2500][10];
int		profilecount;

void W_Profile (void)
{
    int		i;
    memblock_t*	block;
    void*	ptr;
    char	ch;
    FILE 	*f;
    int		j;
    char	name[9];
	
	
    for (i=0 ; i<numlumps ; i++)
    {	
	ptr = lumpcache[i];
	if (!ptr)
	{
	    ch = ' ';
	    continue;
	}
	else
	{
	    block = (memblock_t *) ( (byte *)ptr - sizeof(memblock_t));
	    if (block->tag < PU_PURGELEVEL)
		ch = 'S';
	    else
		ch = 'P';
	}
	info[i][profilecount] = ch;
    }
    profilecount++;
	
    f = fopen ("waddump.txt","w");
    name[8] = 0;

    for (i=0 ; i<numlumps ; i++)
    {
	memcpy (name,lumpinfo[i].name,8);

	for (j=0 ; j<8 ; j++)
	    if (!name[j])
		break;

	for ( ; j<8 ; j++)
	    name[j] = ' ';

	fprintf (f,"%s ",name);

	for (j=0 ; j<profilecount ; j++)
	    fprintf (f,"    %c",info[i][j]);

	fprintf (f,"\n");
    }
    fclose (f);
}

void W_Cleanup(void)
{
	while (numopenfiles)
	{
		Close(filehandles[--numopenfiles]);
	}
}


