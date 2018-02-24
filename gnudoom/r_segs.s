#NO_APP
gcc2_compiled.:
___gnu_compiled_c:
.text
_rcsid:
	.ascii "$Id: r_segs.c,v 1.3 1997/01/29 20:10:19 b1 Exp $\0"
	.even
.globl _R_StoreWallRange
_R_StoreWallRange:
	moveml #0x3f3a,sp@-
	movel sp@(44),a4
	movel sp@(48),a3
	movel _ds_p,a1
	cmpl #_drawsegs+12288,a1
	jeq L19
	movel _curline,a2
	movel a2@(16),_sidedef
	movel a2@(20),_linedef
	movel _linedef,a0
	orw #256,a0@(16)
	movel a2@(12),d0
	addl #1073741824,d0
	movel d0,_rw_normalangle
	subl _rw_angle1,d0
	jpl L21
	negl d0
L21:
	cmpl #1073741824,d0
	jls L22
	movel #1073741824,d0
L22:
	movel #1073741824,d3
	subl d0,d3
	movel a2@,a0
	movel a0@,d0
	movel a0@(4),d1
#APP
	sub.l	_viewx,d0 
	jpl		1f 
	neg.l	d0 
1: sub.l	_viewy,d1 
jpl		2f 
	neg.l	d1 
2: cmp.l	d0,d1 
	jlt		3f 
	exg	d0,d1 
3: tst.l d0 
	jne		4f 
	moveq	#0,d0 
	jra		9f 
4:
	swap	d1 
	move.w	d1,d2 
	ext.l	d2 
	clr.w	d1 
	divs.l	d0,d2:d1 
	asrl	#5,d1 
	lea		_tantoangle,a0 
	move.l	(a0,d1.l*4),d1 
	add.l	#0x40000000,d1 
	swap   d1
	asr.w	#3,d1 
	ext.l	d1 
	lea		_finesine,a0 
	move.l	(a0,d1.l*4),d1 
	swap	d0 
	move	d0,d2 
	ext.l	d2 
	clr.w	d0 
	divs.l	d1,d2:d0 
	9:
#NO_APP
	movel d0,d5
	moveq #19,d6
	lsrl d6,d3
	lea _finesine,a0
	movel a0@(d3:l:4),d0
	movel d5,d6
#APP
	muls.l d0,d0:d6 
	move d0,d6 
	swap d6 
#NO_APP
	movel d6,_rw_distance
	movel a4,_rw_x
	movel a4,a1@(4)
	movel a3,a1@(8)
	movel a2,a1@
	lea a3@(1),a6
	movel a6,_rw_stopx
	lea _xtoviewangle,a2
	movel _viewangle,d3
	movel d3,d0
	addl a2@(a4:l:4),d0
#APP
	move.l	d0,d1 
	sub.l	_rw_normalangle,d1 
	move.l	#0x40000000,d2 
	add.l	d2,d1 
	sub.l	_viewangle,d0 
	add.l	d2,d0 
	lea		_finesine,a0 
	moveq	#19,d2 
	lsr.l	d2,d0 
	move.l	(a0,d0.l*4),d0 
	lsr.l	d2,d1 
	move.l	(a0,d1.l*4),d1 
	muls.l	_projection,d2:d1 
	move	d2,d1 
	swap	d1 
	move.l _detailshift,d2 
	asl.l	d2,d1 
	muls.l	_rw_distance,d2:d0 
	move	d2,d0 
	swap	d0 
	move.l	d1,d2 
	swap	d2 
	ext.l	d2 
	cmp.l	d2,d0 
	jgt		1f 
	moveq	#64,d0 
	swap	d0 
	jra	9f 
1:
	swap d1 
	move	d1,d2 
	ext.l	d2 
	clr.w	d1 
	divs.l	d0,d2:d1 
	cmp.l	#255,d1 
	jgt	2f 
	move.l	#256,d0 
	jra	9f 
2: move.l d1,d0 
	moveq	#64,d2 
	swap	d2 
	cmp.l	d2,d0 
	ble.s	9f 
	move.l	d2,d0 
