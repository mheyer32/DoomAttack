	MACHINE 68020
	FPU

	INCDIR AINCLUDE:
	
	include "r_engine.i"
	include "d_net.i"
	
	XREF	_I_Error
	XREF	_R_MapPlane
	XREF	_WW_CacheLumpNum

	XREF	_xtoviewangle
	XREF	_lumpcache
	XREF	_zlight
	XREF	_spanstart
	XREF	_cachedheight
	XREF	_cacheddistance
	XREF	_cachedxstep
	XREF	_cachedystep
	XREF	_distscale
	XREF	_finesine
	XREF	_numnodes
	XREF	_subsectors

	SECTION	.text,CODE


;/***************************************************/
;/*                                                 */
;/*       PATCHING                                  */
;/*                                                 */
;/***************************************************/

	XDEF	_R_PatchEngine

PATCH_FACTORBYTE = 1
PATCH_FACTORWORD = 2
PATCH_FACTORLONG = 3
PATCH_FACTORLONGM1 = 4
PATCH_ADDDIFF2WORD = 5
PATCH_DONE = -1

_R_PatchEngine:
	movem.l	d2-d3/a6,-(sp)

	lea		.PatchTable(pc),a0

	move.l	#SCREENWIDTH,d0
	move.l	_REALSCREENWIDTH(pc),d1
	move.l	d1,d2
	sub.l		d0,d2
	
.loop:
	movem.l	(a0)+,d3/a1
	cmp.l		#PATCH_FACTORWORD,d3
	bne.s		.no
	
	move		(a1),d3
	ext.l		d3
	muls.l	d1,d3
	divs.l	d0,d3
	move		d3,(a1)
	bra.s		.loop
	
.no:
	cmp.l		#PATCH_FACTORLONG,d3
	bne.s		.no2
	
	move.l	(a1),d3
	muls.l	d1,d3
	divs.l	d0,d3
	move.l	d3,(a1)
	bra.s		.loop
	
.no2:
	cmp.l		#PATCH_FACTORBYTE,d3
	bne.s		.no3
	
	move.b	(a1),d3
	extb.l	d3
	muls.l	d1,d3
	divs.l	d0,d3
	move.b	d3,(a1)
	bra.s		.loop
	
.no3:
	cmp.l		#PATCH_ADDDIFF2WORD,d3
	bne.s		.no4
	
	move		(a1),d3
	add		d2,d3
	add		d2,d3
	move		d3,(a1)
	bra.s		.loop
	
.no4:
	cmp.l		#PATCH_FACTORLONGM1,d3
	bne.s		.done
	
	move.l	(a1),d3
	addq.l	#1,d3
	muls.l	d1,d3
	divs.l	d0,d3
	subq.l	#1,d3
	move.l	d3,(a1)
	bra.s		.loop

.done:

	;/* crosshairs */
	
	lea		crosshairgrafik(pc),a0

.loop2:
	move		(a0),d3
	
	cmp		#$6FFF,d3
	bne.s		.not

	addq.l	#2,a0
	bra.s		.loop2
	
.not:
	cmp		#$7FFF,d3
	beq.s		.exit
	
	move		d3,d2
	lsr		#8,d3
	ext		d3
	muls		d1,d3
	
	ext		d2
	add		d2,d3
	
	move		d3,(a0)+
	bra.s		.loop2

.exit:	
	move.l	4.w,a6
	jsr		-636(a6)			;'CacheClearU

	movem.l	(sp)+,d2-d3/a6
	rts

.PatchTable:
	dc.l	PATCH_FACTORLONG,__RESPATCH1+2
	dc.l	PATCH_ADDDIFF2WORD,__RESPATCH2+2
	dc.l	PATCH_FACTORBYTE,__RESPATCH3+1
	dc.l	PATCH_ADDDIFF2WORD,__RESPATCH4+2
	dc.l	PATCH_FACTORBYTE,__RESPATCH5+1
	dc.l	PATCH_FACTORWORD,__RESPATCH6+2
	
	dc.l	PATCH_FACTORWORD,__RESPATCH7
	dc.l	PATCH_FACTORWORD,__RESPATCH7+2
	dc.l	PATCH_FACTORWORD,__RESPATCH7+4
	
	dc.l	PATCH_FACTORWORD,__RESPATCH8+2
	dc.l	PATCH_FACTORWORD,__RESPATCH9+2
	dc.l	PATCH_FACTORWORD,__RESPATCH10+2
	
	dc.l	PATCH_FACTORWORD,__RESPATCH11+2
	
	dc.l	PATCH_FACTORWORD,__RESPATCH12
	dc.l	PATCH_FACTORWORD,__RESPATCH12+2
	dc.l	PATCH_FACTORWORD,__RESPATCH12+4
	
	dc.l	PATCH_FACTORWORD,__RESPATCH13+2
	dc.l	PATCH_FACTORWORD,__RESPATCH14+2
	dc.l	PATCH_FACTORWORD,__RESPATCH15+2
	
	dc.l	PATCH_FACTORWORD,__RESPATCH16+2
	
	dc.l	PATCH_FACTORWORD,__RESPATCH17
	dc.l	PATCH_FACTORWORD,__RESPATCH17+2
	dc.l	PATCH_FACTORWORD,__RESPATCH17+4
	
	dc.l	PATCH_FACTORWORD,__RESPATCH18+2
	dc.l	PATCH_FACTORWORD,__RESPATCH19+2
	dc.l	PATCH_FACTORWORD,__RESPATCH20+2

	dc.l	PATCH_FACTORWORD,__RESPATCH21+2
	
	dc.l	PATCH_FACTORWORD,__RESPATCH22
	dc.l	PATCH_FACTORWORD,__RESPATCH22+2
	dc.l	PATCH_FACTORWORD,__RESPATCH22+4
	
	dc.l	PATCH_FACTORWORD,__RESPATCH23+2
	dc.l	PATCH_FACTORWORD,__RESPATCH24+2
	dc.l	PATCH_FACTORWORD,__RESPATCH25+2
	
	dc.l	PATCH_FACTORWORD,__RESPATCH26+2

	dc.l	PATCH_FACTORWORD,__RESPATCH27
	dc.l	PATCH_FACTORWORD,__RESPATCH27+2
	dc.l	PATCH_FACTORWORD,__RESPATCH27+4
	
	dc.l	PATCH_FACTORWORD,__RESPATCH28+2
	dc.l	PATCH_FACTORWORD,__RESPATCH29+2
	dc.l	PATCH_FACTORWORD,__RESPATCH30+2
;	dc.l	PATCH_FACTORWORD,__RESPATCH31+2
	dc.l	PATCH_FACTORWORD,__RESPATCH32+2
	dc.l	PATCH_FACTORWORD,__RESPATCH33+2
	dc.l	PATCH_FACTORWORD,__RESPATCH34+2
	
	dc.l	PATCH_FACTORWORD,__RESPATCH35+2

	dc.l	PATCH_FACTORWORD,__RESPATCH36
	dc.l	PATCH_FACTORWORD,__RESPATCH36+2
	dc.l	PATCH_FACTORWORD,__RESPATCH36+4
	
	dc.l	PATCH_FACTORWORD,__RESPATCH37+2
	dc.l	PATCH_FACTORWORD,__RESPATCH38+2
	dc.l	PATCH_FACTORWORD,__RESPATCH39+2
	dc.l	PATCH_FACTORWORD,__RESPATCH40+2
	dc.l	PATCH_FACTORWORD,__RESPATCH41+2
	dc.l	PATCH_FACTORWORD,__RESPATCH42+2
	
	dc.l	PATCH_FACTORLONG,__RESPATCH43+2
	dc.l	PATCH_FACTORLONGM1,__RESPATCH44+2

	dc.l	PATCH_FACTORWORD,__RESPATCH45+2
	
	dc.l	PATCH_FACTORWORD,__RESPATCH46+2
	dc.l	PATCH_FACTORWORD,__RESPATCH47+2
	dc.l	PATCH_FACTORWORD,__RESPATCH48+2

	dc.l	PATCH_FACTORLONG,__RESPATCH49+2
	
	dc.l	PATCH_FACTORWORD,__RESPATCH50+2
	dc.l	PATCH_FACTORWORD,__RESPATCH51+2
	dc.l	PATCH_FACTORWORD,__RESPATCH52+2
	dc.l	PATCH_FACTORWORD,__RESPATCH53+2
	dc.l	PATCH_FACTORWORD,__RESPATCH54+2
	dc.l	PATCH_FACTORWORD,__RESPATCH55+2
	dc.l	PATCH_FACTORWORD,__RESPATCH56+2
	dc.l	PATCH_FACTORWORD,__RESPATCH57+2

	dc.l	PATCH_DONE


;/***************************************************/
;/*                                                 */
;/*       R_MAIN                                    */
;/*                                                 */
;/***************************************************/

;/*= SlopeDiv ======================================================================*/


SLOPEDIV MACRO
	cmp.l		#512,\2
	blo.s		.\@raus

	lsr.l		#8,\2
	lsl.l		#3,\1
	divul.l		\2,\1:\1

	cmp.l		#SLOPERANGE+1,\1
	blo.s		.\@raus2

.\@raus:
	move.l		#SLOPERANGE,\1
.\@raus2:	
	ENDM

;/*===== R_PointToAngle =================================================*/

	XDEF	_R_PointToAngle
	XDEF	_R_PointToAngle_ASM
	CNOP	0,4

_R_PointToAngle:
	movem.l	4(sp),d0/d1
_R_PointToAngle_ASM:
	sub.l	_viewx(pc),d0
	sub.l	_viewy(pc),d1
	bne.s	.weiter
	tst.l	d0
	bne.s	.weiter
	moveq	#0,d0
	rts
	
.weiter:
	tst.l	d0
	blt.s	.xkleinernull
	tst.l	d1
	blt.s	.ykleinernull
	
;x>=0 und y>=0:

	cmp.l	d1,d0
	ble.s	.xkleinergleichy

;octant 0 = tantoangle[s(y,x)]
	
	SLOPEDIV	D1,D0

	lea		_tantoangle,a0
	move.l	(a0,d1.l*4),d0
	rts
	
.xkleinergleichy:

;octant1 = ANG90 - 1 - tantoangle[s(x,y)]
	
	SLOPEDIV	D0,D1

	move.l	#ANG90-1,d1
	lea		_tantoangle,a0
	sub.l	(a0,d0.l*4),d1
	move.l	d1,d0
	rts

.ykleinernull:
	neg.l	d1
	cmp.l	d1,d0
	ble.s	.xkleinergleichy2
	
; octant 8 = -tantoangle[s(y,x)]

	SLOPEDIV	d1,d0

	lea		_tantoangle,a0
	move.l	(a0,d1.l*4),d0
	neg.l	d0
	rts

.xkleinergleichy2:

; octant 7 = ANG270 + tantoangle[s(x,y)]

	SLOPEDIV	d0,d1
	
	lea		_tantoangle,a0
	move.l	(a0,d0.l*4),d0
	add.l	#ANG270,d0
	rts
		
.xkleinernull:
	neg.l	d0
	
	tst.l	d1
	blt.s	.ykleinernull2
	
	cmp.l	d1,d0
	ble.s	.xkleinergleichy3
	
	;octant 3 = ANG180 - 1 - tantoangle[s(y,x)]

	SLOPEDIV	d1,d0

	lea		_tantoangle,a0
	move.l	#ANG180-1,d0
	sub.l	(a0,d1.l*4),d0
	rts
	
.xkleinergleichy3:

	; octant 2 = ANG90 + tantoangle[s(x,y)]

	SLOPEDIV	d0,d1
	
	lea		_tantoangle,a0
	move.l	(a0,d0.l*4),d0
	add.l	#ANG90,d0
	rts


.ykleinernull2:
	neg.l	d1
	
	cmp.l	d1,d0
	ble.s	.xkleinergleichy4
	
	;octant 4 = ANG180 + tantoangle[s(y,x)]
	
	SLOPEDIV	d1,d0
	
	lea		_tantoangle,a0
	move.l	(a0,d1.l*4),d0
	add.l	#ANG180,d0
	rts

.xkleinergleichy4:
	
	;octant 5 = ANG270 - 1 - tantoangle[s(x,y)]
	
	SLOPEDIV	d0,d1
	
	lea		_tantoangle,a0
	move.l	#ANG270-1,d1
	sub.l	(a0,d0.l*4),d1
	move.l	d1,d0
	rts
	

	XDEF	_R_PointInSubsector
	CNOP	0,4
	
_R_PointInSubsector:		;'(fixed_t x, fixed_t y)
;//    node_t*	node;
;//    int		side;
;//    int		nodenum;
;//
	movem.l	a2/d2-d7,-(sp)

;//    /* single subsector is a special case*/

;//    if (!numnodes)				
;//	return subsectors;
	move.l	_numnodes,d4
	beq.s		.nonodes
		
;//    nodenum = numnodes-1;

	subq		#1,d4
	btst		#NFB_SUBSECTOR,d4
	bne.s		.whiledone
	
	move.l	_nodestab,a2
	movem.l	7*4+4(sp),d5/d6		;'d5 = x
											;'d6 = y

;//    while (! (nodenum & NF_SUBSECTOR) )
;//    {
.while:
;//	node = &nodes[nodenum];
	move.l	(a2,d4.w*4),a0
	
	move.l	d5,d0
	move.l	d6,d1
			
;//	side = R_PointOnSide (x, y, node);
	tst.l		8(a0)
	bne.s		.1

	cmp.l		(a0),d0
	bgt.s		.2

	tst.l		12(a0)
	bgt.s		.3

.return0:
	move		nd_children(a0),d4
	bra.s		.9

.return1:
.3:
	move		nd_children+2(a0),d4
	bra.s		.9

.2:
	tst.l		12(a0)
	blt.s		.return1
	move		nd_children(a0),d4
	bra.s		.9
	
.1:
	tst.l		12(a0)
	bne.s		.5
	
	cmp.l		4(a0),d1
	bgt.s		.6
	
	tst.l		8(a0)
	blt.s		.return1
	move		nd_children(a0),d4
	bra.s		.9
	
.6:
	tst.l		8(a0)
	bgt.s		.return1
	move		nd_children(a0),d4
	bra.s		.9

.5:
	sub.l		(a0),d0
	sub.l		4(a0),d1
	
	move.l	d0,d2
	eor.l		d1,d2
	move.l	8(a0),d3
	eor.l		d3,d2
	move.l	12(a0),d3
	eor.l		d3,d2
	bpl.s		.33
	
	eor.l		d3,d0
	bpl.s		.return0
	
	move		nd_children+2(a0),d4
	bra.s		.9

.33:
	move		12(a0),d2
	ext.l		d2

	IFND	version060

	muls.l	d2,d2:d0
	move	d2,d0
	swap	d0

	ELSE

	fmove.l	d0,fp0
	fmul.l	d2,fp0
	fmul.x	fp7,fp0
	fmove.l	fp0,d0

	ENDC

	move		8(a0),d2
	ext.l		d2

	IFND	version060

	muls.l	d2,d2:d1
	move		d2,d1
	swap		d1

	ELSE

	fmove.l	d1,fp0
	fmul.l	d2,fp0
	fmul.x	fp7,fp0
	fmove.l	fp0,d1
	
	ENDC
	
	cmp.l		d0,d1
	blt.s		.return0

	move		nd_children+2(a0),d4
	
.9:

;//	nodenum = node->children[side];

;//    }
	btst		#NFB_SUBSECTOR,d4
	beq.s		.while

.whiledone:
;//    return &subsectors[nodenum & ~NF_SUBSECTOR];
	bclr		#NFB_SUBSECTOR,d4
	move.l	_subsectors,d0
	lsl.l		#3,d4
	add.l		d4,d0
	movem.l	(sp)+,a2/d2-d7
	rts
	
.nonodes:
	move.l	_subsectors,d0
	movem.l	(sp)+,a2/d2-d7
	rts



;/***************************************************/
;/*                                                 */
;/*       R_PLANE                                   */
;/*                                                 */
;/***************************************************/

	
	XDEF	_R_FindPlane
	CNOP	0,4

_R_FindPlane:	;//fixed_t height,int picnum,int lightlevel
	move.l	d2,-(sp)

;//    visplane_t*	check;
	
	movem.l	4+4(sp),d0-d2		;d0 = height,d1 = picnum, d2 = lightlevel
	
;//    if (picnum == skyflatnum)
;//    {
;//	height = 0;			/* all skys map together*/
;//	lightlevel = 0;
;//    }
	
	cmp.l		_skyflatnum(pc),d1
	bne.s		.picnumok
	moveq		#0,d0		;// height = 0
	moveq		#0,d2		;// lightlevel = 0
	
.picnumok:

;//    for (check=visplanes; check<lastvisplane; check++)

	move.l	_visplanes(pc),a0		;// a0 = check
	move.l	_lastvisplane(pc),a1	;// a1 = lastvisplane
	bra.s		.forentry

.for:

;//	if (height == check->height
;//	    && picnum == check->picnum
;//	    && lightlevel == check->lightlevel)
;//	{
;//	    break;
;//	}
;//    }
    
   cmp.l		vp_height(a0),d0
   bne.s		.next
   cmp.l		vp_picnum(a0),d1
   bne.s		.next
   cmp.l		vp_lightlevel(a0),d2
   beq.s		fp_found

.next:
	lea		vp_SIZEOF(a0),a0
.forentry:
	cmp.l		a1,a0
	blt.s		.for

   ;// if (lastvisplane - visplanes == MAXVISPLANES)
	;// I_Error ("R_FindPlane: no more visplanes");

	cmp.l		_maxvisplane(pc),a0
	bne.s		.stillok
	
	pea		ERRTXT_NOVISPLANES(pc)
	jsr		_I_Error
	;// does not return!!
	
.stillok
	;// lastvisplane++;

	lea		vp_SIZEOF(a1),a1
	move.l	a1,_lastvisplane
	
   ;// check->height = height;
   ;// check->picnum = picnum;
   ;// check->lightlevel = lightlevel;
   ;// check->minx = SCREENWIDTH;
   ;// check->maxx = -1;

	movem.l	d0-d2,(a0)
	;// move.l	d0,vp_height(a0)
	;// move.l	d1,vp_picnum(a0)
	;// move.l	d2,vp_lightlevel(a0)

__RESPATCH1:
	move.l	#SCREENWIDTH,vp_minx(a0)
	moveq		#-1,d0
	move.l	d0,vp_maxx(a0)
	
   ;//memset (check->top,0xff,sizeof(check->top));
   
	
	movem.l	d3/d4,-(sp)

	moveq		#-1,d2
	moveq		#-1,d3
	moveq		#-1,d4

__RESPATCH2:
	lea		SCREENWIDTH*2+vp_top(a0),a1
__RESPATCH3:
	moveq		#SCREENWIDTH*2/32,d1
	bra.s		.clrentry
	
	CNOP		0,4

.clr:
	movem.l	d0/d2/d3/d4,-(a1)
	movem.l	d0/d2/d3/d4,-(a1)
.clrentry:
	dbf		d1,.clr

	movem.l	(sp)+,d3/d4

   ;// return check;

fp_found:
;//    if (check < lastvisplane)
;//	return check;

	move.l	a0,d0
	
	move.l	(sp)+,d2
	rts



	XDEF	_R_CheckPlane
	CNOP	0,4

_R_CheckPlane:	;// visplane_t *pl,int start,int stop
	movem.l	d2-d6,-(sp)

;//    int		intrl;	d2
;//    int		intrh;	d3
;//    int		unionl;	d4
;//    int		unionh;	d5
;//    int		x;			d6
	
	move.l	4+20(sp),a0		;// a0 = pl
	movem.l	8+20(sp),d0/d1	;// d0 = start  d1 = stop

;//    if (start < pl->minx)
;//    {
;//	intrl = pl->minx;
;//	unionl = start;
;//    }

	move.l	vp_minx(a0),d2

	cmp.l		d2,d0
	bge.s		.greatereq
	
;//	move.l	vp_minx(a0),d2		;// intrl = d2 = pl->minx
	move.l	d0,d4					;// unionl = d4 = start
	bra.s		.checkstop
	
.greatereq:
;//    else
;//    {
;//	unionl = pl->minx;
;//	intrl = start;
;//    }

	move.l	d2,d4				;// unionl = d4 = pl->minx
	move.l	d0,d2				;// intrl = d2 = start

.checkstop:
;//    if (stop > pl->maxx)
;//    {
;// 	intrh = pl->maxx;
;// 	unionh = stop;
;//    }

	move.l	vp_maxx(a0),d3
	cmp.l		d3,d1
	ble.s		.lowereq
	
	;// move.l	vp_maxx(a0),d3 // intrh = d3 = pl->maxx
	move.l	d1,d5				;// unionh = d5 = stop
	bra.s		.checksdone

.lowereq:	
;//    else
;//    {
;//	unionh = pl->maxx;
;//	intrh = stop;
;//    }

	move.l	d3,d5				;// unionh = d5 = pl->maxx
	move.l	d1,d3				;// intrh = d3 = stop

.checksdone:
;//    for (x=intrl ; x<= intrh ; x++)
;//	if (pl->top[x] != 0xffff)
;//	    break;
	move.l	d2,d6				;// d6 = x = intrl
	lea		vp_top(a0,d6.w*2),a1
	bra.s		.forentry

.for:
	cmp.w		#-1,(a1)+
	bne.s		.found
	
.next:
	addq.l	#1,d6
.forentry:
	cmp.l		d3,d6
	ble.s		.for

;//    if (x > intrh)
;//   {
;//	pl->minx = unionl;
;//	pl->maxx = unionh;

;//	/* use the same one*/
;//	return pl;		
;//    }

	movem.l	d4/d5,vp_minx(a0)
	move.l	a0,d0
	
	movem.l	(sp)+,d2-d6
	rts

.found:
;//    /* make a new visplane*/
;//    lastvisplane->height = pl->height;
;//    lastvisplane->picnum = pl->picnum;
;//    lastvisplane->lightlevel = pl->lightlevel;
 
 	move.l	_lastvisplane(pc),a1
 	movem.l	(a0),d2-d4
 	move.l	a1,a0				;//pl = a0 = lastvisplane ++
 	movem.l	d2-d4,(a1)
 	
;//    pl = lastvisplane++;
;//    pl->minx = start;
;//    pl->maxx = stop;

	movem.l	d0/d1,vp_minx(a1)
	
;//    memset (pl->top,0xff,sizeof(pl->top));

	moveq		#-1,d1
	moveq		#-1,d2
	moveq		#-1,d3
	moveq		#-1,d4

__RESPATCH4:
	lea		SCREENWIDTH*2+vp_top(a0),a1
__RESPATCH5:
	moveq		#SCREENWIDTH*2/32,d0
	bra.s		.clrentry
	CNOP		0,4

.clr:
	movem.l	d1-d4,-(a1)
	movem.l	d1-d4,-(a1)
.clrentry:
	dbf		d0,.clr

;// lastvisplane++ von oben

 	lea		vp_SIZEOF(a0),a1
	move.l	a1,_lastvisplane
	
	move.l	a0,d0
	
	movem.l	(sp)+,d2-d6
	
;// return pl
	rts


R_MAPPLANE:		macro

	movem.l	d2-d6,-(sp)

	movem.l	d0/d1,_ds_y

	lea		_cachedheight,a0
	move.l	_planeheight(pc),d2
	cmp.l		(a0,d0.w*4),d2
	beq.s		.\@istgecached
		
	;/*	cachedheight[y] = planeheight; */
	move.l	d2,(a0,d0.w*4)

	;/*distance = cacheddistance[y] = FixedMul (planeheight, yslope[y]);*/
	move.l	_yslope(pc),a0
	move.l	(a0,d0.w*4),d3

	ifnd version060
		muls.l	d3,d5:d2
		move		d5,d2
		swap		d2				;/* d2 = distance */
	else
		fmove.l	d2,fp0
		fmul.l	d3,fp0
		fmul.x	fp7,fp0
		fmove.l	fp0,d2		;/* d2 = distance */
	endc
		
	lea		_cacheddistance,a0
	move.l	d2,(a0,d0.w*4)
		
	;/* ds_xstep = cachedxstep[y] = FixedMul (distance,basexscale); */
		
	ifnd version060
		move.l	_basexscale(pc),d3
		muls.l	d2,d5:d3
		move		d5,d3
		swap		d3				;/* d3 = ds_xstep */
	else
		fmove.l	_basexscale(pc),fp0
		fmul.l	d2,fp0
		fmul.x	fp7,fp0
		fmove.l	fp0,d3		;/* d3 = ds_xstep */
	endc

	lea		_cachedxstep,a0
	move.l	d3,(a0,d0.w*4)
	move.l	d3,_ds_xstep

	;/*	ds_ystep = cachedystep[y] = FixedMul (distance,baseyscale); */

	ifnd	version060
		move.l	_baseyscale(pc),d3
		muls.l	d2,d5:d3
		move		d5,d3
		swap		d3				;/* d3 = ds_ystep */
	else
		fmove.l	_baseyscale(pc),fp0
		fmul.l	d2,fp0
		fmul.x	fp7,fp0
		fmove.l	fp0,d3		;/* d3 = ds_ystep */
	endc

	lea		_cachedystep,a0
	move.l	d3,(a0,d0.w*4)
	move.l	d3,_ds_ystep
	bra.s		.\@dataok

	;	/* === CACHED ==== */

.\@istgecached:
	lea		_cacheddistance,a0
	move.l	(a0,d0.w*4),d2	;/* d2 = distance */

	lea		_cachedxstep,a0
	move.l	(a0,d0.w*4),_ds_xstep		;/* ds_xstep */
		
	lea		_cachedystep,a0
	move.l	(a0,d0.w*4),_ds_ystep		;/* ds_ystep */
		
	;	/* ============== */
		
.\@dataok:
	;   /* length = FixedMul (distance,distscale[x1]); */
	   
	lea		_distscale,a0
	move.l	(a0,d1.w*4),d3

	ifnd	version060
		muls.l	d2,d5:d3
		move		d5,d3
		swap		d3			;/* d3 = length */
	else
		fmove.l	d3,fp0
		fmul.l	d2,fp0
		fmul.x	fp7,fp0
		fmove.l	fp0,d3	;/* d3 = length */
	endc
		
	;   /* angle = (viewangle + xtoviewangle[x1])>>19; */

	lea		_xtoviewangle,a0
	move.l	(a0,d1.w*4),d4
	add.l		_viewangle(pc),d4
	moveq		#19,d5
	lsr.l		d5,d4			;/* d4 = angle */

	;   /* ds_xfrac = viewx + FixedMul(finecosine[angle], length); */

	move.l	_finecosine(pc),a0
	move.l	(a0,d4.w*4),d6

	ifnd	version060
		muls.l	d3,d5:d6
		move		d5,d6
		swap		d6
	else
		fmove.l	d6,fp0
		fmul.l	d3,fp0
		fmul.x	fp7,fp0
		fmove.l	fp0,d6
	endc

	add.l		_viewx(pc),d6
	move.l	d6,_ds_xfrac

	; 	/* ds_yfrac = -viewy - FixedMul(finesine[angle], length); */

	lea		_finesine,a0		;/* lea!!! */
	move.l	(a0,d4.w*4),d6

	ifnd	version060
		muls.l	d3,d5:d6
		move		d5,d6
		swap		d6
	else
		fmove.l	d6,fp0
		fmul.l	d3,fp0
		fmul.x	fp7,fp0
		fmove.l	fp0,d6
	endc

	add.l		_viewy(pc),d6
	neg.l		d6
	move.l	d6,_ds_yfrac
				
   ; 	/* if (fixedcolormap) ds_colormap = fixedcolormap; */
			
	move.l	_fixedcolormap(pc),d6
	beq.s		.\@nofcmap
	
	move.l	d6,_ds_colormap
	bra.s		.\@draw
		
.\@nofcmap:
	;	/*	index = distance >> LIGHTZSHIFT; */
	
	moveq		#20,d5
	lsr.l		d5,d2

	;/*	if (index >= MAXLIGHTZ ) index = MAXLIGHTZ-1;*/
	
	moveq		#127,d5
	cmp		d5,d2
	ble.s		.\@lightok
	
	move		d5,d2
	
.\@lightok:
	move.l	_planezlight(pc),a0
	move.l	(a0,d2.w*4),_ds_colormap
		
.\@draw:
	move.l	_spanfunc(pc),a0
	jsr		(a0)
	
	movem.l	(sp)+,d2-d6

	ENDM

R_MAKESPANS:	macro		;// d2 = x  d4 = t1  d5 = b1
								;//         d6 = t2  d7 = b2

;// d2/d3,a2/a3/a4/a5/a6 nicht trashen!!!!!

;//    while (t1 < t2 && t1<=b1)
;//    {
;//	R_MapPlane (t1,spanstart[t1],x-1);
;//	t1++;
;//    }

	movem.l	d3/a3/a4,-(sp)

	move.l	d2,_ds_x2		;// ware eigentlich in R_MapPlane
	subq.l	#1,_ds_x2

	lea		_spanstart,a4	;// a4 = spanstart

	move.l	d6,d3			;// d3 = t2 - t1
	sub.l		d4,d3
	ble.s		.while2
	
	subq.l	#1,d3			;// weil t2 *<* t1
	
	move.l	d5,d0			;// d0 = b1 - t1
	sub.l		d4,d0
	
	bmi.s		.whilesdone		;// zweites while ist durch gleiche Abfrage automatisch weg!

	lea		(a4,d4.l*4),a3
	cmp.l		d0,d3
	blt.s		.d3kleiner
	move.l	d0,d3			;// [** t1 <= b1 ist kleiner **]

;//===================

.loop:
	move.l	(a3)+,d1
	move.l	d4,d0

	R_MAPPLANE

	addq.l	#1,d4
	dbf		d3,.loop
	bra.s		.whilesdone		;// es wurde t1<b1 getestet - while fertig - t1<b1 jetzt false -> 2. while automatisch nicht gueltig

;//===================

.d3kleiner:
	move.l	(a3)+,d1
	move.l	d4,d0

	R_MAPPLANE

	addq.l	#1,d4
	dbf		d3,.d3kleiner

;//===================

;//    while (b1 > b2 && b1>=t1)
;//    {
;//	R_MapPlane (b1,spanstart[b1],x-1);
;//	b1--;
;//    }

.while2:
	
	move.l	d5,d3			;// d3 = b1 - b2
	sub.l		d7,d3
	ble.s		.whilesdone
	subq.l	#1,d3
	
	move.l	d5,d0			;// d0 = b1 - t1
	sub.l		d4,d0
	bmi.s		.whilesdone
	
	lea		4(a4,d5.l*4),a3
	cmp.l		d0,d3
	blt.s		.d3kleiner2
	move.l	d0,d3
	
.loop2:
	move.l	-(a3),d1
	move.l	d5,d0

	R_MAPPLANE

	subq.l	#1,d5
	dbf		d3,.loop2
	bra.s		.whilesdone
	
.d3kleiner2:
	move.l	-(a3),d1
	move.l	d5,d0

	R_MAPPLANE

	subq.l	#1,d5
	dbf		d3,.d3kleiner2

;//=============================================
	
.whilesdone:

;//    while (t2 < t1 && t2<=b2)
;//    {
;//	spanstart[t2] = x;
;//	t2++;
;//    }

	move.l	d4,d3			;// t1 - t2
	sub.l		d6,d3
	ble.s		.clear2
	subq.l	#1,d3

	move.l	d7,d0			;// b2 - t2
	sub.l		d6,d0
	bmi.s		.clear2

	lea		(a4,d6.l*4),a3
	
	cmp.l		d0,d3
	bgt.s		.d0kleiner
	move.l	d3,d0

.d0kleiner:
	add.l		d0,d6
	addq.l	#1,d6

	move		d0,d1
	and.w		#7,d1
	move.w  .jumptab(pc,d1.w*2),d1

	lsr		#3,d0

	jmp		.loop3(pc,d1.w)

	CNOP		0,4

.jumptab
	dc.w    .c0-.loop3
	dc.w    .c1-.loop3
	dc.w    .c2-.loop3
	dc.w    .c3-.loop3
	dc.w    .c4-.loop3
	dc.w    .c5-.loop3
	dc.w    .c6-.loop3
	dc.w    .c7-.loop3

.loop3:
.c7:	move.l	d2,(a3)+
.c6:	move.l	d2,(a3)+
.c5	move.l	d2,(a3)+
.c4:	move.l	d2,(a3)+
.c3:	move.l	d2,(a3)+
.c2:	move.l	d2,(a3)+
.c1:	move.l	d2,(a3)+
.c0:	move.l	d2,(a3)+
	dbf		d0,.loop3

.clear2:
;//    while (b2 > b1 && b2>=t2)
;//    {
;//	spanstart[b2] = x;
;//	b2--;
;//    }
	move.l	d7,d3			;// d3 = b2
	sub.l		d5,d3			;// d3 = b2 - b1
	ble.s		.done			;// <= 0 ?
	subq.l	#1,d3

	move.l	d7,d0			;// d0 = b2
	sub.l		d6,d0			;// d0 = b2 - t2
	bmi.s		.done			;// < 0 ? 
	
	lea		4(a4,d7.l*4),a3

	cmp.l		d0,d3
	bgt.s		.d0kleiner2
	move.l	d3,d0
	
.d0kleiner2:
	move		d0,d1
	and.w		#7,d1
	move.w  .jumptab2(pc,d1.w*2),d1

	lsr		#3,d0

	jmp		.loop4(pc,d1.w)

	CNOP		0,4

.jumptab2
	dc.w    .cc0-.loop4
	dc.w    .cc1-.loop4
	dc.w    .cc2-.loop4
	dc.w    .cc3-.loop4
	dc.w    .cc4-.loop4
	dc.w    .cc5-.loop4
	dc.w    .cc6-.loop4
	dc.w    .cc7-.loop4

