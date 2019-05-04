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
/*	The actual span/column drawing functions.*/
/*	Here find the main potential for optimization,*/
/*	 e.g. inline assembly, different algorithms.*/
/**/
/*-----------------------------------------------------------------------------*/

static const char rcsid[] = "$Id: r_draw.c,v 1.4 1997/02/03 16:47:55 b1 Exp $";

#include "doomdef.h"

#include "i_system.h"
#include "w_wad.h"
#include "z_zone.h"

#include "r_local.h"

/* Needs access to LFB (guess what).*/
#include "v_video.h"

/* State.*/
#include "doomstat.h"

/* ?*/
#define MAXWIDTH 1120
#define MAXHEIGHT 832

/* status bar height at bottom of screen*/
#define SBARHEIGHT (32 << MEDRES)

/**/
/* All drawing to the view buffer is accomplished in this file.*/
/* The other refresh files only know about ccordinates,*/
/*  not the architecture of the frame buffer.*/
/* Conveniently, the frame buffer is a linear one,*/
/*  and we need only the base address,*/
/*  and the total size == width*height*depth/8.,*/
/**/

extern byte* viewimage;
extern int viewwidth;
extern int scaledviewwidth;
extern int viewheight;
extern int viewwindowx;
extern int viewwindowy;
extern byte* ylookup[MAXHEIGHT];
extern int columnofs[MAXWIDTH];

/* Color tables for different players,*/
/*  translate a limited part to another*/
/*  (color ramps used for  suit colors).*/
/**/
byte translations[3][256];

/**/
/* R_DrawColumn*/
/* Source is the top of the column to scale.*/
/**/
extern lighttable_t* dc_colormap;
extern int dc_x;
extern int dc_yl;
extern int dc_yh;
extern fixed_t dc_iscale;
extern fixed_t dc_texturemid;

/* first pixel in a column (possibly virtual) */
extern byte* dc_source;

/* just for profiling */
int dccount;

/**/
/* A column is a vertical slice/span from a wall texture that,*/
/*  given the DOOM style restrictions on the view orientation,*/
/*  will always have constant z depth.*/
/* Thus a special case loop for very fast rendering can*/
/*  be used. It has also been used with Wolfenstein 3D.*/
/* */

#ifdef hallohallohallo
void R_DrawColumn(void)
{
    int count;
    byte* dest;
    fixed_t frac;
    fixed_t fracstep;

    count = dc_yh - dc_yl;

    /* Zero length, column does not exceed a pixel.*/
    if (count < 0)
        return;

#ifdef RANGECHECK
    if ((unsigned)dc_x >= SCREENWIDTH || dc_yl < 0 || dc_yh >= REALSCREENHEIGHT) {
        /* hallohallohallo*/
        /* I_Error ("R_DrawColumn: %i to %i at %i", dc_yl, dc_yh, dc_x); */
        return;
    }
#endif

    /* Framebuffer destination address.*/
    /* Use ylookup LUT to avoid multiply with ScreenWidth.*/
    /* Use columnofs LUT for subwindows? */
    dest = ylookup[dc_yl] + columnofs[dc_x];

    /* Determine scaling,*/
    /*  which is the only mapping to be done.*/
    fracstep = dc_iscale;
    frac = dc_texturemid + (dc_yl - centery) * fracstep;

    /* Inner loop that does the actual texture mapping,*/
    /*  e.g. a DDA-lile scaling.*/
    /* This is as fast as it gets.*/
    do {
        /* Re-map color indices from wall texture column*/
        /*  using a lighting/special effects LUT.*/
        *dest = dc_colormap[dc_source[(frac >> FRACBITS) & 127]];

        dest += SCREENWIDTH;
        frac += fracstep;

    } while (count--);
}
#endif