9:
#NO_APP
	movel d0,d4
	movel d0,_rw_scale
	movel d0,a1@(12)
	cmpl a3,a4
	jge L26
	movel d3,d0
	addl a2@(a3:l:4),d0
#APP
	move.l	d0,d1 
	sub.l	_rw_normalangle,d1 
	move.l	#0x40000000,d2 
	add.l	d2,d1 
	sub.l	_viewangle,d0 
	add.l	d2,d0 
	lea		_finesine,a0 
	moveq	#19,d2 
	lsr.l	d2,d0 
	move.l	(a0,d0.l*4),d0 
	lsr.l	d2,d1 
	move.l	(a0,d1.l*4),d1 
	muls.l	_projection,d2:d1 
	move	d2,d1 
	swap	d1 
	move.l _detailshift,d2 
	asl.l	d2,d1 
	muls.l	_rw_distance,d2:d0 
	move	d2,d0 
	swap	d0 
	move.l	d1,d2 
	swap	d2 
	ext.l	d2 
	cmp.l	d2,d0 
	jgt		1f 
	moveq	#64,d0 
	swap	d0 
	jra	9f 
1:
	swap d1 
	move	d1,d2 
	ext.l	d2 
	clr.w	d1 
	divs.l	d0,d2:d1 
	cmp.l	#255,d1 
	jgt	2f 
	move.l	#256,d0 
	jra	9f 
2: move.l d1,d0 
	moveq	#64,d2 
	swap	d2 
	cmp.l	d2,d0 
	ble.s	9f 
	move.l	d2,d0 
9:
#NO_APP
	movel d0,a1@(16)
	subl d4,d0
	movel a3,d1
	subl a4,d1
	divsl d1,d0
	movel d0,_rw_scalestep
	movel d0,a1@(20)
	jra L28
L26:
	movel d0,a1@(16)
L28:
	movel _frontsector,a2
	movel _viewz,d1
	movel a2@(4),d0
	subl d1,d0
	movel d0,_worldtop
	movel a2@,d6
	subl d1,d6
	movel d6,_worldbottom
	clrl _maskedtexture
	clrl _bottomtexture
	clrl _toptexture
	clrl _midtexture
	movel _ds_p,a0
	clrl a0@(44)
	movel _backsector,a1
	tstl a1
	jne L29
	movel _sidedef,a3
	movew a3@(12),a0
	movel _texturetranslation,a1
	movel a1@(a0:l:4),_midtexture
	moveq #1,d6
	movel d6,_markceiling
	movel d6,_markfloor
	movel _linedef,a0
	btst #4,a0@(17)
	jeq L30
	movew a3@(12),a1
	movel _textureheight,a0
	movel a2@,d0
	addl a0@(a1:l:4),d0
	subl d1,d0
L30:
	movel d0,_rw_midtexturemid
	movel _sidedef,a0
	movel a0@(4),d6
	addl d6,_rw_midtexturemid
	movel _ds_p,a0
	moveq #3,d6
	movel d6,a0@(24)
	movel #_screenheightarray,a0@(36)
	movel #_negonearray,a0@(40)
	movel #2147483647,a0@(28)
	movel #-2147483648,a0@(32)
	jra L32
L29:
	clrl a0@(40)
	clrl a0@(36)
	clrl a0@(24)
	movel a1@,d0
	cmpl a2@,d0
	jge L33
	moveq #1,d6
	movel d6,a0@(24)
	movel a2@,a0@(28)
	jra L34
L33:
	cmpl d0,d1
	jge L34
	moveq #1,d6
	movel d6,a0@(24)
	movel #2147483647,a0@(28)
L34:
	movel _frontsector,a1
	movel _backsector,a0
	movel a0@(4),d0
	cmpl a1@(4),d0
	jle L36
	movel _ds_p,a0
	moveq #2,d6
	orl d6,a0@(24)
	movel a1@(4),a0@(32)
	jra L37