.loop4:
.cc7:	move.l	d2,-(a3)
.cc6:	move.l	d2,-(a3)
.cc5:	move.l	d2,-(a3)
.cc4:	move.l	d2,-(a3)
.cc3:	move.l	d2,-(a3)
.cc2:	move.l	d2,-(a3)
.cc1:	move.l	d2,-(a3)
.cc0:	move.l	d2,-(a3)
	dbf		d0,.loop4

.done:
	movem.l	(sp)+,d3/a3/a4
	ENDM


	XDEF	_R_DrawPlanes
	CNOP	0,4
	
_R_DrawPlanes:
	movem.l	d2-d7/a2-a6,-(sp)

;//    visplane_t*		pl;
;//    int			light;
;//    int			x;
;//    int			stop;
;//    int			angle;
			
;//    for (pl = visplanes ; pl < lastvisplane ; pl++)
;//    {

	move.l	_visplanes(pc),a2			;// a2 = visplanes
	move.l	_lastvisplane(pc),a3		;// a3 = lastvisplane
	bra.s		.visplaneforentry
	
.visplanefor:
	; // if (pl->minx > pl->maxx)
	; //    continue;

	movem.l	vp_minx(a2),d2/d3		;// d2 = minx  d3=maxx
	cmp.l		d3,d2
	bgt.s		.visplanenext			;// minx > maxx?

;//	/* sky flat*/
;//	if (pl->picnum == skyflatnum)
;//	{

	move.l	vp_picnum(a2),d1
	cmp.l		_skyflatnum(pc),d1
	bne.s		.notthesky

;//  dc_iscale = pspriteiscale>>detailshift;

	move.l	_skyspriteiscale(pc),_dc_iscale
	    
;    /* Sky is allways drawn full bright,*/
;    /*  i.e. colormaps[0] is used.*/
;    /* Because of this hack, sky is not affected*/
;    /*  by INVUL inverse mapping.*/

;//    dc_colormap = colormaps;

	move.l	_colormaps(pc),_dc_colormap
	
;//	dc_texturemid = skytexturemid;

	move.l	_skytexturemid(pc),_dc_texturemid
	
;//	    for (x=pl->minx ; x <= pl->maxx ; x++)
;//	    {

	lea		_xtoviewangle,a4	;// a4 = xtoviewangle

	lea		vp_top(a2,d2.w*2),a6
	moveq		#0,d4
	lea		vp_bottom-vp_top(a6),a5
	moveq		#0,d7
	moveq		#ANGLETOSKYSHIFT,d5
	move.l	_skytexture(pc),d6
	sub		d2,d3					;// braucht nicht getestet zu werden, s. o.

;//  a3 = dc_x = x;

	move.l	a3,-(sp)

	move.l	d2,a3
	
.xloop:
	;//	dc_yl = pl->top[x];
	;//	dc_yh = pl->bottom[x];

	move		(a6)+,d7		;d7 = dc_yl
	move		(a5)+,d4		;d4 = dc_yh

;//	if (dc_yl <= dc_yh)
;//		{

	cmp		d4,d7
	bgt.s		.dontdraw

	lea		_dc_yh,a0
	movem.l	d4/d7/a3,(a0)

;//  angle = (viewangle + xtoviewangle[x])>>ANGLETOSKYSHIFT;

	move.l	_viewangle(pc),d1
	add.l		(a4,a3.w*4),d1
	lsr.l		d5,d1			;// d1 = angle
	
;// dc_source = R_GetColumn(skytexture, angle);

	move.l	d6,d0
	bsr		R_GetColumn
;//	add.l		#8,sp
	move.l	d0,_dc_source

;// colfunc ();

	move.l	_colfunc(pc),a0
	jsr		(a0)

.dontdraw:
.xloopnext:
	addq.l	#1,a3		;// x++
	dbf		d3,.xloop

	move.l	(sp)+,a3

;// continue;

	bra		.visplanenext

.notthesky:	
;//	/* regular flat*/
;//	ds_source = W_CacheLumpNum(firstflat +
;//				   flattranslation[pl->picnum],
;//				   PU_STATIC);
	
	move.l	_flattranslation(pc),a0
	move.l	(a0,d1.l*4),d0
	add.l		_firstflat(pc),d0
	
	move.l	_lumpcache,a0
	move.l	(a0,d0.w*4),a4	;// a4 = _ds_source
	tst.l		a4
	bne.s		.iscached

	moveq		#PU_STATIC,d1
	move.l	d1,-(sp)
	move.l	d0,-(sp)
	jsr		_WW_CacheLumpNum
	addq.l	#8,sp
	move.l	d0,a4				;// a4 = _ds_source
	bra.s		.later
	
.iscached:
;//	moveq		#PU_STATIC,d0
;//	move.l	d0,-16(a4)		;// PU_STATIC

.later:
	move.l	a4,_ds_source

;//	planeheight = abs(pl->height-viewz);

	move.l	vp_height(a2),d0
	sub.l		_viewz(pc),d0
	bpl.s		.ispos
	neg.l		d0
	
.ispos:
	move.l	d0,_planeheight

;//	light = (pl->lightlevel >> LIGHTSEGSHIFT)+extralight;
	
	lea		_zlight,a0		;// a0 = zlight

	move.l	vp_lightlevel(a2),d0
	lsr.l		#LIGHTSEGSHIFT,d0
	add.l		_extralight(pc),d0

;//	if (light >= LIGHTLEVELS)
;//	    light = LIGHTLEVELS-1;

;//	if (light < 0)
;//	    light = 0;

	bpl.s		.posok
	bra.s		.light3

.posok:
	cmp		#LIGHTLEVELS,d0
	blt.s		.light2
	lea		(LIGHTLEVELS-1)*128*4(a0),a0
	bra.s		.light3

.light2:
;//	planezlight = zlight[light];
	lsl		#8,d0			;// * 128 * 4 = * 512 
	add		d0,d0
	add.w		d0,a0
	
.light3:
	move.l	a0,_planezlight

;//	pl->top[pl->maxx+1] = 0xffff;
;//	pl->top[pl->minx-1] = 0xffff;

	moveq		#-1,d0	
	lea		vp_top(a2),a6

	move		d0,2(a6,d3.w*2)
	lea		(a6,d2.w*2),a6
	move		d0,-(a6)				;// a6 = vp_top-2
	
;//	stop = pl->maxx + 1;

	addq		#1,d3
	sub		d2,d3					;// d3 = loop counter
;//
;//	for (x=pl->minx ; x<= stop ; x++)
	lea		vp_bottom-vp_top(a6),a5		;// a5 = vp_bottom-2

	moveq		#0,d4
	moveq		#0,d5
	moveq		#0,d6
	moveq		#0,d7

.spanloop:
;//	    R_MakeSpans(x,pl->top[x-1],
;//			pl->bottom[x-1],
;//			pl->top[x],
;//			pl->bottom[x]);
	
	move		(a6)+,d4		;d4 = top - 1
	move		(a5)+,d5		;d5 = bottom-1
	move		(a6),d6		;d6 = top
	move		(a5),d7		;d7 = bottom
	
;//	move.l	d7,-(sp)
;//	move.l	d6,-(sp)
;//	move.l	d5,-(sp)
;//	move.l	d4,-(sp)
;//	move.l	d2,-(sp)

	R_MAKESPANS

;//	jsr		_R_MakeSpans
;//	lea		5*4(sp),sp

.spanloopnext:
	addq.l	#1,d2
	dbf		d3,.spanloop
	
;//	Z_ChangeTag (ds_source, PU_CACHE);

	moveq		#PU_CACHE,d0
	move.l	d0,-16(a4)

.visplanenext:
	lea		vp_SIZEOF(a2),a2
	
.visplaneforentry:
	cmp.l		a2,a3
	bne.s		.visplanefor

	movem.l	(sp)+,d2-d7/a2-a6
	rts

	XREF	_R_GenerateComposite
	CNOP	0,4

R_GetColumn:	;d0 = tex  d1 = col 	
	movem.l	d2/d3/a2,-(sp)

	;/* col &= texturewidthmask[tex] */
	
	move.l	_texturewidthmask(pc),a0
	and.l		(a0,d0.w*4),d1

	;/* ofs = texturecolumnofs[tex][col] */

	move.l	_texturecolumnofs(pc),a0
	move.l	(a0,d0.w*4),a0
	moveq		#0,d2
	move.w	(a0,d1.w*2),d2

	;/* d2 = ofs */

	;/* lump = texturecolumnlump[tex][col] */
	
	move.l	_texturecolumnlump(pc),a0
	move.l	(a0,d0.w*4),a0
	moveq		#0,d3
	move.w	(a0,d1.w*2),d3

	;/* d3 = lump */
		
	;/* lump >0 ? */
	
	ble.s		.lumpkleinernull
		
	;/* return W_CacheLumpNum(lump,PU_CACHE)+ofs */
		
	move.l	_lumpcache,a0
	move.l	(a0,d3.w*4),d0
	beq.s		.nichtgecached

	move.l	d0,a0
	moveq		#PU_CACHE,d1
	move.l	d1,-16(a0)	;	/* tag -> PU_CACHE */
	add.l		d2,d0			;	/* + ofs */

	movem.l	(sp)+,d2/d3/a2
	rts
		
.nichtgecached:
	;/* nicht gecached -> richtige (langsame) Funktion aufrufen */

	moveq		#PU_CACHE,d0
	move.l	d0,-(sp)
	move.l	d3,-(sp)
	jsr		_WW_CacheLumpNum
	addq.l	#8,sp
	add.l		d2,d0
	
	movem.l	(sp)+,d2/d3/a2
	rts
		
.lumpkleinernull:
	;/* <0: texturecomposite[tex] ? */
	
	move.l	_texturecomposite(pc),a2
	move.l	(a2,d0.w*4),d1
	beq.s		.istnull
		
	;/* return texturecomposite[tex] + ofs */
	
	move.l	d1,d0
	add.l		d2,d0

	movem.l	(sp)+,d2/d3/a2
	rts
		
.istnull:
	;/* !texturecomposite[tex]: */

	move.l	d0,-(sp)
	lea		(a2,d0.w*4),a2
	jsr		_R_GenerateComposite
	addq.l	#4,sp
		
	move.l	(a2),d0
	add.l		d2,d0
	
	movem.l	(sp)+,d2/d3/a2
	rts




;/***************************************************/
;/*                                                 */
;/*       R_BSP                                     */
;/*                                                 */
;/***************************************************/


	XREF	_R_ClipPassWallSegment
	XREF	_R_ClipSolidWallSegment
;	XREF	_R_StoreWallRange

	XREF	_viewangletox
	XREF	_viewangletox
	XREF	_solidsegs
	XREF	_sscount
	XREF	_subsectors
	XREF	_segs
	XREF	_nodestab

R_ClipSolidWallSegment	macro	;//d0 = first  d1 = last
										;// d2/d3/d4 a2/a3 nicht trashen!!!
;//    cliprange_t*	next;
;//    cliprange_t*	start;

;//    /* Find the first range that touches the range*/
;//    /*  (adjacent pixels are touching).*/

;//    start = solidsegs;
	lea		_solidsegs,a4			;a4 = start

;//    while (start->last < first-1)
;//	start++;
	move.l	d0,d5
	subq.l	#1,d5						;d5 = first - 1
	bra.s		.gwhileentry
	
.gwhile:
	addq.l	#cr_SIZEOF,a4
.gwhileentry:
	cmp.l		cr_last(a4),d5
	bgt.s		.gwhile

;//    if (first < start->first)
;//    {
	move.l	cr_first(a4),d6
	cmp.l		d6,d0
	bge.s		.ohshit

;//		if (last < start->first-1)
;//		{
	subq.l	#1,d6
	cmp.l		d6,d1
	bge.s		.arrrgh

;//		    /* Post is entirely visible (above start),*/
;//		    /*  so insert a new clippost.*/
	
;//		    R_StoreWallRange (first, last);
	move.l	d0,d5
	move.l	d1,d6

;	movem.l	d0/d1,-(sp)
	bsr		_R_StoreWallRange
;	addq.l	#8,sp
	
;//		    next = newend;
	lea		_newend(pc),a0
	move.l	(a0),a5				;a5 = next
	
;//		    newend++;
	addq.l	#cr_SIZEOF,(a0)
		    
;//		    while (next != start)
;//		    {
	cmp.l		a4,a5
	beq.s		.puhh

.hardwork:
;//			*next = *(next-1);
	move.l	-cr_SIZEOF+cr_first(a5),cr_first(a5)
	move.l	-cr_SIZEOF+cr_last(a5),cr_last(a5)
;//			next--;
	subq.l	#cr_SIZEOF,a5

;//		    }
	cmp.l		a4,a5
	bne.s		.hardwork
		    
.puhh:
;//		    next->first = first;
;//		    next->last = last;
	movem.l	d5/d6,(a5)

;//		    return;
	bra.s		.hastalavista
;//		}

.arrrgh:	
;//		/* Now adjust the clip size.*/
;//		start->first = first;	
	move.l	d0,cr_first(a4)

;//		/* There is a fragment above *start.*/
;//		R_StoreWallRange (first, start->first - 1);
	move.l	d1,d5

;	movem.l	d0/d6,-(sp)
	move.l	d6,d1
	bsr		_R_StoreWallRange
;	addq.l	#8,sp
	
	move.l	d5,d1	

;//    }

.ohshit:

;//    /* Bottom contained in start?*/
;//    if (last <= start->last)
;//	return;
	cmp.l		cr_last(a4),d1
	ble.s		.hastalavista
		
;//    next = start;
	move.l	a4,a5							;a5 = next
	move.l	d1,d5							;d5 = last
	bra.s		.wheilentry

;//    while (last >= (next+1)->first-1)
;//    {
.wheil:
;//	/* There is a fragment between two posts.*/
;//	R_StoreWallRange (next->last + 1, (next+1)->first - 1);
	move.l	d6,d1
	move.l	cr_last(a5),d0
	addq.l	#1,d0
	bsr		_R_StoreWallRange
	
;//	next++;
	addq.l	#cr_SIZEOF,a5
	
;//	if (last <= next->last)
;//	{
	cmp.l		cr_last(a5),d5
	bgt.s		.lucky

;//	    /* Bottom is contained in next.*/
;//	    /* Adjust the clip size.*/

;//	    start->last = next->last;	
	move.l	cr_last(a5),cr_last(a4)

;//	    goto crunch;
	bra.s		.crunch
	
;//	}
.lucky:

;//    }
.wheilentry:
	move.l	cr_SIZEOF+cr_first(a5),d6
	subq.l	#1,d6
	cmp.l		d6,d5
	bge.s		.wheil
	
	
;//    /* There is a fragment after *next.*/
;//    R_StoreWallRange (next->last + 1, last);
	move.l	d5,d1
	move.l	cr_last(a5),d0
	addq.l	#1,d0
	bsr		_R_StoreWallRange
	
;//    /* Adjust the clip size.*/
;//    start->last = last;
	move.l	d5,cr_last(a4)
	
;//    /* Remove start+1 to next from the clip list,*/
;//    /* because start now covers their area.*/
;//  crunch:

.crunch:
;//    if (next == start)
;//    {
;//	/* Post just extended past the bottom of one post.*/
;//	return;
;//    }
	cmp.l		a4,a5
	beq.s		.hastalavista

;//    while (next++ != newend)
;//    {
;//	/* Remove a post.*/
;//	*++start = *next;
;//    }
	move.l	_newend(pc),a0
	cmp.l		a5,a0
	addq.l	#cr_SIZEOF,a5
	beq.s		.whileok
	
.whilii:
	addq.l	#cr_SIZEOF,a4
	move.l	cr_first(a5),cr_first(a4)
	move.l	cr_last(a5),cr_last(a4)
	cmp.l		a5,a0
	addq.l	#cr_SIZEOF,a5
	bne.s		.whilii
	
.whileok:
;//    newend = start+1;
	lea		cr_SIZEOF(a4),a0
	move.l	a0,_newend
    
.hastalavista:

	ENDM



R_ClipPassWallSegment macro	;//d0 = first  d1 = last
										;// d2/d3/d4 a2/a3 nicht trashen!!!
;//    cliprange_t*	start;

;//    /* Find the first range that touches the range*/
;//    /*  (adjacent pixels are touching).*/

;//    start = solidsegs;
	lea		_solidsegs,a4					;a4 = start

;//    while (start->last < first-1)
;//	start++;

	move.l	d0,d5
	subq.l	#1,d5								;d5 = start - 1
	bra.s		.mywhileentry
	
.mywhile:
	addq.l	#cr_SIZEOF,a4

.mywhileentry:
	cmp.l		cr_last(a4),d5
	bgt.s		.mywhile

;//    if (first < start->first)
;//    {
	move.l	cr_first(a4),d5
	cmp.l		d5,d0
	bge.s		.nonoman

;//		if (last < start->first-1)
;//		{
	subq.l	#1,d5
	cmp.l		d5,d1
	bge.s		.shit
	
;//		    /* Post is entirely visible (above start).*/
;//		    R_StoreWallRange (first, last);

;	movem.l	d0/d1,-(sp)
	bsr		_R_StoreWallRange
;	addq.l	#8,sp

;//		    return;
;//		}

	bra.s		.jobdone

.shit:
;//		/* There is a fragment above *start.*/
;//		R_StoreWallRange (first, start->first - 1);
	move.l	d1,-(sp)

;	movem.l	d0/d5,-(sp)
	move.l	d5,d1
	bsr		_R_StoreWallRange
;	addq.l	#8,sp

	move.l	(sp)+,d1
;//    }

.nonoman:
;//    /* Bottom contained in start?*/
;//    if (last <= start->last)
;//	return;
	cmp.l		cr_last(a4),d1
	ble.s		.jobdone
	
;//    while (last >= (start+1)->first-1)
;//    {
	move.l	d1,d5						;d5 = last
	bra.s		.whilyentry
	
.whily:
;//	/* There is a fragment between two posts.*/
;//	R_StoreWallRange (start->last + 1, (start+1)->first - 1);
	move.l	d6,d1
	move.l	cr_last(a4),d0
	addq.l	#1,d0
	bsr		_R_StoreWallRange

;//		start++;
	addq.l	#cr_SIZEOF,a4
	
;//	if (last <= start->last)
;//	    return;
	cmp.l		cr_last(a4),d5
	ble.s		.jobdone

;//    }
.whilyentry:
	move.l	cr_SIZEOF+cr_first(a4),d6
	subq.l	#1,d6
	cmp.l		d6,d5
	bge.s		.whily

	
;//    /* There is a fragment after *next.*/
;//    R_StoreWallRange (start->last + 1, last);

	move.l	cr_last(a4),d0
	addq.l	#1,d0
	move.l	d5,d1
	bsr		_R_StoreWallRange
	
.jobdone:

	ENDM



_R_AddLine macro		;// a3 = seg_t line
							;// d2/d3/d4 a2/a3 nicht trashen!!!

;//    int			x1;
;//    int			x2;
;//    angle_t		angle1;
;//    angle_t		angle2;
;//    angle_t		span;
;//    angle_t		tspan;
    
;//    curline = line;

	move.l	a3,_curline

;//    /* OPTIMIZE: quickly reject orthogonal back sides.*/
;//    angle1 = R_PointToAngle (line->v1->x, line->v1->y);
	move.l	sg_v1(a3),a0
	movem.l	(a0),d0/d1
	bsr		_R_PointToAngle_ASM
	move.l	d0,d5					;d5 = angle1

;//    angle2 = R_PointToAngle (line->v2->x, line->v2->y);
	move.l	sg_v2(a3),a0
	movem.l	(a0),d0/d1
	bsr		_R_PointToAngle_ASM
										;d0 = angle2

;//    /* Clip to view edges.*/
;//    /* OPTIMIZE: make constant out of 2*clipangle (FIELDOFVIEW).*/
;//    span = angle1 - angle2;

	move.l	d5,d1
	sub.l		d0,d1					;d1 = span

;//    /* Back side? I.e. backface culling?*/
;//    if (span >= ANG180)
;//	return;		

	bmi.s		.fertig

;//    /* Global angle needed by segcalc.*/
;//    rw_angle1 = angle1;
	move.l	d5,_rw_angle1

;//    angle1 -= viewangle;
	move.l	_viewangle(pc),d6
	sub.l		d6,d5

;//    angle2 -= viewangle;
	sub.l		d6,d0
	
;//    tspan = angle1 + clipangle;
	move.l	d5,d7
	add.l		_clipangle(pc),d7			; d7 = tspan

;//    if (tspan > doubleclipangle)
;//    {
	move.l	_doubleclipangle(pc),d6	; d6 = doubleclipangle
	cmp.l		d6,d7
	bls.s		.tspankleinergl

;//	tspan -= doubleclipangle;
	sub.l		d6,d7

;//	/* Totally off the left edge?*/
;//	if (tspan >= span)
;//	    return;
	cmp.l		d1,d7
	bhs.s		.fertig
	
;//	angle1 = clipangle;
	move.l	_clipangle(pc),d5
;//    }
    
.tspankleinergl:
;//    tspan = clipangle - angle2;

	move.l	_clipangle(pc),d7
	sub.l		d0,d7

;//    if (tspan > doubleclipangle)
;//    {
	cmp.l		d6,d7
	bls.s		.tspankleinergl2

;//	tspan -= doubleclipangle;
	sub.l		d6,d7

;//	/* Totally off the left edge?*/
;//	if (tspan >= span)
;//	    return;	
	cmp.l		d1,d7
	bhs.s		.fertig

;//	angle2 = -clipangle;
	move.l	_clipangle(pc),d0
	neg.l		d0
;//    }

.tspankleinergl2:
;//    /* The seg is in the view range,*/
;//    /* but not necessarily visible.*/
;    angle1 = (angle1+ANG90)>>ANGLETOFINESHIFT;
	moveq		#ANGLETOFINESHIFT,d6
	move.l	#ANG90,d7
	
	add.l		d7,d5
	lsr.l		d6,d5

;//    angle2 = (angle2+ANG90)>>ANGLETOFINESHIFT;
	add.l		d7,d0
	lsr.l		d6,d0

;//    x2 = viewangletox[angle2];
	lea		_viewangletox,a0
	move.l	(a0,d0.w*4),d1			;d1 = x2
	
;//    x1 = viewangletox[angle1];
	move.l	(a0,d5.w*4),d0			;d0 = x1

;//    /* Does not cross a pixel?*/
;//    if (x1 == x2)
;//	return;				
	cmp.l		d0,d1
	beq.s		.fertig
	
;//    backsector = line->backsector;
	move.l	sg_backsector(a3),a0		;a0 = backsector
	move.l	a0,_backsector

;//    /* Single sided line?*/
;//    if (!backsector)
;//	goto clipsolid;		

	tst.l		a0
	beq.s		.clipsolid

	move.l	_frontsector(pc),a1			;a1 = frontsector

;//    /* Closed door.*/
;//    if (backsector->ceilingheight <= frontsector->floorheight
;//	|| backsector->floorheight >= frontsector->ceilingheight)
;//	goto clipsolid;		
	move.l	sc_ceilingheight(a0),d5
	cmp.l		sc_floorheight(a1),d5
	ble.s		.clipsolid
	
	move.l	sc_floorheight(a0),d6
	cmp.l		sc_ceilingheight(a1),d6
	bge.s		.clipsolid
	
;//    /* Window.*/
;//    if (backsector->ceilingheight != frontsector->ceilingheight
;//	|| backsector->floorheight != frontsector->floorheight)
;//	goto clippass;	
	cmp.l		sc_ceilingheight(a1),d5
	bne.s		.clippass
	cmp.l		sc_floorheight(a1),d6
	bne.s		.clippass

;//    /* Reject empty lines used for triggers*/
;//    /*  and special events.*/
;//    /* Identical floor and ceiling on both sides,*/
;//    /* identical light levels on both sides,*/
;//    /* and no middle texture.*/

;//    if (backsector->ceilingpic == frontsector->ceilingpic
;//	&& backsector->floorpic == frontsector->floorpic
;//	&& backsector->lightlevel == frontsector->lightlevel
;//	&& curline->sidedef->midtexture == 0)
;//    {
;//	return;
;//    }
    
    addq.l	#sc_floorpic,a0
    addq.l	#sc_floorpic,a1
    cmpm.l	(a0)+,(a1)+		;// test floorpic/ceilingpic
    bne.s	.clippass
    cmpm.w	(a0)+,(a1)+		;// test lightlevel
    bne.s	.clippass
    move.l	sg_sidedef(a3),a0
    tst.w	sd_midtexture(a0)
    beq.s	.fertig
				
.clippass:
;//    R_ClipPassWallSegment (x1, x2-1);	
;//    return;
	subq.l	#1,d1

	R_ClipPassWallSegment
	
	bra.s		.fertig
		
.clipsolid:
;//    R_ClipSolidWallSegment (x1, x2-1);
	subq.l	#1,d1

	R_ClipSolidWallSegment

.fertig:

	ENDM



_R_CheckBBox macro	;// can trash everything except d2/d3/a2
							;// (fixed_t *a0 bspcoord)

;//    int			boxx;
;//    int			boxy;
;//    int			boxpos;

;//    fixed_t		x1;
;//    fixed_t		y1;
;//    fixed_t		x2;
;//    fixed_t		y2;
    
;//    angle_t		angle1;
;//    angle_t		angle2;
;//    angle_t		span;
;//    angle_t		tspan;
    
;//    cliprange_t*	start;

;//    int			sx1;
;//    int			sx2;
    
;//    /* Find the corners of the box*/
;//    /* that define the edges from current viewpoint.*/
   
   
;//   if (viewx <= bspcoord[BOXLEFT])
;//	boxx = 0;
	move.l	_viewx(pc),d0
	cmp.l		BOXLEFT*4(a0),d0
	bgt.s		.no
	moveq		#0,d0
	bra.s		.boxxOK

.no:
;//    else if (viewx < bspcoord[BOXRIGHT])
;//	boxx = 1;
	cmp.l		BOXRIGHT*4(a0),d0
	bge.s		.no2
	moveq		#1,d0
	bra.s		.boxxOK
	
.no2:
;// else
;//	boxx = 2;
	moveq		#2,d0

.boxxOK:								; d0 = boxx

;//    if (viewy >= bspcoord[BOXTOP])
;//	boxy = 0;
	move.l	_viewy(pc),d1
	cmp.l		BOXTOP*4(a0),d1
	blt.s		.no3
	moveq		#0,d1
	bra.s		.boxyOK
	
.no3:
;//    else if (viewy > bspcoord[BOXBOTTOM])
;//	boxy = 1;
	cmp.l		BOXBOTTOM*4(a0),d1
	ble.s		.no4
	moveq		#1,d1
	bra.s		.boxyOK

.no4:	
;//    else
;//	boxy = 2;
	moveq		#2,d1
	
.boxyOK:								;d1 = boxy		
;//    boxpos = (boxy<<2)+boxx;
	lsl		#2,d1
	add		d1,d0					;d0 = boxpos

	cmp		#5,d0
	beq.s		.done

;//    x1 = bspcoord[checkcoord[boxpos][0]];
;//    y1 = bspcoord[checkcoord[boxpos][1]];
;//    x2 = bspcoord[checkcoord[boxpos][2]];
;//    y2 = bspcoord[checkcoord[boxpos][3]];

	lea		checkcoord(pc),a1
	add		d0,d0
	lea		(a1,d0.w*4),a1
	
	movem		(a1),d0/d1/d4/d5
	move.l	(a0,d0.w*4),d0		;// d0 = x1
	move.l	(a0,d1.w*4),d1		;// d1 = y1
	move.l	(a0,d4.w*4),d4		;// d4 = x2
	move.l	(a0,d5.w*4),d5		;// d5 = y2

;//    /* check clip list for an open space*/
;//    angle1 = R_PointToAngle (x1, y1) - viewangle;

	bsr		_R_PointToAngle_ASM

	move.l	d5,d1
	move.l	d0,d5
	move.l	_viewangle(pc),d6
	sub.l		d6,d5						; d5 = angle1
	
;//   angle2 = R_PointToAngle (x2, y2) - viewangle;
	move.l	d4,d0
	
	bsr		_R_PointToAngle_ASM
	
	sub.l		d6,d0
						
;//  span = angle1 - angle2;

	move.l	d0,d1					;d1 = angle2
	neg.l		d0
	add.l		d5,d0					;d0 = span

;//    /* Sitting on a line?*/
;//    if (span >= ANG180)
;//	return true;

	bmi.s		.done
    
;//    tspan = angle1 + clipangle;

	move.l	d5,d4
	add.l		_clipangle(pc),d4		;d4 = tspan
	
;//    if (tspan > doubleclipangle)
;//    {
	
	move.l	_doubleclipangle(pc),d6	;d6 = clipangle * 2
	cmp.l		d6,d4
	bls.s		.tspankleinergleich

;//		tspan -= doubleclipangle;
	sub.l		d6,d4

;//		/* Totally off the left edge?*/
;//		if (tspan >= span)
;//		    return false;	

	cmp.l		d0,d4
	bhs.s		.donefalse

;//		angle1 = clipangle;
	move.l	_clipangle(pc),d5
;//    }

.tspankleinergleich:
;//    tspan = clipangle - angle2;
	move.l	_clipangle(pc),d4
	sub.l		d1,d4
	
;//    if (tspan > doubleclipangle)
;//    {
	cmp.l		d6,d4
	bls.s		.tspankleinergleich2
	
;//	tspan -= doubleclipangle;

	sub.l		d6,d4

;//	/* Totally off the left edge?*/
;//	if (tspan >= span)
;//	    return false;
	cmp.l		d0,d4
	bhs.s		.donefalse
	
;//	angle2 = -clipangle;
	move.l		_clipangle(pc),d1
	neg.l			d1
;//    }

.tspankleinergleich2:

;//    /* Find the first clippost*/
;//    /*  that touches the source post*/
;//    /*  (adjacent pixels are touching).*/

;//    angle1 = (angle1+ANG90)>>ANGLETOFINESHIFT;

	moveq		#ANGLETOFINESHIFT,d0
	add.l		#ANG90,d5
	lsr.l		d0,d5
	
;//    angle2 = (angle2+ANG90)>>ANGLETOFINESHIFT;

	add.l		#ANG90,d1
	lsr.l		d0,d1

;//    sx1 = viewangletox[angle1];

	lea		_viewangletox,a0
	move.l	(a0,d5.w*4),d0			; d0 = sx1
	
;//   sx2 = viewangletox[angle2];

	move.l	(a0,d1.w*4),d1			; d1 = sx2

;//    /* Does not cross a pixel.*/
;//    if (sx1 == sx2)
;//	return false;			
	cmp.l		d0,d1
	beq.s		.donefalse

;//    sx2--;
	subq.l	#1,d1

;//    start = solidsegs;
	lea		_solidsegs+cr_last,a0
	moveq		#cr_SIZEOF,d4

;//    while (start->last < sx2)
;//	start++;

.while:
	cmp.l		(a0),d1
	ble.s		.startok
	add.w		d4,a0
	cmp.l		(a0),d1
	ble.s		.startok
	add.w		d4,a0
	cmp.l		(a0),d1
	ble.s		.startok
	add.w		d4,a0
	cmp.l		(a0),d1
	ble.s		.startok
	add.w		d4,a0
	bra.s		.while

.startok:
;//    if (sx1 >= start->first
;//	&& sx2 <= start->last)
;//    {
;//	/* The clippost contains the new span.*/
;//	return false;
;//    }

	cmp.l		cr_first-cr_last(a0),d0
	blt.s		.donetrue	
	cmp.l		cr_last-cr_last(a0),d1
	ble.s		.donefalse

;//    return true;
.donetrue:
	moveq		#1,d0
	bra.s		.done

.donefalse:
	moveq		#0,d0
.done:

	ENDM



	CNOP	0,4

_R_Subsector:
;//    int			count;
;//    seg_t*		line;
;//    subsector_t*	sub;
	
;//    sscount++;
	addq.l	#1,_sscount

;//    sub = &subsectors[num];
	move.l	_subsectors,a0
	add.l		d0,d0
	lea		(a0,d0.w*4),a0				;// a0 = sub

;//    frontsector = sub->sector;
	move.l	ss_sector(a0),a1			;// a1 = frontsector
	move.l	a1,_frontsector
	
;//    count = sub->numlines;
	move		ss_numlines(a0),d4		;// d4 = count
	
;//line = &segs[sub->firstline];
	moveq		#0,d0
	move		ss_firstline(a0),d0
	move.l	_segs,a0
	lsl.l		#3,d0
	lea		(a0,d0.l*4),a3				;// a3 = line
	
;//    if (frontsector->floorheight < viewz)
;//    {
	move.l	sc_floorheight(a1),d0
	cmp.l		_viewz(pc),d0
	blt.s		.kleiner

;//    else
;//	floorplane = NULL;

	clr.l		_floorplane
	bra.s		.checkceiling

.kleiner
	move.l	a1,-(sp)

;//	floorplane = R_FindPlane (frontsector->floorheight,
;//				  frontsector->floorpic,
;//				  frontsector->lightlevel);

	moveq		#0,d0
	move		sc_lightlevel(a1),d0
	move.l	d0,-(sp)
	move		sc_floorpic(a1),d0
	move.l	d0,-(sp)
	move.l	sc_floorheight(a1),-(sp)
	bsr		_R_FindPlane
	lea		4*3(sp),sp
	move.l	d0,_floorplane
	
	move.l	(sp)+,a1
    
.checkceiling:
;//    if (frontsector->ceilingheight > viewz 
;//	|| frontsector->ceilingpic == skyflatnum)
;//   {

	move.l	sc_ceilingheight(a1),d0
	cmp.l		_viewz(pc),d0
	bgt.s		.doceiling
	move.l	_skyflatnum(pc),d1
	cmp		sc_ceilingpic(a1),d1
	beq.s		.doceiling

;//    else
;//	ceilingplane = NULL;
	clr.l		_ceilingplane
	bra.s		.sprites