/* UNUSED.*/
/* Loop unrolled.*/
#if 0
void R_DrawColumn (void) 
{ 
    int			count; 
    byte*		source;
    byte*		dest;
    byte*		colormap;
    
    unsigned		frac;
    unsigned		fracstep;
    unsigned		fracstep2;
    unsigned		fracstep3;
    unsigned		fracstep4;	 
 
    count = dc_yh - dc_yl + 1; 

    source = dc_source;
    colormap = dc_colormap;		 
    dest = ylookup[dc_yl] + columnofs[dc_x];  
	 
    fracstep = dc_iscale<<9; 
    frac = (dc_texturemid + (dc_yl-centery)*dc_iscale)<<9; 
 
    fracstep2 = fracstep+fracstep;
    fracstep3 = fracstep2+fracstep;
    fracstep4 = fracstep3+fracstep;
	
    while (count >= 8) 
    { 
	dest[0] = colormap[source[frac>>25]]; 
	dest[SCREENWIDTH] = colormap[source[(frac+fracstep)>>25]]; 
	dest[SCREENWIDTH*2] = colormap[source[(frac+fracstep2)>>25]]; 
	dest[SCREENWIDTH*3] = colormap[source[(frac+fracstep3)>>25]];
	
	frac += fracstep4; 

	dest[SCREENWIDTH*4] = colormap[source[frac>>25]]; 
	dest[SCREENWIDTH*5] = colormap[source[(frac+fracstep)>>25]]; 
	dest[SCREENWIDTH*6] = colormap[source[(frac+fracstep2)>>25]]; 
	dest[SCREENWIDTH*7] = colormap[source[(frac+fracstep3)>>25]]; 

	frac += fracstep4; 
	dest += SCREENWIDTH*8; 
	count -= 8;
    } 
	
    while (count > 0)
    { 
	*dest = colormap[source[frac>>25]]; 
	dest += SCREENWIDTH; 
	frac += fracstep; 
	count--;
    } 
}
#endif

#ifdef hallohallohallo
void R_DrawColumnLow(void)
{
    int count;
    byte* dest;
    byte* dest2;
    fixed_t frac;
    fixed_t fracstep;

    count = dc_yh - dc_yl;

    /* Zero length.*/
    if (count < 0)
        return;

#ifdef RANGECHECK
    if ((unsigned)dc_x >= SCREENWIDTH || dc_yl < 0 || dc_yh >= REALSCREENHEIGHT) {
        I_Error("R_DrawColumn: %i to %i at %i", dc_yl, dc_yh, dc_x);
    }
/*	dccount++; */
#endif
    /* Blocky mode, need to multiply by 2.*/
    dc_x <<= 1;

    dest = ylookup[dc_yl] + columnofs[dc_x];
    dest2 = ylookup[dc_yl] + columnofs[dc_x + 1];

    fracstep = dc_iscale;
    frac = dc_texturemid + (dc_yl - centery) * fracstep;

    do {
        /* Hack. Does not work corretly.*/
        *dest2 = *dest = dc_colormap[dc_source[(frac >> FRACBITS) & 127]];
        dest += SCREENWIDTH;
        dest2 += SCREENWIDTH;
        frac += fracstep;

    } while (count--);
}
#endif

/**/
/* Spectre/Invisibility.*/
/**/

#define FUZZTABLE 50
#define FUZZOFF (SCREENWIDTH)

static int thefuzzoffset[FUZZTABLE] = {
    FUZZOFF,  -FUZZOFF, FUZZOFF,  -FUZZOFF, FUZZOFF,  FUZZOFF,  -FUZZOFF, FUZZOFF,  FUZZOFF,  -FUZZOFF,
    FUZZOFF,  FUZZOFF,  FUZZOFF,  -FUZZOFF, FUZZOFF,  FUZZOFF,  FUZZOFF,  -FUZZOFF, -FUZZOFF, -FUZZOFF,
    -FUZZOFF, FUZZOFF,  -FUZZOFF, -FUZZOFF, FUZZOFF,  FUZZOFF,  FUZZOFF,  FUZZOFF,  -FUZZOFF, FUZZOFF,
    -FUZZOFF, FUZZOFF,  FUZZOFF,  -FUZZOFF, -FUZZOFF, FUZZOFF,  FUZZOFF,  -FUZZOFF, -FUZZOFF, -FUZZOFF,
    -FUZZOFF, FUZZOFF,  FUZZOFF,  FUZZOFF,  FUZZOFF,  -FUZZOFF, FUZZOFF,  FUZZOFF,  -FUZZOFF, FUZZOFF};

int fuzzpos = 0;

int fuzzoffset[MAXSCREENHEIGHT + FUZZTABLE];

void R_InitFuzz(void)
{
    int i;

    for (i = 0; i < (MAXSCREENHEIGHT + FUZZTABLE); i++) {
        fuzzoffset[i] = thefuzzoffset[i % FUZZTABLE] * REALSCREENWIDTH / SCREENWIDTH;
    }
}