L36:
	cmpl _viewz,d0
	jge L37
	movel _ds_p,a0
	moveq #2,d6
	orl d6,a0@(24)
	movel #-2147483648,a0@(32)
L37:
	movel _backsector,a1
	movel _frontsector,a0
	movel a1@(4),a1
	cmpl a0@,a1
	jgt L39
	movel _ds_p,a0
	movel #_negonearray,a0@(40)
	movel #2147483647,a0@(28)
	moveq #1,d6
	orl d6,a0@(24)
L39:
	movel _backsector,a1
	movel _frontsector,a0
	movel a1@,a1
	cmpl a0@(4),a1
	jlt L40
	movel _ds_p,a0
	movel #_screenheightarray,a0@(36)
	movel #-2147483648,a0@(32)
	moveq #2,d6
	orl d6,a0@(24)
L40:
	movel _backsector,a1
	movel _viewz,d0
	movel a1@(4),d1
	subl d0,d1
	movel d1,_worldhigh
	movel a1@,a6
	subl d0,a6
	movel a6,_worldlow
	movel _frontsector,a0
	movew a0@(10),a2
	cmpl _skyflatnum,a2
	jne L41
	movew a1@(10),a0
	cmpl a0,a2
	jne L41
	movel d1,_worldtop
L41:
	movel _worldlow,d6
	cmpl _worldbottom,d6
	jne L43
	movel _backsector,a0
	movel _frontsector,a1
	movew a1@(8),d6
	cmpw a0@(8),d6
	jne L43
	movew a1@(12),d6
	cmpw a0@(12),d6
	jeq L42
L43:
	moveq #1,d6
	movel d6,_markfloor
	jra L44
L42:
	clrl _markfloor
L44:
	movel _worldhigh,a6
	cmpl _worldtop,a6
	jne L46
	movel _backsector,a0
	movel _frontsector,a1
	movew a1@(10),d6
	cmpw a0@(10),d6
	jne L46
	movew a1@(12),d6
	cmpw a0@(12),d6
	jeq L45
L46:
	moveq #1,d6
	movel d6,_markceiling
	jra L47
L45:
	clrl _markceiling
L47:
	movel _backsector,a0
	movel _frontsector,a1
	movel a0@(4),a6
	cmpl a1@,a6
	jle L49
	movel a0@,a0
	cmpl a1@(4),a0
	jlt L48
L49:
	moveq #1,d6
	movel d6,_markfloor
	movel d6,_markceiling
L48:
	movel _worldtop,d0
	cmpl _worldhigh,d0
	jle L50
	movel _sidedef,a3
	movew a3@(8),a0
	movel _texturetranslation,a1
	movel a1@(a0:l:4),_toptexture
	movel _linedef,a0
	btst #3,a0@(17)
	jne L91
	movel _backsector,a2
	movew a3@(8),a1
	movel _textureheight,a0
	movel a2@(4),d0
	addl a0@(a1:l:4),d0
	subl _viewz,d0
L91:
	movel d0,_rw_toptexturemid
L50:
	movel _worldlow,d0
	cmpl _worldbottom,d0
	jle L53
	movel _sidedef,a0
	movew a0@(10),a1
	movel _texturetranslation,a0
	movel a0@(a1:l:4),_bottomtexture
	movel _linedef,a0
	btst #4,a0@(17)
	jeq L54
	movel _worldtop,_rw_bottomtexturemid
	jra L53
L54:
	movel d0,_rw_bottomtexturemid
L53:
	movel _sidedef,a0
	movel a0@(4),d6
	addl d6,_rw_toptexturemid
	movel a0@(4),d6
	addl d6,_rw_bottomtexturemid
	tstw a0@(12)
	jeq L32
	moveq #1,d6
	movel d6,_maskedtexture
	movel _ds_p,a1
	movel _rw_x,d1
	movel d1,d0
	addl d0,d0
	movel _lastopening,a0
	movel a0,a6
	subl d0,a6
	movel a6,d0
	movel d0,_maskedtexturecol
	movel d0,a1@(44)
	movel _rw_stopx,d0
	subl d1,d0
	lea a0@(d0:l:2),a0
	movel a0,_lastopening