.doceiling:
;//	ceilingplane = R_FindPlane (frontsector->ceilingheight,
;//				    frontsector->ceilingpic,
;//				    frontsector->lightlevel);
	move.l	a1,-(sp)

	moveq		#0,d0
	move		sc_lightlevel(a1),d0
	move.l	d0,-(sp)
	move		sc_ceilingpic(a1),d0
	move.l	d0,-(sp)
	move.l	sc_ceilingheight(a1),-(sp)
	bsr		_R_FindPlane
	lea		3*4(sp),sp
	move.l	d0,_ceilingplane
	
	move.l	(sp)+,a1

.sprites:		
;//    R_AddSprites (frontsector);
;	move.l	a1,-(sp)
;	jsr		_R_AddSprites
;	addq.l	#4,sp

	bsr		_R_AddSprites
	
;//    while (count--)
;//    {
;//	R_AddLine (line);
;//	line++;
;//    }
	
	bra.s		.loopentry

.loop:

	_R_AddLine

	lea		sg_SIZEOF(a3),a3
.loopentry:
	dbf		d4,.loop
	rts


	XDEF	_R_RenderBSPNode	;// (int bspnum)
	CNOP	0,4
	
_R_RenderBSPNode:
	move.l	4(sp),d0					;// d0 = bspnum

	movem.l	d2-d7/a2-a6,-(sp)
	move		d0,d2						;// d2 = bspnum
	bsr.s		R_RenderBSPNode
	
	movem.l	(sp)+,d2-d7/a2-a6

	rts

R_RenderBSPNode:
;//    /* Found a subsector?*/
;//    if (bspnum & NF_SUBSECTOR)
;//    {
	btst		#NFB_SUBSECTOR,d2
	beq.s		.notsubsector

;//	if (bspnum == -1)			
;//	    R_Subsector (0);
	cmp		#-1,d2
	bne.s		.notminus1

	moveq		#0,d0
	bsr.s		_R_Subsector
	rts

;//	else
;//	    R_Subsector (bspnum&(~NF_SUBSECTOR));
;//	return;
	
.notminus1:
	move		d2,d0
	and		#(~NF_SUBSECTOR)&$FFFF,d0
	bsr.s		_R_Subsector
	rts

.notsubsector:
	movem.l	d2/d3/a2,-(sp)

;//    bsp = &nodes[bspnum];

	move.l	_nodestab,a0
	move.l	(a0,d2.w*4),a2		;a2 = bsp

	move.l	a2,a0
	move.l	_viewx(pc),d0
	move.l	_viewy(pc),d1
	
;   /* Decide which side the view point is on.*/
;    side = R_PointOnSide (viewx, viewy, bsp);

;//---R_PointOnSide

	tst.l		8(a0)
	bne.s		.nodedx

	cmp.l		(a0),d0
	bgt.s		.2

	tst.l		12(a0)
	bgt.s		.3

.return0:
	moveq		#0,d0
	bra.s		.afterPOS

.return1:
.3:
	moveq		#1,d0
	bra.s		.afterPOS

.2:
	tst.l		12(a0)
	blt.s		.return1
	moveq		#0,d0
	bra.s		.afterPOS
	
.nodedx:
	tst.l		12(a0)
	bne.s		.nodedy
	
	cmp.l		4(a0),d1
	bgt.s		.6
	
	tst.l		8(a0)
	blt.s		.return1
	moveq		#0,d0
	bra.s		.afterPOS
	
.6:
	tst.l		8(a0)
	bgt.s		.return1
	moveq		#0,d0
	bra.s		.afterPOS
	
.nodedy:	
	sub.l		(a0),d0
	sub.l		4(a0),d1
	
	move.l	d0,d6
	eor.l		d1,d6
	move.l	8(a0),d7
	eor.l		d7,d6
	move.l	12(a0),d7
	eor.l		d7,d6
	bpl.s		.33
	
	eor.l		d7,d0
	bpl.s		.return0
	
	moveq		#1,d0
	bra.s		.afterPOS

.33:
	move		12(a0),d6
	ext.l		d6

	IFND	version060

	muls.l	d6,d6:d0
	move		d6,d0
	swap		d0
	
	ELSE

	fmove.l	d0,fp0
	fmul.l	d6,fp0
	fmul.x	fp7,fp0
	fmove.l	fp0,d0
	
	ENDC

	move		8(a0),d6
	ext.l		d6

	IFND	version060

	muls.l	d6,d6:d1
	move		d6,d1
	swap		d1

	ELSE

	fmove.l	d1,fp0
	fmul.l	d6,fp0
	fmul.x	fp7,fp0
	fmove.l	fp0,d1
	
	ENDC

	cmp.l		d0,d1
	bge.s		.return1

	moveq		#0,d0

.afterPOS:

;---End R_PointOnSide

	move.l	d0,d3			;d3 = side

;    /* Recursively divide front space.*/
;    R_RenderBSPNode (bsp->children[side]); 

	move		nd_children(a2,d3.w*2),d2
	bsr.s		R_RenderBSPNode
	
;//    /* Possibly divide back space.*/
;//    if (R_CheckBBox (bsp->bbox[side^1]))	
;//	R_RenderBSPNode (bsp->children[side^1]);

;// side^1
	eor		#1,d3
	move		d3,d0
	lsl		#2,d0
	lea		nd_bbox(a2,d0.w*4),a0
	
	_R_CheckBBox

	tst.l		d0
	beq.s		.exit
	
	move		nd_children(a2,d3.w*2),d2
	bsr.s		R_RenderBSPNode
	
.exit:
	movem.l	(sp)+,d2/d3/a2
	rts



;/***************************************************/
;/*                                                 */
;/*       R_SEGS                                    */
;/*                                                 */
;/***************************************************/


R_GetColumn2	macro	;d0 = tex  d1 = col 	
	movem.l	d2/d3/a2,-(sp)

	;/* col &= texturewidthmask[tex] */
	
	move.l	_texturewidthmask(pc),a0
	and.l		(a0,d0.w*4),d1

	;/* ofs = texturecolumnofs[tex][col] */

	move.l	_texturecolumnofs(pc),a0
	move.l	(a0,d0.w*4),a0
	moveq		#0,d2
	move.w	(a0,d1.w*2),d2

	;/* d2 = ofs */

	;/* lump = texturecolumnlump[tex][col] */
	
	move.l	_texturecolumnlump(pc),a0
	move.l	(a0,d0.w*4),a0
	moveq		#0,d3
	move.w	(a0,d1.w*2),d3

	;/* d3 = lump */
		
	;/* lump >0 ? */
	
	ble.s		.\@lumpkleinernull
		
	;/* return W_CacheLumpNum(lump,PU_CACHE)+ofs */
		
	move.l	_lumpcache,a0
	move.l	(a0,d3.w*4),d0
	beq.s		.\@nichtgecached

	move.l	d0,a0
	moveq		#PU_CACHE,d1
	move.l	d1,-16(a0)	;	/* tag -> PU_CACHE */
	bra.s		.\@exit2
		
.\@nichtgecached:
	;/* nicht gecached -> richtige (langsame) Funktion aufrufen */

	moveq		#PU_CACHE,d0
	move.l	d0,-(sp)
	move.l	d3,-(sp)
	jsr		_WW_CacheLumpNum
	addq.l	#8,sp
	bra.s		.\@exit2
		
.\@lumpkleinernull:
	;/* <0: texturecomposite[tex] ? */
	
	move.l	_texturecomposite(pc),a2
	move.l	(a2,d0.w*4),d1
	beq.s		.\@istnull
		
	;/* return texturecomposite[tex] + ofs */
	
	move.l	d1,d0
	bra.s		.\@exit2
		
.\@istnull:
	;/* !texturecomposite[tex]: */

	move.l	d0,-(sp)
	lea		(a2,d0.w*4),a2
	jsr		_R_GenerateComposite
	addq.l	#4,sp
		
	move.l	(a2),d0
.\@exit2:
	add.l		d2,d0
.\@exit:	
	movem.l	(sp)+,d2/d3/a2
	
	ENDM


	XREF	_ceilingclip
	XREF	_floorclip
	XREF	_scalelight
	XREF	_finetangent
	XREF	_tantoangle
	XREF	_screenheightarray
	XREF	_negonearray

	XDEF	_R_RenderSegLoop
	CNOP	0,4
	
_R_RenderSegLoop:
;//    angle_t		angle;
;//    unsigned		index;
;//    int			yl;
;//    int			yh;
;//    int			mid;
;//    fixed_t		texturecolumn;
;//    int			top;
;//    int			bottom;

;//    /*texturecolumn = 0;				// shut up compiler warning*/
	
;//    for ( ; rw_x < rw_stopx ; rw_x++)
;//    {

	move.l	_rw_x(pc),d0
	cmp.l		_rw_stopx(pc),d0
	blt.s		.muchwork
	rts

.muchwork:
	movem.l	d2-d7/a2-a6,-(sp)

	move.l	d0,a2							;'a2 = rw_x
	move.l	_topfrac(pc),a3					;'a3 = topfrac
	move.l	_bottomfrac(pc),a4				;'a4 = bottomfrac
	move.l	_rw_scale(pc),a5				;'a5 = rw_scale
	lea		_ceilingclip,a6			;'a6 = ceilingclip
	
.rwloop:
;//	/* mark floor / ceiling areas*/
;//	yl = (topfrac+HEIGHTUNIT-1)>>HEIGHTBITS;
	move.l	a3,d2
	add.l		#HEIGHTUNIT-1,d2
	moveq		#HEIGHTBITS,d0
	asr.l		d0,d2							;'d2 = yl

;//	/* no space above wall?*/
;//	if (yl < ceilingclip[rw_x]+1)
;//	    yl = ceilingclip[rw_x]+1;
	move		(a6,a2.w*2),d0
	ext.l		d0
	move.l	d0,d1							;'d1 = ceilingclip[rw_x]
	addq.l	#1,d0							;'d0 = ceilingclip[rw_x]+1
	cmp.l		d0,d2
	bge.s		.ylOK
	move.l	d0,d2
	
.ylOK:
;//	if (markceiling)
;//	{
	tst.l		_markceiling(pc)
	beq.s		.nomarkceiling

;//	    top = ceilingclip[rw_x]+1;
;	d0								;d0 = top

;//	    bottom = yl-1;
	move.l	d2,d3
	subq.l	#1,d3				;d3 = bottom
	
;//	    if (bottom >= floorclip[rw_x])
;//		bottom = floorclip[rw_x]-1;
	lea		_floorclip,a0
	move		(a0,a2.w*2),d4
	ext.l		d4
	cmp.l		d4,d3
	blt.s		.bottomok
	move.l	d4,d3
	subq.l	#1,d3
	
.bottomok:
;//	    if (top <= bottom)
;//	    {

	cmp.l		d3,d0
	bgt.s		.topgreater
	
	move.l	_ceilingplane(pc),a0

;//		ceilingplane->top[rw_x] = top;
	move		d0,vp_top(a0,a2.w*2)
	
;//		ceilingplane->bottom[rw_x] = bottom;
	move		d3,vp_bottom(a0,a2.w*2)

;//	    }
.topgreater:
;//	}

.nomarkceiling:
;//	yh = bottomfrac>>HEIGHTBITS;
	move.l	a4,d3
	moveq		#HEIGHTBITS,d0
	asr.l		d0,d3						;'d3 = yh
	
;//	if (yh >= floorclip[rw_x])
;//	    yh = floorclip[rw_x]-1;

	lea		_floorclip,a0
	move		(a0,a2.w*2),d0
	ext.l		d0							;'d0 = floorclip[rw_x]
	move.l	d0,d1
	subq.l	#1,d1						;'d1 = floorclip[rw_x]-1
	
	cmp.l		d0,d3
	blt.s		.yhOK
	move.l	d1,d3
	
.yhOK:
;//	if (markfloor)
;//	{
	tst.l		_markfloor(pc)
	beq.s		.nomarkfloor

;//	    top = yh+1;
	move.l	d3,d4
	addq.l	#1,d4						;'d4 = top
	
;//	    bottom = floorclip[rw_x]-1;
;	d1										;'d1 = bottom

;//	    if (top <= ceilingclip[rw_x])
;//			top = ceilingclip[rw_x]+1;
	move		(a6,a2.w*2),d0
	cmp		d0,d4
	bgt.s		.topok
	move		d0,d4
	addq		#1,d4
	
.topok:
;//	    if (top <= bottom)
;//	    {

	cmp		d1,d4
	bgt.s		.topgreater2

;//		floorplane->top[rw_x] = top;
	move.l	_floorplane(pc),a0
	move		d4,vp_top(a0,a2.w*2)

;//		floorplane->bottom[rw_x] = bottom;
	move		d1,vp_bottom(a0,a2.w*2)
;//	    }
.topgreater2:
;//	}

.nomarkfloor:	
;//	/* texturecolumn and lighting are independent of wall tiers*/
;//	if (segtextured)
;//	{
	tst.l		_segtextured(pc)
	beq.s		.notsegtextured

;//	    /* calculate texture offset*/
;//	    angle = (rw_centerangle + xtoviewangle[rw_x])>>ANGLETOFINESHIFT;
	move.l	_rw_centerangle(pc),d0
	lea		_xtoviewangle,a0
	add.l		(a0,a2.w*4),d0
	moveq		#ANGLETOFINESHIFT,d1
	lsr.l		d1,d0				;d0 = angle
	
;//	    texturecolumn = rw_offset-FixedMul(finetangent[angle],rw_distance);
	
	lea		_finetangent,a0
	move.l	(a0,d0.w*4),d0
	
	IFND	version060
	
	muls.l	_rw_distance(pc),d1:d0
	move		d1,d0
	swap		d0
	
	ELSE
	
	fmove.l	_rw_distance(pc),fp0
	fmul.l	d0,fp0
	fmul.x	fp7,fp0
	fmove.l	fp0,d0
	
	ENDC
	
	move.l	_rw_offset(pc),d4
	sub.l		d0,d4						;'d4 = texturecolumn

;//	    texturecolumn >>= FRACBITS;
	swap		d4
	ext.l		d4		;wird von R_GetColumn sowieso mit texturewidthmask geANDet


;//	    /* calculate lighting*/
;//	    index = rw_scale>>LIGHTSCALESHIFT;
	move.l	a5,d0
	moveq		#LIGHTSCALESHIFT,d1
	asr.l		d1,d0

;//	    if (index >=  MAXLIGHTSCALE )
;//		index = MAXLIGHTSCALE-1;

	moveq		#MAXLIGHTSCALE,d1
	cmp.l		d1,d0
	blo.s		.indexok
	moveq		#MAXLIGHTSCALE-1,d0

.indexok:
;//	    dc_colormap = walllights[index];
	move.l	_walllights(pc),a0
	move.l	(a0,d0.w*4),_dc_colormap

;//	    dc_x = rw_x;
	move.l	a2,_dc_x

;//	    dc_iscale = ULongDiv(0xffffffffu,(unsigned)rw_scale);
	moveq		#-1,d0
	move.l	a5,d1
	divu.l	d1,d0
	move.l	d0,_dc_iscale

;//	}

.notsegtextured:
;//	/* draw the wall tiers*/
;//	if (midtexture)
;//	{
	tst.l		_midtexture(pc)
	beq.s		.else

;//	    /* single sided line*/
;//	    dc_yl = yl;
	move.l	d2,_dc_yl

;//	    dc_yh = yh;
	move.l	d3,_dc_yh

;//	    dc_texturemid = rw_midtexturemid;
	move.l	_rw_midtexturemid(pc),d0
	move.l	d0,_dc_texturemid

;//	    dc_source = R_GetColumn(midtexture,texturecolumn);
	move.l	_midtexture(pc),d0
	move.l	d4,d1

	R_GetColumn2

	move.l	d0,_dc_source
	
;//    colfunc ();
	move.l	_colfunc(pc),a0
	jsr		(a0)

;//	    ceilingclip[rw_x] = viewheight;
	move.l	_viewheight(pc),d0
	move		d0,(a6,a2.w*2)
	
;//	    floorclip[rw_x] = -1;
	lea		_floorclip,a0
	moveq		#-1,d0
	move		d0,(a0,a2.w*2)
	
;//	}
	bra.s		.donext

;//	else
;//	{

.else:

;//	    /* two sided line*/
;//	    if (toptexture)
;//	    {
	tst.l		_toptexture(pc)
	beq.s		.nottoptexture

;//		/* top wall*/
;//		mid = pixhigh>>HEIGHTBITS;
	lea		_pixhigh,a0
	move.l	(a0),d5
	moveq		#HEIGHTBITS,d0
	asr.l		d0,d5							;'d5 = mid
	
;//		pixhigh += pixhighstep;
	move.l	_pixhighstep(pc),d0
	add.l		d0,(a0)

;//		if (mid >= floorclip[rw_x])
;//		    mid = floorclip[rw_x]-1;
	lea		_floorclip,a0
	move		(a0,a2.w*2),d0
	ext.l		d0
	
	cmp.l		d0,d5
	blt.s		.midOK
	move.l	d0,d5
	subq.l	#1,d5
	
.midOK:
;//		if (mid >= yl)
;//		{
	cmp.l		d2,d5
	blt.s		.midsmaller

;//		    dc_yl = yl;
	move.l	d2,_dc_yl
	
;//		    dc_yh = mid;
	move.l	d5,_dc_yh

;//		    dc_texturemid = rw_toptexturemid;
	move.l	_rw_toptexturemid(pc),d0
	move.l	d0,_dc_texturemid

;//		    dc_source = R_GetColumn(toptexture,texturecolumn);
	move.l	_toptexture(pc),d0
	move.l	d4,d1
	
	R_GetColumn2
	
	move.l	d0,_dc_source
	
;//		    colfunc ();
	move.l	_colfunc(pc),a0
	jsr		(a0)

;//		    ceilingclip[rw_x] = mid;
	move.w	d5,(a6,a2.w*2)
	
;//		}
	bra.s		.bottomtexture

;//		else
.midsmaller:
;//		    ceilingclip[rw_x] = yl-1;
	move		d2,d0
	subq		#1,d0
	move		d0,(a6,a2.w*2)
;//	    }
	bra.s		.bottomtexture

.nottoptexture:
;//	    else
;//	    {
;//		/* no top wall*/
;//		if (markceiling)
;//		    ceilingclip[rw_x] = yl-1;
	tst.l		_markceiling(pc)
	beq.s		.bottomtexture
	
	move		d2,d0
	subq		#1,d0
	move		d0,(a6,a2.w*2)
;//	    }

.bottomtexture:
;//	    if (bottomtexture)
;//	    {
	tst.l		_bottomtexture(pc)
	beq.s		.nobottomtexture

;//		/* bottom wall*/
;//		mid = (pixlow+HEIGHTUNIT-1)>>HEIGHTBITS;
	lea		_pixlow,a0
	move.l	(a0),d5
	add.l		#HEIGHTUNIT-1,d5
	moveq		#HEIGHTBITS,d0
	asr.l		d0,d5							;'d5 = mid
	
;//		pixlow += pixlowstep;
	move.l	_pixlowstep(pc),d0
	add.l		d0,(a0)

;//		/* no space above wall?*/
;//		if (mid <= ceilingclip[rw_x])
;//		    mid = ceilingclip[rw_x]+1;
	move		(a6,a2.w*2),d0
	ext.l		d0
	
	cmp.l		d0,d5
	bgt.s		.midok
	move.l	d0,d5
	addq.l	#1,d5
	
.midok:
;//		if (mid <= yh)
;//		{
	cmp.l		d3,d5
	bgt.s		.midgreater

;//		    dc_yl = mid;
	move.l	d5,_dc_yl

;//		    dc_yh = yh;
	move.l	d3,_dc_yh

;//		    dc_texturemid = rw_bottomtexturemid;
	move.l	_rw_bottomtexturemid(pc),d0
	move.l	d0,_dc_texturemid

;//		    dc_source = R_GetColumn(bottomtexture,
;//					    texturecolumn);
	move.l	_bottomtexture(pc),d0
	move.l	d4,d1
	
	R_GetColumn2
	
	move.l	d0,_dc_source

;//		    colfunc ();
	move.l	_colfunc(pc),a0
	jsr		(a0)

;//		    floorclip[rw_x] = mid;
	lea		_floorclip,a0
	move		d5,(a0,a2.w*2)

;//		}
	bra.s		.maskedtexture

;//		else
.midgreater:
;//		    floorclip[rw_x] = yh+1;
	lea		_floorclip,a0
	move		d3,d0
	addq		#1,d0
	move		d0,(a0,a2.w*2)

;//	    }
	bra.s		.maskedtexture

.nobottomtexture:
;//	    else
;//	    {
;//		/* no bottom wall*/
;//		if (markfloor)
;//		    floorclip[rw_x] = yh+1;
	tst.l		_markfloor(pc)
	beq.s		.maskedtexture
	
	lea		_floorclip,a0
	move		d3,d0
	addq		#1,d0
	move		d0,(a0,a2.w*2)
;//	    }

.maskedtexture:
;//	    if (maskedtexture)
;//	    {
	tst.l		_maskedtexture(pc)
	beq.s		.donext

;//		/* save texturecol*/
;//		/*  for backdrawing of masked mid texture*/
;//		maskedtexturecol[rw_x] = texturecolumn;
	
	move.l	_maskedtexturecol(pc),a0
	move		d4,(a0,a2.w*2)
;//	    }


;//	}

.donext:	
;//	rw_scale += rw_scalestep;
	add.l		_rw_scalestep(pc),a5
;//	topfrac += topstep;
	add.l		_topstep(pc),a3
;//	bottomfrac += bottomstep;
	add.l		_bottomstep(pc),a4

	addq.l	#1,a2
	cmp.l		_rw_stopx(pc),a2
	blt.s		.rwloop

	move.l	a2,_rw_x
	move.l	a3,_topfrac
	move.l	a4,_bottomfrac
	move.l	a5,_rw_scalestep
	movem.l	(sp)+,d2-d7/a2-a6
	rts	

	XREF	_sprbottomscreen

	XDEF	_R_RenderMaskedSegRange
	CNOP	0,4

_R_RenderMaskedSegRange:	;' (drawseg_t*	ds,int x1, int x2 )
;//    unsigned	index;
;//    column_t*	col;
;//    int		lightnum;
;//    int		texnum;
    
;//    /* Calculate light table.*/
;//    /* Use different light tables*/
;//    /*   for horizontal / vertical / diagonal. Diagonal?*/
;//    /* OPTIMIZE: get rid of LIGHTSEGSHIFT globally*/

	movem.l	d2-d7/a2-a6,-(sp)
	
	movem.l	11*4+4(sp),a2/a3/a4			;'a2 = ds
													;'a3 = x1
													;'a4 = x2
;//    curline = ds->curline;
	move.l	ds_curline(a2),a0
	move.l	a0,_curline
	
;//    frontsector = curline->frontsector;
	move.l	sg_frontsector(a0),a5		;'a5 = frontsector
	move.l	a5,_frontsector

;//    backsector = curline->backsector;
	move.l	sg_backsector(a0),a6
	move.l	a6,_backsector					;'a6 = backsector

;//    texnum = texturetranslation[curline->sidedef->midtexture];
	move.l	sg_sidedef(a0),a1
	move		sd_midtexture(a1),d2
	move.l	_texturetranslation(pc),a1
	move.l	(a1,d2.w*4),d2					;'d2 = texnum
	
;//    lightnum = (frontsector->lightlevel >> LIGHTSEGSHIFT)+extralight;

	move		sc_lightlevel(a5),d0
	lsr		#LIGHTSEGSHIFT,d0
	add		_extralight+2(pc),d0				;'d0 = lightnum

;//    if (curline->v1->y == curline->v2->y)
;//	lightnum--;
	move.l	sg_v1(a0),a1
	movem.l	(a1),d3/d4
	move.l	sg_v2(a0),a1
	movem.l	(a1),d5/d6
	cmp.l		d4,d6
	bne.s		.lightok
	subq		#1,d0
	bra.s		.lightokok
	
.lightok:
;//    else if (curline->v1->x == curline->v2->x)
;//	lightnum++;
	cmp.l		d3,d5
	bne.s		.lightokok
	addq		#1,d0
	
.lightokok:
;//    if (lightnum < 0)		
;//	walllights = scalelight[0];
	tst		d0
	bpl.s		.istpos
	move.l	#_scalelight,_walllights
	bra.s		.walllightsok

.istpos
;//    else if (lightnum >= LIGHTLEVELS)
;//	walllights = scalelight[LIGHTLEVELS-1];
	cmp		#LIGHTLEVELS,d0
	blt.s		.lightinnerhalb
	move.l	#_scalelight+(MAXLIGHTSCALE*4*(LIGHTLEVELS-1)),_walllights
	bra.s		.walllightsok
	
.lightinnerhalb:
;//    else
;//	walllights = scalelight[lightnum];
	lea		_scalelight,a1
	lsl		#6,d0		; * 64
	add.w		d0,a1
	add		d0,d0		; * 128
	add.w		d0,a1
	move.l	a1,_walllights

.walllightsok:
;//    maskedtexturecol = ds->maskedtexturecol;
	move.l	ds_maskedtexturecol(a2),_maskedtexturecol
	
;//    rw_scalestep = ds->scalestep;		
	move.l	ds_scalestep(a2),d0
	move.l	d0,_rw_scalestep

;//    spryscale = ds->scale1 + (x1 - ds->x1)*rw_scalestep;
	move.l	a3,d1
	sub.l		ds_x1(a2),d1
	muls.l	d0,d1
	add.l		ds_scale1(a2),d1
	move.l	d1,_spryscale
	
;//    mfloorclip = ds->sprbottomclip;
	move.l	ds_sprbottomclip(a2),_mfloorclip

;//   mceilingclip = ds->sprtopclip;
   move.l	ds_sprtopclip(a2),_mceilingclip
   
;    /* find positioning*/
;//    if (curline->linedef->flags & ML_DONTPEGBOTTOM)
;//    {
	move.l	sg_linedef(a0),a1
	btst		#MLB_DONTPEGBOTTOM,ln_flags+1(a1)
	beq.s		.else

;//		dc_texturemid = frontsector->floorheight > backsector->floorheight
;//		    ? frontsector->floorheight : backsector->floorheight;
	move.l	sc_floorheight(a5),d0
	move.l	sc_floorheight(a6),d1
	cmp.l		d1,d0
	bgt.s		.gut
	move.l	d1,d0
.gut:
;//		dc_texturemid = dc_texturemid + textureheight[texnum] - viewz;
	move.l	_textureheight(pc),a1
	add.l		(a1,d2.w*4),d0
	sub.l		_viewz(pc),d0
;//    }
	bra.s		.posok
	
;//    else
;//    {
.else:
;//		dc_texturemid =frontsector->ceilingheight<backsector->ceilingheight
;//		    ? frontsector->ceilingheight : backsector->ceilingheight;
	
	move.l	sc_ceilingheight(a5),d0
	move.l	sc_ceilingheight(a6),d1
	cmp.l		d1,d0
	blt.s		.gut2
	move.l	d1,d0

.gut2:
;//		dc_texturemid = dc_texturemid - viewz;
	sub.l		_viewz(pc),d0
;//    }
.posok:
;//    dc_texturemid += curline->sidedef->rowoffset;
	move.l	sg_sidedef(a0),a1
	add.l		sd_rowoffset(a1),d0
	move.l	d0,_dc_texturemid
			
;//    if (fixedcolormap)
;//		dc_colormap = fixedcolormap;
	move.l	_fixedcolormap(pc),d0
   beq.s		.notfixedcolormap
   move.l	d0,_dc_colormap

.notfixedcolormap:
;//    /* draw the columns*/
;//    for (dc_x = x1 ; dc_x <= x2 ; dc_x++)
;//    {
	move.l	a4,d7
	sub.l		a3,d7
	bmi.s		.byebye
	move.l	a3,_dc_x
	
	move.l	_maskedtexturecol(pc),a2
	lea		(a2,a3.w*2),a2
	move.l	_walllights(pc),a3
	lea		_spryscale(pc),a4
	move.l	(a4),d4
	move.w	#MAXSHORT,d5
	move.l	_centeryfrac(pc),d6
;//	subq.l	#4,sp

	tst.l		_fixedcolormap(pc)
	beq.s		.for

;' for wo fixedcolormap

.for_fast:
;//		/* calculate lighting*/
;//		if (maskedtexturecol[dc_x] != MAXSHORT)
;//		{
	move		(a2),d1
	cmp		d5,d1
	beq.s		.for_fast2

;//		    sprtopscreen = centeryfrac - FixedMul(dc_texturemid, spryscale);
	
	IFND	version060
	
	move.l	d4,d0
	muls.l	_dc_texturemid,d3:d0
	move		d3,d0
	swap		d0
	
	ELSE
	
	fmove.l	_dc_texturemid,fp0
	fmul.l	d4,fp0
	fmul.x	fp7,fp0
	fmove.l	fp0,d0
	
	ENDC
	
	move.l	d6,a0
	sub.l		d0,a0
	move.l	a0,_sprtopscreen

;//		    dc_iscale = 0xffffffffu / (unsigned)spryscale;
	moveq		#-1,d0
	divu.l	d4,d0
	move.l	d0,_dc_iscale

;//		    /* draw the texture*/
;//		    col = (column_t *)( 
;//			(byte *)R_GetColumn(texnum,maskedtexturecol[dc_x]) -3);

	move.l	d2,d0

	R_GetColumn2

	subq.l	#3,d0

;//		    R_DrawMaskedColumn (col);
;//	move.l	d0,(sp)
	bsr		_R_DrawMaskedColumn

;//		    maskedtexturecol[dc_x] = MAXSHORT;
	move.w	d5,(a2)
;//		}
.for_fast2:
;//		spryscale += rw_scalestep;
	add.l		_rw_scalestep(pc),d4
	move.l	d4,(a4)

;//    }
	addq.l	#2,a2
	addq.l	#1,_dc_x
	dbf		d7,.for_fast

	bra.s		.fordone

;' For wo !fixedcolormap
	
.for:
;//		/* calculate lighting*/
;//		if (maskedtexturecol[dc_x] != MAXSHORT)
;//		{
	move		(a2),d1
	cmp		d5,d1
	beq.s		.for2

;//		    if (!fixedcolormap)
;//		    {
	tst.l		_fixedcolormap(pc)
	bne.s		.isfixedcolormap

;//			index = spryscale>>LIGHTSCALESHIFT;
	move.l	d4,d0
	moveq		#LIGHTSCALESHIFT,d3
	lsr.l		d3,d0

;//			if (index >=  MAXLIGHTSCALE )
;//			    index = MAXLIGHTSCALE-1;
	moveq		#MAXLIGHTSCALE-1,d3
	cmp		d3,d0
	bls.s		.indexok
	move		d3,d0
	
.indexok:
;//			dc_colormap = walllights[index];
	move.l	(a3,d0.w*4),_dc_colormap
;//		    }
.isfixedcolormap:				
;//		    sprtopscreen = centeryfrac - FixedMul(dc_texturemid, spryscale);
	
	IFND	version060
	
	move.l	d4,d0
	muls.l	_dc_texturemid,d3:d0
	move		d3,d0
	swap		d0
	
	ELSE
	
	fmove.l	_dc_texturemid,fp0
	fmul.l	d4,fp0
	fmul.x	fp7,fp0
	fmove.l	fp0,d0
	
	ENDC
	
	move.l	d6,a0
	sub.l		d0,a0
	move.l	a0,_sprtopscreen

;//		    dc_iscale = 0xffffffffu / (unsigned)spryscale;
	moveq		#-1,d0
	divu.l	d4,d0
	move.l	d0,_dc_iscale

;//		    /* draw the texture*/
;//		    col = (column_t *)( 
;//			(byte *)R_GetColumn(texnum,maskedtexturecol[dc_x]) -3);

	move.l	d2,d0

	R_GetColumn2

	subq.l	#3,d0

;//		    R_DrawMaskedColumn (col);
;//	move.l	d0,(sp)
	bsr		_R_DrawMaskedColumn

;//		    maskedtexturecol[dc_x] = MAXSHORT;
	move.w	d5,(a2)
;//		}
.for2:
;//		spryscale += rw_scalestep;
	add.l		_rw_scalestep(pc),d4
	move.l	d4,(a4)

;//    }
	addq.l	#2,a2
	addq.l	#1,_dc_x
	dbf		d7,.for

.fordone:
;//	addq.l	#4,sp


.byebye:
	movem.l	(sp)+,d2-d7/a2-a6
	rts

	

;	IFD notyetimplemented

	XDEF	_RR_StoreWallRange
	CNOP	0,4
	
_RR_StoreWallRange:
_R_StoreWallRange:
;	movem.l	4(sp),d0/d1

	movem.l	d2-d7/a2-a6,-(sp)

;//    if (ds_p == &drawsegs[MAXDRAWSEGS])
;//	return;		
	
	move.l	_ds_p(pc),a2								;'a2 = ds_p
	cmp.l		 _maxdrawseg(pc),a2
	beq.s		.geschafft

;//    sidedef = curline->sidedef;
	move.l	_curline,a3							;'a3 = curline
	move.l	sg_sidedef(a3),_sidedef
	
;//    linedef = curline->linedef;
	move.l	sg_linedef(a3),a0
	move.l	a0,_linedef

;//    /* mark the segment as visible for auto map*/
;//    linedef->flags |= ML_MAPPED;
   bset		#0,ln_flags(a0)
   
;//    /* calculate rw_distance for scale calculation*/
;//   rw_normalangle = curline->angle + ANG90;
	move.l	#ANG90,d3
	move.l	sg_angle(a3),d2
	add.l		d3,d2
	move.l	d2,_rw_normalangle

;//    offsetangle = abs(rw_normalangle-rw_angle1);
   sub.l		_rw_angle1,d2
   bpl.s		.signOK
   neg.l		d2
   
.signOK:
;//    if (offsetangle > ANG90)
;//	offsetangle = ANG90;
	cmp.l		d3,d2
	bls.s		.offsetangleOK
	move.l	d3,d2
	
.offsetangleOK:
;//    distangle = ANG90 - offsetangle;
	sub.l		d2,d3							;'d3 = distangle