#ifdef hallohallohallo
/**/
/* Framebuffer postprocessing.*/
/* Creates a fuzzy image by copying pixels*/
/*  from adjacent ones to left and right.*/
/* Used with an all black colormap, this*/
/*  could create the SHADOW effect,*/
/*  i.e. spectres and invisible players.*/
/**/
void R_DrawFuzzColumn(void)
{
    int count;
    byte* dest;
    fixed_t frac;
    fixed_t fracstep;

    /* Adjust borders. Low... */
    if (!dc_yl)
        dc_yl = 1;

    /* .. and high.*/
    if (dc_yh == viewheight - 1)
        dc_yh = viewheight - 2;

    count = dc_yh - dc_yl;

    /* Zero length.*/
    if (count < 0)
        return;

#ifdef RANGECHECK
    if ((unsigned)dc_x >= SCREENWIDTH || dc_yl < 0 || dc_yh >= REALSCREENHEIGHT) {
        I_Error("R_DrawFuzzColumn: %i to %i at %i", dc_yl, dc_yh, dc_x);
    }
#endif

    /* Keep till detailshift bug in blocky mode fixed,*/
    /*  or blocky mode removed.*/
    /* WATCOM code
    if (detailshift)
    {
    if (dc_x & 1)
    {
        outpw (GC_INDEX,GC_READMAP+(2<<8) );
        outp (SC_INDEX+1,12);
    }
    else
    {
        outpw (GC_INDEX,GC_READMAP);
        outp (SC_INDEX+1,3);
    }
    dest = destview + dc_yl*80 + (dc_x>>1);
    }
    else
    {
    outpw (GC_INDEX,GC_READMAP+((dc_x&3)<<8) );
    outp (SC_INDEX+1,1<<(dc_x&3));
    dest = destview + dc_yl*80 + (dc_x>>2);
    }*/

    /* Does not work with blocky mode.*/
    dest = ylookup[dc_yl] + columnofs[dc_x];

    /* Looks familiar.*/
    fracstep = dc_iscale;
    frac = dc_texturemid + (dc_yl - centery) * fracstep;

    /* Looks like an attempt at dithering,*/
    /*  using the colormap #6 (of 0-31, a bit*/
    /*  brighter than average).*/
    do {
        /* Lookup framebuffer, and retrieve*/
        /*  a pixel that is either one column*/
        /*  left or right of the current one.*/
        /* Add index from colormap to index.*/
        *dest = colormaps[6 * 256 + dest[fuzzoffset[fuzzpos]]];

        /* Clamp table lookup index.*/
        if (++fuzzpos == FUZZTABLE)
            fuzzpos = 0;

        dest += SCREENWIDTH;

        frac += fracstep;
    } while (count--);
}
#endif

/**/
/* R_DrawTranslatedColumn*/
/* Used to draw player sprites*/
/*  with the green colorramp mapped to others.*/
/* Could be used with different translation*/
/*  tables, e.g. the lighter colored version*/
/*  of the BaronOfHell, the HellKnight, uses*/
/*  identical sprites, kinda brightened up.*/
/**/
extern byte* dc_translation;
byte* translationtables;

#ifdef hallohallohallo
void R_DrawTranslatedColumn(void)
{
    int count;
    byte* dest;
    fixed_t frac;
    fixed_t fracstep;

    count = dc_yh - dc_yl;
    if (count < 0)
        return;

#ifdef RANGECHECK
    if ((unsigned)dc_x >= SCREENWIDTH || dc_yl < 0 || dc_yh >= REALSCREENHEIGHT) {
        I_Error("R_DrawColumn: %i to %i at %i", dc_yl, dc_yh, dc_x);
    }

#endif

    /* WATCOM VGA specific.*/
    /* Keep for fixing.
    if (detailshift)
    {
    if (dc_x & 1)
        outp (SC_INDEX+1,12);
    else
        outp (SC_INDEX+1,3);

    dest = destview + dc_yl*80 + (dc_x>>1);
    }
    else
    {
    outp (SC_INDEX+1,1<<(dc_x&3));

    dest = destview + dc_yl*80 + (dc_x>>2);
    }*/

    /* FIXME. As above.*/
    dest = ylookup[dc_yl] + columnofs[dc_x];

    /* Looks familiar.*/
    fracstep = dc_iscale;
    frac = dc_texturemid + (dc_yl - centery) * fracstep;

    /* Here we do an additional index re-mapping.*/
    do {
        /* Translation tables are used*/
        /*  to map certain colorramps to other ones,*/
        /*  used with PLAY sprites.*/
        /* Thus the "green" ramp of the player 0 sprite*/
        /*  is mapped to gray, red, black/indigo. */
        *dest = dc_colormap[dc_translation[dc_source[frac >> FRACBITS]]];
        dest += SCREENWIDTH;

        frac += fracstep;
    } while (count--);
}
#endif