L32:
	movel _midtexture,d0
	orl _toptexture,d0
	orl _bottomtexture,d0
	orl _maskedtexture,d0
	movel d0,_segtextured
	jeq L57
	movel _rw_normalangle,d2
	movel _rw_angle1,d3
	movel d2,d0
	subl d3,d0
	cmpl #-2147483648,d0
	jls L58
	negl d0
L58:
	cmpl #1073741824,d0
	jls L59
	movel #1073741824,d0
L59:
	moveq #19,d6
	lsrl d6,d0
	lea _finesine,a0
	movel a0@(d0:l:4),d0
	movel d5,d1
#APP
	muls.l d0,d0:d1 
	move d0,d1 
	swap d1 
#NO_APP
	movel d1,_rw_offset
	movel d2,d0
	subl d3,d0
	cmpl #2147483647,d0
	jhi L61
	negl d1
	movel d1,_rw_offset
L61:
	movel _sidedef,a0
	movel _curline,a2
	movel a0@,d0
	addl a2@(8),d0
	addl d0,_rw_offset
	movel d2,d0
	addl #-1073741824,d0
	movel _viewangle,a6
	subl d0,a6
	movel a6,_rw_centerangle
	tstl _fixedcolormap
	jne L57
	movel _frontsector,a0
	movew a0@(12),d0
	swap d0
	clrw d0
	moveq #20,d6
	asrl d6,d0
	movel d0,a0
	addl _extralight,a0
	movel a2@,a1
	movel a2@(4),a2
	movel a1@(4),a6
	cmpl a2@(4),a6
	jne L63
	subqw #1,a0
	jra L64
L63:
	movel a1@,a1
	cmpl a2@,a1
	jne L64
	addqw #1,a0
L64:
	tstl a0
	jge L66
	movel #_scalelight,_walllights
	jra L57
L66:
	moveq #15,d6
	cmpl a0,d6
	jge L68
	movel #_scalelight+2880,_walllights
	jra L57
L68:
	lea a0@(a0:l:2),a0
	movel a0,d0
	asll #6,d0
	addl #_scalelight,d0
	movel d0,_walllights
L57:
	movel _frontsector,a0
	movel _viewz,d0
	cmpl a0@,d0
	jgt L70
	clrl _markfloor
L70:
	cmpl a0@(4),d0
	jlt L71
	movew a0@(10),a0
	cmpl _skyflatnum,a0
	jeq L71
	clrl _markceiling
L71:
	movel _worldtop,d0
	asrl #4,d0
	movel d0,a1
	movel a1,_worldtop
	movel _worldbottom,d0
	movel d0,d7
	asrl #4,d7
	movel d7,_worldbottom
	movel _rw_scalestep,d5
	movel d5,d0
	movel a1,d1
#APP
	muls.l d1,d1:d0 
	move d1,d0 
	swap d0 
#NO_APP
	negl d0
	movel d0,_topstep
	movel _rw_scale,d4
	movel a1,d1
	movel d4,d0
#APP
	muls.l d0,d0:d1 
	move d0,d1 
	swap d1 
#NO_APP
	movel _centeryfrac,d0
	asrl #4,d0
	movel d0,a0
	movel a0,a6
	subl d1,a6
	movel a6,_topfrac
	movel d5,d0
	movel d7,d1
#APP
	muls.l d1,d1:d0 
	move d1,d0 
	swap d0 
#NO_APP
	negl d0
	movel d0,_bottomstep
	movel d7,d0
	movel d4,d1
#APP
	muls.l d1,d1:d0 
	move d1,d0 
	swap d0 
#NO_APP
	movel a0,d6
	subl d0,d6
	movel d6,_bottomfrac
	tstl _backsector
	jeq L76
	movel _worldhigh,d0
	movel d0,d2
	asrl #4,d2
	movel d2,_worldhigh
	movel _worldlow,d0
	movel d0,d3
	asrl #4,d3
	movel d3,_worldlow
	cmpl d2,a1
	jle L77
	movel d2,d0
	movel d4,d1