;//    hyp = R_PointToDist (curline->v1->x, curline->v1->y);

	move.l	sg_v1(a3),a0
	movem.l	(a0),d4/d5
	
	;*** R_POINTTODIST ***

	sub.l		_viewx(pc),d4
	bpl.s		.1
	
	neg.l		d4
	
.1:
	sub.l		_viewy(pc),d5
	bpl.s		.2
	
	neg.l		d5

.2:
	cmp.l		d4,d5
	blt.s		.3
	
	exg		d4,d5
	
.3:
	tst.l	 	d4
	bne.s		.4
	moveq		#0,d4
	bra.s		.9

.4:
	
	IFND	version060
	
	swap		d5
	move.w	d5,d2
	ext.l		d2
	clr.w		d5
	divs.l	d4,d2:d5

	ELSE

	fmove.l	d5,fp0
	fdiv.l	d4,fp0
	fmul.x	fp6,fp0
	fmove.l	fp0,d5

	ENDC

	lsr.l		#5,d5
	
	lea		_tantoangle,a0
	move.l	(a0,d5.l*4),d5
	add.l		#$40000000,d5
	swap   	d5
	asr.w		#3,d5
	ext.l		d5
	
	lea		_finesine,a0
	move.l	(a0,d5.l*4),d5
	
	IFND	version060

	swap		d4
	move		d4,d2
	ext.l		d2
	clr.w		d4
	divs.l	d5,d2:d4

	ELSE

	fmove.l	d4,fp0
	fdiv.l	d5,fp0
	fmul.x	fp6,fp0
	fmove.l	fp0,d4

	ENDC
	
.9:
	
	;*** R_POINTTODIST ***

														;'d4 = hyp

;//    sineval = finesine[distangle>>ANGLETOFINESHIFT];
	lea		_finesine,a0
	moveq		#ANGLETOFINESHIFT,d2
	lsr.l		d2,d3
	
	move.l	(a0,d3.w*4),d3
	
;//    rw_distance = FixedMul (hyp, sineval);
	
	IFND	version060
	
	move.l	d4,d2
	muls.l	d3,d3:d2
	move		d3,d2
	swap		d2
	
	ELSE
	
	fmove.l	d4,fp0
	fmul.l	d3,fp0
	fmul.x	fp7,fp0
	fmove.l	fp0,d2
	
	ENDC
	
	move.l	d2,_rw_distance
	
;//    ds_p->x1 = rw_x = start;
;//    ds_p->x2 = stop;
	movem.l	d0/d1,ds_x1(a2)
	move.l	d0,_rw_x

;//    ds_p->curline = curline;
	move.l	a3,ds_curline(a2)

;//    rw_stopx = stop+1;
	move.l	d1,d2
	addq.l	#1,d2
	move.l	d2,_rw_stopx
    
;//    /* calculate scale at both ends and step*/
;//    ds_p->scale1 = rw_scale = 
;//	R_ScaleFromGlobalAngle (viewangle + xtoviewangle[start])/* * (REALSCREENHEIGHT / 200)*/;

   move.l	_viewangle(pc),d2		;// d2 = viewangle
   move.l	d2,d3
   lea		_xtoviewangle,a1
   add.l		(a1,d0.w*4),d3
   
	;*** R_SCALEFROMGLOBALANGLE ***
	
	move.l	d3,d5
	sub.l		_rw_normalangle,d5
	move.l	#$40000000,d6
	add.l		d6,d5
	sub.l		_viewangle(pc),d3
	add.l		d6,d3
	lea		_finesine,a0
	moveq		#19,d6
	lsr.l		d6,d3
	move.l	(a0,d3.l*4),d3
	lsr.l		d6,d5
	move.l	(a0,d5.l*4),d5
	
	IFND	version060

	muls.l	_projection(pc),d6:d5
	move		d6,d5
	swap		d5
	
	ELSE

	fmove.l	_projection(pc),fp0
	fmul.l	d5,fp0
	fmul.x	fp7,fp0
	fmove.l	fp0,d5
	
	ENDC
	
	move.l 	_detailshift(pc),d6
	asl.l		d6,d5
		
	IFND	version060
	
	muls.l	_rw_distance,d6:d3
	move		d6,d3
	swap		d3
	
	ELSE

	fmove.l	_rw_distance,fp0
	fmul.l	d3,fp0
	fmul.x	fp7,fp0
	fmove.l	fp0,d3
	
	ENDC

	move.l	d5,d6
	swap		d6
	ext.l		d6
	cmp.l		d6,d3
	bgt.s		.11
		
	moveq		#64,d3
	swap		d3
	bra.s		.99
		
.11:
	
	IFND	version060
	
	swap		d5
	move		d5,d6
	ext.l		d6
	clr.w		d5
	divs.l	d3,d6:d5

	ELSE

	fmove.l 	d5,fp0
	fdiv.l	d3,fp0
	fmul.x  	fp6,fp0
	fmove.l	fp0,d5

	ENDC

	move.l	#256,d6
	cmp.l		d6,d5
	bge.s		.22
	move.l	d6,d3
	bra.s		.99

.22:
	move.l	 d5,d3
	moveq		#64,d6
	swap		d6
	cmp.l		d6,d3
	ble.s		.99
	move.l	d6,d3
		
.99:

	*** END R_SCALEFROMGLOBALANGLE ***
   
   move.l	d3,_rw_scale
   move.l	d3,d7
   move.l	d3,ds_scale1(a2)
   
;//    if (stop > start )
;//    {
	cmp.l		d0,d1
	ble.s		.stopkleinergleich

;//	ds_p->scale2 = R_ScaleFromGlobalAngle (viewangle + xtoviewangle[stop])/* * (REALSCREENHEIGHT / 200)*/;
	move.l	d2,d3
	add.l		(a1,d1.w*4),d3

   
	;*** R_SCALEFROMGLOBALANGLE ***
	
	move.l	d3,d5
	sub.l		_rw_normalangle,d5
	move.l	#$40000000,d6
	add.l		d6,d5
	sub.l		_viewangle(pc),d3
	add.l		d6,d3
	lea		_finesine,a0
	moveq		#19,d6
	lsr.l		d6,d3
	move.l	(a0,d3.l*4),d3
	lsr.l		d6,d5
	move.l	(a0,d5.l*4),d5
	
	IFND	version060

	muls.l	_projection(pc),d6:d5
	move		d6,d5
	swap		d5
	
	ELSE

	fmove.l	_projection(pc),fp0
	fmul.l	d5,fp0
	fmul.x	fp7,fp0
	fmove.l	fp0,d5
	
	ENDC
	
	move.l 	_detailshift(pc),d6
	asl.l		d6,d5
		
	IFND	version060
	
	muls.l	_rw_distance,d6:d3
	move		d6,d3
	swap		d3
	
	ELSE

	fmove.l	_rw_distance,fp0
	fmul.l	d3,fp0
	fmul.x	fp7,fp0
	fmove.l	fp0,d3
	
	ENDC

	move.l	d5,d6
	swap		d6
	ext.l		d6
	cmp.l		d6,d3
	bgt.s		.111
		
	moveq		#64,d3
	swap		d3
	bra.s		.999
		
.111:
	
	IFND	version060
	
	swap		d5
	move		d5,d6
	ext.l		d6
	clr.w		d5
	divs.l	d3,d6:d5

	ELSE

	fmove.l 	d5,fp0
	fdiv.l	d3,fp0
	fmul.x  	fp6,fp0
	fmove.l	fp0,d5

	ENDC

	move.l	#256,d6
	cmp.l		d6,d5
	bge.s		.222
	move.l	d6,d3
	bra.s		.999

.222:
	move.l	 d5,d3
	moveq		#64,d6
	swap		d6
	cmp.l		d6,d3
	ble.s		.999
	move.l	d6,d3
		
.999:

	*** END R_SCALEFROMGLOBALANGLE ***

	move.l	d3,ds_scale2(a2)

;//	ds_p->scalestep = rw_scalestep =  (ds_p->scale2 - rw_scale) / (stop-start);
	sub.l		d7,d3
	move.l	d1,d7
	sub.l		d0,d7
	divs.l	d7,d3
	move.l	d3,ds_scalestep(a2)
	move.l	d3,_rw_scalestep

	bra.s		.scalesOK
;//    }

.stopkleinergleich:
;//    else
;//    {
;//	ds_p->scale2 = ds_p->scale1;
	move.l	d3,ds_scale2(a2)
;//    }

.scalesOK:
;//    /* calculate texture boundaries*/
;//    /*  and decide if floor / ceiling marks are needed*/
;//    worldtop = frontsector->ceilingheight - viewz;
	move.l	_frontsector,a4				;'a4 = frontsector
	move.l	sc_ceilingheight(a4),d7
	move.l	_viewz(pc),d6
	sub.l		d6,d7
	move.l	d7,_worldtop
	
;//    worldbottom = frontsector->floorheight - viewz;
	move.l	sc_floorheight(a4),d7
	sub.l		d6,d7
	move.l	d7,_worldbottom
	
;//    midtexture = toptexture = bottomtexture = maskedtexture = 0;
	clr.l		_midtexture
	clr.l		_toptexture
	clr.l		_bottomtexture
	clr.l		_maskedtexture
	
;//    ds_p->maskedtexturecol = NULL;
	clr.l		ds_maskedtexturecol(a2)

;//    if (!backsector)
;//    {
	tst.l		_backsector
	bne.s		.isbacksector
	
;//		/* single sided line*/
;//		midtexture = texturetranslation[sidedef->midtexture];
	move.l	_sidedef,a0						;'a0 = sidedef
	move		sd_midtexture(a0),d2
	move.l	_texturetranslation(pc),a1
	move.l	(a1,d2.w*4),_midtexture
	
;//		/* a single sided line is terminal, so it must mark ends*/
;//		markfloor = markceiling = true;
	moveq		#1,d3
	move.l	d3,_markfloor
	move.l	d3,_markceiling

;//		if (linedef->flags & ML_DONTPEGBOTTOM)
;//		{
	move.l	_linedef,a1
	btst		#MLB_DONTPEGBOTTOM,ln_flags+1(a1)
	beq.s		.notdontpegbottom

;//		    vtop = frontsector->floorheight +
;//			textureheight[sidedef->midtexture];
	move.l	_textureheight(pc),a1
	move.l	(a1,d2.w*4),d3
	add.l		sc_floorheight(a4),d3
	
;//		    /* bottom of texture at bottom*/
;//		    rw_midtexturemid = vtop - viewz;	
	sub.l		_viewz(pc),d3

;//		}
	bra.s		.afterdontpegbottomtest


.notdontpegbottom:
;//		else
;//		{
;//		    /* top of texture at top*/
;//		    rw_midtexturemid = worldtop;
	move.l	_worldtop,d3
;//		}

.afterdontpegbottomtest:
;//		rw_midtexturemid += sidedef->rowoffset;
	add.l		sd_rowoffset(a0),d3
	move.l	d3,_rw_midtexturemid
	
;//		ds_p->silhouette = SIL_BOTH;
	moveq		#SIL_BOTH,d3
	move.l	d3,ds_silhouette(a2)

;//		ds_p->sprtopclip = screenheightarray;
	move.l	#_screenheightarray,ds_sprtopclip(a2)

;//		ds_p->sprbottomclip = negonearray;
	move.l	#_negonearray,ds_sprbottomclip(a2)

;//		ds_p->bsilheight = MAXINT;
;//		ds_p->tsilheight = MININT;
	move.l	#$7FFFFFFF,d3
	move.l	d3,ds_bsilheight(a2)
	addq.l	#1,d3
	move.l	d3,ds_tsilheight(a2)

;//	 }
	bra.s		.aftersectorcheck

.isbacksector:
;//    else
;//    {
;//		/* two sided line*/
;//		ds_p->sprtopclip = ds_p->sprbottomclip = NULL;
;//		ds_p->silhouette = 0;
	clr.l		ds_sprtopclip(a2)
	clr.l		ds_sprbottomclip(a2)
	clr.l		ds_silhouette(a2)

;//		if (frontsector->floorheight > backsector->floorheight)
;//		{
	move.l	_backsector,a5					;'a5 = backsector
	move.l	sc_floorheight(a4),d2
	
	cmp.l		sc_floorheight(a5),d2
	ble.s		.ischkleinergleich
	
;//		    ds_p->silhouette = SIL_BOTTOM;
	moveq		#SIL_BOTTOM,d3
	move.l	d3,ds_silhouette(a2)

;//		    ds_p->bsilheight = frontsector->floorheight;
	move.l	d2,ds_bsilheight(a2)
;//		}
	bra.s		.weita

.ischkleinergleich:
;//		else if (backsector->floorheight > viewz)
;//		{
	move.l	_viewz(pc),d2
	cmp.l		sc_floorheight(a5),d2
	bge.s		.weita

;//		    ds_p->silhouette = SIL_BOTTOM;
	moveq		#SIL_BOTTOM,d2
	move.l	d2,ds_silhouette(a2)

;//		    ds_p->bsilheight = MAXINT;
	move.l	#$7FFFFFFF,ds_bsilheight(a2)
;//		    /* ds_p->sprbottomclip = negonearray;*/
;//		}

.weita:
;//		if (frontsector->ceilingheight < backsector->ceilingheight)
;//		{
		move.l	sc_ceilingheight(a4),d2
		cmp.l		sc_ceilingheight(a5),d2
		bge.s		.ischgreater

;//		    ds_p->silhouette |= SIL_TOP;
		bset		#1,ds_silhouette+3(a2)

;//		    ds_p->tsilheight = frontsector->ceilingheight;
		move.l	d2,ds_tsilheight(a2)
;//		}
		bra.s		.weitaaa

.ischgreater:
;//		else if (backsector->ceilingheight < viewz)
;//		{
		move.l	_viewz(pc),d2
		cmp.l		sc_ceilingheight(a5),d2
		ble.s		.weitaaa

;//		    ds_p->silhouette |= SIL_TOP;
		bset		#1,ds_silhouette+3(a2)

;//		    ds_p->tsilheight = MININT;
		move.l	#$80000000,ds_tsilheight(a2)
		
;//		    /* ds_p->sprtopclip = screenheightarray;*/
;//		}

.weitaaa:
		movem.l	sc_floorheight(a4),d2/d3
		movem.l	sc_floorheight(a5),d6/d7

;//		if (backsector->ceilingheight <= frontsector->floorheight)
;//		{
		cmp.l		d2,d7
		bgt.s		.hoila

;//		    ds_p->sprbottomclip = negonearray;
		move.l	#_negonearray,ds_sprbottomclip(a2)

;//		    ds_p->bsilheight = MAXINT;
		move.l	#$7FFFFFFF,ds_bsilheight(a2)

;//		    ds_p->silhouette |= SIL_BOTTOM;
		bset		#0,ds_silhouette+3(a2)
;//		}

.hoila:		
;//		if (backsector->floorheight >= frontsector->ceilingheight)
;//		{
		cmp.l		d3,d6
		blt.s		.naa

;//		    ds_p->sprtopclip = screenheightarray;
		move.l	#_screenheightarray,ds_sprtopclip(a2)

;//		    ds_p->tsilheight = MININT;
		move.l	#$80000000,ds_tsilheight(a2)

;//		    ds_p->silhouette |= SIL_TOP;
		bset		#1,ds_silhouette+3(a2)
;//		}

.naa:		
;//		worldhigh = backsector->ceilingheight - viewz;
		move.l	_viewz(pc),d5
		move.l	d7,a0
		sub.l		d5,a0
		move.l	a0,_worldhigh			;'a0 = worldhigh

;//		worldlow = backsector->floorheight - viewz;
		move.l	d6,a1
		sub.l		d5,a1
		move.l	a1,_worldlow			;'a1 = worldlow
			
;//		/* hack to allow height changes in outdoor areas*/
;//		if (frontsector->ceilingpic == skyflatnum 
;//		    && backsector->ceilingpic == skyflatnum)
;//		{
		move.l	_skyflatnum(pc),d5
		cmp		sc_ceilingpic(a4),d5
		bne.s		.niet
		cmp		sc_ceilingpic(a5),d5
		bne.s		.niet

;//		    worldtop = worldhigh;
		move.l	a0,_worldtop
;//		}
		
.niet:
;//		if (worldlow != worldbottom 
;//		    || backsector->floorpic != frontsector->floorpic
;//		    || backsector->lightlevel != frontsector->lightlevel)
;//		{
		
		cmp.l		_worldbottom,a1
		bne.s		.markfloortrue
		move		sc_floorpic(a5),d5
		cmp		sc_floorpic(a4),d5
		bne.s		.markfloortrue
		move		sc_lightlevel(a5),d5
		cmp		sc_lightlevel(a4),d5
		beq.s		.markfloorfalse
		
.markfloortrue:
;//		    markfloor = true;
		move.b	#1,_markfloor+3
		bra.s		.continue
;//

.markfloorfalse:
;//		else
;//		{
;//		    /* same plane on both sides*/
;//		    markfloor = false;
		clr.b		_markfloor+3
;//		}
		
.continue:
;//		if (worldhigh != worldtop 
;//		    || backsector->ceilingpic != frontsector->ceilingpic
;//		    || backsector->lightlevel != frontsector->lightlevel)
;//		{
		cmp.l		_worldtop,a0
		bne.s		.markceilingtrue
		move		sc_ceilingpic(a5),d5
		cmp		sc_ceilingpic(a4),d5
		bne.s		.markceilingtrue
		move		sc_lightlevel(a5),d5
		cmp		sc_lightlevel(a4),d5
		beq.s		.markceilingfalse

.markceilingtrue:
;//		    markceiling = true;
		move.b	#1,_markceiling+3
		bra.s		.continue2
;//		}

.markceilingfalse:
;//		else
;//		{
;//		    /* same plane on both sides*/
;//		    markceiling = false;
		clr.b		_markceiling+3
;//		}

.continue2:
;//		if (backsector->ceilingheight <= frontsector->floorheight
;//		    || backsector->floorheight >= frontsector->ceilingheight)
		cmp.l		d2,d7
		ble.s		.markbothtrue
		cmp.l		d3,d6
		blt.s		.dontmarkboth

.markbothtrue:
;//		{
;//		    /* closed door*/
;//		    markceiling = markfloor = true;
		move.b	#1,_markceiling+3
		move.b	#1,_markfloor+3
;//		}

.dontmarkboth:
		move.l	_worldtop,a0
		move.l	_sidedef,a3			;'a3 = sidedef
		move.l	_linedef,a6			;'a6 = linedef
	
;//		if (worldhigh < worldtop)
;//		{
		cmp.l		_worldhigh,a0
		ble.s		.worldhighgreater

;//		    /* top texture*/
;//		    toptexture = texturetranslation[sidedef->toptexture];
		move		sd_toptexture(a3),d5
		move.l	_texturetranslation(pc),a1
		move.l	(a1,d5.w*4),_toptexture
		
;//		    if (linedef->flags & ML_DONTPEGTOP)
;//		    {
;//			/* top of texture at top*/
		btst		#MLB_DONTPEGTOP,ln_flags+1(a6)
		beq.s		.notpegtop
		
;//			rw_toptexturemid = worldtop;
		move.l	a0,_rw_toptexturemid
		
;//		    }
		bra.s		.worldhighgreater

.notpegtop:
;//		    else
;//		    {
;//			vtop =
;//			    backsector->ceilingheight
;//			    + textureheight[sidedef->toptexture];
		move		sd_toptexture(a3),d5
		move.l	_textureheight(pc),a1
		move.l	(a1,d5.w*4),d5
		add.l		d7,d5
			
;//			/* bottom of texture*/
;//			rw_toptexturemid = vtop - viewz;	
		sub.l		_viewz(pc),d5
		move.l	d5,_rw_toptexturemid
;//		    }
;//		}

.worldhighgreater:
		move.l	_worldlow,a0
;//		if (worldlow > worldbottom)
;//		{
		cmp.l		_worldbottom,a0
		ble.s		.worldlowkleinergleich

;//		    /* bottom texture*/
;//		    bottomtexture = texturetranslation[sidedef->bottomtexture];
		move		sd_bottomtexture(a3),d5
		move.l	_texturetranslation(pc),a1
		move.l	(a1,d5.w*4),_bottomtexture
	
;//		    if (linedef->flags & ML_DONTPEGBOTTOM )
;//		    {
		btst		#MLB_DONTPEGBOTTOM,ln_flags+1(a6)
		beq.s		.keindontpegbottom

;//			/* bottom of texture at bottom*/
;//			/* top of texture at top*/
;//			rw_bottomtexturemid = worldtop;
		move.l	_worldtop,_rw_bottomtexturemid

;//		    }
		bra.s		.worldlowkleinergleich

.keindontpegbottom:
;//		    else	/* top of texture at top*/
;//			rw_bottomtexturemid = worldlow;
		move.l	a0,_rw_bottomtexturemid
;//		}

.worldlowkleinergleich:
;//		rw_toptexturemid += sidedef->rowoffset;
;//		rw_bottomtexturemid += sidedef->rowoffset;
		move.l	sd_rowoffset(a3),d5
		add.l		d5,_rw_toptexturemid
		add.l		d5,_rw_bottomtexturemid
		
;//		/* allocate space for masked texture tables*/
;//		if (sidedef->midtexture)
;//		{
		tst		sd_midtexture(a3)
		beq.s		.aftersectorcheck

;//		    /* masked midtexture*/
;//		    maskedtexture = true;
		move.b	#1,_maskedtexture+3

;//		    ds_p->maskedtexturecol = maskedtexturecol = lastopening - rw_x;
		move.l	_lastopening(pc),d5
		move.l	_rw_x,d2
		sub.l		d2,d5
		sub.l		d2,d5
		move.l	d5,_maskedtexturecol
		move.l	d5,ds_maskedtexturecol(a2)

;//		    lastopening += rw_stopx - rw_x;
		move.l	_rw_stopx,d2
		add.l		d2,d5
		add.l		d2,d5
		move.l	d5,_lastopening

;//		}
;//    }

.aftersectorcheck:

;//    /* calculate rw_offset (only needed for textured lines)*/
;//    segtextured = midtexture | toptexture | bottomtexture | maskedtexture;
	move.l	_midtexture,d2
	or.l		_toptexture,d2
	or.l		_bottomtexture,d2
	or.l		_maskedtexture,d2
	move.l	d2,_segtextured
	
;//    if (segtextured)
;//    {
	beq.s		.notsegtextured

;//		offsetangle = rw_normalangle-rw_angle1;
	moveq		#1,d5
	move.l	_rw_normalangle,d2
	sub.l		_rw_angle1,d2
		
;//		if (offsetangle > ANG180)
;//		    offsetangle = -offsetangle;
	bpl.s		.oaOK
	
	moveq		#0,d5
	neg.l		d2
	
.oaOK:
;//		if (offsetangle > ANG90)
;//		    offsetangle = ANG90;
	move.l	#ANG90,d3
	cmp.l		d3,d2
	bls.s		.oaOK2
	
	move.l	d3,d2
	
.oaOK2:
;//		sineval = finesine[offsetangle >>ANGLETOFINESHIFT];
	moveq		#ANGLETOFINESHIFT,d3
	lea		_finesine,a0
	lsr.l		d3,d2
	move.l	(a0,d2.w*4),d2

;//		rw_offset = FixedMul (hyp, sineval);
	
	IFND	version060
	
	muls.l	d4,d4:d2
	move		d4,d2
	swap		d2
	
	ELSE
	
	fmove.l	d4,fp0
	fmul.l	d2,fp0
	fmul.x	fp7,fp0
	fmove.l	fp0,d2
	
	ENDC
	
;//		if (rw_normalangle-rw_angle1 < ANG180)
;//		    rw_offset = -rw_offset;
	tst		d5
	beq.s		.nene
	neg.l		d2
	
.nene:
;//		rw_offset += sidedef->textureoffset + curline->offset;

	move.l	_sidedef,a3
	add.l		sd_textureoffset(a3),d2
	move.l	_curline,a3						;'a3 = curline
	add.l		sg_offset(a3),d2
	move.l	d2,_rw_offset
	
;//		rw_centerangle = ANG90 + viewangle - rw_normalangle;
	move.l	_viewangle(pc),d2
	add.l		#ANG90,d2
	sub.l		_rw_normalangle,d2
	move.l	d2,_rw_centerangle
		
;//		/* calculate light table*/
;//		/*  use different light tables*/
;//		/*  for horizontal / vertical / diagonal*/
;//		/* OPTIMIZE: get rid of LIGHTSEGSHIFT globally*/

;//		if (!fixedcolormap)
;//		{
	tst.l		_fixedcolormap(pc)
	bne.s		.notsegtextured

;//		    lightnum = (frontsector->lightlevel >> LIGHTSEGSHIFT)+extralight;
	move		sc_lightlevel(a4),d2
	lsr		#LIGHTSEGSHIFT,d2
	add		_extralight+2(pc),d2
	
;//		    if (curline->v1->y == curline->v2->y)
;//			lightnum--;
	move.l	sg_v1(a3),a0
	move.l	4(a0),d3
	move.l	sg_v2(a3),a0
	cmp.l		4(a0),d3
	bne.s		.lightno

	subq		#1,d2
	bra.s		.lightcheck
	
;//		    else if (curline->v1->x == curline->v2->x)
;//			lightnum++;
.lightno:
	move.l	sg_v1(a3),a0
	move.l	(a0),d3
	move.l	sg_v2(a3),a0
	cmp.l		(a0),d3
	bne.s		.lightcheck
	
	addq		#1,d2

.lightcheck:
;//    if (lightnum < 0)		
;//	walllights = scalelight[0];
	tst		d2
	bpl.s		.lightistpos
	move.l	#_scalelight,_walllights
	bra.s		.walllightsok

.lightistpos
;//    else if (lightnum >= LIGHTLEVELS)
;//	walllights = scalelight[LIGHTLEVELS-1];
	cmp		#LIGHTLEVELS,d2
	blt.s		.lightinnerhalb
	move.l	#_scalelight+(MAXLIGHTSCALE*4*(LIGHTLEVELS-1)),_walllights
	bra.s		.walllightsok
	
.lightinnerhalb:
;//    else
;//	walllights = scalelight[lightnum];
	lea		_scalelight,a1
	lsl		#6,d2		; * 64
	add.w		d2,a1
	add		d2,d2		; * 128
	add.w		d2,a1
	move.l	a1,_walllights

.walllightsok:
;//
;//

.notsegtextured:

;//    /* if a floor / ceiling plane is on the wrong side*/
;//    /*  of the view plane, it is definitely invisible*/
;//    /*  and doesn't need to be marked.*/
    
;//    if (frontsector->floorheight >= viewz)
;//    {
		move.l	_viewz(pc),d2
		cmp.l		sc_floorheight(a4),d2
		bgt.s		.schade

;//	/* above view plane*/
;//	markfloor = false;
		clr.b		_markfloor+3

;//    }

.schade:    
;//    if (frontsector->ceilingheight <= viewz 
;//	&& frontsector->ceilingpic != skyflatnum)
;//    {
		cmp.l		sc_ceilingheight(a4),d2
		blt.s		.schade2
		
		move.l	_skyflatnum(pc),d3
		cmp		sc_ceilingpic(a4),d3
		beq.s		.schade2

;//	/* below view plane*/
;//	markceiling = false;
		clr.b		_markceiling+3
;//    }

.schade2:
;//    /* calculate incremental stepping values for texture edges*/
;//    worldtop >>= 4;
;//    worldbottom >>= 4;
		move.l	_worldtop,d2
		asr.l		#4,d2
		move.l	_worldbottom,d3
		asr.l		#4,d3
		move.l	d2,_worldtop
		move.l	d3,_worldbottom
		
		move.l	_centeryfrac(pc),d1
		asr.l		#4,d1						;'d1 = centeryfrac>>4
		
;//    topstep = -FixedMul (rw_scalestep, worldtop);

		IFND	version060
		
		move.l	d2,d4
		muls.l	_rw_scalestep,d5:d4
		move		d5,d4
		swap		d4
		
		ELSE
		
		fmove.l	_rw_scalestep,fp0
		fmul.l	d2,fp0
		fmul.x	fp7,fp0
		fmove.l	fp0,d4
		
		ENDC
		
		neg.l		d4
		move.l	d4,_topstep

;//    topfrac = (centeryfrac>>4) - FixedMul (worldtop, rw_scale);

		IFND version060
		
		move.l	d2,d4
		muls.l	_rw_scale,d5:d4
		move		d5,d4
		swap		d4
		
		ELSE
		
		fmove.l	_rw_scale,fp0
		fmul.l	d2,fp0
		fmul.x	fp7,fp0
		fmove.l	fp0,d4
		
		ENDC
		
		move.l	d1,d5
		sub.l		d4,d5
		move.l	d5,_topfrac

;//    bottomstep = -FixedMul (rw_scalestep,worldbottom);
		
		IFND	version060
		
		move.l	d3,d4
		muls.l	_rw_scalestep,d5:d4
		move		d5,d4
		swap		d4
		
		ELSE
		
		fmove.l	_rw_scalestep,fp0
		fmul.l	d3,fp0
		fmul.x	fp7,fp0
		fmove.l	fp0,d4
		
		ENDC

		neg.l		d4
		move.l	d4,_bottomstep
		
;//    bottomfrac = (centeryfrac>>4) - FixedMul (worldbottom, rw_scale);
		
		IFND	version060
		
		move.l	d3,d4
		muls.l	_rw_scale,d5:d4
		move		d5,d4
		swap		d4
		
		ELSE
		
		fmove.l	_rw_scale,fp0
		fmul.l	d3,fp0
		fmul.x	fp7,fp0
		fmove.l	fp0,d4
		
		ENDC
		
		move.l	d1,d5
		sub.l		d4,d5
		move.l	d5,_bottomfrac
		
;//    if (backsector)
;//    {	
		tst.l		_backsector
		beq.s		.ischnetbacksector

;//		worldhigh >>= 4;
;//		worldlow >>= 4;
		move.l	_worldhigh,d4
		asr.l		#4,d4
		move.l	_worldlow,d5
		asr.l		#4,d5
		move.l	d4,_worldhigh
		move.l	d5,_worldlow

;//		if (worldhigh < worldtop)
;//		{
		cmp.l		d2,d4
		bge.s		.nua
		
;//		    pixhigh = (centeryfrac>>4) - FixedMul (worldhigh, rw_scale);
		
		IFND	version060
		
		move.l	d4,d6
		muls.l	_rw_scale,d7:d6
		move		d7,d6
		swap		d6
		
		ELSE
		
		fmove.l	_rw_scale,fp0
		fmul.l	d4,fp0
		fmul.x	fp7,fp0
		fmove.l	fp0,d6
		
		ENDC
		
		move.l	d1,d7
		sub.l		d6,d7
		move.l	d7,_pixhigh

;//		    pixhighstep = -FixedMul (rw_scalestep,worldhigh);
		
		IFND	version060
		
		move.l	d4,d6
		muls.l	_rw_scalestep,d7:d6
		move		d7,d6
		swap		d6
		
		ELSE
		
		fmove.l	_rw_scalestep,fp0
		fmul.l	d4,fp0
		fmul.x	fp7,fp0
		fmove.l	fp0,d6
		
		ENDC
		
		neg.l		d6
		move.l	d6,_pixhighstep
;//		}

.nua:
;//		if (worldlow > worldbottom)
;//		{
		cmp.l		d3,d5
		ble.s		.nua2

;//		    pixlow = (centeryfrac>>4) - FixedMul (worldlow, rw_scale);
		
		IFND	version060
		
		move.l	d5,d6
		muls.l	_rw_scale,d7:d6
		move		d7,d6
		swap		d6
		
		ELSE
		
		fmove.l	_rw_scale,fp0
		fmul.l	d5,fp0
		fmul.x	fp7,fp0
		fmove.l	fp0,d6
		
		ENDC
		
		move.l	d1,d7
		sub.l		d6,d7
		move.l	d7,_pixlow
		
;//		    pixlowstep = -FixedMul (rw_scalestep,worldlow);
		
		IFND	version060
		
		move.l	d5,d6
		muls.l	_rw_scalestep,d7:d6
		move		d7,d6
		swap		d6
		
		ELSE
		
		fmove.l	_rw_scalestep,fp0
		fmul.l	d5,fp0
		fmul.x	fp7,fp0
		fmove.l	fp0,d6
		
		ENDC
		
		neg.l		d6
		move.l	d6,_pixlowstep
		
;//		}
;//    }

.nua2:
.ischnetbacksector:
	move.l	d0,d2						;'d2 = start

;//    /* render it*/
;//    if (markceiling)
;//	ceilingplane = R_CheckPlane (ceilingplane, rw_x, rw_stopx-1);
	tst.l		_markceiling
	beq.s		.keinechance
   
   move.l	_rw_stopx,d7
   subq.l	#1,d7
   move.l	d7,-(sp)
   move.l	_rw_x,-(sp)
   move.l	_ceilingplane,-(sp)
   bsr		_R_CheckPlane
	lea		12(sp),sp
	
	move.l	d0,_ceilingplane

.keinechance:
	
;//    if (markfloor)
;//	floorplane = R_CheckPlane (floorplane, rw_x, rw_stopx-1);
	tst.l		_markfloor
	beq.s		.keinechance2

	move.l	_rw_stopx,d7
	subq.l	#1,d7
	move.l	d7,-(sp)
	move.l	_rw_x,-(sp)
	move.l	_floorplane,-(sp)
	bsr		_R_CheckPlane
	lea		12(sp),sp
	
	move.l	d0,_floorplane

.keinechance2:
;//    R_RenderSegLoop ();
	bsr		_R_RenderSegLoop

;//    /* save sprite clipping info*/
;//    if ( ((ds_p->silhouette & SIL_TOP) || maskedtexture)
;//	 && !ds_p->sprtopclip)
;//    {
	btst		#1,ds_silhouette+3(a2)
	bne.s		.einsgut
	tst.l		_maskedtexture
	beq.s		.zumglueck

.einsgut:
	tst.l		ds_sprtopclip(a2)
	bne.s		.zumglueck
	