/**/
/* R_InitTranslationTables*/
/* Creates the translation tables to map*/
/*  the green color ramp to gray, brown, red.*/
/* Assumes a given structure of the PLAYPAL.*/
/* Could be read from a lump instead.*/
/**/
void R_InitTranslationTables(void)
{
    int i;

    translationtables = Z_Malloc(256 * 3 + 255, PU_STATIC, 0);
    translationtables = (byte*)(((int)translationtables + 255) & ~255);

    /* translate just the 16 green colors*/
    for (i = 0; i < 256; i++) {
        if (i >= 0x70 && i <= 0x7f) {
            /* map green ramp to gray, brown, red*/
            translationtables[i] = 0x60 + (i & 0xf);
            translationtables[i + 256] = 0x40 + (i & 0xf);
            translationtables[i + 512] = 0x20 + (i & 0xf);
        } else {
            /* Keep all other colors as is.*/
            translationtables[i] = translationtables[i + 256] = translationtables[i + 512] = i;
        }
    }
}

/**/
/* R_DrawSpan */
/* With DOOM style restrictions on view orientation,*/
/*  the floors and ceilings consist of horizontal slices*/
/*  or spans with constant z depth.*/
/* However, rotation around the world z axis is possible,*/
/*  thus this mapping, while simpler and faster than*/
/*  perspective correct texture mapping, has to traverse*/
/*  the texture at an angle in all but a few cases.*/
/* In consequence, flats are not stored by column (like walls),*/
/*  and the inner loop has to step in texture space u and v.*/
/**/
extern int ds_y;
extern int ds_x1;
extern int ds_x2;

extern lighttable_t* ds_colormap;

extern fixed_t ds_xfrac;
extern fixed_t ds_yfrac;
extern fixed_t ds_xstep;
extern fixed_t ds_ystep;

/* start of a 64*64 tile image */
extern byte* ds_source;

/* just for profiling*/
int dscount;

#if 1

typedef union {
    fixed_t f;
    struct
    {
        unsigned int topbits : 4;
        unsigned int t : 4;
        unsigned int ty : 2;
        unsigned int frac : 20;
    };
} YFrac;

typedef union {
    fixed_t f;
    struct
    {
        unsigned int topbits : 10;
        unsigned int ttx : 6;
        unsigned int frac : 16;
    };
} XFrac;

/**/
/* Draws the actual span.*/
void R_DrawSpan(void)
{
    int count;
//    int spot;

#ifdef RANGECHECK
    if (ds_x2 < ds_x1 || ds_x1 < 0 || ds_x2 >= SCREENWIDTH || (unsigned)ds_y > REALSCREENHEIGHT) {
        I_Error("R_DrawSpan: %i to %i at %i", ds_x1, ds_x2, ds_y);
    }
/*	dscount++; */
#endif

    /* We do not check for zero spans here?*/
    count = ds_x2 - ds_x1;
    if (!count) {
        return;
    }

    fixed_t xfrac = ds_xfrac;
    fixed_t yfrac = ds_yfrac;
    byte* dest = ylookup[ds_y] + columnofs[ds_x1];

    lighttable_t const* const light = ds_colormap;
    byte const* const source = ds_source;
    const fixed_t dx = ds_xstep;
    const fixed_t dy = ds_ystep;

    do {
        short spot = ((((YFrac)yfrac).t) << 8) | (((YFrac)yfrac).ty) | ((((XFrac)xfrac).ttx )<< 2);

        /* Lookup pixel from flat texture tile,*/
        /*  re-index using light/colormap.*/
        *dest++ = light[source[spot]];

        /* Next step in u,v.*/
        xfrac += dx;
        yfrac += dy;

    } while (count--);
}
#endif