#APP
	muls.l d1,d1:d0 
	move d1,d0 
	swap d0 
#NO_APP
	movel a0,a6
	subl d0,a6
	movel a6,_pixhigh
	movel d5,d0
#APP
	muls.l d2,d2:d0 
	move d2,d0 
	swap d0 
#NO_APP
	negl d0
	movel d0,_pixhighstep
L77:
	cmpl d3,d7
	jge L76
	movel d3,d0
#APP
	muls.l d4,d4:d0 
	move d4,d0 
	swap d0 
#NO_APP
	subl d0,a0
	movel a0,_pixlow
	movel d5,d0
#APP
	muls.l d3,d3:d0 
	move d3,d0 
	swap d0 
#NO_APP
	negl d0
	movel d0,_pixlowstep
L76:
	tstl _markceiling
	jeq L83
	movel _rw_stopx,d6
	subql #1,d6
	movel d6,sp@-
	movel _rw_x,sp@-
	movel _ceilingplane,sp@-
	jbsr _R_CheckPlane
	movel d0,_ceilingplane
	addqw #8,sp
	addqw #4,sp
L83:
	tstl _markfloor
	jeq L84
	movel _rw_stopx,a6
	subqw #1,a6
	movel a6,sp@-
	movel _rw_x,sp@-
	movel _floorplane,sp@-
	jbsr _R_CheckPlane
	movel d0,_floorplane
	addqw #8,sp
	addqw #4,sp
L84:
	jbsr _R_RenderSegLoop
	movel _ds_p,a0
	btst #1,a0@(27)
	jne L86
	tstl _maskedtexture
	jeq L85
L86:
	tstl a0@(36)
	jne L85
	movel _rw_stopx,d0
	subl a4,d0
	addl d0,d0
	movel a4,d2
	addl d2,d2
	movel d0,sp@-
	movel _lastopening,sp@-
	movel d2,d6
	addl #_ceilingclip,d6
	movel d6,sp@-
	jbsr _bcopy
	addqw #8,sp
	addqw #4,sp
	movel _ds_p,a0
	movel _lastopening,a1
	movel a1,a6
	subl d2,a6
	movel a6,a0@(36)
	movel _rw_stopx,d0
	subl a4,d0
	lea a1@(d0:l:2),a1
	movel a1,_lastopening
L85:
	movel _ds_p,a0
	btst #0,a0@(27)
	jne L88
	tstl _maskedtexture
	jeq L90
L88:
	tstl a0@(40)
	jne L87
	movel _rw_stopx,d0
	subl a4,d0
	addl d0,d0
	movel a4,d2
	addl d2,d2
	movel d0,sp@-
	movel _lastopening,sp@-
	movel d2,d6
	addl #_floorclip,d6
	movel d6,sp@-
	jbsr _bcopy
	addqw #8,sp
	addqw #4,sp
	movel _ds_p,a0
	movel _lastopening,a1
	movel a1,a6
	subl d2,a6
	movel a6,a0@(40)
	movel _rw_stopx,d0
	subl a4,d0
	lea a1@(d0:l:2),a1
	movel a1,_lastopening
L87:
	tstl _maskedtexture
	jeq L90
	movel _ds_p,a0
	movel a0@(24),d0
	btst #1,d0
	jne L89
	moveq #2,d6
	orl d0,d6
	movel d6,a0@(24)
	movel #-2147483648,a0@(32)
L89:
	tstl _maskedtexture
	jeq L90
	movel _ds_p,a0
	movel a0@(24),d0
	btst #0,d0
	jne L90
	moveq #1,d6
	orl d0,d6
	movel d6,a0@(24)
	movel #2147483647,a0@(28)
L90:
	moveq #48,d6
	addl d6,_ds_p
L19:
	moveml sp@+,#0x5cfc
	rts