;//	memcpy (lastopening, ceilingclip+start, 2*(rw_stopx-start));
	move.l	_lastopening(pc),a1
	move.l	a1,a4
	move.l	a1,a5

	lea		_ceilingclip,a0
	lea		(a0,d2.w*2),a0
	move.l	_rw_stopx,d7
	add.l		d7,a5
	add.l		d7,a5

	sub.l		d2,d7
	ble.s		.nomemcpy
	subq.l	#1,d7
	
.memcpy:
	move		(a0)+,(a1)+
	dbf		d7,.memcpy

.nomemcpy:
;//	ds_p->sprtopclip = lastopening - start;
	sub.l		d2,a4
	sub.l		d2,a4
	move.l	a4,ds_sprtopclip(a2)

;//	lastopening += rw_stopx - start;
	sub.l		d2,a5
	sub.l		d2,a5
	move.l	a5,_lastopening
;//    }

.zumglueck:
;//    if ( ((ds_p->silhouette & SIL_BOTTOM) || maskedtexture)
;//	 && !ds_p->sprbottomclip)
;//    {
	btst		#0,ds_silhouette+3(a2)
	bne.s		.einsgut2
	tst.l		_maskedtexture
	beq.s		.zumglueck2

.einsgut2:
	tst.l		ds_sprbottomclip(a2)
	bne.s		.zumglueck2
	
;//	memcpy (lastopening, floorclip+start, 2*(rw_stopx-start));
	move.l	_lastopening(pc),a1
	move.l	a1,a4
	move.l	a1,a5
	
	lea		_floorclip,a0
	lea		(a0,d2.w*2),a0
	
	move.l	_rw_stopx,d7
	add.l		d7,a5
	add.l		d7,a5

	sub.l		d2,d7
	ble.s		.nomemcpy2
	subq.l	#1,d7
	
.memcpy2:
	move		(a0)+,(a1)+
	dbf		d7,.memcpy2

.nomemcpy2:

;//	ds_p->sprbottomclip = lastopening - start;
	sub.l		d2,a4
	sub.l		d2,a4
	move.l	a4,ds_sprbottomclip(a2)

;//	lastopening += rw_stopx - start;	
	sub.l		d2,a5
	sub.l		d2,a5
	move.l	a5,_lastopening

;//    }

.zumglueck2:

;//    if (maskedtexture && !(ds_p->silhouette&SIL_TOP))
;//    {
	tst.l		_maskedtexture
	beq.s		.puhh2
	btst		#1,ds_silhouette+3(a2)
	bne.s		.puhh
	
;//	ds_p->silhouette |= SIL_TOP;
	bset		#1,ds_silhouette+3(a2)

;//	ds_p->tsilheight = MININT;
	move.l	#$80000000,ds_tsilheight(a2)
	
;//    }

.puhh:
;//    if (maskedtexture && !(ds_p->silhouette&SIL_BOTTOM))
;//    {
	btst		#0,ds_silhouette+3(a2)
	bne.s		.puhh2

;//	ds_p->silhouette |= SIL_BOTTOM;
	bset		#0,ds_silhouette+3(a2)

;//	ds_p->bsilheight = MAXINT;
	move.l	#$7FFFFFFF,ds_bsilheight(a2)
;//    }

.puhh2:
;//    ds_p++;
	lea		ds_SIZEOF(a2),a2
	move.l	a2,_ds_p

.geschafft:
	movem.l	(sp)+,d2-d7/a2-a6
	rts



;	ENDC

;/***************************************************/
;/*                                                 */
;/*       R_THINGS                                  */
;/*                                                 */
;/***************************************************/

;	XREF	_R_ProjectSprite
	
	XREF	_translationtables
	XREF	_overflowsprite

;	XDEF	_R_DrawMaskedColumn
	CNOP	0,4
	
_R_DrawMaskedColumn:		;' (column_t *column) ' [d0]

	movem.l	d2-d7/a2-a6,-(sp)

;//    int		topscreen;
;//    int 	bottomscreen;
;//    fixed_t	basetexturemid;
	
;	move.l	11*4+4(sp),a2					;'a2 = column
	move.l	d0,a2

;//    basetexturemid = dc_texturemid;
	
	move.l	_dc_texturemid,d2				;'d2 = basetexturemid

;//    for ( ; column->topdelta != 0xff ; ) 
;//    {
	moveq		#0,d0
	move.b	cl_topdelta(a2),d0
	cmp.b		#$FF,d0
	beq.s		.fordone

	move.l	_dc_x(pc),d1

	move.l	_mfloorclip(pc),a0	
	move		(a0,d1.w*2),d6					;'d6 = mfloorclip[dc_x]-1
	ext.l		d6
	subq.l	#1,d6

	move.l	_mceilingclip(pc),a0
	move		(a0,d1.w*2),d7					;'d7 = mceilingclip[dc_x]+1
	ext.l		d7
	addq.l	#1,d7

	move.l	_spryscale(pc),d4					;'d4 = spryscale
	move.l	_colfunc(pc),a5						;'a5 = colfunc

.for:
	move.l	d0,d3								;'d3 = cl_topdelta
;//		/* calculate unclipped screen coordinates*/
;//		/*  for post*/

;//		topscreen = sprtopscreen + spryscale*column->topdelta;
	muls.l	d4,d0
	add.l		_sprtopscreen(pc),d0				;'d0 = topscreen

;//		bottomscreen = topscreen + spryscale*column->length;
	moveq		#0,d1
	move.b	cl_length(a2),d1
	move		d1,d5								;'d5 = cl_length.w

	muls.l	d4,d1
	add.l		d0,d1								;'d1 = bottomscreen
	
;//		dc_yl = (topscreen+FRACUNIT-1)>>FRACBITS;
	add.l		#FRACUNIT-1,d0
	swap		d0
	ext.l		d0

	
;//		dc_yh = (bottomscreen-1)>>FRACBITS;
	subq.l	#1,d1
	swap		d1
	ext.l		d1
			
;//		if (dc_yh >= mfloorclip[dc_x])
;//		    dc_yh = mfloorclip[dc_x]-1;
	cmp.l		d6,d1
	ble.s		.yhOK
	move.l	d6,d1
	
.yhOK:
;//		if (dc_yl <= mceilingclip[dc_x])
;//		    dc_yl = mceilingclip[dc_x]+1;
	cmp.l		d7,d0
	bge.s		.ylOK
	move.l	d7,d0
	
.ylOK:
;//		if (dc_yl <= dc_yh)
;//		{
	cmp.l		d1,d0
	bgt.s		.nothingtodo
	
	move.l	d0,_dc_yl
	move.l	d1,_dc_yh

;//		    dc_source = (byte *)column + 3;
	lea		3(a2),a0
	move.l	a0,_dc_source

;//		    dc_texturemid = basetexturemid - (column->topdelta<<FRACBITS);
	move.l	d2,a0
;	clr		d3
	swap		d3
	sub.l		d3,a0
	move.l	a0,_dc_texturemid
	
;//		    /* dc_source = (byte *)column + 3 - column->topdelta;*/
	
;//		    /* Drawn by either R_DrawColumn*/
;//		    /*  or (SHADOW) R_DrawFuzzColumn.*/

;//		    colfunc ();	
	jsr		(a5)
	
;//		}
.nothingtodo:
;//		column = (column_t *)(  (byte *)column + column->length + 4);
	add.w		d5,a2
	addq.l	#4,a2

;//    }
	moveq		#0,d0
	move.b	cl_topdelta(a2),d0
	cmp.b		#$FF,d0
	bne.s		.for

.fordone:
;//    dc_texturemid = basetexturemid;
	move.l	d2,_dc_texturemid

	movem.l	(sp)+,d2-d7/a2-a6
	rts

	XDEF	_R_DrawVisSprite
	CNOP	0,4
	
_R_DrawVisSprite:			;'( vissprite_t* vis,int x1, int	x2)
;//    column_t*		column;
;//    int			texturecolumn;
;//    fixed_t		frac;
;//    patch_t*		patch;
	
	movem.l	d2-d4/a2-a4,-(sp)
	
;//    patch = W_CacheLumpNum (vis->patch+firstspritelump, PU_CACHE);
;//
	move.l	6*4+4(sp),a2					;'a2 = vis
	move.l	vs_patch(a2),d0
	add.l		_firstspritelump(pc),d0
	
	move.l	_lumpcache,a0
	move.l	(a0,d0.w*4),a3			;'a3 = patch
	tst.l		a3
	bne.s		.iscached
	
	moveq		#PU_CACHE,d1
	movem.l	d0/d1,-(sp)
	jsr		_WW_CacheLumpNum
	addq.l	#8,sp

	move.l	d0,a3

.iscached:	
;//    dc_colormap = vis->colormap;
	move.l	vs_colormap(a2),_dc_colormap
 
;//    if (!dc_colormap)
;//    {
	bne.s		.else

;//		/* NULL colormap = shadow draw*/
;//		colfunc = fuzzcolfunc;
	move.l	_fuzzcolfunc(pc),_colfunc
;//    }
	bra.s		.weiter

.else:
;//    else if (vis->mobjflags & MF_TRANSLATION)
;//    {
	move.l	vs_mobjflags(a2),d0
	and.l		#MF_TRANSLATION,d0
	beq.s		.weiter
	
;//		colfunc = transcolfunc;
	move.l	_transcolfunc(pc),_colfunc
	
;//		dc_translation = translationtables - 256 +
;//		    ( (vis->mobjflags & MF_TRANSLATION) >> (MF_TRANSSHIFT-8) );

	moveq		#MF_TRANSSHIFT-8,d2
	lsr.l		d2,d0
	
	add.l		_translationtables,d0
	sub.l		#256,d0
	move.l	d0,_dc_translation
	
;//    }

.weiter:	
;//    dc_iscale = abs(vis->xiscale)>>detailshift;
	move.l	vs_xiscale(a2),d0
	bpl.s		.signOK
	neg.l		d0
	
.signOK:
	move.l	_detailshift(pc),d1
	asr.l		d1,d0
	move.l	d0,_dc_iscale

;//    dc_texturemid = vis->texturemid;
	move.l	vs_texturemid(a2),d0			;d0 = tc_texturemid
	move.l	d0,_dc_texturemid

;//    frac = vis->startfrac;
	move.l	vs_startfrac(a2),d2			;'d2 = frac

;//    spryscale = vis->scale;
	move.l	vs_scale(a2),d1				;d1 = spryscale
	move.l	d1,_spryscale

;//    sprtopscreen = centeryfrac - FixedMul(dc_texturemid,spryscale);
	
	IFND		version060
	
	muls.l	d1,d1:d0
	move		d1,d0
	swap		d0
	neg.l		d0
	add.l		_centeryfrac(pc),d0
	
	ELSE
	
	fmove.l	d0,fp0
	fmul.l	d1,fp0
	fmul.x	fp7,fp0
	fmove.l	fp0,d0
	neg.l		d0
	add.l		_centeryfrac(pc),d0
	
	ENDC
	
	move.l	d0,_sprtopscreen
	
;//    for (dc_x=vis->x1 ; dc_x<=vis->x2 ; dc_x++, frac += vis->xiscale)
;//    {
	lea		_dc_x(pc),a4
	movem.l	vs_x1(a2),d0/d3
	sub.l		d0,d3
	bmi.s		.nofor

	move.l	d0,(a4)
	move.l	vs_xiscale(a2),d4		;'d4 = fracstep

;//	subq.l	#4,sp
		
.for:
;//		texturecolumn = frac>>FRACBITS;
;//		column = (column_t *) ((byte *)patch +
;//				       LONG(patch->columnofs[texturecolumn]));

	move.l	d2,d0
	swap		d0
	move.l	pa_columnofs(a3,d0.w*4),d0
	ror.w		#8,d0
	swap		d0
	ror.w		#8,d0
	
	add.l		a3,d0

;//		R_DrawMaskedColumn (column);

;//	move.l	a0,(sp)
	bsr		_R_DrawMaskedColumn

	add.l		d4,d2
	addq.l	#1,(a4)
	dbf		d3,.for
	
;//	addq.l	#4,sp

.nofor:
;//    colfunc = basecolfunc;
	move.l	_basecolfunc(pc),_colfunc
	
	movem.l	(sp)+,d2-d4/a2-a4
	rts
	
R_ProjectSprite: macro	;' a2 = thing (mobj_t)
								;// alles trashen, ausser a2

;//    fixed_t		tr_x;
;//    fixed_t		tr_y;  
;//    fixed_t		gxt;
;//    fixed_t		gyt;    
;//    fixed_t		tx;
;//    fixed_t		tz;
;//    fixed_t		xscale; 
;//    int			x1;
;//    int			x2;
;//    spritedef_t*	sprdef;
;//    spriteframe_t*	sprframe;
;//    int			lump; 
;//    unsigned		rot;
;//    boolean		flip; 
;//    int			index;
;//    vissprite_t*	vis; 
;//    angle_t		ang;
;//    fixed_t		iscale;
    
;//    /* transform the origin point*/
;//    tr_x = thing->x - viewx;
;//    tr_y = thing->y - viewy;
	movem.l	mo_x(a2),d0/d1
	sub.l		_viewx(pc),d0
	sub.l		_viewy(pc),d1
	move.l	d0,d2					;'d2 = tr_x
	move.l	d1,d3					;'d3 = tr_y

	movem.l	_viewcos(pc),d5/d6		;'d5 = viewcos
												;'d6 = viewsin

;//    gxt = FixedMul(tr_x,viewcos);
	
	IFND	version060
	
	muls.l	d5,d4:d0
	move		d4,d0
	swap		d0
	
	ELSE
	
	fmove.l	d5,fp0
	fmul.l	d0,fp0
	fmul.x	fp7,fp0
	fmove.l	fp0,d0
	
	ENDC
	
;//    gyt = -FixedMul(tr_y,viewsin);
	
	IFND	version060
	
	muls.l	d6,d4:d1
	move		d4,d1
	swap		d1
   
   ELSE
   
   fmove.l	d6,fp0
   fmul.l	d1,fp0
   fmul.x	fp7,fp0
   fmove.l	fp0,d1
   
   ENDC

;	neg.l		d1				;// (-- = +)
	
;//    tz = (gxt-gyt);
	add.l		d1,d0									;'d0 = tz

;//    /* thing is behind view plane?*/
;//    if (tz < MINZ)
;//	return;
	cmp.l		#MINZ,d0
	blt.s		.geschafft

;//    xscale = FixedDiv(projection, tz);
	
	IFND	version060
	
	move.l	_projection(pc),d1
	swap		d1
	move		d1,d4
	ext.l		d4
	clr.w		d1
	divs.l	d0,d4:d1
	
	ELSE
	
	fmove.l	_projection(pc),fp0
	fdiv.l	d0,fp0
	fmul.x	fp6,fp0
	fmove.l	fp0,d1
	
	ENDC
													;'d1 = xscale
	
;//    gxt = -FixedMul(tr_x,viewsin);
	IFND	version060
	
	muls.l	d6,d6:d2
	move		d6,d2
	swap		d2
	
	ELSE
	
	fmove.l	d6,fp0
	fmul.l	d2,fp0
	fmul.x	fp7,fp0
	fmove.l	fp0,d2
	
	ENDC
	
	;neg.l	d2

;//    gyt = FixedMul(tr_y,viewcos);
	
	IFND	version060
	
	muls.l	d5,d5:d3
	move		d5,d3
	swap		d3
	
	ELSE
	
	fmove.l	d5,fp0
	fmul.l	d3,fp0
	fmul.x	fp7,fp0
	fmove.l	fp0,d3
	
	ENDC

;//    tx = -(gyt+gxt);
	sub.l		d3,d2									;'d2 = tx
	
;//    /* too far off the side?*/
;//    if (abs(tx)>(tz<<2))
;//	return;
	asl.l		#2,d0
	move.l	d2,d3
	bpl.s		.ischpos
	neg.l		d3
	
.ischpos:
	cmp.l		d0,d3
	bgt.s		.geschafft
	
;//    /* decide which patch to use for sprite relative to player*/
;//    sprdef = &sprites[thing->sprite];
	move.l	mo_sprite(a2),d0
	lsl.l		#3,d0
	move.l	_sprites(pc),a0
	add.l		d0,a0
	
;//  sprframe = &sprdef->spriteframes[ thing->frame & FF_FRAMEMASK];
	move.l	mo_frame(a2),d0
	and.l		#FF_FRAMEMASK,d0
	move.l	sp_spriteframes(a0),a3
	move.l	d0,d4		;/* x * 28 = x * 32 - (x*4) */
	lsl.l		#5,d0
	lsl.l		#2,d4
	sub.l		d4,d0
	add.l		d0,a3								;'a3 = sprframe

;//    if (sprframe->rotate)
;//    {
	tst.l		sf_rotate(a3)
	beq.s		.keinrotate

;//		/* choose a different rotation based on player view*/
;//		ang = R_PointToAngle (thing->x, thing->y);
	move.l	d1,d4
	movem.l	mo_x(a2),d0/d1
	bsr		_R_PointToAngle_ASM
	move.l	d4,d1
	
;//		rot = (ang-thing->angle+(unsigned)(ANG45/2)*9)>>29;
	sub.l		mo_angle(a2),d0
	add.l		#$90000000,d0
	rol.l		#3,d0
	and		#7,d0

;//		lump = sprframe->lump[rot];
	moveq		#0,d4
	move		sf_lump(a3,d0.w*2),d4			;'d4.w = lump
	
;//		flip = (boolean)sprframe->flip[rot];
	move.b	sf_flip(a3,d0.w),d7				;'d7 = flip

;//    }
	bra.s		.aha

.keinrotate:
;//    else
;//    {
;//		/* use single rotation for all views*/
;//		lump = sprframe->lump[0];
	moveq		#0,d4
	move		sf_lump(a3),d4						;'d4 = lump
	
;//		flip = (boolean)sprframe->flip[0];
	move.b	sf_flip(a3),d7						;'d7 = flip
;//    }

.aha: 
;//    /* calculate edges of the shape*/
;//    tx -= (spriteoffset[lump]);	
	move.l	_spriteoffset(pc),a1
	sub.l		(a1,d4.w*4),d2
	
;//    x1 = (centerxfrac + FixedMul (tx,xscale) ) >>FRACBITS;

	IFND	version060
	
	move.l	d1,d5
	move.l	d2,d3
	muls.l	d3,d3:d5
	move		d3,d5
	swap		d5
	
	ELSE
	
	fmove.l	d1,fp0
	fmul.l	d2,fp0
	fmul.x	fp7,fp0
	fmove.l	fp0,d5
	
	ENDC
	
	add.l		_centerxfrac(pc),d5
	swap		d5
	ext.l		d5										;'d5 = x1

;//    /* off the right side?*/
	move.l	_viewwidth(pc),a1					;'a1 = viewwidth
;//    if (x1 > viewwidth)
;//	return;
	cmp.l		a1,d5
	bgt.s		.geschafft
    
;//    tx +=  (spritewidth[lump]);
	move.l	_spritewidth(pc),a3
	add.l		(a3,d4.w*4),d2
	
;//    x2 = ((centerxfrac + FixedMul (tx,xscale) ) >>FRACBITS) - 1;

	IFND		version060
	
	move.l	d1,d6
	muls.l	d2,d2:d6
	move		d2,d6
	swap		d6
	
	ELSE
	
	fmove.l	d2,fp0
	fmul.l	d1,fp0
	fmul.x	fp7,fp0
	fmove.l	fp0,d6
	
	ENDC
	
	add.l		_centerxfrac(pc),d6
	swap		d6
	ext.l		d6
	subq.l	#1,d6								;'d6 = x2
	
;//    /* off the left side*/
;//    if (x2 < 0)
;//	return;
	bmi.s		.geschafft
    
;//    /* store information in a vissprite*/
;//    vis = R_NewVisSprite ();

;// ** NEWVISSPRITE **

;//    if (vissprite_p == &vissprites[MAXVISSPRITES])
;//	return &overflowsprite;
;//
;//    vissprite_p++;
;//    return vissprite_p-1;

	move.l	_vissprite_p(pc),a3
	cmp.l		_maxvissprite(pc),a3
	blo.s		.notvsoverflow
	
	lea		_overflowsprite,a3
	bra.s		.vsokay

.notvsoverflow:
	lea		vs_SIZEOF(a3),a4
	move.l	a4,_vissprite_p
	addq.l	#1,_visspritecount
	
;// ** END NEWVISSPRITE **

.vsokay:
;//    vis->mobjflags = thing->flags;
	move.l	mo_flags(a2),vs_mobjflags(a3)

;//    vis->scale = xscale<<detailshift;
	move.l	d1,d0
	move.l	_detailshift(pc),d2
	asl.l		d2,d0
	move.l	d0,vs_scale(a3)
	
;//    vis->gx = thing->x;
;//    vis->gy = thing->y;
;//    vis->gz = thing->z;
	movem.l	mo_x(a2),d0/d2/a4
	movem.l	d0/d2/a4,vs_gx(a3)
	
;//    vis->gzt = thing->z + spritetopoffset[lump];
	move.l	_spritetopoffset(pc),a5
	add.l		(a5,d4.w*4),a4
	move.l	a4,vs_gzt(a3)
	
;//    vis->texturemid = vis->gzt - viewz;
	sub.l		_viewz(pc),a4
	move.l	a4,vs_texturemid(a3)

;//    vis->x1 = x1 < 0 ? 0 : x1;
	move.l	d5,vs_x1(a3)
	bpl.s		.ischgut
	clr.l		vs_x1(a3)

.ischgut:
;//    vis->x2 = x2 >= viewwidth ? viewwidth-1 : x2;	
	cmp.l		a1,d6
	blt.s		.ischnett
	subq.l	#1,a1
	move.l	a1,vs_x2(a3)
	bra.s		.doiscale

.ischnett:
	move.l	d6,vs_x2(a3)

.doiscale:
;//    iscale = FixedDiv (FRACUNIT, xscale);
	
	
	IFND	version060
	
	moveq		#0,d2		;'low
	moveq		#1,d0		;'high
	divs.l	d1,d0:d2
	
	ELSE
	
	moveq		#1,d0
	swap		d0
	fmove.l	d0,fp0
	fdiv.l	d1,fp0
	fmul.x	fp6,fp0
	fmove.l	fp0,d2
	
	ENDC											;'d2 = iscale

;//    if (flip)
;//    {
	tst.b		d7
	beq.s		.kaaflip
	
;//	vis->startfrac = spritewidth[lump]-1;
	move.l	_spritewidth(pc),a0
	move.l	(a0,d4.w*4),d0
	subq.l	#1,d0
	move.l	d0,vs_startfrac(a3)
	
;//	vis->xiscale = -iscale;
	neg.l		d2
	move.l	d2,vs_xiscale(a3)
	
;// }
	bra.s		.flipfertig

.kaaflip:
;//    else
;//    {
;//	vis->startfrac = 0;
	clr.l		vs_startfrac(a3)
	
;//	vis->xiscale = iscale;
	move.l	d2,vs_xiscale(a3)
	
;//    }

.flipfertig:
;//    if (vis->x1 > x1)
;//	vis->startfrac += vis->xiscale*(vis->x1-x1);
	sub.l		vs_x1(a3),d5
	neg.l		d5
	ble.s		.buahh

	muls.l	vs_xiscale(a3),d5
	add.l		d5,vs_startfrac(a3)
	
.buahh:
;//    vis->patch = lump;
	move.l	d4,vs_patch(a3)
    
;//    /* get light level*/
;//    if (thing->flags & MF_SHADOW)
;//    {
	btst		#2,mo_flags+1(a2)
	beq.s		.kaashadow
	
;//	/* shadow draw*/
;//	vis->colormap = NULL;

	clr.l		vs_colormap(a3)
	bra.s		.colmapischgut

;//    }

.kaashadow:
;//    else if (fixedcolormap)
;//    {
	move.l	_fixedcolormap(pc),d0
	beq.s		.kaafixedcm

;//	/* fixed map*/
;//	vis->colormap = fixedcolormap;
	move.l	d0,vs_colormap(a3)
	bra.s		.colmapischgut

;//    }

.kaafixedcm:
;//    else if (thing->frame & FF_FULLBRIGHT)
;//    {
	tst		mo_frame+2(a2)
	bpl.s		.kaafullbright
	
;//	/* full bright*/
;//	vis->colormap = colormaps;
	move.l	_colormaps(pc),vs_colormap(a3)
	bra.s		.colmapischgut
;//    }

.kaafullbright:
;//    else
;//    {
;//	/* diminished light*/
;//	index = xscale>>(LIGHTSCALESHIFT-detailshift);

	moveq		#LIGHTSCALESHIFT,d0
	sub.l		_detailshift(pc),d0
	lsr.l		d0,d1
	
;//	if (index >= MAXLIGHTSCALE) 
;//	    index = MAXLIGHTSCALE-1;

	moveq		#MAXLIGHTSCALE-1,d0
	cmp.l		d0,d1
	ble.s		.lightischgut

	move		d0,d1

.lightischgut:
;//	vis->colormap = spritelights[index];
	move.l	_spritelights(pc),a0
	move.l	(a0,d1.w*4),vs_colormap(a3)
	
;//    }	

.colmapischgut:
.geschafft:
;//}

	ENDM



	XDEF	_R_AddSprites
	CNOP	0,4
	
_R_AddSprites:				;'a1 = sector_t *sec
;//    mobj_t*		thing;
;//    int			lightnum;

;//    /* BSP is traversed by subsector.*/
;//    /* A sector might have been split into several*/
;//  /*  subsectors during BSP building.*/
;//    /* Thus we check whether its already added.*/

;//    if (sec->validcount == validcount)
;//	return;		
	move.l	_validcount(pc),d0
	cmp.l		sc_validcount(a1),d0
	beq.s		.raus
	
;//    /* Well, now it will be done.*/
;//    sec->validcount = validcount;
	move.l	d0,sc_validcount(a1)
	
;//    lightnum = (sec->lightlevel >> LIGHTSEGSHIFT)+extralight;
	move		sc_lightlevel(a1),d0
	lsr		#LIGHTSEGSHIFT,d0
	add		_extralight+2(pc),d0

;//    if (lightnum < 0)		
;//	spritelights = scalelight[0];
	bge.s		.a
	move.l	#_scalelight,_spritelights
	bra.s		.lightok
	
;//    else if (lightnum >= LIGHTLEVELS)
;//	spritelights = scalelight[LIGHTLEVELS-1];
.a:
	cmp		#LIGHTLEVELS,d0
	blt.s		.b
	
	move.l	#_scalelight+(MAXLIGHTSCALE*4*(LIGHTLEVELS-1)),_spritelights
	bra.s		.lightok
	
.b:
;//    else
;//	spritelights = scalelight[lightnum];
	lea		_scalelight,a0
	lsl		#6,d0		; * 64
	add.w		d0,a0
	add		d0,d0		; * 128
	add.w		d0,a0
	move.l	a0,_spritelights

.lightok:
;//    /* Handle all things in sector.*/
;//    for (thing = sec->thinglist ; thing ; thing = thing->snext)
;//	R_ProjectSprite (thing);
	move.l	a2,-(sp)

	move.l	sc_thinglist(a1),a2
;	move.l	a2,-(sp)
	tst.l		a2
	beq.s		.fordone

	movem.l	d2-d7/a3-a6,-(sp)

.for:
;	jsr		_R_ProjectSprite

	R_ProjectSprite

	move.l	mo_snext(a2),a2
	tst.l		a2
;	move.l	a2,(sp)
	bne.s		.for

	movem.l	(sp)+,d2-d7/a3-a6
	
.fordone:
	move.l	(sp)+,a2

.raus:
	rts
	


	XDEF	_R_DrawSprite
	CNOP	0,4
	
_R_DrawSprite				;'(vissprite_t *spr)
;//    drawseg_t*		ds;
;//    short		clipbot[SCREENWIDTH];
;//    short		cliptop[SCREENWIDTH];
;//    int			x;
;//    int			r1;
;//    int			r2;
;//    fixed_t		scale;
;//    fixed_t		lowscale;
;//    int			silhouette;
	
	 movem.l	d2-d7/a2-a5,-(sp)
	 
;//    for (x = spr->x1 ; x<=spr->x2 ; x++)
;//	clipbot[x] = cliptop[x] = -2;
   
    move.l	10*4+4(sp),a2				;'a2 = spr

	 movem.l	vs_x1(a2),d2/d3			;'d2 = spr->x1
	 											;'d3 = spr->x2
	 move.l	d3,d1
	 sub.l	d2,d1
	 bmi.s	.fordone
	 
	 lea		clipbot,a0
	 lea		(a0,d2.w*2),a0
	 lea		cliptop,a1
	 lea		(a1,d2.w*2),a1

	 lsr		#1,d1
	 move		d1,d0
	 and		#7,d0
	 move		.jumptab(pc,d0.w*2),d0
	 lsr		#3,d1
	 move.l	#$FFFEFFFE,d4
	 jmp		.for(pc,d0.w)
	 
	 cnop		0,4
	 
.jumptab:
	 dc.w		.c0-.for
	 dc.w		.c1-.for
	 dc.w		.c2-.for
	 dc.w		.c3-.for
	 dc.w		.c4-.for
	 dc.w		.c5-.for
	 dc.w		.c6-.for
	 dc.w		.c7-.for

.for:
.c7:	move.l	d4,(a0)+
		move.l	d4,(a1)+
.c6:	move.l	d4,(a0)+
		move.l	d4,(a1)+
.c5:	move.l	d4,(a0)+
		move.l	d4,(a1)+
.c4:	move.l	d4,(a0)+
		move.l	d4,(a1)+
.c3:	move.l	d4,(a0)+
		move.l	d4,(a1)+
.c2:	move.l	d4,(a0)+
		move.l	d4,(a1)+
.c1:	move.l	d4,(a0)+
		move.l	d4,(a1)+
.c0:	move.l	d4,(a0)+
		move.l	d4,(a1)+
		dbf		d1,.for
	 
.fordone:
	 
;//    /* Scan drawsegs from end to start for obscuring segs.*/
;//    /* The first drawseg that has a greater scale*/
;//    /*  is the clip seg.*/

;//    for (ds=ds_p-1 ; ds >= drawsegs ; ds--)
;//    {
		move.l	_ds_p(pc),a3							;'a3 = ds
		cmp.l		_drawsegs(pc),a3
		bls.s		.segfordone

		lea		-ds_SIZEOF(a3),a3

.dsfor:
;//		/* determine if the drawseg obscures the sprite*/
;//		if (ds->x1 > spr->x2
;//		    || ds->x2 < spr->x1
;//		    || (!ds->silhouette
;//			&& !ds->maskedtexturecol) )
;//		{
;//		    /* does not cover sprite*/
;//		    continue;
	
		movem.l	ds_x1(a3),d0/d1	;// d0 = ds_x1
											;// d1 = ds_x2

		cmp.l		d3,d0
		bgt.s		.dsnext
		
		cmp.l		d2,d1
		blt.s		.dsnext
		
		tst.l		ds_silhouette(a3)
		bne.s		.mustdo
		
		tst.l		ds_maskedtexturecol(a3)
		beq.s		.dsnext

;//		}

.mustdo:			
;//		r1 = ds->x1 < spr->x1 ? spr->x1 : ds->x1;
		cmp.l		d2,d0
		bgt.s		.r1ok
		move.l	d2,d0
		
.r1ok:
;//		r2 = ds->x2 > spr->x2 ? spr->x2 : ds->x2;
		cmp.l		d3,d1
		blt.s		.r2ok
		move.l	d3,d1
		
.r2ok:
;//		if (ds->scale1 > ds->scale2)
;//		{
;//		    lowscale = ds->scale2;
;//		    scale = ds->scale1;
;//		}
;//		else
;//		{
;//		    lowscale = ds->scale1;
;//		    scale = ds->scale2;
;//		}
		movem.l	ds_scale1(a3),a0/a1
		cmp.l		a1,a0
		blt.s		.orderok
		exg.l		a1,a0
		
.orderok:
;//		if (scale < spr->scale
;//		    || ( lowscale < spr->scale
;//			 && !R_PointOnSegSide (spr->gx, spr->gy, ds->curline) ) )
;//		{
		cmp.l		vs_scale(a2),a1
		blt.s		.mustrender
		cmp.l		vs_scale(a2),a0
		bge.s		.norender
		
		movem.l	d0/d1,-(sp)

		movem.l	vs_gx(a2),d0/d1
		move.l	ds_curline(a3),a0
		bsr		.R_PointOnSegSide
		tst.l		d0

		movem.l	(sp)+,d0/d1
		bne.s		.norender
		
.mustrender:				
;//		    /* masked mid texture?*/
;//		    if (ds->maskedtexturecol)	
;//			R_RenderMaskedSegRange (ds, r1, r2);
		tst.l		ds_maskedtexturecol(a3)
		beq.s		.nextseg
		
		movem.l	d0/d1,-(sp)
		move.l	a3,-(sp)
		bsr		_R_RenderMaskedSegRange
		lea		12(sp),sp
		
;//		    /* seg is behind sprite*/
;//		    continue;
		bra.s		.nextseg
;//		}

.norender:
;//		/* clip this piece of the sprite*/
;//		silhouette = ds->silhouette;
		move.l	ds_silhouette(a3),d4		;'d4 = silhouette
				
;//		if (spr->gz >= ds->bsilheight)
;//		    silhouette &= ~SIL_BOTTOM;
		move.l	vs_gz(a2),a0
		cmp.l		ds_bsilheight(a3),a0
		blt.s		.silok1
		
		bclr		#0,d4
		
.silok1:
;//		if (spr->gzt <= ds->tsilheight)
;//		    silhouette &= ~SIL_TOP;
		move.l	vs_gzt(a2),a0
		cmp.l		ds_tsilheight(a3),a0
		bgt.s		.silok2
		
		bclr		#1,d4

.silok2:
		sub.l		d0,d1
		bmi.s		.clipdone
		
		lea		clipbot,a0
		add.l		d0,d0
		lea		cliptop,a1
		add.l		d0,a0
		add.l		d0,a1