/* UNUSED.*/
/* Loop unrolled by 4.*/
#if 0
void R_DrawSpan (void) 
{ 
    unsigned	position, step;

    byte*	source;
    byte*	colormap;
    byte*	dest;
    
    unsigned	count;
    usingned	spot; 
    unsigned	value;
    unsigned	temp;
    unsigned	xtemp;
    unsigned	ytemp;
		
    position = ((ds_xfrac<<10)&0xffff0000) | ((ds_yfrac>>6)&0xffff);
    step = ((ds_xstep<<10)&0xffff0000) | ((ds_ystep>>6)&0xffff);
		
    source = ds_source;
    colormap = ds_colormap;
    dest = ylookup[ds_y] + columnofs[ds_x1];	 
    count = ds_x2 - ds_x1 + 1; 
	
    while (count >= 4) 
    { 
	ytemp = position>>4;
	ytemp = ytemp & 4032;
	xtemp = position>>26;
	spot = xtemp | ytemp;
	position += step;
	dest[0] = colormap[source[spot]]; 

	ytemp = position>>4;
	ytemp = ytemp & 4032;
	xtemp = position>>26;
	spot = xtemp | ytemp;
	position += step;
	dest[1] = colormap[source[spot]];
	
	ytemp = position>>4;
	ytemp = ytemp & 4032;
	xtemp = position>>26;
	spot = xtemp | ytemp;
	position += step;
	dest[2] = colormap[source[spot]];
	
	ytemp = position>>4;
	ytemp = ytemp & 4032;
	xtemp = position>>26;
	spot = xtemp | ytemp;
	position += step;
	dest[3] = colormap[source[spot]]; 
		
	count -= 4;
	dest += 4;
    } 
    while (count > 0) 
    { 
	ytemp = position>>4;
	ytemp = ytemp & 4032;
	xtemp = position>>26;
	spot = xtemp | ytemp;
	position += step;
	*dest++ = colormap[source[spot]]; 
	count--;
    } 
}
#endif

#ifdef hallo
/**/
/* Again..*/
/**/
void R_DrawSpanLow(void)
{
    fixed_t xfrac;
    fixed_t yfrac;
    byte* dest;
    int count;
    int spot;

#ifdef RANGECHECK
    if (ds_x2 < ds_x1 || ds_x1 < 0 || ds_x2 >= SCREENWIDTH || (unsigned)ds_y > REALSCREENHEIGHT) {
        I_Error("R_DrawSpan: %i to %i at %i", ds_x1, ds_x2, ds_y);
    }
/*	dscount++; */
#endif

    xfrac = ds_xfrac;
    yfrac = ds_yfrac;

    /* Blocky mode, need to multiply by 2.*/
    ds_x1 <<= 1;
    ds_x2 <<= 1;

    dest = ylookup[ds_y] + columnofs[ds_x1];

    count = ds_x2 - ds_x1;
    do {
        spot = ((yfrac >> (16 - 6)) & (63 * 64)) + ((xfrac >> 16) & 63);
        /* Lowres/blocky mode does it twice,*/
        /*  while scale is adjusted appropriately.*/
        *dest++ = ds_colormap[ds_source[spot]];
        *dest++ = ds_colormap[ds_source[spot]];

        xfrac += ds_xstep;
        yfrac += ds_ystep;

    } while (count--);
}
#endif

/**/
/* R_InitBuffer */
/* Creats lookup tables that avoid*/
/*  multiplies and other hazzles*/
/*  for getting the framebuffer address*/
/*  of a pixel to draw.*/
/**/
void R_InitBuffer(int width, int height)
{
    int i;

    /* Handle resize,*/
    /*  e.g. smaller view windows*/
    /*  with border and/or status bar.*/
    viewwindowx = (REALSCREENWIDTH - width) >> 1;

    /* Column offset. For windows.*/
    for (i = 0; i < width; i++)
        columnofs[i] = viewwindowx + i;

    /* Samw with base row offset.*/
    if (width == REALSCREENWIDTH)
        viewwindowy = 0;
    else
        viewwindowy = (REALSCREENHEIGHT - SBARHEIGHT - height) >> 1;

    /* Preclaculate all row offsets.*/
    for (i = 0; i < height; i++)
        ylookup[i] = screens[0] + (i + viewwindowy) * REALSCREENWIDTH;
}

/**/
/* R_FillBackScreen*/
/* Fills the back screen with a pattern*/
/*  for variable screen sizes*/
/* Also draws a beveled edge.*/
/**/

extern int hudmap;

void R_FillBackScreen(void)
{
    byte* src;
    byte* dest;
    int x;
    int y;
    patch_t *patch, *patch2;

    /* DOOM border patch.*/
    char name1[] = "FLOOR7_2";

    /* DOOM II border patch.*/
    char name2[] = "GRNROCK";

    char* name;

    if ((scaledviewwidth == REALSCREENWIDTH) && (viewheight == REALSCREENHEIGHT) && !(automapactive && hudmap == 0))
        return;

    if (gamemode == commercial)
        name = name2;
    else
        name = name1;

    src = W_CacheLumpName(name, PU_CACHE);
    dest = screens[1];

    for (y = 0; y < REALSCREENHEIGHT /*-SBARHEIGHT*/; y++) {
        for (x = 0; x < REALSCREENWIDTH / 64; x++) {
            memcpy(dest, src + ((y & 63) << 6), 64);
            dest += 64;
        }

        if (REALSCREENWIDTH & 63) {
            memcpy(dest, src + ((y & 63) << 6), REALSCREENWIDTH & 63);
            dest += (REALSCREENWIDTH & 63);
        }
    }

    if (scaledviewwidth < REALSCREENWIDTH) {
        patch = W_CacheLumpName("brdr_t", PU_STATIC);
        patch2 = W_CacheLumpName("brdr_b", PU_STATIC);

        for (x = 0; x < scaledviewwidth; x += 8) {
            V_DrawPatch(viewwindowx + x, viewwindowy - 8, 1, patch);
            V_DrawPatch(viewwindowx + x, viewwindowy + viewheight, 1, patch2);
        }
        Z_ChangeTag(patch, PU_CACHE);
        Z_ChangeTag2(patch2, PU_CACHE);

        patch = W_CacheLumpName("brdr_l", PU_STATIC);
        patch2 = W_CacheLumpName("brdr_r", PU_STATIC);

        for (y = 0; y < viewheight; y += 8) {
            V_DrawPatch(viewwindowx - 8, viewwindowy + y, 1, patch);
            V_DrawPatch(viewwindowx + scaledviewwidth, viewwindowy + y, 1, patch2);
        }

        Z_ChangeTag(patch, PU_CACHE);
        Z_ChangeTag(patch2, PU_CACHE);

        /* Draw beveled edge. */
        V_DrawPatch(viewwindowx - 8, viewwindowy - 8, 1, W_CacheLumpName("brdr_tl", PU_CACHE));

        V_DrawPatch(viewwindowx + scaledviewwidth, viewwindowy - 8, 1, W_CacheLumpName("brdr_tr", PU_CACHE));

        V_DrawPatch(viewwindowx - 8, viewwindowy + viewheight, 1, W_CacheLumpName("brdr_bl", PU_CACHE));

        V_DrawPatch(viewwindowx + scaledviewwidth, viewwindowy + viewheight, 1, W_CacheLumpName("brdr_br", PU_CACHE));

    } else if (REALSCREENWIDTH > SCREENWIDTH) {
        patch = W_CacheLumpName("brdr_b", PU_STATIC);
        patch2 = W_CacheLumpName("brdr_t", PU_STATIC);

        for (x = 0; x < REALSCREENWIDTH; x += 8) {
            V_DrawPatch(x, REALSCREENHEIGHT - SBARHEIGHT, 1, patch);
            V_DrawPatch(x, REALSCREENHEIGHT - 8, 1, patch2);
        }

        Z_ChangeTag(patch, PU_CACHE);
        Z_ChangeTag(patch2, PU_CACHE);

        patch = W_CacheLumpName("brdr_r", PU_STATIC);
        patch2 = W_CacheLumpName("brdr_l", PU_STATIC);

        for (y = REALSCREENHEIGHT - SBARHEIGHT; y < REALSCREENHEIGHT; y += 8) {
            V_DrawPatch(0, y, 1, patch);
            V_DrawPatch(REALSCREENWIDTH - 8, y, 1, patch2);
            V_DrawPatch((REALSCREENWIDTH - SCREENWIDTH) / 2 - 8, y, 1, patch2);
            V_DrawPatch(REALSCREENWIDTH - (REALSCREENWIDTH - SCREENWIDTH) / 2, y, 1, patch);
        }

        Z_ChangeTag(patch, PU_CACHE);
        Z_ChangeTag(patch2, PU_CACHE);

        V_DrawPatch(0, REALSCREENHEIGHT - SBARHEIGHT, 1, W_CacheLumpName("brdr_br", PU_CACHE));
        V_DrawPatch(REALSCREENWIDTH - 8, REALSCREENHEIGHT - SBARHEIGHT, 1, W_CacheLumpName("brdr_bl", PU_CACHE));
        V_DrawPatch(0, REALSCREENHEIGHT - 8, 1, W_CacheLumpName("brdr_tr", PU_CACHE));
        V_DrawPatch(REALSCREENWIDTH - 8, REALSCREENHEIGHT - 8, 1, W_CacheLumpName("brdr_tl", PU_CACHE));

        V_DrawPatch((REALSCREENWIDTH - SCREENWIDTH) / 2 - 8, REALSCREENHEIGHT - SBARHEIGHT, 1,
                    W_CacheLumpName("brdr_bl", PU_CACHE));
        V_DrawPatch(REALSCREENWIDTH - (REALSCREENWIDTH - SCREENWIDTH) / 2, REALSCREENHEIGHT - SBARHEIGHT, 1,
                    W_CacheLumpName("brdr_br", PU_CACHE));
        V_DrawPatch((REALSCREENWIDTH - SCREENWIDTH) / 2 - 8, REALSCREENHEIGHT - 8, 1,
                    W_CacheLumpName("brdr_tl", PU_CACHE));
        V_DrawPatch(REALSCREENWIDTH - (REALSCREENWIDTH - SCREENWIDTH) / 2, REALSCREENHEIGHT - 8, 1,
                    W_CacheLumpName("brdr_tr", PU_CACHE));
    }
}