;//		if (silhouette == 1)
;//		{
		subq		#1,d4
		bne.s		.nono
		
;//		    /* bottom sil*/
;//		    for (x=r1 ; x<=r2 ; x++)
;//			if (clipbot[x] == -2)
;//			    clipbot[x] = ds->sprbottomclip[x];
		
		move.l	ds_sprbottomclip(a3),a1
		add.l		d0,a1
		
.fori:
		cmp.w		#-2,(a0)+
		bne.s		.niet
		
		move.w	(a1),-2(a0)
.niet:
		addq.l	#2,a1
		dbf		d1,.fori
;//		}
		bra.s		.clipdone

.nono:
;//		else if (silhouette == 2)
;//		{
		subq		#1,d4
		bne.s		.nono2

		move.l	ds_sprtopclip(a3),a0
		add.l		d0,a0

;//		    /* top sil*/
;//		    for (x=r1 ; x<=r2 ; x++)
;//			if (cliptop[x] == -2)
;//			    cliptop[x] = ds->sprtopclip[x];

		
.fori2:
		cmp		#-2,(a1)+
		bne.s		.niet2
		
		move		(a0),-2(a1)
.niet2:
		addq.l	#2,a0
		dbf		d1,.fori2

;//		}
		bra.s		.clipdone
		
.nono2:
;//		else if (silhouette == 3)
;//		{
		subq		#1,d4
		bne.s		.clipdone
		
		move.l	ds_sprbottomclip(a3),a4
		add.l		d0,a4
		move.l	ds_sprtopclip(a3),a5
		add.l		d0,a5
		
;//		    /* both*/
;//		    for (x=r1 ; x<=r2 ; x++)
;//		    {

.fori3:
;//			if (clipbot[x] == -2)
;//			    clipbot[x] = ds->sprbottomclip[x];
		cmp		#-2,(a0)+
		bne.s		.niet3
		move		(a4),-2(a0)

.niet3:
;//			if (cliptop[x] == -2)
;//			    cliptop[x] = ds->sprtopclip[x];
		cmp		#-2,(a1)+
		bne.s		.niet4
		move		(a5),-2(a1)
		
.niet4:
		addq.l	#2,a4
		addq.l	#2,a5
		dbf		d1,.fori3

;//		    }
;//		}

.clipdone:
.dsnext:
.nextseg:
		lea		-ds_SIZEOF(a3),a3
		cmp.l		_drawsegs(pc),a3
		bhs.s		.dsfor

;//    }

.segfordone:

;//    /* all clipping has been performed, so draw the sprite*/

;//    /* check for unclipped columns*/
;//    for (x = spr->x1 ; x<=spr->x2 ; x++)
;//    {		
		lea		clipbot,a0
		move.l	a0,_mfloorclip

		lea		cliptop,a1
		move.l	a1,_mceilingclip

		move.l	d3,d1
		sub.l		d2,d1
		bmi.s		.clipcheckdone

		lea		(a0,d2.l*2),a0

		lea		(a1,d2.l*2),a1
		
		move.l	_viewheight(pc),d0
		moveq		#-1,d4

.checkclip:		
;//		if (clipbot[x] == -2)		
;//		    clipbot[x] = viewheight;
		cmp		#-2,(a0)+
		bne.s		.check1
		move		d0,-2(a0)

.check1:
;//		if (cliptop[x] == -2)
;//		    cliptop[x] = -1;

		cmp		#-2,(a1)+
		bne.s		.check2
		move		d4,-2(a1)
		
.check2:
		dbf		d1,.checkclip

;//    }

.clipcheckdone:
;//    mfloorclip = clipbot;
;		move.l	#clipbot,_mfloorclip

;//    mceilingclip = cliptop;
;		move.l	#cliptop,_mceilingclip
		
;//    R_DrawVisSprite (spr, spr->x1, spr->x2);
	
;		movem.l	d2/d3,-(sp)
		move.l	a2,-(sp)
		bsr		_R_DrawVisSprite
;		lea		12(sp),sp
		addq.l	#4,sp
		
		movem.l	(sp)+,d2-d7/a2-a5
		rts


.R_PointOnSegSide:	
;	/* d4=lx d5=ly */
	move.l	(a0),a1
	movem.l	(a1),d4-d5
	move.l	4(a0),a1
	movem.l	(a1),d6-d7

;	/* d6=ldx d7 = ldy */	
	sub.l		d4,d6
	sub.l		d5,d7

;	/* if (!ldx) */
	tst.l		d6
	bne.s		.ldxnotzero

;	/* if (x <= lx) */
	cmp.l		d4,d0
	bgt.s		.2

	tst.l		d7
	bgt.s		.3

.return0:
	moveq		#0,d0
	rts

.return1:
.3:
	moveq		#1,d0
	rts

.2:
	tst.l		d7
	blt.s		.return1
	moveq		#0,d0
	rts

.ldxnotzero:
	tst.l		d7
	bne.s		.ldynotzero
	
	cmp.l		d5,d1
	bgt.s		.6
	
	tst.l		d6
	blt.s		.return1
	moveq		#0,d0
	rts
	
.6:
	tst.l		d6
	bgt.s		.return1
	moveq		#0,d0
	rts
	
.ldynotzero:
	movem.l	d2/d3,-(sp)

	sub.l		d4,d0
	sub.l		d5,d1
	
	move.l	d0,d2
	eor.l		d1,d2
	eor.l		d6,d2
	eor.l		d7,d2

	movem.l	(sp)+,d2/d3
	bpl.s		.33
	
	eor.l		d7,d0
	bpl.s		.return0
	
	moveq		#1,d0
	rts

.33:
	swap		d7
	ext.l		d7

	IFND version060
	
	muls.l	d7,d7:d0
	move		d7,d0
	swap		d0

	ELSE

	fmove.l	d7,fp0
	fmul.l	d0,fp0
	fmul.x	fp7,fp0
	fmove.l	fp0,d0

	ENDC

	swap 		d6
	ext.l		d6

	IFND version060
	
	muls.l	d6,d6:d1
	move		d6,d1
	swap		d1

	ELSE

	fmove.l	d6,fp0
	fmul.l	d1,fp0
	fmul.x	fp7,fp0
	fmove.l	fp0,d1

	ENDC

	cmp.l		d0,d1
	blt.s		.return0

	moveq		#1,d0
	rts
	


	XDEF	_R_ClearSprites
	CNOP	0,4

_R_ClearSprites:
	move.l	_vissprites(pc),_vissprite_p
	clr.l		_visspritecount
	rts
	

	XDEF	_R_SortVisSprites
	XREF	_vsprsortedhead
	XREF	_vsprsortedtail

	CNOP	0,4
	
_R_SortVisSprites:
	move.l	_visspritecount(pc),d0
	beq.s		.exit
	subq		#1,d0							;' d0 = num vissprites

	movem.l	a2-a3,-(sp)

	lea		_vsprsortedhead,a0
	lea		_vsprsortedtail,a1
	move.l	a1,vs_next(a0)
	move.l	a0,vs_prev(a1)
	
	move.l	_vissprites,a2				;' a2 = sprite to sort

.sort:
	move.l	a1,a0
	move.l	vs_scale(a2),d1

.sort2:
	move.l	vs_prev(a0),a0
	cmp.l		vs_scale(a0),d1
	blt.s		.sort2
	
	move.l	vs_next(a0),a3
	move.l	a2,vs_next(a0)
	move.l	a0,vs_prev(a2)
	move.l	a3,vs_next(a2)
	move.l	a2,vs_prev(a3)
	
	lea		vs_SIZEOF(a2),a2
	dbf		d0,.sort

	movem.l	(sp)+,a2/a3

.exit:
	rts


;/***************************************************/
;/*                                                 */
;/*       R_DRAW                                    */
;/*                                                 */
;/***************************************************/


		
;/*= R_DrawColumn =================================================================*/

	XDEF _R_DrawColumn
	XDEF _R_DrawColumn_Check

	CNOP	0,4

_R_DrawColumn_Check:
_R_DrawColumn:
		movem.l d3-d4/d6-d7/a2/a3,-(sp)

		move.l  _dc_yh(pc),d7     ; count = _dc_yh - _dc_yl
		move.l  _dc_yl(pc),d0
		sub.l   d0,d7
		bmi.w   dc_end8

		move.l  _dc_x(pc),d1      ; dest = ylookup[_dc_yl] + columnofs[_dc_x]
		lea     _ylookup(pc),a0
		move.l  (a0,d0.l*4),a0
		lea     _columnofs(pc),a1
		add.l   (a1,d1.l*4),a0

		move.l  _dc_colormap(pc),d4
		move.l  _dc_source(pc),a1

		move.l  _dc_iscale(pc),d1 ; frac = _dc_texturemid + (_dc_yl-centery)*fracstep
		sub.l   _centery(pc),d0
		muls.l  d1,d0
		add.l   _dc_texturemid(pc),d0

		moveq   #$7f,d3

__RESPATCH6:
		lea     (SCREENWIDTH*4).w,a3

; d7: cnt >> 2
; a0: chunky
; a1: texture
; d0: frac  (uuuu uuuu uuuu uuuu 0000 0000 0UUU UUUU)
; d1: dfrac (.......................................)
; d3: $7f
; d4: light table aligned to 256 byte boundary
; a3: SCREENWIDTH

		move.l  d7,d6
		and.w   #3,d6

		swap    d0              ; swap decimals and fraction
		swap    d1

		add.w   dc_width_tab8(pc,d6.w*2),a0
		lsr.w   #2,d7
		move.w  dc_tmap_tab8(pc,d6.w*2),d6

		and.w   d3,d0
		sub.w   d1,d0
		add.l   d1,d0           ; setup the X flag

		jmp	dc_loop8(pc,d6.w)

		cnop    0,4

__RESPATCH7:
dc_width_tab8
		dc.w    -3*SCREENWIDTH
		dc.w    -2*SCREENWIDTH
		dc.w    -1*SCREENWIDTH
		dc.w    0
dc_tmap_tab8
		dc.w    dc_08-dc_loop8
		dc.w    dc_18-dc_loop8
		dc.w    dc_28-dc_loop8
		dc.w    dc_38-dc_loop8
dc_loop8
dc_38
		move.b  (a1,d0.w),d4
		addx.l  d1,d0
		move.l  d4,a2
		and.w   d3,d0
		move.b  (a2),(a0)
dc_28
		move.b  (a1,d0.w),d4
		addx.l  d1,d0
		move.l  d4,a2
		and.w   d3,d0
		
__RESPATCH8:
		move.b  (a2),SCREENWIDTH(a0)
dc_18
		move.b  (a1,d0.w),d4
		addx.l  d1,d0
		move.l  d4,a2
		and.w   d3,d0
		
__RESPATCH9:
		move.b  (a2),SCREENWIDTH*2(a0)
dc_08
		move.b  (a1,d0.w),d4
		addx.l  d1,d0
		move.l  d4,a2
		and.w   d3,d0

__RESPATCH10:
		move.b  (a2),SCREENWIDTH*3(a0)

		add.l   a3,a0
.loop_end8
		dbf d7,dc_loop8
dc_end8
		movem.l (sp)+,d3-d4/d6-d7/a2/a3
		rts

;/*= R_DrawColumnLow ==============================================================*/

	XDEF _R_DrawColumnLow
	XDEF _R_DrawColumnLow_Check

	CNOP	0,4

_R_DrawColumnLow_Check:
_R_DrawColumnLow:
		movem.l d3-d4/d6-d7/a2/a3,-(sp)

		move.l  _dc_yh(pc),d7	; count = _dc_yh - _dc_yl
		move.l  _dc_yl(pc),d0
		sub.l   d0,d7
		bmi.w   dcl_end1

		move.l  _dc_x(pc),d1    ; dest = ylookup[_dc_yl] + columnofs[_dc_x]
		lea     _ylookup(pc),a0
		add.l	d1,d1		; dc_x <<= 1 
		move.l  (a0,d0.l*4),a0
		lea     _columnofs(pc),a1
		add.l   (a1,d1.l*4),a0

		move.l  _dc_colormap(pc),d4
		move.l  _dc_source(pc),a1

		move.l  _dc_iscale(pc),d1 ; frac = _dc_texturemid + (_dc_yl-centery)*fracstep
		sub.l   _centery(pc),d0
		muls.l  d1,d0
		add.l   _dc_texturemid(pc),d0

		moveq   #$7f,d3
		
__RESPATCH11:
		lea     (SCREENWIDTH*4).w,a3

; d7: cnt >> 2
; a0: chunky
; a1: texture
; d0: frac  (uuuu uuuu uuuu uuuu 0000 0000 0UUU UUUU)
; d1: dfrac (.......................................)
; d3: $7f
; d4: light table aligned to 256 byte boundary
; a3: SCREENWIDTH

		move.l  d7,d6
		and.w   #3,d6

		swap    d0              ; swap decimals and fraction
		swap    d1

		add.w   dcl_width_tab1(pc,d6.w*2),a0
		lsr.w   #2,d7
		move.w  dcl_tmap_tab1(pc,d6.w*2),d6

		and.w   d3,d0
		sub.w   d1,d0
		add.l   d1,d0           ; setup the X flag

		jmp 	dcl_loop1(pc,d6.w)

		cnop    0,4
__RESPATCH12:
dcl_width_tab1
		dc.w    -3*SCREENWIDTH
		dc.w    -2*SCREENWIDTH
		dc.w    -1*SCREENWIDTH
		dc.w    0
dcl_tmap_tab1
		dc.w    dcl_01-dcl_loop1
		dc.w    dcl_11-dcl_loop1
		dc.w    dcl_21-dcl_loop1
		dc.w    dcl_31-dcl_loop1
dcl_loop1
dcl_31
		move.b  (a1,d0.w),d4
		addx.l  d1,d0
		move.l  d4,a2
		move.w  (a2),d6
		and.w   d3,d0
		move.b	(a2),d6
		move.w	d6,(a0)
dcl_21
		move.b  (a1,d0.w),d4
		addx.l  d1,d0
		move.l  d4,a2
		move.w  (a2),d6
		and.w   d3,d0
		move.b	(a2),d6
		
__RESPATCH13:
		move.w	d6,SCREENWIDTH(a0)
dcl_11
		move.b  (a1,d0.w),d4
		addx.l  d1,d0
		move.l  d4,a2
		move.w  (a2),d6
		and.w   d3,d0
		move.b	(a2),d6

__RESPATCH14:
		move.w	d6,SCREENWIDTH*2(a0)
dcl_01
		move.b  (a1,d0.w),d4
		addx.l  d1,d0
		move.l  d4,a2
		move.w	(a2),d6
		and.w   d3,d0
		move.b  (a2),d6

__RESPATCH15:
		move.w	d6,SCREENWIDTH*3(a0)

		add.l   a3,a0
.loop_end1
		dbf 	d7,dcl_loop1
dcl_end1
		movem.l (sp)+,d3-d4/d6-d7/a2/a3
		rts

;/*= R_DrawTranslatedColumn =======================================================*/

	XDEF	_R_DrawTranslatedColumn
	XDEF	_R_DrawTranslatedColumn_Check

	CNOP	0,4

_R_DrawTranslatedColumn_Check
_R_DrawTranslatedColumn:
  		movem.l d2-d4/d6-d7/a2/a3,-(sp)

		move.l  _dc_yh(pc),d7	; count = _dc_yh - _dc_yl
		move.l  _dc_yl(pc),d0
		sub.l   d0,d7
		bmi.w   dtc_end6

		move.l  _dc_x(pc),d1	; dest = ylookup[_dc_yl] + columnofs[_dc_x]
		lea     _ylookup(pc),a0
		move.l  (a0,d0.l*4),a0
		lea     _columnofs(pc),a1
		add.l   (a1,d1.l*4),a0

		move.l	_dc_translation(pc),d2
		move.l  _dc_colormap(pc),d4
		move.l  _dc_source(pc),a1

		move.l  _dc_iscale(pc),d1 ; frac = _dc_texturemid + (_dc_yl-centery)*fracstep
		sub.l   _centery(pc),d0
		muls.l  d1,d0
		add.l   _dc_texturemid(pc),d0

		moveq   #$7f,d3
		
__RESPATCH16:
		lea     (SCREENWIDTH*4).w,a3

; d7: cnt >> 2
; a0: chunky
; a1: texture
; d0: frac  (uuuu uuuu uuuu uuuu 0000 0000 0UUU UUUU)
; d1: dfrac (.......................................)
; d3: $7f
; d4: light table aligned to 256 byte boundary
; d2: translation table aligned to 256 byte boundary
; a3: SCREENWIDTH

		move.l  d7,d6
		and.w   #3,d6

		swap    d0              ; swap decimals and fraction
		swap    d1

		add.w   dtc_width_tab6(pc,d6.w*2),a0
		lsr.w   #2,d7
		move.w  dtc_tmap_tab6(pc,d6.w*2),d6

		and.w   d3,d0
		sub.w   d1,d0
		add.l   d1,d0           ; setup the X flag

		jmp 	dtc_loop6(pc,d6.w)

		cnop    0,4
		
__RESPATCH17:
dtc_width_tab6
		dc.w    -3*SCREENWIDTH
		dc.w    -2*SCREENWIDTH
		dc.w    -1*SCREENWIDTH
		dc.w    0
dtc_tmap_tab6
		dc.w    dtc_06-dtc_loop6
		dc.w    dtc_16-dtc_loop6
		dc.w    dtc_26-dtc_loop6
		dc.w    dtc_36-dtc_loop6
dtc_loop6
dtc_36
		move.b  (a1,d0.w),d2
		move.l	d2,a2
		addx.l  d1,d0
		move.b	(a2),d4
		and.w   d3,d0
		move.l  d4,a2
		move.b  (a2),(a0)
dtc_26
		move.b  (a1,d0.w),d2
		move.l	d2,a2
		addx.l  d1,d0
		move.b	(a2),d4
		and.w   d3,d0
		move.l  d4,a2
		
__RESPATCH18:
		move.b  (a2),SCREENWIDTH(a0)
dtc_16
		move.b  (a1,d0.w),d2
		move.l	d2,a2
		addx.l  d1,d0
		move.b	(a2),d4
		and.w   d3,d0
		move.l  d4,a2
		
__RESPATCH19:
		move.b  (a2),SCREENWIDTH*2(a0)
dtc_06
		move.b  (a1,d0.w),d2
		move.l	d2,a2
		addx.l  d1,d0
		move.b	(a2),d4
		and.w   d3,d0
		move.l  d4,a2

__RESPATCH20:
		move.b  (a2),SCREENWIDTH*3(a0)

		add.l   a3,a0
.loop_end6
		dbf 	d7,dtc_loop6
dtc_end6
		movem.l (sp)+,d2-d4/d6-d7/a2/a3
		rts

;/*= R_DrawTranslatedColumnLow ====================================================*/

	XDEF	_R_DrawTranslatedColumnLow
	XDEF	_R_DrawTranslatedColumnLow_Check

	CNOP	0,4

_R_DrawTranslatedColumnLow_Check:
_R_DrawTranslatedColumnLow:
		movem.l d2-d4/d6-d7/a2/a3,-(sp)

		move.l  _dc_yh(pc),d7	; count = _dc_yh - _dc_yl
		move.l  _dc_yl(pc),d0
		sub.l   d0,d7
		bmi.w   dtcl_end3

		move.l  _dc_x(pc),d1	; dest = ylookup[_dc_yl] + columnofs[_dc_x]
		lea     _ylookup(pc),a0
		add.l	d1,d1
		move.l  (a0,d0.l*4),a0
		lea     _columnofs(pc),a1
		add.l   (a1,d1.l*4),a0

		move.l	_dc_translation(pc),d2
		move.l  _dc_colormap(pc),d4
		move.l  _dc_source(pc),a1

		move.l  _dc_iscale(pc),d1 ; frac = _dc_texturemid + (_dc_yl-centery)*fracstep
		sub.l   _centery(pc),d0
		muls.l  d1,d0
		add.l   _dc_texturemid(pc),d0

		moveq   #$7f,d3
		
__RESPATCH21:
		lea     (SCREENWIDTH*4).w,a3

; d7: cnt >> 2
; a0: chunky
; a1: texture
; d0: frac  (uuuu uuuu uuuu uuuu 0000 0000 0UUU UUUU)
; d1: dfrac (.......................................)
; d3: $7f
; d4: light table aligned to 256 byte boundary
; d2: translation table aligned to 256 byte boundary
; a3: SCREENWIDTH

		move.l  d7,d6
		and.w   #3,d6

		swap    d0              ; swap decimals and fraction
		swap    d1

		add.w   dtcl_width_tab3(pc,d6.w*2),a0
		lsr.w   #2,d7
		move.w  dtcl_tmap_tab3(pc,d6.w*2),d6

		and.w   d3,d0
		sub.w   d1,d0
		add.l   d1,d0           ; setup the X flag

		jmp 	dtcl_loop3(pc,d6.w)

		cnop    0,4

__RESPATCH22:
dtcl_width_tab3
		dc.w    -3*SCREENWIDTH
		dc.w    -2*SCREENWIDTH
		dc.w    -1*SCREENWIDTH
		dc.w    0
dtcl_tmap_tab3
		dc.w    dtcl_03-dtcl_loop3
		dc.w    dtcl_13-dtcl_loop3
		dc.w    dtcl_23-dtcl_loop3
		dc.w    dtcl_33-dtcl_loop3
dtcl_loop3
dtcl_33
		move.b  (a1,d0.w),d2
		move.l	d2,a2
		addx.l  d1,d0
		move.b	(a2),d4
		move.l  d4,a2
		and.w   d3,d0
		move.w	(a2),d6
		move.b  (a2),d6
		move.w	d6,(a0)
dtcl_23
		move.b  (a1,d0.w),d2
		move.l	d2,a2
		addx.l  d1,d0
		move.b	(a2),d4
		move.l  d4,a2
		and.w   d3,d0
		move.w	(a2),d6
		move.b  (a2),d6
		
__RESPATCH23:
		move.w	d6,SCREENWIDTH(a0)
dtcl_13
		move.b  (a1,d0.w),d2
		move.l	d2,a2
		addx.l  d1,d0
		move.b	(a2),d4
		move.l  d4,a2
		and.w   d3,d0
		move.w	(a2),d6
		move.b	(a2),d6
		
__RESPATCH24:
		move.w  d6,SCREENWIDTH*2(a0)
dtcl_03
		move.b  (a1,d0.w),d2
		move.l	d2,a2
		addx.l  d1,d0
		move.b	(a2),d4
		move.l  d4,a2
		and.w   d3,d0
		move.w	(a2),d6
		move.b	(a2),d6

__RESPATCH25:
		move.w  d6,SCREENWIDTH*3(a0)

		add.l   a3,a0
.loop_end3
		dbf 	d7,dtcl_loop3
dtcl_end3
		movem.l (sp)+,d2-d4/d6-d7/a2/a3
		rts



;/*= R_DrawFuzzColumn ============================================================*/

	XDEF	_R_DrawFuzzColumn
	XDEF	_R_DrawFuzzColumn_Check

	XREF	_fuzzoffset

	CNOP	0,4

_R_DrawFuzzColumn_Check:
_R_DrawFuzzColumn:
		movem.l d4/d6-d7/a2/a3,-(sp)

		move.l	_viewheight(pc),d1
		subq.l	#1,d1
		move.l  _dc_yh(pc),d7	; count = _dc_yh - _dc_yl
		cmp.l		d1,d7
		bne.b		.skip_yh5
		subq.l	#1,d1
		move.l	d1,d7

.skip_yh5
		move.l  _dc_yl(pc),d0
		bne.b		.skip_yl5
		moveq		#1,d0

.skip_yl5
		sub.l   d0,d7
		bmi.w   dfc_end5

		move.l  _dc_x(pc),d1	; dest = ylookup[_dc_yl] + columnofs[_dc_x]
		lea     _ylookup(pc),a0
		move.l  (a0,d0.l*4),a0
		lea     _columnofs(pc),a1
		add.l   (a1,d1.l*4),a0

		move.l  _colormaps(pc),d4
		add.l		#6*256,d4

		lea		_fuzzoffset,a1
		move.l	fuzzpos(pc),d0

.pos_loop5	sub.w	#200,d0
		bpl	.pos_loop5
		add.w	#200,d0
		add.l	d0,a1

__RESPATCH26:
		lea     (SCREENWIDTH*4).w,a3

; d7: cnt >> 2
; a0: chunky
; a1: fuzzoffset
; d0: frac  (uuuu uuuu uuuu uuuu 0000 0000 0UUU UUUU)
; d1: dfrac (.......................................)
; d3: $7f
; d4: light table aligned to 256 byte boundary
; a3: SCREENWIDTH

		move.l  d7,d6
		and.w   #3,d6

		add.w   dfc_width_tab5(pc,d6.w*2),a0
		lsr.w   #2,d7
		move.w  dfc_tmap_tab5(pc,d6.w*2),d6

		jmp 	dfc_loop5(pc,d6.w)

		cnop    0,4
		
__RESPATCH27:
dfc_width_tab5
		dc.w    -3*SCREENWIDTH
		dc.w    -2*SCREENWIDTH
		dc.w    -1*SCREENWIDTH
		dc.w    0
dfc_tmap_tab5
		dc.w    dfc_05-dfc_loop5
		dc.w    dfc_15-dfc_loop5
		dc.w    dfc_25-dfc_loop5
		dc.w    dfc_35-dfc_loop5
dfc_loop5
dfc_35		move.l	a0,a2			; This is essentially
		add.l	(a1)+,a2		; just moving memory around.
		move.b	(a2),d4
		move.l	d4,a2			; Not 060 optimized but
		move.b	(a2),(a0)		; if you have hordes of

__RESPATCH28:
dfc_25		lea	SCREENWIDTH(a0),a2	; invisible monsters which
		add.l	(a1)+,a2		; slow down the game too much,
		move.b	(a2),d4			; do tell me.
		move.l	d4,a2

__RESPATCH29:
		move.b	(a2),SCREENWIDTH(a0)

__RESPATCH30:
dfc_15		lea	2*SCREENWIDTH(a0),a2
		add.l	(a1)+,a2
		move.b	(a2),d4
		move.l	d4,a2
__RESPATCH32:
		move.b	(a2),2*SCREENWIDTH(a0)

__RESPATCH33:
dfc_05		lea	3*SCREENWIDTH(a0),a2
		add.l	(a1)+,a2
		move.b	(a2),d4
		move.l	d4,a2

__RESPATCH34:
		move.b	(a2),3*SCREENWIDTH(a0)

		add.l   a3,a0
.loop_end5
		dbf	d7,dfc_loop5
		sub.l	#_fuzzoffset,a1
		move.l	a1,fuzzpos
dfc_end5
		movem.l (sp)+,d4/d6-d7/a2/a3
		rts

;/*= R_DrawFuzzColumnLow =========================================================*/

	XDEF	_R_DrawFuzzColumnLow
	XDEF	_R_DrawFuzzColumnLow_Check

	CNOP	0,4

_R_DrawFuzzColumnLow_Check:
_R_DrawFuzzColumnLow:
		movem.l d4/d6-d7/a2/a3,-(sp)

		move.l	_viewheight(pc),d1
		subq.l	#1,d1
		move.l  _dc_yh(pc),d7	; count = _dc_yh - _dc_yl
		cmp.l		d1,d7
		bne.b		.skip_yh4
		subq.l	#1,d1
		move.l	d1,d7

.skip_yh4
		move.l  _dc_yl(pc),d0
		bne.b		.skip_yl4
		moveq		#1,d0

.skip_yl4
		sub.l   d0,d7
		bmi.w   dfcl_end4

		move.l  _dc_x(pc),d1	; dest = ylookup[_dc_yl] + columnofs[_dc_x]
		lea     _ylookup(pc),a0
		add.l	d1,d1
		move.l  (a0,d0.l*4),a0
		lea     _columnofs(pc),a1
		add.l   (a1,d1.l*4),a0

		move.l  _colormaps(pc),d4
		add.l	#6*256,d4

		lea	_fuzzoffset,a1
		move.l	fuzzpos(pc),d0	; bring it down 

.pos_loop4	sub.w	#200,d0
		bpl	.pos_loop4
		add.w	#200,d0
		add.l	d0,a1

__RESPATCH35:
		lea     (SCREENWIDTH*4).w,a3

; d7: cnt >> 2
; a0: chunky
; a1: fuzzoffset
; d0: frac  (uuuu uuuu uuuu uuuu 0000 0000 0UUU UUUU)
; d1: dfrac (.......................................)
; d3: $7f
; d4: light table aligned to 256 byte boundary
; a3: SCREENWIDTH

		move.l  d7,d6
		and.w   #3,d6

		add.w   dfcl_width_tab4(pc,d6.w*2),a0
		lsr.w   #2,d7
		move.w  dfcl_tmap_tab4(pc,d6.w*2),d6

		jmp 	dfcl_loop4(pc,d6.w)

		cnop    0,4
		
__RESPATCH36:
dfcl_width_tab4
		dc.w    -3*SCREENWIDTH
		dc.w    -2*SCREENWIDTH
		dc.w    -1*SCREENWIDTH
		dc.w    0
dfcl_tmap_tab4
		dc.w    dfcl_04-dfcl_loop4
		dc.w    dfcl_14-dfcl_loop4
		dc.w    dfcl_24-dfcl_loop4
		dc.w    dfcl_34-dfcl_loop4
dfcl_loop4
dfcl_34		move.l	a0,a2			; This is essentially
		add.l	(a1)+,a2		; just moving memory around.
		move.b	(a2),d4
		move.l	d4,a2			
		move.w	(a2),d6
		move.b	(a2),d6
		move.w	d6,(a0)		
		
__RESPATCH37:
dfcl_24		lea	SCREENWIDTH(a0),a2	
		add.l	(a1)+,a2		
		move.b	(a2),d4			
		move.l	d4,a2
		move.w	(a2),d6
		move.b	(a2),d6
		
__RESPATCH38:
		move.w	d6,SCREENWIDTH(a0)

__RESPATCH39:
dfcl_14		lea	2*SCREENWIDTH(a0),a2
		add.l	(a1)+,a2
		move.b	(a2),d4
		move.l	d4,a2
		move.w	(a2),d6
		move.b	(a2),d6

__RESPATCH40:
		move.w	d6,2*SCREENWIDTH(a0)
		
__RESPATCH41:
dfcl_04		lea	3*SCREENWIDTH(a0),a2
		add.l	(a1)+,a2
		move.b	(a2),d4
		move.l	d4,a2
		move.w	(a2),d6
		move.b	(a2),d6

__RESPATCH42:
		move.w	d6,3*SCREENWIDTH(a0)

		add.l   a3,a0
.loop_end4
		dbf	d7,dfcl_loop4
		sub.l	#_fuzzoffset,a1
		move.l	a1,fuzzpos
dfcl_end4
		movem.l (sp)+,d4/d6-d7/a2/a3
		rts


fuzzpos:		dc.l	0


;/*= R_DrawSpan ==================================================================*/

	XDEF	_R_DrawSpan
	XDEF	_R_DrawSpan_Check

	CNOP	0,4

_R_DrawSpan_Check:
		movem.l d2-d7/a2-a4,-(sp)
		move.l  _ds_y(pc),d0
		cmp.l	_REALSCREENHEIGHT(pc),d0
		bhs.s	DrawSpan_Exit

		move.l  _ds_x1(pc),d1	; dest = ylookup[_ds_y] + columnofs[_ds_x1]
		bmi.s	DrawSpan_Exit

		lea     _ylookup(pc),a0
		move.l  (a0,d0.l*4),a0
		lea     _columnofs(pc),a1
		add.l   (a1,d1.l*4),a0
		move.l  _ds_source(pc),a1
		move.l  _ds_colormap(pc),a2
		move.l  _ds_x2(pc),d7	; count = _ds_x2 - _ds_x1
		cmp.l	d1,d7
		blt.s	DrawSpan_Exit
		
__RESPATCH43:
		cmp.l	#SCREENWIDTH,d7
		bhs.s	DrawSpan_Exit

		bra.s	DrawSpan_Common
		
		CNOP	0,4

_R_DrawSpan:    
		movem.l d2-d7/a2-a4,-(sp)
		move.l  _ds_y(pc),d0
		move.l  _ds_x1(pc),d1	; dest = ylookup[_ds_y] + columnofs[_ds_x1]
		lea     _ylookup(pc),a0
		move.l  (a0,d0.l*4),a0
		lea     _columnofs(pc),a1
		add.l   (a1,d1.l*4),a0
		move.l  _ds_source(pc),a1
		move.l  _ds_colormap(pc),a2
		move.l  _ds_x2(pc),d7	; count = _ds_x2 - _ds_x1

DrawSpan_Common:
		sub.l   d1,d7
		addq.l  #1,d7
		move.l  _ds_xfrac(pc),d0
		move.l  _ds_yfrac(pc),d1
		move.l  _ds_xstep(pc),d2
		move.l  _ds_ystep(pc),d3
		move.l  a0,d4
		btst    #0,d4
		beq.b   .skipb0
		move.l  d0,d5           ; do the unaligned pixels
		move.l  d1,d6           ; so we can write to longword
		swap    d5              ; boundary in the main loop
		swap    d6
		and.w   #$3f,d5
		and.w   #$3f,d6
		lsl.w   #6,d6
		or.w    d5,d6
		move.b  (a1,d6.w),d5
		add.l   d2,d0
		move.b  (a2,d5.w),(a0)+
		add.l   d3,d1
		move.l  a0,d4
		subq.l  #1,d7
.skipb0		btst    #1,d4
		beq.b   .skips0
		moveq   #2,d4
		cmp.l   d4,d7
		bls.b   .skips0
		move.l  d0,d5           ; write two pixels
		move.l  d1,d6
		swap    d5
		swap    d6
		and.w   #$3f,d5
		and.w   #$3f,d6
		lsl.w   #6,d6
		or.w    d5,d6
		move.b  (a1,d6.w),d5
		move.w  (a2,d5.w),d4
		add.l   d2,d0
		add.l   d3,d1
		move.l  d0,d5
		move.l  d1,d6
		swap    d5
		swap    d6
		and.w   #$3f,d5
		and.w   #$3f,d6
		lsl.w   #6,d6
		or.w    d5,d6
		move.b  (a1,d6.w),d5
		move.b  (a2,d5.w),d4
		add.l   d2,d0
		move.w  d4,(a0)+
		add.l   d3,d1
		subq.l  #2,d7