/**/
/* Copy a screen buffer.*/
/**/
void R_VideoErase(unsigned ofs, int count)
{
    /* LFB copy.*/
    /* This might not be a good idea if memcpy*/
    /*  is not optiomal, e.g. byte by byte on*/
    /*  a 32bit CPU, as GNU GCC/Linux libc did*/
    /*  at one point.*/
    memcpy(screens[0] + ofs, screens[1] + ofs, count);
}

/**/
/* R_DrawViewBorder*/
/* Draws the border around the view*/
/*  for different size windows?*/
/**/
void V_MarkRect(int x, int y, int width, int height);

void R_DrawViewBorder(void)
{
    int top;
    int side, side2;
    int ofs;
    int i;

    if ((REALSCREENWIDTH > SCREENWIDTH) && ((REALSCREENHEIGHT != viewheight) || (automapactive && hudmap == 0))) {
        ofs = (REALSCREENHEIGHT - SBARHEIGHT) * REALSCREENWIDTH;
        side = (REALSCREENWIDTH - SCREENWIDTH) / 2;
        side2 = side * 2;
        R_VideoErase(ofs, side);

        ofs += (REALSCREENWIDTH - side);
        for (i = 1; i < SBARHEIGHT; i++) {
            R_VideoErase(ofs, side2);
            ofs += REALSCREENWIDTH;
        }
        R_VideoErase(ofs, side);
    }

    if (viewheight >= (REALSCREENHEIGHT - SBARHEIGHT))
        return;

    /*    if (scaledviewwidth == REALSCREENWIDTH)
        return; */

    top = ((REALSCREENHEIGHT - SBARHEIGHT) - viewheight) / 2;
    side = (REALSCREENWIDTH - scaledviewwidth) / 2;

    /* copy top and one line of left side */
    R_VideoErase(0, top * REALSCREENWIDTH + side);

    /* copy one line of right side and bottom */
    ofs = (viewheight + top) * REALSCREENWIDTH - side;
    R_VideoErase(ofs, top * REALSCREENWIDTH + side);

    /* copy sides using wraparound */
    ofs = top * REALSCREENWIDTH + REALSCREENWIDTH - side;
    side <<= 1;

    for (i = 1; i < viewheight; i++) {
        R_VideoErase(ofs, side);
        ofs += REALSCREENWIDTH;
    }

    /* ? */
    V_MarkRect(0, 0, REALSCREENWIDTH, REALSCREENHEIGHT - SBARHEIGHT);
}