.skips0		move.l  a2,d4
		add.l   #$1000,a1       ; catch 22
		move.l  a0,a3
		add.l   d7,a3
		move.l  d7,d5
		and.b   #~3,d5
		move.l  a0,a4
		add.l   d5,a4
		eor.w   d0,d1           ; swap fraction parts for addx
		eor.w   d2,d3
		eor.w   d1,d0
		eor.w   d3,d2
		eor.w   d0,d1
		eor.w   d2,d3
		swap    d0
		swap    d1
		swap    d2
		swap    d3
		lsl.w   #6,d1
		lsl.w   #6,d3
		move.w  #$ffc0,d6
		move.w  #$f03f,d7
		lsr.w   #2,d5
		beq.b   .skip_loop20
		sub.w   d2,d0
		add.l   d2,d0           ; setup the X flag
.loop20		or.w    d6,d0
		or.w    d7,d1
		and.w   d1,d0
		addx.l  d3,d1
		move.b  (a1,d0.w),d4
		addx.l  d2,d0
		move.l  d4,a2
		move.w  (a2),d5
		or.w    d6,d0
		or.w    d7,d1
		and.w   d1,d0
		addx.l  d3,d1
		move.b  (a1,d0.w),d4
		addx.l  d2,d0
		move.l  d4,a2
		move.b  (a2),d5
		swap    d5
		or.w    d6,d0
		or.w    d7,d1
		and.w   d1,d0
		addx.l  d3,d1
		move.b  (a1,d0.w),d4
		addx.l  d2,d0
		move.l  d4,a2
		move.w  (a2),d5
		or.w    d6,d0
		or.w    d7,d1
		and.w   d1,d0
		addx.l  d3,d1
		move.b  (a1,d0.w),d4
		addx.l  d2,d0
		move.l  d4,a2
		move.b  (a2),d5
		move.l  d5,(a0)+
		cmp.l   a0,a4
		bne.b   .loop20
.skip_loop20
		sub.w   d2,d0
		add.l   d2,d0

		bra.b   .loop_end20
.loop30		or.w    d6,d0
		or.w    d7,d1
		and.w   d1,d0
		addx.l  d3,d1
		move.b  (a1,d0.w),d4
		addx.l  d2,d0
		move.l  d4,a2
		move.b  (a2),(a0)+
.loop_end20
		cmp.l   a0,a3
		bne.b   .loop30

DrawSpan_Exit:
.end20		movem.l (sp)+,d2-d7/a2-a4
		rts


;/*= R_DrawSpanLow ===============================================================*/

	XDEF	_R_DrawSpanLow
	XDEF	_R_DrawSpanLow_Check

	CNOP	0,4

_R_DrawSpanLow_Check:
		movem.l d2-d7/a2-a4,-(sp)
		move.l  _ds_y(pc),d0
		cmp.l	_REALSCREENHEIGHT(pc),d0
		bhs.s	DrawSpanLow_Exit

		move.l  _ds_x1(pc),d1	; dest = ylookup[_ds_y] + columnofs[_ds_x1]
		bmi.s	DrawSpanLow_Exit

		lea     _ylookup(pc),a0
		add.l	d1,d1
		move.l  (a0,d0.l*4),a0
		lea     _columnofs(pc),a1
		add.l   (a1,d1.l*4),a0
		move.l  _ds_x2(pc),d7	; count = _ds_x2 - _ds_x1
		move.l  _ds_source(pc),a1
		add.l	d7,d7

__RESPATCH44:
		cmp.l	#SCREENWIDTH-1,d7
		bhs.s	DrawSpanLow_Exit
		cmp.l	d1,d7
		blt.s	DrawSpanLow_Exit
		
		bra.s	DrawSpanLow_Common
		
		CNOP	0,4

_R_DrawSpanLow:    
		movem.l d2-d7/a2-a4,-(sp)
		move.l  _ds_y(pc),d0
		move.l  _ds_x1(pc),d1	; dest = ylookup[_ds_y] + columnofs[_ds_x1]
		lea     _ylookup(pc),a0
		add.l	d1,d1
		move.l  (a0,d0.l*4),a0
		lea     _columnofs(pc),a1
		add.l   (a1,d1.l*4),a0
		move.l  _ds_x2(pc),d7	; count = _ds_x2 - _ds_x1
		move.l  _ds_source(pc),a1
		add.l	d7,d7

DrawSpanLow_Common:
		move.l  _ds_colormap(pc),a2
		sub.l   d1,d7
		addq.l	#2,d7
		move.l  _ds_xfrac(pc),d0
		move.l  _ds_yfrac(pc),d1
		move.l  _ds_xstep(pc),d2
		move.l  _ds_ystep(pc),d3
		move.l  a0,d4		; notice, that this address must already be aligned by word
		btst    #1,d4
		beq.b   .skips2
		move.l  d0,d5           ; do the unaligned pixels
		move.l  d1,d6           ; so we can write to longword
		swap    d5              ; boundary in the main loop
		swap    d6
		and.w   #$3f,d5
		and.w   #$3f,d6		; this is the worst possible
		lsl.w   #6,d6		; way but hey, this is not a loop
		or.w    d5,d6
		move.b  (a1,d6.w),d5
		add.l   d2,d0
		move.b  (a2,d5.w),(a0)+
		add.l   d3,d1
		move.b	(a2,d5.w),(a0)+	; I know this is crap but spare me the comments
		subq.l  #2,d7
.skips2		move.l  a2,d4
		lea     $1000(a1),a1	; catch 22
		move.l  a0,a3
		add.l   d7,a3
		move.l  d7,d5
		and.b   #~7,d5
		move.l  a0,a4
		add.l   d5,a4
		eor.w   d0,d1           ; swap fraction parts for addx
		eor.w   d2,d3
		eor.w   d1,d0
		eor.w   d3,d2
		eor.w   d0,d1
		eor.w   d2,d3
		swap    d0
		swap    d1
		swap    d2
		swap    d3
		lsl.w   #6,d1
		lsl.w   #6,d3
		move.w  #$ffc0,d6
		move.w  #$f03f,d7
		lsr.w   #3,d5
		beq.b   .skip_loop22
		sub.w   d2,d0
		add.l   d2,d0           ; setup the X flag
.loop22		or.w    d6,d0		; Not really and exercise in optimizing
		or.w    d7,d1		; but I guess it's faster than 1x1 for 030
		and.w   d1,d0		; where this low detail business is needed.
		addx.l  d3,d1
		move.b  (a1,d0.w),d4
		addx.l  d2,d0
		move.l  d4,a2
		move.w  (a2),d5
		or.w    d6,d0
		move.b	(a2),d5
		or.w    d7,d1
		and.w   d1,d0
		swap	d5
		addx.l  d3,d1
		move.b  (a1,d0.w),d4
		addx.l  d2,d0
		move.l  d4,a2
		move.w  (a2),d5
		or.w    d6,d0
		move.b	(a2),d5
		or.w    d7,d1
		and.w   d1,d0
		move.l	d5,(a0)+
		addx.l  d3,d1
		move.b  (a1,d0.w),d4
		addx.l  d2,d0
		move.l  d4,a2
		move.w  (a2),d5
		or.w    d6,d0
		move.b	(a2),d5
		or.w    d7,d1
		and.w   d1,d0
		swap	d5
		addx.l  d3,d1
		move.b  (a1,d0.w),d4
		addx.l  d2,d0
		move.l  d4,a2
		move.w  (a2),d5
		move.b	(a2),d5
		move.l  d5,(a0)+
		cmp.l   a0,a4
		bne.b   .loop22
.skip_loop22
		sub.w   d2,d0
		add.l   d2,d0

		bra.b   .loop_end22
.loop32  	or.w    d6,d0
		or.w    d7,d1
		and.w   d1,d0
		addx.l  d3,d1
		move.b  (a1,d0.w),d4
		addx.l  d2,d0
		move.l  d4,a2
		move.b  (a2),(a0)+
		move.b	(a2),(a0)+
.loop_end22
		cmp.l   a0,a3
		bne.b   .loop32

DrawSpanLow_Exit:
.end22		movem.l (sp)+,d2-d7/a2-a4
		rts


;/*= R_DrawCrossHair =============================================================*/

	XDEF	_R_DrawCrossHair
	CNOP	0,4
	
_R_DrawCrossHair:
	move.l	_crosshair(pc),d1
	bne.s		.weiter
	rts
	
.weiter:
	move.l	d2,-(sp)
	
	subq		#1,d1
	and		#3,d1

	move.l	_viewheight(pc),d0
	lsr.l		#1,d0
;	add.l		_viewwindowy(pc),d0

	lea		_ylookup(pc),a0
	move.l	(a0,d0.w*4),a1
	
	move.l	_scaledviewwidth(pc),d0
	lsr.l		#1,d0
	add.l		_viewwindowx(pc),d0
	
	add.w		d0,a1

	add.l		d1,d1
	add.l		_MEDRES,d1

	move.l	crosstab(pc,d1.w*4),a0
	move		#$6FFF,d1
	move.l	_crosshaircolor(pc),d2
	bra.s		.draw
	
	CNOP	0,4

.draw:
	
	REPT	4

	move		(a0)+,d0
	cmp		d1,d0
	beq.s		.done
	
	move.b	d2,(a1,d0.w)

	ENDR
	
	bra.s		.draw

.done:
	move.l	(sp)+,d2

	rts

	CNOP	0,4

crosstab:
	dc.l		ct_simple
	dc.l		ct_simplemed
	dc.l		ct_cool
	dc.l		ct_coolmed
	dc.l		ct_round
	dc.l		ct_roundmed
	dc.l		ct_super
	dc.l		ct_supermed

crosshairgrafik:
ct_simple:
	dc.b		-5,0
	dc.b		-4,0 
	dc.b		-3,0 
	dc.b		-2,0 
	dc.b		2,0 
	dc.b		3,0 
	dc.b		4,0 
	dc.b		5,0 
	dc.b		0,-5,0,-4,0,-3,0,-2
	dc.b		0,2,0,3,0,4,0,5
	dc.w		$6FFF
	
ct_simplemed:
	dc.b		-11,0 
	dc.b		-10,0
	dc.b		-9,0
	dc.b		-8,0
	dc.b		-7,0 
	dc.b		-6,0
	dc.b		-5,0
	dc.b		-4,0
	dc.b		4,0
	dc.b		5,0 
	dc.b		6,0 
	dc.b		7,0 
	dc.b		8,0 
	dc.b		9,0 
	dc.b		10,0 
	dc.b		11,0 
	dc.b		0,-5,0,-4,0,-3,0,-2
	dc.b		0,2,0,3,0,4,0,5
	dc.w		$6FFF
	
ct_cool:
	dc.b		-5,-5
	dc.b		-5,-4
	dc.b		-5,-3
	dc.b		-5,-2

	dc.b		-5,2
	dc.b		-5,3
	dc.b		-5,4
	dc.b		-5,5
	
	dc.b		-4,-5
	dc.b		-3,-5
	dc.b		-2,-5
	
	dc.b		-4,5
	dc.b		-3,5
	dc.b		-2,5

	dc.b		5,-5
	dc.b		5,-4
	dc.b		5,-3
	dc.b		5,-2

	dc.b		5,2
	dc.b		5,3
	dc.b		5,4
	dc.b		5,5
	
	dc.b		4,-5
	dc.b		3,-5
	dc.b		2,-5
	
	dc.b		4,5
	dc.b		3,5
	dc.b		2,5
	
	dc.b		0,0
	
	dc.w		$6FFF

ct_coolmed:
	dc.b		-11,-5
	dc.b		-11,-4
	dc.b		-11,-3
	dc.b		-11,-2

	dc.b		-11,2
	dc.b		-11,3
	dc.b		-11,4
	dc.b		-11,5
	
	dc.b		-10,-5
	dc.b		-9,-5
	dc.b		-8,-5
	dc.b		-7,-5
	dc.b		-6,-5
	dc.b		-5,-5
	dc.b		-4,-5

	dc.b		-10,5
	dc.b		-9,5
	dc.b		-8,5
	dc.b		-7,5
	dc.b		-6,5
	dc.b		-5,5
	dc.b		-4,5

	dc.b		11,-5
	dc.b		11,-4
	dc.b		11,-3
	dc.b		11,-2

	dc.b		11,2
	dc.b		11,3
	dc.b		11,4
	dc.b		11,5
	
	dc.b		10,-5
	dc.b		9,-5
	dc.b		8,-5
	dc.b		7,-5
	dc.b		6,-5
	dc.b		5,-5
	dc.b		4,-5

	dc.b		10,5
	dc.b		9,5
	dc.b		8,5
	dc.b		7,5
	dc.b		6,5
	dc.b		5,5
	dc.b		4,5

	dc.b		0,0
	
	dc.w		$6FFF

ct_round:
	dc.b		-4,-4
	dc.b		-5,-3
	dc.b		-5,-2

	dc.b		-5,2
	dc.b		-5,3
	dc.b		-4,4
	
	dc.b		-3,-5
	dc.b		-2,-5
	
	dc.b		-3,5
	dc.b		-2,5

	dc.b		4,-4
	dc.b		5,-3
	dc.b		5,-2

	dc.b		5,2
	dc.b		5,3
	dc.b		4,4
	
	dc.b		3,-5
	dc.b		2,-5
	
	dc.b		3,5
	dc.b		2,5
	
	dc.b		0,0
	
	dc.w		$6FFF

ct_roundmed:
	dc.b		-11,-3
	dc.b		-11,-2

	dc.b		-11,2
	dc.b		-11,3
	
	dc.b		-10,-4
	dc.b		-9,-4
	dc.b		-8,-5
	dc.b		-7,-5
	dc.b		-6,-5
	dc.b		-5,-5
	dc.b		-4,-5

	dc.b		-10,4
	dc.b		-9,4
	dc.b		-8,5
	dc.b		-7,5
	dc.b		-6,5
	dc.b		-5,5
	dc.b		-4,5

	dc.b		11,-3
	dc.b		11,-2

	dc.b		11,2
	dc.b		11,3
	
	dc.b		10,-4
	dc.b		9,-4
	dc.b		8,-5
	dc.b		7,-5
	dc.b		6,-5
	dc.b		5,-5
	dc.b		4,-5

	dc.b		10,4
	dc.b		9,4
	dc.b		8,5
	dc.b		7,5
	dc.b		6,5
	dc.b		5,5
	dc.b		4,5

	dc.b		0,0
	
	dc.w		$6FFF

ct_super:
	dc.b		-4,-5
	dc.b		-4,-4
	dc.b		-4,-3
	
	dc.b		-4,3
	dc.b		-4,4
	dc.b		-4,5
	
	dc.b		-3,-5
	dc.b		-3,-4
	
	dc.b		-3,4
	dc.b		-3,5
	
	dc.b		-2,-5
	dc.b		-2,-3
	dc.b		-2,-2
	
	dc.b		-2,2
	dc.b		-2,3
	dc.b		-2,5
	
	dc.b		-1,-3
	dc.b		-1,3
	
	dc.b		0,-3,0,0,0,3

	dc.b		4,-5
	dc.b		4,-4
	dc.b		4,-3
	
	dc.b		4,3
	dc.b		4,4
	dc.b		4,5
	
	dc.b		3,-5
	dc.b		3,-4
	
	dc.b		3,4
	dc.b		3,5
	
	dc.b		2,-5
	dc.b		2,-3
	dc.b		2,-2
	
	dc.b		2,2
	dc.b		2,3
	dc.b		2,5
	
	dc.b		1,-3
	dc.b		1,3
	
	dc.w		$6FFF
	
ct_supermed:
	dc.b		-8,-5
	dc.b		-8,-4
	dc.b		-8,-3
	dc.b		-8,3
	dc.b		-8,4
	dc.b		-8,5
	
	dc.b		-7,-5
	dc.b		-7,-4
	dc.b		-7,4
	dc.b		-7,5

	dc.b		-6,-5
	dc.b		-6,-4
	dc.b		-6,4
	dc.b		-6,5
	
	dc.b		-5,-5
	dc.b		-5,-3
	
	dc.b		-5,3
	dc.b		-5,5
	
	dc.b		-4,-5
	dc.b		-4,-3
	dc.b		-4,-2
	
	dc.b		-4,2
	dc.b		-4,3
	dc.b		-4,5
	
	dc.b		-3,-3
	dc.b		-3,3
	
	dc.b		-2,-3
	dc.b		-2,3
	
	dc.b		-1,-3
	dc.b		-1,3
	
	dc.b		0,-3,0,0,0,3

	dc.b		8,-5
	dc.b		8,-4
	dc.b		8,-3
	dc.b		8,3
	dc.b		8,4
	dc.b		8,5
	
	dc.b		7,-5
	dc.b		7,-4
	dc.b		7,4
	dc.b		7,5

	dc.b		6,-5
	dc.b		6,-4
	dc.b		6,4
	dc.b		6,5
	
	dc.b		5,-5
	dc.b		5,-3
	
	dc.b		5,3
	dc.b		5,5
	
	dc.b		4,-5
	dc.b		4,-3
	dc.b		4,-2
	
	dc.b		4,2
	dc.b		4,3
	dc.b		4,5
	
	dc.b		3,-3
	dc.b		3,3
	
	dc.b		2,-3
	dc.b		2,3
	
	dc.b		1,-3
	dc.b		1,3
	
	dc.w		$6FFF
	
	dc.w		$7FFF


;/*******************************************************/
;/*																	  */
;/*						68060 routinen							  */
;/*																	  */
;/*******************************************************/


;/*= R_DrawColumn_060 =============================================================*/

	XDEF	_R_DrawColumn_060
	XDEF	_R_DrawColumn_060_Check
	
	CNOP	0,4
	
_R_DrawColumn_060:
_R_DrawColumn_060_Check:
		movem.l d2-d3/d5-d7/a2/a3,-(sp)

		move.l  (_dc_yh,pc),d7     ; count = _dc_yh - _dc_yl
		move.l  (_dc_yl,pc),d0
		sub.l   d0,d7
		bmi.w   dc60_end7

		move.l  (_dc_x,pc),d1      ; dest = ylookup[_dc_yl] + columnofs[_dc_x]
		lea     (_ylookup,pc),a0
		move.l  (a0,d0.l*4),a0
		lea     (_columnofs,pc),a1
		add.l   (a1,d1.l*4),a0

		move.l  (_dc_colormap,pc),a2
		move.l  (_dc_source,pc),a1

		move.l  (_dc_iscale,pc),d1 ; frac = _dc_texturemid + (_dc_yl-centery)*fracstep
		sub.l   (_centery),d0
		muls.l  d1,d0
		add.l   (_dc_texturemid,pc),d0

		moveq   #$7f,d3
		
__RESPATCH45:
		move.w  #SCREENWIDTH,a3

		move.l  d7,d6           ; Do the leftover iterations in
		and.w   #3,d6           ; this loop.
		addq.w	#1,d6
.skip_loop7
		move.l  d0,d5
		swap    d5
		and.l   d3,d5
		move.b  (a1,d5.w),d5
		add.l   d1,d0
		move.b  (a2,d5.w),(a0)
		add.l   a3,a0
		subq.w  #1,d6
		bne.b   .skip_loop7
; d7: cnt >> 2
; a0: chunky
; a1: texture
; a2: light_table
; d0: frac  (uuuu uuuu uuuu uuuu 0000 0000 0UUU UUUU)
; d1: dfrac*2   (.......................................)
; d2: frac+dfrac(.......................................)
; d3: $7f
; a3: SCREENWIDTH
.skip7
		lsr.l   #2,d7
		subq.l	#1,d7
		bmi.b	dc60_end7

		add.l   a3,a3

		move.l  d0,d2
		add.l   a3,a3
		add.l   d1,d2
		add.l   d1,d1

		eor.w   d0,d2           ; swap the fraction part for addx
		eor.w   d2,d0           ; assuming 16.16 fixed point
		eor.w   d0,d2

		swap    d0              ; swap decimals and fraction
		swap    d1
		swap    d2

		moveq   #0,d5
		and.w   d3,d2
		and.w   d3,d0

		sub.w   d1,d0
		add.l   d1,d0           ; setup the X flag

		move.b  (a1,d2.w),d5
dc60_loop7
		; This should be reasonably scheduled for
		; m68060. It should perform well on other processors
		; too. That AGU stall still bothers me though.

		move.b  (a1,d0.w),d6        ; stall + pOEP but allows sOEP
		addx.l  d1,d2               ; pOEP only
		move.b  (a2,d5.l),d5        ; pOEP but allows sOEP
		and.w   d3,d2               ; sOEP
		move.b  (a2,d6.l),d6        ; pOEP but allows sOEP

__RESPATCH46:
		move.b  d5,SCREENWIDTH(a0)  ; sOEP
		addx.l  d1,d0               ; pOEP only
		move.b  (a1,d2.w),d5        ; pOEP but allows sOEP
		and.w   d3,d0               ; sOEP
		move.b  d6,(a0)             ; pOEP
						; = ~4 cycles/pixel
						; + cache misses

		; The vertical writes are the true timehog of the loop
		; because of the characteristics of the copyback cache
		; operation.
		
		; Better mark the chunky buffer as write through
		; with the MMU and have all the horizontal writes
		; be longs aligned to longword boundary.

		move.b  (a1,d0.w),d6
		addx.l  d1,d2
		move.b  (a2,d5.l),d5
		and.w   d3,d2
		move.b  (a2,d6.l),d6

__RESPATCH47:
		move.b  d5,SCREENWIDTH*3(a0)
		addx.l  d1,d0
		move.b  (a1,d2.w),d5
		and.w   d3,d0

__RESPATCH48:
		move.b  d6,SCREENWIDTH*2(a0)

		add.l   a3,a0
.loop_end7
		dbf     d7,dc60_loop7

		; it's faster to divide it to two lines on 060
		; and shouldn't be slower on 040.

;		move.b  (a1,d0.w),d6    ; new
;		move.b  (a2,d6.l),d6    ; new
;		move.b  d6,(a0)     ; new

dc60_end7
		movem.l (sp)+,d2-d3/d5-d7/a2/a3
		rts

;/*= R_DrawSpan_060 =============================================================*/

	XDEF	_R_DrawSpan_060
	XDEF	_R_DrawSpan_060_Check
	
	CNOP	0,4
	
_R_DrawSpan_060_Check:
		movem.l d2-d7/a2/a3,-(sp)
		move.l  _ds_y(pc),d0
		cmp.l		_REALSCREENHEIGHT(pc),d0
		bhs.s		DrawSpan_060_Exit

		move.l  _ds_x1(pc),d1	; dest = ylookup[_ds_y] + columnofs[_ds_x1]
		bmi.s		DrawSpan_060_Exit

		lea     _ylookup(pc),a0
		move.l  (a0,d0.l*4),a0
		lea     _columnofs(pc),a1
		add.l   (a1,d1.l*4),a0
		move.l  _ds_source(pc),a1
		move.l  _ds_colormap(pc),a2
		move.l  _ds_x2(pc),d7	; count = _ds_x2 - _ds_x1
		cmp.l		d1,d7
		blt.s		DrawSpan_060_Exit

__RESPATCH49:
		cmp.l		#SCREENWIDTH,d7
		bhs.s		DrawSpan_060_Exit

		bra.s		DrawSpan_060_Common
		
		CNOP	0,4

_R_DrawSpan_060:
		movem.l d2-d7/a2/a3,-(sp)
		move.l  (_ds_y,pc),d0
		move.l  (_ds_x1,pc),d1     ; dest = ylookup[_ds_y] + columnofs[_ds_x1]
		lea     (_ylookup,pc),a0
		move.l  (a0,d0.l*4),a0
		lea     (_columnofs,pc),a1
		add.l   (a1,d1.l*4),a0
		move.l  (_ds_source,pc),a1
		move.l  (_ds_colormap,pc),a2
		move.l  (_ds_x2),d7     ; count = _ds_x2 - _ds_x1

DrawSpan_060_Common:
		sub.l   d1,d7
		addq.l  #1,d7
		move.l  (_ds_xfrac,pc),d0
		move.l  (_ds_yfrac,pc),d1
		move.l  (_ds_xstep,pc),d2
		move.l  (_ds_ystep,pc),d3
		move.l  a0,d4
		btst    #0,d4
		beq.b     .skipb9
		move.l  d0,d5           ; do the unaligned pixels
		move.l  d1,d6           ; so we can write to longword
		swap    d5              ; boundary in the main loop
		swap    d6
		and.w   #$3f,d5
		and.w   #$3f,d6
		lsl.w   #6,d6
		or.w    d5,d6
		move.b  (a1,d6.w),d5
		add.l   d2,d0
		move.b  (a2,d5.w),(a0)+
		add.l   d3,d1
		move.l  a0,d4
		subq.l  #1,d7
.skipb9		btst    #1,d4
		beq.b     .skips9
		moveq   #2,d4
		cmp.l   d4,d7
		bls.b   .skips9
		move.l  d0,d5           ; write two pixels
		move.l  d1,d6
		swap    d5
		swap    d6
		and.w   #$3f,d5
		and.w   #$3f,d6
		lsl.w   #6,d6
		or.w    d5,d6
		move.b  (a1,d6.w),d5
		move.w  (a2,d5.w),d4
		add.l   d2,d0
		add.l   d3,d1
		move.l  d0,d5
		move.l  d1,d6
		swap    d5
		swap    d6
		and.w   #$3f,d5
		and.w   #$3f,d6
		lsl.w   #6,d6
		or.w    d5,d6
		move.b  (a1,d6.w),d5
		move.b  (a2,d5.w),d4
		add.l   d2,d0
		move.w  d4,(a0)+
		add.l   d3,d1
		subq.l  #2,d7
.skips9		move.l  d7,d6           ; setup registers
		and.w   #3,d6
		move.l  d6,a3
		eor.w   d0,d1           ; swap fraction parts for addx
		eor.w   d2,d3
		eor.w   d1,d0
		eor.w   d3,d2
		eor.w   d0,d1
		eor.w   d2,d3
		swap    d0
		swap    d1
		swap    d2
		swap    d3
		lsl.w   #6,d1
		lsl.w   #6,d3
		moveq   #0,d6
		moveq   #0,d5
		sub.l   #$f000,a1
		lsr.l   #2,d7
		beq.w   .skip_loop29
		subq.l  #1,d7
		sub.w   d3,d1
		add.l   d3,d1           ; setup the X flag
		or.w    #$ffc0,d0
		or.w    #$f03f,d1
		move.w  d0,d6
		and.w   d1,d6
		bra.b   .start_loop29
		cnop    0,4
.loop29		or.w    #$ffc0,d0       ; pOEP
		or.w    #$f03f,d1       ; sOEP
		move.b  (a2,d5.l),d4    ; pOEP but allows sOEP
		move.w  d0,d6           ; sOEP
		and.w   d1,d6           ; pOEP
		move.l  d4,(a0)+        ; sOEP
.start_loop29
		addx.l  d2,d0           ; pOEP only
		addx.l  d3,d1           ; pOEP only
		move.b  (a1,d6.l),d5    ; pOEP but allows sOEP
		or.w    #$ffc0,d0       ; sOEP
		or.w    #$f03f,d1       ; pOEP
		move.w  d0,d6           ; sOEP
		move.w  (a2,d5.l),d4    ; pOEP but allows sOEP
		and.w   d1,d6           ; sOEP
		addx.l  d2,d0           ; pOEP only
		addx.l  d3,d1           ; pOEP only
		move.b  (a1,d6.l),d5    ; pOEP but allows sOEP
		or.w    #$ffc0,d0       ; sOEP
		or.w    #$f03f,d1       ; pOEP
		move.w  d0,d6           ; sOEP
		move.b  (a2,d5.l),d4    ; pOEP but allows sOEP
		and.w   d1,d6           ; sOEP
		addx.l  d2,d0           ; pOEP only
		addx.l  d3,d1           ; pOEP only
		move.b  (a1,d6.l),d5    ; pOEP but allows sOEP
		or.w    #$ffc0,d0       ; sOEP
		or.w    #$f03f,d1       ; pOEP
		move.w  d0,d6           ; sOEP
		swap    d4              ; pOEP only
		move.w  (a2,d5.l),d4    ; pOEP but allows sOEP
		and.w   d1,d6           ; sOEP
		addx.l  d2,d0           ; pOEP only
		addx.l  d3,d1           ; pOEP only
		move.b  (a1,d6.l),d5    ; pOEP but allows sOEP
		dbf     d7,.loop29      ; pOEP only = 7.75 cycles/pixel
		move.b  (a2,d5.l),d4
		move.l  d4,(a0)+
.skip_loop29
		sub.w   d3,d1
		add.l   d3,d1
		move.l  a3,d7
		bra.b     .loop_end29
.loop39  	or.w    #$ffc0,d0
		or.w    #$f03f,d1
		move.w  d0,d6
		and.w   d1,d6
		addx.l  d2,d0
		addx.l  d3,d1
		move.b  (a1,d6.l),d5
		move.b  (a2,d5.l),(a0)+
.loop_end29
		dbf     d7,.loop39
DrawSpan_060_Exit:
.end29   	movem.l (sp)+,d2-d7/a2/a3
		rts



;/***************************************************/
;/*                                                 */
;/*       V_VIDEO                                   */
;/*                                                 */
;/***************************************************/

	XDEF	_V_CopyRect
	XREF	_screens

	CNOP	0,4
	
_V_CopyRect:				;//( int		srcx,
								;//  int		srcy,
								;//  int		srcscrn,
								;//  int		width,
								;//  int		height,
								;//  int		destx,
								;//  int		desty,
								;//  int		destscrn ) 
;//{ 
;//    byte*	src;
;//    byte*	dest; 
	 
	movem.l	d2-d4/a2-a6,-(sp)
	
;//    V_MarkRect (destx, desty, width, height); 
	 
	movem.l	8*4+4(sp),d0-d4/a2-a4
	 
;//    src = screens[srcscrn]+SCREENWIDTH*srcy+srcx;

	lea		_yoffsettable,a5
	move.l	(a5,d1.w*4),a0
	lea		_screens,a6
	add.l		(a6,d2.w*4),a0
	add.w		d0,a0						;'a0 = src
	     
;//    dest = screens[destscrn]+SCREENWIDTH*desty+destx; 
	
	move.l	(a5,a3.w*4),a1
	add.l		(a6,a4.w*4),a1
	add.w		a2,a1						;'a1 = dest
	
	subq		#1,d4

__RESPATCH50:
	move		#SCREENWIDTH,d0
	sub		d3,d0						;'d0 = modulo
	subq		#1,d3
		
.yloop:
	move		d3,d1
	
.xloop:
	move.b	(a0)+,(a1)+
	dbf		d1,.xloop

	add.w		d0,a0
	add.w		d0,a1
	dbf		d4,.yloop

 	movem.l	(sp)+,d2-d4/a2-a6
 	rts



	XDEF	_V_DrawPatch

	CNOP	0,4


_V_DrawPatch:				;//( int		x,
								;//  int		y,
								;//  int		scrn,
								;//  patch_t*	patch ) 


;//    int		count;
;//    int		col; 
;//    column_t*	column; 
;//    byte*	desttop;
;//    byte*	dest;
;//    byte*	source; 
;//    int		w; 
	 
	movem.l	d2-d3/a2-a5,-(sp)
	
	movem.l	6*4+4(sp),d0/d1/d2/a3

;//    y -= SHORT(patch->topoffset); 
;//    x -= SHORT(patch->leftoffset); 
	move.l	pa_leftoffset(a3),d3
	
	rol.w		#8,d3
	sub		d3,d1
	
	swap		d3
	rol.w		#8,d3
	sub		d3,d0

;//    if (!scrn)
;//	V_MarkRect (x, y, SHORT(patch->width), SHORT(patch->height)); 

;// /*    col = 0; */

;//   desttop = screens[scrn]+y*SCREENWIDTH+x; 

	lea		_yoffsettable,a5			;'a5 = yoffsettable
	move.l	(a5,d1.w*4),a4
	lea		_screens,a1
	add.l		(a1,d2.w*4),a4
	add.w		d0,a4							;'a4 = desttop		
	
__RESPATCH51:
	move.w	#SCREENWIDTH,d3			;/* screenwidth */
	moveq		#0,d2							;/* col = 0 */
	move		(a3),d1						;/* d1 = w = SHORT(patch->width) */
	ror.w		#8,d1
	subq		#1,d1
	bmi.s		.9
		
.1:
	move.l	a3,a2							;/* a2 = patch */
	move.l	8(a3,d2.w*4),d0			;/* patch-> columnofs[col] */
	ror.w		#8,d0							;/* LONG */
	swap		d0
	ror.w		#8,d0
	add.l		d0,a2							;/* column = a2 = patch + colum ... */

.2:
	cmp.b		#255,(a2)					;/* while column->topdelta != 0xff */
	beq.s		.5
		
	lea		3(a2),a0						;/* source = column + 3 */
	move.l	a4,a1							;/* a1 = dest = desttop + ... */
	moveq		#0,d0
	move.b	(a2),d0						;/* topdelta */
	add.l		(a5,d0.w*4),a1
	move.b	1(a2),d0						;/* count = column->length */
	subq		#1,d0
	bmi.s		.4

.3:
	move.b	(a0)+,(a1)
	add.w		d3,a1
	dbf		d0,.3

.4:		
	moveq		#0,d0							;/* column += column->length + 4 */
	move.b	1(a2),d0
	addq.l	#4,d0
	add.l		d0,a2
	bra.s		.2

.5:
	addq		#1,d2
	addq.l	#1,a4
	dbf		d1,.1

.9:
	movem.l	(sp)+,d2-d3/a2-a5
	rts

 
	XDEF	_V_DrawPatch2
	
	CNOP	0,4
	
_V_DrawPatch2:
	tst.l		_MEDRES(pc)
	beq.s		_V_DrawPatch
	

								;//( int		x,
								;//  int		y,
								;//  int		scrn,
								;//  patch_t*	patch ) 

;//    int		count;
;//    int		col; 
;//    column_t*	column; 
;//    byte*	desttop;
;//    byte*	dest;
;//    byte*	source; 
;//    int		w; 
	 
	movem.l	d2-d3/a2-a5,-(sp)
	
	movem.l	6*4+4(sp),d0/d1/d2/a3

;//    y -= SHORT(patch->topoffset); 
;//    x -= SHORT(patch->leftoffset); 
	move.l	pa_leftoffset(a3),d3
	
	rol.w		#8,d3
	sub		d3,d1
	
	swap		d3
	rol.w		#8,d3
	sub		d3,d0

;//    if (!scrn)
;//	V_MarkRect (x, y, SHORT(patch->width), SHORT(patch->height)); 

;// /*    col = 0; */

;//   desttop = screens[scrn]+y*2*SCREENWIDTH+x; 

	lea		_yoffsettable,a5			;'a5 = yoffsettable
	move.l	(a5,d1.w*8),a4
	lea		_screens,a1
	add.l		(a1,d2.w*4),a4
	add.w		d0,a4							;'a4 = desttop		
	
__RESPATCH52:
	move.w	#SCREENWIDTH,d3			;/* screenwidth */
	moveq		#0,d2							;/* col = 0 */
	move		(a3),d1						;/* d1 = w = SHORT(patch->width) */
	ror.w		#8,d1
	subq		#1,d1
	bmi.s		.9
		
.1:
	move.l	a3,a2							;/* a2 = patch */
	move.l	8(a3,d2.w*4),d0			;/* patch-> columnofs[col] */
	ror.w		#8,d0							;/* LONG */
	swap		d0
	ror.w		#8,d0
	add.l		d0,a2							;/* column = a2 = patch + colum ... */

.2:
	cmp.b		#255,(a2)					;/* while column->topdelta != 0xff */
	beq.s		.5
		
	lea		3(a2),a0						;/* source = column + 3 */
	move.l	a4,a1							;/* a1 = dest = desttop + ... */
	moveq		#0,d0
	move.b	(a2),d0						;/* topdelta */
	add.l		(a5,d0.w*8),a1
	move.b	1(a2),d0						;/* count = column->length */
	subq		#1,d0
	bmi.s		.4

.3:
	move.b	(a0),(a1)
	add.w		d3,a1
	move.b	(a0)+,(a1)
	add.w		d3,a1
	dbf		d0,.3

.4:		
	moveq		#0,d0							;/* column += column->length + 4 */
	move.b	1(a2),d0
	addq.l	#4,d0
	add.l		d0,a2
	bra.s		.2

.5:
	addq		#1,d2
	addq.l	#1,a4
	dbf		d1,.1

.9:
	movem.l	(sp)+,d2-d3/a2-a5
	rts


	XDEF	_V_DrawPatch3
	
	CNOP	0,4
	
_V_DrawPatch3:
	tst.l		_HIGHRES(pc)
	beq.s		_V_DrawPatch2
	

								;//( int		x,
								;//  int		y,
								;//  int		scrn,
								;//  patch_t*	patch ) 

;//    int		count;
;//    int		col; 
;//    column_t*	column; 
;//    byte*	desttop;
;//    byte*	dest;
;//    byte*	source; 
;//    int		w; 
	 
	movem.l	d2-d4/a2-a5,-(sp)
	
	movem.l	7*4+4(sp),d0/d1/d2/a3

;//    y -= SHORT(patch->topoffset); 
;//    x -= SHORT(patch->leftoffset); 
	move.l	pa_leftoffset(a3),d3
	
	rol.w		#8,d3
	sub		d3,d1
	
	swap		d3
	rol.w		#8,d3
	sub		d3,d0

;//    if (!scrn)
;//	V_MarkRect (x, y, SHORT(patch->width), SHORT(patch->height)); 

;// /*    col = 0; */

;//   desttop = screens[scrn]+y*2*SCREENWIDTH+x; 

	lea		_yoffsettable,a5			;'a5 = yoffsettable
	move.l	(a5,d1.w*8),a4
	lea		_screens,a1
	add.l		(a1,d2.w*4),a4
	lea		(a4,d0.w*2),a4				;'a4 = desttop		

__RESPATCH56:
	move.w	#SCREENWIDTH,d3			;/* screenwidth */
	moveq		#0,d2							;/* col = 0 */
	move		(a3),d1						;/* d1 = w = SHORT(patch->width) */
	ror.w		#8,d1
	subq		#1,d1
	bmi.s		.9
		
.1:
	move.l	a3,a2							;/* a2 = patch */
	move.l	8(a3,d2.w*4),d0			;/* patch-> columnofs[col] */
	ror.w		#8,d0							;/* LONG */
	swap		d0
	ror.w		#8,d0
	add.l		d0,a2							;/* column = a2 = patch + colum ... */

.2:
	cmp.b		#255,(a2)					;/* while column->topdelta != 0xff */
	beq.s		.5
		
	lea		3(a2),a0						;/* source = column + 3 */
	move.l	a4,a1							;/* a1 = dest = desttop + ... */
	
	moveq		#0,d0
	move.b	(a2),d0						;/* topdelta */
	add.l		(a5,d0.w*8),a1
	move.b	1(a2),d0						;/* count = column->length */
	subq		#1,d0
	bmi.s		.4

.3:
	move.w	(a0),d4
	move.b	(a0)+,d4
	move		d4,(a1)
	add.w		d3,a1
	move		d4,(a1)
	add.w		d3,a1
	dbf		d0,.3

.4:		
	moveq		#0,d0							;/* column += column->length + 4 */
	move.b	1(a2),d0
	addq.l	#4,d0
	add.l		d0,a2
	bra.s		.2

.5:
	addq		#1,d2
	addq.l	#2,a4
	dbf		d1,.1

.9:
	movem.l	(sp)+,d2-d4/a2-a5
	rts


 	XDEF	_V_DrawPatchFlipped
 	CNOP	0,4

_V_DrawPatchFlipped:		;//( int		x,
								;//  int		y,
								;//  int		scrn,
								;//  patch_t*	patch ) 

;//    int		count;
;//    int		col; 
;//    column_t*	column; 
;//    byte*	desttop;
;//    byte*	dest;
;//    byte*	source; 
;//    int		w; 
	 
	movem.l	d2-d3/a2-a5,-(sp)
	
	movem.l	6*4+4(sp),d0/d1/d2/a3

;//    y -= SHORT(patch->topoffset); 
;//    x -= SHORT(patch->leftoffset); 
	move.l	pa_leftoffset(a3),d3
	
	rol.w		#8,d3
	sub		d3,d1
	
	swap		d3
	rol.w		#8,d3
	sub		d3,d0

;//    if (!scrn)
;//	V_MarkRect (x, y, SHORT(patch->width), SHORT(patch->height)); 

;// /*    col = 0; */

;//   desttop = screens[scrn]+y*SCREENWIDTH+x; 

	lea		_yoffsettable,a5			;'a5 = yoffsettable
	move.l	(a5,d1.w*4),a4
	lea		_screens,a1
	add.l		(a1,d2.w*4),a4
	add.w		d0,a4							;'a4 = desttop		
	
__RESPATCH53:
	move.w	#SCREENWIDTH,d3			;/* screenwidth */
	moveq		#0,d2							;/* col = 0 */
	move		(a3),d1						;/* d1 = w = SHORT(patch->width) */
	ror.w		#8,d1
	subq		#1,d1
	bmi.s		.9
		
.1:
	move.l	a3,a2							;/* a2 = patch */
	move.l	8(a3,d1.w*4),d0			;/* patch-> columnofs[w-1-col] */
	ror.w		#8,d0							;/* LONG */
	swap		d0
	ror.w		#8,d0
	add.l		d0,a2							;/* column = a2 = patch + colum ... */

.2:
	cmp.b		#255,(a2)					;/* while column->topdelta != 0xff */
	beq.s		.5
		
	lea		3(a2),a0						;/* source = column + 3 */
	move.l	a4,a1							;/* a1 = dest = desttop + ... */
	moveq		#0,d0
	move.b	(a2),d0						;/* topdelta */
	add.l		(a5,d0.w*4),a1
	move.b	1(a2),d0						;/* count = column->length */
	subq		#1,d0
	bmi.s		.4

.3:
	move.b	(a0)+,(a1)
	add.w		d3,a1
	dbf		d0,.3

.4:		
	moveq		#0,d0							;/* column += column->length + 4 */
	move.b	1(a2),d0
	addq.l	#4,d0
	add.l		d0,a2
	bra.s		.2

.5:
	addq		#1,d2
	addq.l	#1,a4
	dbf		d1,.1

.9:
	movem.l	(sp)+,d2-d3/a2-a5
	rts


	XDEF	_V_DrawPatchFlipped2
	CNOP	0,4
	

_V_DrawPatchFlipped2:
	tst.l		_MEDRES(pc)
	beq.s		_V_DrawPatchFlipped

								;//( int		x,
								;//  int		y,
								;//  int		scrn,
								;//  patch_t*	patch ) 

;//    int		count;
;//    int		col; 
;//    column_t*	column; 
;//    byte*	desttop;
;//    byte*	dest;
;//    byte*	source; 
;//    int		w; 
	 
	movem.l	d2-d3/a2-a5,-(sp)
	
	movem.l	6*4+4(sp),d0/d1/d2/a3

;//    y -= SHORT(patch->topoffset); 
;//    x -= SHORT(patch->leftoffset); 
	move.l	pa_leftoffset(a3),d3
	
	rol.w		#8,d3
	sub		d3,d1
	
	swap		d3
	rol.w		#8,d3
	sub		d3,d0

;//    if (!scrn)
;//	V_MarkRect (x, y, SHORT(patch->width), SHORT(patch->height)); 

;// /*    col = 0; */

;//   desttop = screens[scrn]+y*2*SCREENWIDTH+x; 

	lea		_yoffsettable,a5			;'a5 = yoffsettable
	move.l	(a5,d1.w*8),a4
	lea		_screens,a1
	add.l		(a1,d2.w*4),a4
	add.w		d0,a4							;'a4 = desttop		
	
__RESPATCH54:
	move.w	#SCREENWIDTH,d3			;/* screenwidth */
	moveq		#0,d2							;/* col = 0 */
	move		(a3),d1						;/* d1 = w = SHORT(patch->width) */
	ror.w		#8,d1
	subq		#1,d1
	bmi.s		.9
		
.1:
	move.l	a3,a2							;/* a2 = patch */
	move.l	8(a3,d1.w*4),d0			;/* patch-> columnofs[w-1-col] */
	ror.w		#8,d0							;/* LONG */
	swap		d0
	ror.w		#8,d0
	add.l		d0,a2							;/* column = a2 = patch + colum ... */

.2:
	cmp.b		#255,(a2)					;/* while column->topdelta != 0xff */
	beq.s		.5
		
	lea		3(a2),a0						;/* source = column + 3 */
	move.l	a4,a1							;/* a1 = dest = desttop + ... */
	moveq		#0,d0
	move.b	(a2),d0						;/* topdelta */
	add.l		(a5,d0.w*8),a1
	move.b	1(a2),d0						;/* count = column->length */
	subq		#1,d0
	bmi.s		.4

.3:
	move.b	(a0),(a1)
	add.w		d3,a1
	move.b	(a0)+,(a1)
	add.w		d3,a1
	dbf		d0,.3

.4:		
	moveq		#0,d0							;/* column += column->length + 4 */
	move.b	1(a2),d0
	addq.l	#4,d0
	add.l		d0,a2
	bra.s		.2

.5:
	addq		#1,d2
	addq.l	#1,a4
	dbf		d1,.1

.9:
	movem.l	(sp)+,d2-d3/a2-a5
	rts


	XDEF	_V_DrawPatchFlipped3
	CNOP	0,4
	

_V_DrawPatchFlipped3:
	tst.l		_HIGHRES(pc)
	beq.s		_V_DrawPatchFlipped2

								;//( int		x,
								;//  int		y,
								;//  int		scrn,
								;//  patch_t*	patch ) 

;//    int		count;
;//    int		col; 
;//    column_t*	column; 
;//    byte*	desttop;
;//    byte*	dest;
;//    byte*	source; 
;//    int		w; 
	 
	movem.l	d2-d4/a2-a5,-(sp)
	
	movem.l	7*4+4(sp),d0/d1/d2/a3

;//    y -= SHORT(patch->topoffset); 
;//    x -= SHORT(patch->leftoffset); 
	move.l	pa_leftoffset(a3),d3
	
	rol.w		#8,d3
	sub		d3,d1
	
	swap		d3
	rol.w		#8,d3
	sub		d3,d0

;//    if (!scrn)
;//	V_MarkRect (x, y, SHORT(patch->width), SHORT(patch->height)); 

;// /*    col = 0; */

;//   desttop = screens[scrn]+y*2*SCREENWIDTH+x; 

	lea		_yoffsettable,a5			;'a5 = yoffsettable
	move.l	(a5,d1.w*8),a4
	lea		_screens,a1
	add.l		(a1,d2.w*4),a4
	lea		(a4,d0.w*2),a4				;'a4 = desttop		
	
__RESPATCH57:
	move.w	#SCREENWIDTH,d3			;/* screenwidth */
	moveq		#0,d2							;/* col = 0 */
	move		(a3),d1						;/* d1 = w = SHORT(patch->width) */
	ror.w		#8,d1
	subq		#1,d1
	bmi.s		.9
		
.1:
	move.l	a3,a2							;/* a2 = patch */
	move.l	8(a3,d1.w*4),d0			;/* patch-> columnofs[w-1-col] */
	ror.w		#8,d0							;/* LONG */
	swap		d0
	ror.w		#8,d0
	add.l		d0,a2							;/* column = a2 = patch + colum ... */

.2:
	cmp.b		#255,(a2)					;/* while column->topdelta != 0xff */
	beq.s		.5
		
	lea		3(a2),a0						;/* source = column + 3 */
	move.l	a4,a1							;/* a1 = dest = desttop + ... */
	moveq		#0,d0
	move.b	(a2),d0						;/* topdelta */
	add.l		(a5,d0.w*8),a1
	move.b	1(a2),d0						;/* count = column->length */
	subq		#1,d0
	bmi.s		.4

.3:
	move		(a0),d4
	move.b	(a0)+,d4
	move		d4,(a1)
	add.w		d3,a1
	move		d4,(a1)
	add.w		d3,a1
	dbf		d0,.3

.4:		
	moveq		#0,d0							;/* column += column->length + 4 */
	move.b	1(a2),d0
	addq.l	#4,d0
	add.l		d0,a2
	bra.s		.2

.5:
	addq		#1,d2
	addq.l	#2,a4
	dbf		d1,.1

.9:
	movem.l	(sp)+,d2-d4/a2-a5
	rts

 
	XDEF	_V_DrawBlock
	CNOP	0,4
	
_V_DrawBlock:				;//( int		x,
								;//  int		y,
								;//  int		scrn,
								;//  int		width,
								;//  int		height,
								;//  byte*		src ) 

;//    byte*	dest; 

	movem.l	d2-d4/a2,-(sp)
		 
;//    V_MarkRect (x, y, width, height); 
 
 	movem.l	4*4+4(sp),d0-d4/a0
 	
;//    dest = screens[scrn] + y*SCREENWIDTH+x; 
	lea		_yoffsettable,a1
	move.l	(a1,d1.w*4),a1
	lea		_screens,a2
	add.l		(a2,d2.w*4),a1
	add.w		d0,a1

	subq		#1,d4

__RESPATCH55:
	move		#SCREENWIDTH,d2
	sub		d3,d2						;'d2 = modulo
	subq		#1,d3
		
.1:
	move		d3,d0
.2:
	move.b	(a0)+,(a1)+
	dbf		d0,.2

	add.w		d2,a1
	dbf		d4,.1
		
	movem.l	(sp)+,d2-d4/a2
	rts

;/***************************************************/
;/*                                                 */
;/*       D_NET                                     */
;/*                                                 */
;/***************************************************/

	XREF	_I_NetCmd
	XREF	_HHGetPacket
	XREF	_HHSendPacket

	XREF	_netbuffer
	XREF	_doomcom
	XREF	_debugfile
	XREF	_reboundpacket
	XREF	_reboundstore
	XREF	_netgame
	XREF	_demoplayback
	
	XDEF	_NetbufferChecksum
	CNOP	0,4
	
_NetbufferChecksum:
	move.l	_PCCheckSum(pc),d0
	bne.s		.pccheck
	rts
	
.pccheck:
	movem.l	d2/d3,-(sp)
;//    c = 0x1234567;
	move.l	#$1234567,d0
	move.l	_netbuffer,a0

;//    c += SWAPLONG(*(unsigned *)&netbuffer->retransmitfrom);
	addq.l	#4,a0
	move.l	(a0)+,d1
	ror.w		#8,d1
	swap		d1
	ror.w		#8,d1
	add.l		d1,d0

;//    for (i = 0; i < netbuffer->numtics; i++) {
	moveq		#0,d2
	move.b	-1(a0),d2
	ble.s		.done
	subq		#1,d2
	moveq		#2,d3

.loop:
;//      t = &netbuffer->cmds[i];
;//      c += ((i << 1) + 2) * (((unsigned char)t->forwardmove) +
;//                             (((unsigned char)t->sidemove) << 8) +
;//                             (((unsigned short)t->angleturn) << 16));
	move.l	(a0)+,d1
	swap		d1
	ror.w		#8,d1
	muls.l	d3,d1
	add.l		d1,d0
	
	addq.l	#1,d3
;//      c += ((i << 1) + 3) * (((unsigned short)t->consistancy) +
;//                             (((unsigned char)t->chatchar) << 16) +
;//                             (((unsigned char)t->buttons) << 24));
	move.l	(a0)+,d1
	ror.w		#8,d1
	swap		d1
	
	muls.l	d3,d1
	add.l		d1,d0
	addq.l	#1,d3
	
	dbf		d2,.loop
;//    }

.done:
;//    return c & NCMD_CHECKSUM;
	and.l		#NCMD_CHECKSUM,d0
	
	movem.l	(sp)+,d2/d3
	rts

	XDEF	_HGetPacket
	CNOP	0,4

_HGetPacket:
	tst.l		_debugfile
	beq.s		.fast
	jmp		_HHGetPacket
	
.fast:
;//    if (reboundpacket)
;//    {
	tst.l		_reboundpacket
	beq.s		.notreboundpacket

;//		*netbuffer = reboundstore;
	movem.l	d2-d7/a2-a6,-(sp)

	move.l	_netbuffer,a1
	lea		dd_SIZEOF(a1),a1
	lea		_reboundstore+(dd_SIZEOF/2),a0

	movem.l	(a0),d0-d7/a2-a6			;'first 52 bytes
	movem.l	d0-d7/a2-a6,-(a1)

	lea		-(dd_SIZEOF/2)(a0),a0
	movem.l	(a0),d0-d7/a2-a6			;'second 52 bytes
	movem.l	d0-d7/a2-a6,-(a1)

	movem.l	(sp)+,d2-d7/a2-a6
	
;//		doomcom->remotenode = 0;
	move.l	_doomcom,a0
	clr		dc_remotenode(a0)
	
;//		reboundpacket = false;
	clr.l		_reboundpacket

;//		return true;
;//    }
	moveq		#1,d0
	rts

.notreboundpacket:
;//    if (!netgame) return false;
;//    if (demoplayback) return false;
	tst.l		_netgame
	bne.s		.next
	tst.l		_demoplayback
	beq.s		.next

.returnfalse:
	moveq		#0,d0
	rts

.next:
;//    doomcom->command = CMD_GET;
	move.l	_doomcom,a0
	move		#CMD_GET,dc_command(a0)
	
;//    I_NetCmd ();
	jsr		_I_NetCmd
    
;//    if (doomcom->remotenode == -1) return false;
	move.l	_doomcom,a0
	cmp		#-1,dc_remotenode(a0)
	beq.s		.returnfalse

;//    if (doomcom->datalength != NetbufferSize ())
;//    {
;//		if (debugfile)
;//		    fprintf (debugfile,"bad packet length %i\n",doomcom->datalength);
;//		return false;
;//    }

	move		dc_datalength(a0),d0
	moveq		#0,d1
	move.l	_netbuffer,a1
	move.b	dd_numtics(a1),d1
	lsl		#3,d1
	addq		#8,d1
	cmp		d1,d0
	bne.s		.returnfalse
	
;//    if (NetbufferChecksum () != (netbuffer->checksum&NCMD_CHECKSUM) )
;//    {
;//		if (debugfile)
;//		    fprintf (debugfile,"bad packet checksum\n");
;//		return false;
;//    }

	bsr		_NetbufferChecksum
	move.l	_netbuffer,a1
	move.l	dd_checksum(a1),d1
	and.l		#NCMD_CHECKSUM,d1
	cmp.l		d0,d1
	bne.s		.returnfalse
	
;//    return true;	
	moveq		#1,d0
	rts

	XDEF	_HSendPacket
	CNOP	0,4

_HSendPacket:		;(int node, int flags)
	tst.l		_debugfile
	beq.s		.fast
	jmp		_HHSendPacket

.fast:
;//    netbuffer->checksum = NetbufferChecksum () | flags;
	bsr		_NetbufferChecksum
	move.l	_netbuffer,a0
	or.l		8(sp),d0
	move.l	d0,dd_checksum(a0)

;//    if (!node)
;//    {
;//		reboundstore = *netbuffer;
;//		reboundpacket = true;
;//		return;
;//    }
	move.l	4(sp),d0						;'d0 = node
	bne.s		.notreboundpacket
	
	movem.l	d2-d7/a2-a6,-(sp)
	
	lea		_reboundstore+dd_SIZEOF,a1
	move.l	_netbuffer,a0
	lea		(dd_SIZEOF/2)(a0),a0
	
	movem.l	(a0),d0-d7/a2-a6			;' first 52 bytes
	movem.l	d0-d7/a2-a6,-(a1)

	lea		-(dd_SIZEOF/2)(a0),a0
	movem.l	(a0),d0-d7/a2-a6			;' second 52 bytes
	movem.l	d0-d7/a2-a6,-(a1)
	
	movem.l	(sp)+,d2-d7/a2-a6
	st.b		_reboundpacket+3
.return:
	rts

.notreboundpacket:
;//    if (demoplayback)
;//	return;
	tst.l		_demoplayback
	bne.s		.return

;//    if (!netgame)
;//	I_Error ("Tried to transmit to another node");
	tst.l		_netgame
	bne.s		.go
	
	pea		ERRTXT_NONETGAME(pc)
	jsr		_I_Error
	;// does not return
	
.go:
;//    doomcom->command = CMD_SEND;
	move.l	_doomcom,a0
	move		#CMD_SEND,dc_command(a0)

;//    doomcom->remotenode = node;
	move		d0,dc_remotenode(a0)

;//    doomcom->datalength = NetbufferSize ();
	move.l	_netbuffer,a1
	moveq		#0,d1
	move.b	dd_numtics(a1),d1
	lsl		#3,d1
	addq		#8,d1
	move		d1,dc_datalength(a0)
	
	jsr		_I_NetCmd
	rts


;/********** DATA **************************************/

	CNOP	0,4

	XDEF	_curline
	XDEF	_sidedef
	XDEF	_linedef
	XDEF	_frontsector
	XDEF	_backsector

	XDEF	_lastvisplane
	XDEF	_floorplane
	XDEF	_ceilingplane
	XDEF	_maxvisplane
	
	XDEF	_planezlight
	XDEF	_planeheight
	XDEF	_basexscale
	XDEF	_baseyscale

	XDEF	_segtextured
	XDEF	_markfloor
	XDEF	_markceiling
	XDEF	_maskedtexture
	XDEF	_toptexture
	XDEF	_bottomtexture
	XDEF	_midtexture
	XDEF	_rw_normalangle
	XDEF	_rw_angle
	XDEF	_rw_angle1
	XDEF	_rw_x
	XDEF	_rw_stopx
	XDEF	_rw_centerangle
	XDEF	_rw_offset
	XDEF	_rw_distance
	XDEF	_rw_scale
	XDEF	_rw_scalestep
	XDEF	_rw_midtexturemid
	XDEF	_rw_toptexturemid
	XDEF	_rw_bottomtexturemid
	XDEF	_worldtop
	XDEF	_worldbottom
	XDEF	_worldhigh
	XDEF	_worldlow
	XDEF	_pixhigh
	XDEF	_pixlow
	XDEF	_pixhighstep
	XDEF	_pixlowstep
	XDEF	_topfrac
	XDEF	_topstep
	XDEF	_bottomfrac
	XDEF	_bottomstep
	XDEF	_walllights
	XDEF	_maskedtexturecol
	XDEF	_PCCheckSum
	XDEF	_vissprite_p
	XDEF	_spritelights
	XDEF	_sprites
	XDEF	_mfloorclip
	XDEF	_mceilingclip
	XDEF	_spryscale
	XDEF	_sprtopscreen
	XDEF	_ds_p
	XDEF	_newend
	XDEF	_firstflat
	XDEF	_firstspritelump
	XDEF	_texturewidthmask
	XDEF	_textureheight
	XDEF	_texturecolumnlump
	XDEF	_texturecolumnofs
	XDEF	_flattranslation
	XDEF	_texturetranslation
	XDEF	_spritewidth
	XDEF	_spriteoffset
	XDEF	_spritetopoffset
	XDEF	_colormaps
	XDEF	_texturecomposite
	XDEF	_validcount
	XDEF	_fixedcolormap
	XDEF	_centerx
	XDEF	_centery
	XDEF	_centerxfrac
	XDEF	_centeryfrac
	XDEF	_projection
	XDEF	_viewx
	XDEF	_viewy
	XDEF	_viewz
	XDEF	_viewangle
	XDEF	_viewcos
	XDEF	_viewsin
	XDEF	_detailshift
	XDEF	_clipangle
	XDEF	_doubleclipangle
	XDEF	_finecosine
	XDEF	_extralight
	XDEF	_colfunc
	XDEF	_basecolfunc
	XDEF	_fuzzcolfunc
	XDEF	_transcolfunc
	XDEF	_spanfunc
	XDEF	_lastopening
	XDEF	_dc_yh
	XDEF	_dc_yl
	XDEF	_dc_x
	XDEF	_dc_iscale
	XDEF	_dc_texturemid
	XDEF	_dc_source
	XDEF	_dc_colormap
	XDEF	_dc_translation
	XDEF	_ds_y
	XDEF	_ds_x1
	XDEF	_ds_x2
	XDEF	_ds_colormap
	XDEf	_ds_xfrac
	XDEF	_ds_yfrac
	XDEF	_ds_xstep
	XDEF	_ds_ystep
	XDEF	_ds_source
	XDEF	_viewimage
	XDEF	_viewwidth
	XDEF	_scaledviewwidth
	XDEF	_viewheight
	XDEF	_viewwindowx
	XDEF	_viewwindowy
	XDEF	_ylookup
	XDEF	_columnofs
	XDEF	_skyflatnum
	XDEF	_skytexture
	XDEF	_skytexturemid
	XDEF	_skyspriteiscale
	XDEF	_yslope
	XDEF	_crosshair
	XDEF	_visspritecount
	XDEF	_MEDRES
	XDEf	_HIGHRES
	XDEF	_crosshaircolor
	XDEF	_visplanes
	XDEF	_REALSCREENHEIGHT
	XDEF	_REALSCREENWIDTH
	XDEF	_vissprites
	XDEF	_maxvissprite
	XDEF	_maxdrawsegs
	XDEF	_maxdrawseg
	XDEF	_drawsegs

_PCCheckSum:	dc.l	0
_curline:		dc.l	0
_sidedef:		dc.l	0
_linedef:		dc.l	0
_frontsector:	dc.l	0
_backsector:	dc.l	0
_lastvisplane:	dc.l	0
_floorplane:	dc.l	0
_ceilingplane:	dc.l	0
_maxvisplane:	dc.l	0	;		/*exclusive!!*/
_planezlight:	dc.l	0
_planeheight:	dc.l	0
_basexscale:	dc.l	0
_baseyscale:	dc.l	0

_segtextured:	dc.l	0
_markfloor:		dc.l	0
_markceiling:	dc.l	0
_maskedtexture:	dc.l	0
_toptexture:		dc.l	0
_bottomtexture:	dc.l	0
_midtexture:		dc.l	0
_rw_normalangle:	dc.l	0
_rw_angle:			dc.l	0
_rw_angle1:			dc.l	0
_rw_x:				dc.l	0
_rw_stopx:			dc.l	0
_rw_centerangle:	dc.l	0
_rw_offset:			dc.l	0
_rw_distance:		dc.l	0
_rw_scale:			dc.l	0
_rw_scalestep:		dc.l	0
_rw_midtexturemid:	dc.l	0
_rw_toptexturemid:	dc.l	0
_rw_bottomtexturemid:	dc.l	0
_worldtop:		dc.l	0
_worldbottom:	dc.l	0
_worldhigh:		dc.l	0
_worldlow:		dc.l	0
_pixhigh:		dc.l	0
_pixlow:			dc.l	0
_pixhighstep:	dc.l	0
_pixlowstep:	dc.l	0
_topfrac:		dc.l	0
_topstep:		dc.l	0
_bottomfrac:	dc.l	0
_bottomstep:	dc.l	0
_walllights:	dc.l	0
_maskedtexturecol:	dc.l	0
_vissprite_p:	dc.l	0
_spritelights:	dc.l	0
_sprites:		dc.l	0
_mfloorclip:	dc.l	0
_mceilingclip:	dc.l	0
_spryscale:		dc.l	0
_sprtopscreen:	dc.l	0
_ds_p:			dc.l	0
_newend:			dc.l	0
_firstflat:		dc.l	0
_firstspritelump:	dc.l	0
_texturewidthmask:	dc.l	0
_textureheight:	dc.l	0
_texturecolumnlump:	dc.l	0
_texturecolumnofs:	dc.l	0
_flattranslation:	dc.l	0
_texturetranslation:	dc.l	0
_spritewidth:		dc.l	0
_spriteoffset:		dc.l	0
_spritetopoffset:	dc.l	0
_colormaps:			dc.l	0
_texturecomposite:	dc.l	0
_validcount:		dc.l	1
_fixedcolormap:	dc.l	0
_centerx:			dc.l	0
_centery:			dc.l	0
_centerxfrac:		dc.l	0
_centeryfrac:		dc.l	0
_projection:		dc.l	0
_viewx:				dc.l	0
_viewy:				dc.l	0
_viewz:				dc.l	0
_viewangle:			dc.l	0
_viewcos:			dc.l	0
_viewsin:			dc.l	0
_detailshift:		dc.l	0
_clipangle:			dc.l	0
_doubleclipangle:	dc.l	0
_finecosine:		dc.l	_finesine+(FINEANGLES/4*4)
_extralight:		dc.l	0
_colfunc:			dc.l	0
_basecolfunc:		dc.l	0
_fuzzcolfunc:		dc.l	0
_transcolfunc:		dc.l	0
_spanfunc:			dc.l	0
_lastopening:		dc.l	0
_dc_yh:				dc.l	0
_dc_yl:				dc.l	0
_dc_x:				dc.l	0
_dc_iscale:			dc.l	0
_dc_texturemid:	dc.l	0
_dc_source:			dc.l	0
_dc_colormap:		dc.l	0
_dc_translation:	dc.l 0
_ds_y:				dc.l 0
_ds_x1:				dc.l 0
_ds_x2:				dc.l 0
_ds_colormap:		dc.l 0
_ds_xfrac:			dc.l 0
_ds_yfrac:			dc.l 0
_ds_xstep:			dc.l 0
_ds_ystep:			dc.l 0
_ds_source:			dc.l 0
_viewimage:				dc.l 0
_viewwidth:				dc.l 0
_scaledviewwidth:		dc.l 0
_viewheight:			dc.l 0
_viewwindowx:			dc.l 0
_viewwindowy:			dc.l 0
_skyflatnum:			dc.l	0
_skytexture:			dc.l	0
_skytexturemid:		dc.l	0
_skyspriteiscale:		dc.l	0
_yslope:					dc.l	0
_crosshair:				dc.l	0
_visspritecount:		dc.l	0
_MEDRES:					dc.l	0
_HIGHRES:				dc.l	0
_crosshaircolor:		dc.l	176
_visplanes:				dc.l	0
_REALSCREENWIDTH:		dc.l	320
_REALSCREENHEIGHT:	dc.l	200
_vissprites:			dc.l	0
_maxvissprite:			dc.l	0
_maxdrawsegs:			dc.l	0
_drawsegs:				dc.l	0
_maxdrawseg:			dc.l	0

_ylookup:	blk.l	MAXHEIGHT,0
_columnofs:	blk.l	MAXWIDTH,0

checkcoord:
	dc.w	3,0,2,1
	dc.w	3,0,2,0
	dc.w	3,1,2,0
	dc.w	0,0,0,0

	dc.w	2,0,2,1
 	dc.w	0,0,0,0
 	dc.w	3,1,3,0
 	dc.w	0,0,0,0
 	
 	dc.w	2,0,3,1
 	dc.w	2,1,3,1
 	dc.w	2,1,3,0
 	dc.w	0,0,0,0

;/********** ERROR TEXTS *******************************/

ERRTXT_NOVISPLANES:
	dc.b 'R_FindPlane: No more visplanes',0
ERRTXT_NONETGAME:
	dc.b 'Tried to transmit to another node',0


;/*************** BSS *********************************/

	SECTION .data,BSS

	XDEF	_yoffsettable

_yoffsettable:
	ds.l		MAXHEIGHT
cliptop:
	ds.w		MAXWIDTH+4
clipbot:
	ds.w		MAXWIDTH+4

	END

