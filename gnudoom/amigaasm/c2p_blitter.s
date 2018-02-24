		MACHINE 68020

		INCDIR AINCLUDE:
		
		include exec/execbase.i
		include dos/dos.i
		include hardware/custom.i
		include lvo/exec_lib.i
		include lvo/dos_lib.i
		include lvo/graphics_lib.i

		rts
		dc.b		'C2P',0
		dc.l		chunky2planar
		dc.l		InitChunky
		dc.l		EndChunky
		dc.l		Support

		
BPLSIZE		equ	4000


		;Init routine
		;4(sp) d0 - Width
		;8(sp) d1 - Height
		;12(sp) d2 - PlaneSize
	
InitChunky:
	move.l	4.w,a6
	sub.l	a1,a1
	jsr		_LVOFindTask(a6)
	move.l	d0,DoomTask

	move.l	#SIGBREAKF_CTRL_F|SIGBREAKF_CTRL_E|SIGBREAKF_CTRL_D,d0
	move.l	d0,d1
	jsr		_LVOSetSignal(a6)
	
	lea		dosname(pc),a1
	moveq	#39,d0
	jsr		_LVOOpenLibrary(a6)
	move.l	d0,_DOSBase
	beq.s	.fail

	lea		gfxname(pc),a1
	moveq	#39,d0
	jsr		_LVOOpenLibrary(a6)
	move.l	d0,_GfxBase
	beq.s	.fail

	moveq	#1,d0
	rts

.fail:
	bsr		EndChunky
	moveq	#0,d0
	rts
	
DoomTask:
	dc.l	0

EndChunky:
	move.l	a6,-(sp)
	move.l	_DOSBase,a6
	tst.l	a6
	beq.s	.noDOS
	moveq	#50*2,d1
	jsr		_LVODelay(a6)
	
.noDOS:
	move.l	4.w,a6
	move.l	_GfxBase(pc),a1
	jsr		_LVOCloseLibrary(a6)
	
	move.l	_DOSBase(pc),a1
	jsr		_LVOCloseLibrary(a6)
	move.l	(sp)+,a6
	rts

_GfxBase:	dc.l 0
_DOSBase:	dc.l 0 
gfxname:	dc.b 'graphics.library',0
dosname:	dc.b 'dos.library',0


		;Main routine		
		;4(sp) a0 - chunkybuffer
		;8(sp) a1 - planes

depth = 8

	CNOP	0,8

; ---------------------------------------------------------------------

; void __asm c2p_020 (register __a2 UBYTE *fBUFFER,
;                     register __a4 PLANEPTR *planes,
;                     register __d0 ULONG signals1,
;                     register __d1 ULONG signals2,
;                     register __d4 ULONG signals3,
;                     register __d2 ULONG pixels,     // width*height
;                     register __d3 ULONG offset,     // byte offset into plane
;                     register __a1 UBYTE *xlate,
;                     register __a5 struct Task *othertask);
;
; Pipelined CPU+blitter 8-plane chunky to planar converter.
; Optimised for 68020/30 with fastmem.
;
; Author: Peter McGavin (e-mail peterm@maths.grace.cri.nz), 21 April 1994
; Based on James McCoull's 4-pass blitter algorithm.
;
; This code is public domain.
;
; Perform first 2 merges (Fast->Chip) with the CPU (in 1 pass).
; Wait for previous QBlit() to completely finish (signals2).
; Then launch merge passes 3 & 4 with QBlit().
; Return immediately after launching passes 3 & 4.
; Signal this task signals1 (asynchronously) after completion of pass 3.
; Signal this task signals2 from CleanUp() on completion of QBlit().
; Also signal othertask signals3 from CleanUp() on completion of QBlit().
; Calling task must wait for signals1 before next call to c2p_020()
;
; (Unimplemented speedup idea: use a "scrambled" chunky buffer.
; Skip pass 1.)
;
; Example usage:
;
;	/* clear fBUFFER, fBUFFER_CMP, and planes here */
;	if ((sigbit1 = AllocSignal(-1)) == -1 ||
;	    (sigbit2 = AllocSignal(-1)) == -1)
;		die ("Can't allocate signal!\n");
;	SetSignal ((1<<sigbit1)|(1<<sigbit2),  // initial state is "finished"
;		   (1<<sigbit1)|(1<<sigbit2));
;	for (;;) {
;		/* render to fBUFFER here */
;		Wait (1<<sigbit1);  // wait for prev c2p8() to finish pass 3
;	        c2p8 (fBUFFER, &RASTPORT->BitMap->Planes[0],
;		      1<<sigbit1, 1<<sigbit2, WIDTH*HEIGHT,
;                     WIDTH/8*LINESTOSKIP, xlate);
;	}
;	Wait (1<<sigbit1);  // wait for last c2p8 to finish pass 3
;	Wait (1<<sigbit2);  // wait for last c2p8 to completely finish
;	FreeSignal(sigbit1);
;	FreeSignal(sigbit2);
;
; ---------------------------------------------------------------------

maxwidth	equ	320	; must be a multiple of 32
maxheight	equ	200
maxpixels	equ	maxwidth*maxheight

cleanup		equ	$40

xload		macro	; translate 4 8-bit pixels to 6-bit EHB using xlate[]
		move.b	(\1,a2),d4
		move.b	(a6,d4.w),\2
		lsl.w	#8,\2
		move.b	(\1+8,a2),d4
		move.b	(a6,d4.w),\2
		swap	\2
		move.b	(\1+2,a2),d4
		move.b	(a6,d4.w),\2
		lsl.w	#8,\2
		move.b	(\1+10,a2),d4
		move.b	(a6,d4.w),\2
		endm

;		section chunks,code

	ifeq	depth-8
;		xdef	_c2p_8_020
_c2p_8_020:
	else
	ifeq	depth-6
;		xdef	_c2p_6_020
_c2p_6_020:
	else
		fail	"unsupported depth!"
	endc
	endc

planeptr:		blk.l	8,0

chunky2planar:
		movem.l	d2-d7/a2-a6,-(sp)

		move.l	4.w,a6
		move.l	#SIGBREAKF_CTRL_D,d0
		jsr		_LVOWait(a6)

		move.l	DoomTask(pc),a5			;a5=othertask
		move.l	11*4+4(sp),a2			;a2=chunky
		move.l	11*4+8(sp),a4			;a4=planes
		move.l	a4,a1

		move.l	a1,planeptr				;eins
		lea		320*200/8(a1),a1
		move.l	a1,planeptr+4			;zwei
		lea		320*200/8(a1),a1
		move.l	a1,planeptr+8			;drei
		lea		320*200/8(a1),a1
		move.l	a1,planeptr+12			;vier
		lea		320*200/8(a1),a1
		move.l	a1,planeptr+16			;fuenf
		lea		320*200/8(a1),a1
		move.l	a1,planeptr+20			;sechs
		lea		320*200/8(a1),a1
		move.l	a1,planeptr+24			;sieben
		lea		320*200/8(a1),a1
		move.l	a1,planeptr+28			;acht
		
		lea		planeptr(pc),a4
		
		move.l	#SIGBREAKF_CTRL_D,d0	;d0=signals1
		move.l	#SIGBREAKF_CTRL_E,d1	;d1=signals2
		move.l	#SIGBREAKF_CTRL_F,d4	;d4=signals4
		move.l	#320*200,d2				;d2=Pixels
		moveq	#0,d3					;d3=Offset into framebuffer
		sub.l	a1,a1					;xlate

; save arguments

		lea		mybltnode,a0
		move.l	a5,(othertask-mybltnode,a0)
		move.l	a2,(chunky-mybltnode,a0)
		move.l	a4,(planes-mybltnode,a0)
		move.l	d0,(signals1-mybltnode,a0)
		move.l	d1,(signals2-mybltnode,a0)
		move.l	d4,(signals3-mybltnode,a0)
		move.l	d2,(pixels-mybltnode,a0)
		lsr.l	#1,d2
		move.l	d2,(pixels2-mybltnode,a0)
		lsr.l	#1,d2
		move.l	d2,(pixels4-mybltnode,a0)
		lsr.l	#1,d2
		move.l	d2,(pixels8-mybltnode,a0)
		lsr.l	#1,d2
		move.l	d2,(pixels16-mybltnode,a0)
		move.l	d3,(offset-mybltnode,a0)
	IFLE depth-6
		move.l	a1,(xlate-mybltnode,a0)
	ENDC

;-------------------------------------------------
;original chunky data
;0		a7a6a5a4a3a2a1a0 b7b6b5b4b3b2b1b0
;2		c7c6c5c4c3c2c1c0 d7d6d5d4d3d2d1d0
;4		e7e6e5e4e3e2e1e0 f7f6f5f4f3f2f1f0
;6		g7g6g5g4g3g2g1g0 h7h6h5h4h3h2h1h0
;8		i7i6i5i4i3i2i1i0 j7j6j5j4j3j2j1j0
;10		k7k6k5k4k3k2k1k0 l7l6l5l4l3l2l1l0
;12		m7m6m5m4m3m2m1m0 n7n6n5n4n3n2n1n0
;14		o7o6o5o4o3o2o1o0 p7p6p5p4p3p2p1p0
;16		q7q6q5q4q3q2q1q0 r7r6r5r4r3r2r1r0
;18		s7s6s5s4s3s2s1s0 t7t6t5t4t3t2t1t0
;20		u7u6u5u4u3u2u1u0 v7v6v5v4v3v2v1v0
;22		w7w6w5w4w3w2w1w0 x7x6x5x4x3x2x1x0
;24		y7y6y5y4y3y2y1y0 z7z6z5z4z3z2z1z0
;26		A7A6A5A4A3A2A1A0 B7B6B5B4B3B2B1B0
;28		C7C6C5C4C3C2C1C0 D7D6D5D4D3D2D1D0
;30		E7E6E5E4E3E2E1E0 F7F6F5F4F3F2F1F0
;-------------------------------------------------

		move.l	(pixels16-mybltnode,a0),d6 ; loop count = pixels/16

	IFLE depth-6
		move.l	(xlate-mybltnode,a0),a6	; a6 -> xlate
	ENDC
		move.l	(pixels4-mybltnode,a0),d0
		move.l	#buff2,a0	; a0 -> buff2 (in Chip)
		lea	(a0,d0.l),a1	; a1 -> buff2+pixels/4
		lea	(a1,d0.l),a4	; a4 -> buff2+pixels/2
		lea	(a4,d0.l),a5	; a5 -> buff2+3*pixels/4

		move.l	#$0f0f0f0f,d7	; constant
		move.l	#$00ff00ff,d5	; constant

	IFGT depth-6			; 8-plane version
		subq.w	#1,d6
		movem.l	(a2)+,d0-d3	; AaBbCcDd EeFfGgHh IiJjKkLl MmNnOoPp
		move.l	d2,d4
		lsr.l	#8,d4
		eor.l	d0,d4
		and.l	d5,d4
		eor.l	d4,d0
		lsl.l	#8,d4
		eor.l	d4,d2
		move.l	d3,d4
		lsr.l	#8,d4
		eor.l	d1,d4
		and.l	d5,d4
		eor.l	d4,d1
		lsl.l	#8,d4
		eor.l	d4,d3
		move.l	d1,d4
		lsr.l	#4,d4
		bra	start8
	ELSE
		bra	end_pass1loop
	ENDC

		cnop	0,4

; main loop (starts here) processes 16 chunky pixels at a time
; convert 16 pixels (passes 1 and 2 combined)

	IFGT depth-6			; 8-plane version

mainloop:	movem.l	(a2)+,d0-d3	; AaBbCcDd EeFfGgHh IiJjKkLl MmNnOoPp

		move.l	d4,(a4)+

		move.l	d2,d4
		lsr.l	#8,d4
		eor.l	d0,d4
		and.l	d5,d4
		eor.l	d4,d0
		lsl.l	#8,d4
		eor.l	d4,d2
		move.l	d3,d4

		move.l	a6,(a1)+

		lsr.l	#8,d4
		eor.l	d1,d4
		and.l	d5,d4
		eor.l	d4,d1
		lsl.l	#8,d4
		eor.l	d4,d3
		move.l	d1,d4
		lsr.l	#4,d4

		move.l	a3,(a5)+

start8:		eor.l	d0,d4
		and.l	d7,d4
		eor.l	d4,d0		; d0=AEIMCGKO
		lsl.l	#4,d4
		eor.l	d1,d4		; d4=aeimcgko
		move.l	d3,d1
		lsr.l	#4,d1
		eor.l	d2,d1

		move.l	d0,(a0)+

		and.l	d7,d1
		eor.l	d1,d2
		lsl.l	#4,d1
		eor.l	d1,d3
		movea.l	d2,a6		; a6=BFJNDHLP
		movea.l	d3,a3		; a3=bfjndhlp

end_pass1loop:	dbra	d6,mainloop

		move.l	d4,(a4)+
		move.l	a6,(a1)+
		move.l	a3,(a5)+

	ELSE				; 6-plane version with pixel xlate table

mainloop:	moveq	#0,d4
		xload	0,d0		; d0=xlate[AaIiCcKk]
		xload	4,d1		; d1=xlate[EeMmGgOo]
		xload	1,d2		; d2=xlate[BbJjDdLl]
		xload	5,d3		; d3=xlate[FfNnHhPp]
		adda.w	#16,a2

		move.l	d1,d4
		lsr.l	#4,d4
		eor.l	d0,d4
		and.l	d7,d4
		eor.l	d4,d0		; d0=AEIMCGKO

		move.l	d0,(a0)+

		lsl.l	#4,d4
		eor.l	d4,d1		; d1=aeimcgko
		move.l	d3,d4
		lsr.l	#4,d4

		move.l	d1,(a4)+

		eor.l	d2,d4
		and.l	d7,d4
		eor.l	d4,d2		; d2=BFJNDHLP

		move.l	d2,(a1)+

		lsl.l	#4,d4
		eor.l	d4,d3		; d3=bfjndhlp

		move.l	d3,(a5)+

end_pass1loop:	dbra	d6,mainloop

	ENDC

; wait until previous QBlit() has completely finished (signals2)
; then start the blitter in the background for passes 3 & 4

done:		lea	mybltnode,a2	; a2->mybltnode
		move.l	(4).w,a6	; a6->SysBase
		move.l	(ThisTask,a6),(task-mybltnode,a2) ; save task ptr
		move.l	(signals2-mybltnode,a2),d0
		jsr	(_LVOWait,a6)

		move.l	a2,a1
		move.l	(_GfxBase),a6
		jsr	(_LVOQBlit,a6)

ret:		movem.l	(sp)+,d2-d7/a2-a6
		rts

;-----------------------------------------------------------------------------
; QBlit functions (called asynchronously)

;-------------------------------------------------
;buff2 after pass 2
;0		a7a6a5a4e7e6e5e4 i7i6i5i4m7m6m5m4
;2		c7c6c5c4g7g6g5g4 k7k6k5k4o7o6o5o4
;4		q7q6q5q4u7u6u5u4 y7y6y5y4C7C6C5C4
;6		s7s6s5s4w7w6w5w4 A7A6A5A4E7E6E5E4
;
;Pixels/4+0	b7b6b5b4f7f6f5f4 j7j6j5j4n7n6n5n4
;Pixels/4+2	d7d6d5d4h7h6h5h4 l7l6l5l4p7p6p5p4
;Pixels/4+4	r7r6r5r4v7v6v5v4 z7z6z5z4D7D6D5D4
;Pixels/4+6	t7t6t5t4x7x6x5x4 B7B6B5B4F7F6F5F4
;
;Pixels/2+0	a3a2a1a0e3e2e1e0 i3i2i1i0m3m2m1m0
;Pixels/2+2	c3c2c1c0g3g2g1g0 k3k2k1k0o3o2o1o0
;Pixels/2+4	q3q2q1q0u3u2u1u0 y3y2y1y0C3C2C1C0
;Pixels/2+6	s3s2s1s0w3w2w1w0 A3A2A1A0E3E2E1E0
;
;3*Pixels/4+0	b3b2b1b0f3f2f1f0 j3j2j1j0n3n2n1n0	
;3*Pixels/4+2	d3d2d1d0h3h2h1h0 l3l2l1l0p3p2p1p0
;3*Pixels/4+4	r3r2r1r0v3v2v1v0 z3z2z1z0D3D2D1D0
;3*Pixels/4+6	t3t2t1t0x3x2x1x0 B3B2B1B0F3F2F1F0
;-------------------------------------------------

;Pass 3, subpass 1
;	apt		Buff2
;	bpt		Buff2+2
;	dpt		Buff3
;	amod		2
;	bmod		2
;	dmod		0
;	cdat		$cccc
;	sizv		Pixels/4
;	sizh		1 word
;	con		D=AC+(B>>2)~C, ascending

blit31:
		moveq	#-1,d0
		move.l	d0,(bltafwm,a0)
		move.w	#0,(bltdmod,a0)
		move.l	#buff2,(bltapt,a0)
		move.l	#buff2+2,(bltbpt,a0)
		move.l	#buff3,(bltdpt,a0)
		move.w	#2,(bltamod,a0)		; 2
		move.w	#2,(bltbmod,a0)		; 2
		move.w	#$cccc,(bltcdat,a0)
		move.l	#$0DE42000,(bltcon0,a0)	; D=AC+(B>>2)~C

;		move.l	(pixels4-mybltnode,a1),d0	; pixels/4
;blit31a:	cmp.l	#32768,d0		; check for overflow blitter
;		bls.b	blit31c			; branch if ok
;		move.l	d0,(sizv-mybltnode,a1)	; else save (too big) bltsizv
;		move.w	#32768,(bltsizv,a0)	; max possible bltsizv
;		move.w	#1,(bltsizh,a0)		; do blit
;		lea	(blit31b,pc),a0
;		move.l	a0,(qblitfunc-mybltnode,a1)
;		rts
;
;blit31b:	move.l	(sizv-mybltnode,a1),d0	; restore (too big) bltsizv
;		sub.l	#32768,d0		; subtract number already done
;		bra.b	blit31a			; loop back
;
;blit31c:	move.w	d0,(bltsizv,a0)		; pixels/8

		move.w	(pixels4+2-mybltnode,a1),(bltsizv,a0) ; pixels/4

		move.w	#1,(bltsizh,a0)		;do blit
		
		lea	(blit32,pc),a0
		move.l	a0,(qblitfunc-mybltnode,a1)
		rts

;Pass 3, subpass 2
;	apt		Buff2+Pixels-2-2
;	bpt		Buff2+Pixels-2
;	dpt		Buff3+Pixels-2
;	amod		2
;	bmod		2
;	dmod		0
;	cdat		$cccc
;	sizv		Pixels/4
;	sizh		1 word
;	con		D=(A<<2)C+B~C, descending

blit32:		move.l	#buff2,d0
		add.l	(pixels-mybltnode,a1),d0
		subq.l	#2+2,d0
		move.l	d0,(bltapt,a0)		; buff2+pixels-2-2
		addq.l	#2,d0
		move.l	d0,(bltbpt,a0)		; buff2+pixels-2
		add.l	#buff3-buff2,d0
		move.l	d0,(bltdpt,a0)		; buff3+pixels-2
		move.l	#$2DE40002,(bltcon0,a0)	; D=(A<<2)C+B~C, desc.

;		move.l	(pixels4-mybltnode,a1),d0	; pixels/4
;blit32a:	cmp.l	#32768,d0		; check for overflow blitter
;		bls.b	blit32c			; branch if ok
;		move.l	d0,(sizv-mybltnode,a1)	; else save (too big) bltsizv
;		move.w	#32768,(bltsizv,a0)	; max possible bltsizv
;		move.w	#1,(bltsizh,a0)		; do blit
;		lea	(blit32b,pc),a0
;		move.l	a0,(qblitfunc-mybltnode,a1)
;		rts
;
;blit32b:	move.l	(sizv-mybltnode,a1),d0	; restore (too big) bltsizv
;		sub.l	#32768,d0		; subtract number already done
;		bra.b	blit32a			; loop back
;
;blit32c:	move.w	d0,(bltsizv,a0)		; pixels/8

		move.w	#1,(bltsizh,a0)		;do blit
	IFGT depth-6
		lea	(blit47,pc),a0
	ELSE
		lea	(blit43,pc),a0
	ENDC
		move.l	a0,(qblitfunc-mybltnode,a1)
		rts

;-------------------------------------------------
;buff3 after pass 3
;0		a7a6c7c6e7e6g7g6 i7i6k7k6m7m6o7o6
;2		q7q6s7s6u7u6w7w6 y7y6A7A6C7C6E7E6
;
;Pixels/8+0	b7b6d7d6f7f6h7h6 j7j6l7l6n7n6p7p6
;Pixels/8+2	r7r6t7t6v7v6x7x6 z7z6B7B6D7D6F7F6
;
;Pixels/4+0	a3a2c3c2e3e2g3g2 i3i2k3k2m3m2o3o2
;Pixels/4+2	q3q2s3s2u3u2w3w2 y3y2A3A2C3C2E3E2
;
;3*Pixels/8+0	b3b2d3d2f3f2h3h2 j3j2l3l2n3n2p3p2
;3*Pixels/8+2	r3r2t3t2v3v2x3x2 z3z2B3B2D3D2F3F2
;
;Pixels/2+0	a5a4c5c4e5e4g5g4 i5i4k5k4m5m4o5o4
;Pixels/2+2	q5q4s5s4u5u4w5w4 y5y4A5A4C5C4E5E4
;
;5*Pixels/8+0	b5b4d5d4f5f4h5h4 j5j4l5l4n5n4p5p4
;5*Pixels/8+2	r5r4t5t4v5v4x5x4 z5z4B5B4D5D4F5F4
;
;3*Pixels/4+0	a1a0c1c0e1e0g1g0 i1i0k1k0m1m0o1o0
;3*Pixels/4+2	q1q0s1s0u1u0w1w0 y1y0A1A0C1C0E1E0
;
;7*Pixels/8+0	b1b0d1d0f1f0h1h0 j1j0l1l0n1n0p1p0
;7*Pixels/8+2	r1r0t1t0v1v0x1x0 z1z0B1B0D1D0F1F0
;-------------------------------------------------

	IFGT depth-6

;Pass 4, plane 7
;	apt		Buff3+0*pixels/8
;	bpt		Buff3+1*pixels/8
;	dpt		Plane7+offset
;	amod		0
;	bmod		0
;	dmod		0
;	cdat		$aaaa
;	sizv		Pixels/16
;	sizh		1 word
;	con		D=AC+(B>>1)~C, ascending

blit47:		movem.l	a2,-(sp)

		move.w	#0,(bltamod,a0)
		move.w	#0,(bltbmod,a0)
		move.w	(pixels16+2-mybltnode,a1),(bltsizv,a0)	; pixels/16
		move.w	#$aaaa,(bltcdat,a0)
		move.l	#$0DE41000,(bltcon0,a0)	; D=AC+(B>>1)~C

		move.l	#buff3,d0
		move.l	d0,(bltapt,a0)		; buff3+0*pixels/8
		add.l	(pixels8-mybltnode,a1),d0
		move.l	d0,(bltbpt,a0)		; buff3+1*pixels/8
		move.l	(planes-mybltnode,a1),a2
		move.l	(7*4,a2),d0
		add.l	(offset-mybltnode,a1),d0
		move.l	d0,(bltdpt,a0)		; Plane7+offset
		move.w	#1,(bltsizh,a0)		;plane 7

		movem.l	a1/a6,-(sp)
		move.l	(signals1-mybltnode,a1),d0
		move.l	(task-mybltnode,a1),a1
		move.l	(4).w,a6		; a6->SysBase
		jsr	(_LVOSignal,a6)		; signal pass 3 has finished
		movem.l	(sp)+,a1/a6

		lea	(blit43,pc),a0
		move.l	a0,(qblitfunc-mybltnode,a1)
		movem.l	(sp)+,a2
		rts

;-------------------------------------------------
;Plane7		a7b7c7d7e7f7g7h7 i7j7k7l7m7n7o7p7
;Plane7+2	q7r7s7t7u7v7w7x7 y7z7A7B7C7D7E7F7
;-------------------------------------------------

	ENDC

;Pass 4, plane 3
;	apt		buff3+2*pixels/8
;	bpt		buff3+3*pixels/8
;	dpt		Plane3+offset
;	amod		0
;	bmod		0
;	dmod		0
;	cdat		$aaaa
;	sizv		pixels/16
;	sizh		1 word
;	con		D=AC+(B>>1)~C, ascending

blit43:		move.l	a2,-(sp)		; preserve a2
	IFLE depth-6
		move.w	#0,(bltamod,a0)
		move.w	#0,(bltbmod,a0)
		move.w	(pixels16+2-mybltnode,a1),(bltsizv,a0)	; pixels/16
		move.w	#$aaaa,(bltcdat,a0)
		move.l	#$0DE41000,(bltcon0,a0)	; D=AC+(B>>1)~C
	ENDC
		move.l	#buff3,d0
		add.l	(pixels4-mybltnode,a1),d0
		move.l	d0,(bltapt,a0)		; buff3+2*pixels/8
		add.l	(pixels8-mybltnode,a1),d0
		move.l	d0,(bltbpt,a0)		; buff3+3*pixels/8
		move.l	(planes-mybltnode,a1),a2
		move.l	(3*4,a2),d0
		add.l	(offset-mybltnode,a1),d0
		move.l	d0,(bltdpt,a0)		; Plane3+offset
		move.w	#1,(bltsizh,a0)		;plane 3
	IFLE depth-6
		movem.l	a1/a6,-(sp)
		move.l	(signals1-mybltnode,a1),d0
		move.l	(task-mybltnode,a1),a1
		move.l	(4).w,a6		; a6->SysBase
		jsr	(_LVOSignal,a6)		; signal pass 3 has finished
		movem.l	(sp)+,a1/a6
	ENDC
		lea	(blit45,pc),a0
		move.l	a0,(qblitfunc-mybltnode,a1)
		move.l	(sp)+,a2		; restore a2
		rts

;-------------------------------------------------
;Plane3		a3b3c3d3e3f3g3h3 i3j3k3l3m3n3o3p3
;Plane3+2	q3r3s3t3u3v3w3x3 y3z3A3B3C3D3E3F3
;-------------------------------------------------

;Pass 4, plane 5
;	apt		buff3+4*pixels/8
;	bpt		buff3+5*pixels/8
;	dpt		Plane5+offset
;	amod		0
;	bmod		0
;	dmod		0
;	cdat		$aaaa
;	sizv		pixels/16
;	sizh		1 word
;	con		D=AC+(B>>1)~C, ascending

blit45:		move.l	a2,d1			; preserve a2
		move.l	#buff3,d0
		add.l	(pixels2-mybltnode,a1),d0
		move.l	d0,(bltapt,a0)		; buff3+4*pixels/8
		add.l	(pixels8-mybltnode,a1),d0
		move.l	d0,(bltbpt,a0)		; buff3+5*pixels/8
		move.l	(planes-mybltnode,a1),a2
		move.l	(5*4,a2),d0
		add.l	(offset-mybltnode,a1),d0
		move.l	d0,(bltdpt,a0)		; Plane5+offset
		move.w	#1,(bltsizh,a0)		;plane 5
		lea	(blit41,pc),a0
		move.l	a0,(qblitfunc-mybltnode,a1)
		move.l	d1,a2			; restore a2
		rts

;-------------------------------------------------
;Plane5		a5b5c5d5e5f5g5h5 i5j5k5l5m5n5o5p5
;Plane5+2	q5r5s5t5u5v5w5x5 y5z5A5B5C5D5E5F5
;-------------------------------------------------

;Pass 4, plane 1
;	apt		buff3+6*pixels/8
;	bpt		buff3+7*pixels/8
;	dpt		Plane1+offset
;	amod		0
;	bmod		0
;	dmod		0
;	cdat		$aaaa
;	sizv		pixels/16
;	sizh		1 word
;	con		D=AC+(B>>1)~C, ascending

blit41:		move.l	a2,d1			; preserve a2
		move.l	#buff3,d0
		add.l	(pixels4-mybltnode,a1),d0
		add.l	(pixels2-mybltnode,a1),d0
		move.l	d0,(bltapt,a0)		; buff3+6*pixels/8
		add.l	(pixels8-mybltnode,a1),d0
		move.l	d0,(bltbpt,a0)		; buff3+7*pixels/8
		move.l	(planes-mybltnode,a1),a2
		move.l	(1*4,a2),d0
		add.l	(offset-mybltnode,a1),d0
		move.l	d0,(bltdpt,a0)		; Plane1+offset
		move.w	#1,(bltsizh,a0)		;plane 1
	IFGT depth-6
		lea	(blit46,pc),a0
	ELSE
		lea	(blit42,pc),a0
	ENDC
		move.l	a0,(qblitfunc-mybltnode,a1)
		move.l	d1,a2			; restore a2
		rts

;-------------------------------------------------
;Plane1		a1b1c1d1e1f1g1h1 i1j1k1l1m1n1o1p1
;Plane1+2	q1r1s1t1u1v1w1x1 y1z1A1B1C1D1E1F1
;-------------------------------------------------

	IFGT depth-6

;Pass 4, plane 6
;	apt		buff3+1*pixels/8-2
;	bpt		buff3+2*pixels/8-2
;	dpt		Plane6+plsiz-2+offset
;	amod		0
;	bmod		0
;	dmod		0
;	cdat		$aaaa
;	sizv		pixels/16
;	sizh		1 word
;	con		D=(A<<1)C+B~C, descending

blit46:		move.l	a2,d1			; preserve a2
		move.l	#buff3,d0
		add.l	(pixels8-mybltnode,a1),d0
		subq.l	#2,d0
		move.l	d0,(bltapt,a0)		; buff3+1*pixels/8-2
		add.l	(pixels8-mybltnode,a1),d0
		move.l	d0,(bltbpt,a0)		; buff3+2*pixels/8-2
		move.l	(planes-mybltnode,a1),a2
		move.l	(6*4,a2),d0
		add.l	(offset-mybltnode,a1),d0
		add.l	(pixels8-mybltnode,a1),d0
		subq.l	#2,d0
		move.l	d0,(bltdpt,a0)		; Plane6+offset+plsiz-2
		move.l	#$1DE40002,(bltcon0,a0)	; D=(A<<1)C+B~C, desc.
		move.w	#1,(bltsizh,a0)		;plane 6
		lea	(blit42,pc),a0
		move.l	a0,(qblitfunc-mybltnode,a1)
		move.l	d1,a2			; restore a2
		rts

;-------------------------------------------------
;Plane6		a6b6c6d6e6f6g6h6 i6j6k6l6m6n6o6p6
;Plane6+2	q6r6s6t6u6v6w6x6 y6z6A6B6C6D6E6F6
;-------------------------------------------------

	ENDC

;Pass 4, plane 2
;	apt		buff3+3*pixels/8-2
;	bpt		buff3+4*pixels/8-2
;	dpt		Plane2+plsiz-2+offset
;	amod		0
;	bmod		0
;	dmod		0
;	cdat		$aaaa
;	sizv		pixels/16
;	sizh		1 word
;	con		D=(A<<1)C+B~C, descending

blit42:		move.l	a2,d1			; preserve a2
		move.l	#buff3,d0
		add.l	(pixels2-mybltnode,a1),d0
		subq.l	#2,d0
		move.l	d0,(bltbpt,a0)		; buff3+4*pixels/8-2
		sub.l	(pixels8-mybltnode,a1),d0
		move.l	d0,(bltapt,a0)		; buff3+3*pixels/8-2
		move.l	(planes-mybltnode,a1),a2
		move.l	(2*4,a2),d0
		add.l	(offset-mybltnode,a1),d0
		add.l	(pixels8-mybltnode,a1),d0
		subq.l	#2,d0
		move.l	d0,(bltdpt,a0)		; Plane2+offset+plsiz-2
	IFLE depth-6
		move.l	#$1DE40002,(bltcon0,a0)	; D=(A<<1)C+B~C, desc.
	ENDC
		move.w	#1,(bltsizh,a0)		;plane 2
		lea	(blit44,pc),a0
		move.l	a0,(qblitfunc-mybltnode,a1)
		move.l	d1,a2			; restore a2
		rts

;-------------------------------------------------
;Plane2		a2b2c2d2e2f2g2h2 i2j2k2l2m2n2o2p2
;Plane2+2	q2r2s2t2u2v2w2x2 y2z2A2B2C2D2E2F2
;-------------------------------------------------

;Pass 4, plane 4
;	apt		buff3+5*pixels/8-2
;	bpt		buff3+6*pixels/8-2
;	dpt		Plane4+plsiz-2+offset
;	amod		0
;	bmod		0
;	dmod		0
;	cdat		$aaaa
;	sizv		pixels/16
;	sizh		1 word
;	con		D=(A<<1)C+B~C, descending

blit44:		move.l	a2,d1			; preserve a2
		move.l	#buff3,d0
		add.l	(pixels2-mybltnode,a1),d0
		add.l	(pixels4-mybltnode,a1),d0
		subq.l	#2,d0
		move.l	d0,(bltbpt,a0)		; buff3+6*pixels/8-2
		sub.l	(pixels8-mybltnode,a1),d0
		move.l	d0,(bltapt,a0)		; buff3+5*pixels/8-2
		move.l	(planes-mybltnode,a1),a2
		move.l	(4*4,a2),d0
		add.l	(offset-mybltnode,a1),d0
		add.l	(pixels8-mybltnode,a1),d0
		subq.l	#2,d0
		move.l	d0,(bltdpt,a0)		; Plane4+offset+plsiz-2
		move.w	#1,(bltsizh,a0)		;plane 4
		lea	(blit40,pc),a0
		move.l	a0,(qblitfunc-mybltnode,a1)
		move.l	d1,a2			; restore a2
		rts

;-------------------------------------------------
;Plane4		a4b4c4d4e4f4g4h4 i4j4k4l4m4n4o4p4
;Plane4+2	q4r4s4t4u4v4w4x4 y4z4A4B4C4D4E4F4
;-------------------------------------------------

;Pass 4, plane 0
;	apt		buff3+7*pixels/8-2
;	bpt		buff3+8*pixels/8-2
;	dpt		Plane0+plsiz-2+offset
;	amod		0
;	bmod		0
;	dmod		0
;	cdat		$aaaa
;	sizv		pixels/16
;	sizh		1 word
;	con		D=(A<<1)C+B~C, descending

blit40:		move.l	a2,d1			; preserve a2
		move.l	#buff3,d0
		add.l	(pixels-mybltnode,a1),d0
		subq.l	#2,d0
		move.l	d0,(bltbpt,a0)		; buff3+8*pixels/8-2
		sub.l	(pixels8-mybltnode,a1),d0
		move.l	d0,(bltapt,a0)		; buff3+7*pixels/8-2
		move.l	(planes-mybltnode,a1),a2
		move.l	(a2),d0
		add.l	(offset-mybltnode,a1),d0
		add.l	(pixels8-mybltnode,a1),d0
		subq.l	#2,d0
		move.l	d0,(bltdpt,a0)		; Plane0+offset+plsiz-2
		move.w	#1,(bltsizh,a0)		;plane 0
		lea	(blit31,pc),a0
		move.l	a0,(qblitfunc-mybltnode,a1)
		move.l	d1,a2			; restore a2
		moveq	#0,d0			; set Z flag
		rts

;-------------------------------------------------
;Plane0		a0b0c0d0e0f0g0h0 i0j0k0l0m0n0o0p0
;Plane0+2	q0r0s0t0u0v0w0x0 y0z0A0B0C0D0E0F0
;-------------------------------------------------

qblitcleanup:	movem.l	a2/a6,-(sp)
		move.l	#mybltnode,a2
		move.l	(task-mybltnode,a2),a1	; signal QBlit() has finished
		move.l	(signals2-mybltnode,a2),d0
		move.l	(4).w,a6
		jsr	(_LVOSignal,a6)		; may be called from interrupts
		move.l	(othertask-mybltnode,a2),a1
		move.l	(signals3-mybltnode,a2),d0
		jsr	(_LVOSignal,a6)		; signal pass 3 has finished
		movem.l	(sp)+,a2/a6
		rts

;-----------------------------------------------------------------------------
		section	data,data

		CNOP	0,4

mybltnode:	dc.l	0		; next bltnode
qblitfunc:	dc.l	blit31		; ptr to qblitfunc()
		dc.b	cleanup		; stat
		dc.b	0		; filler
		dc.w	0		; blitsize
		dc.w	0		; beamsync
		dc.l	qblitcleanup	; ptr to qblitcleanup()

		CNOP	0,4

chunky:		dc.l	0		; ptr to original chunky data
planes:		dc.l	0		; ptr to list of output plane ptrs
pixels:		dc.l	0		; width*height
pixels2:	dc.l	0		; width*height/2
pixels4:	dc.l	0		; width*height/4
pixels8:	dc.l	0		; width*height/8
pixels16:	dc.l	0		; width*height/16
offset:		dc.l	0		; byte offset into plane
task:		dc.l	0		; ptr to this task
othertask:	dc.l	0		; ptr to other task
signals1:	dc.l	0		; signals to Signal() task after pass 3
signals2:	dc.l	0		; signals to Signal() task at cleanup
signals3:	dc.l	0		; signals to Signal() othertask at cleanup
;sizv		dc.l	0
xlate:		dc.l	0
force_update:	dc.w	0

;-----------------------------------------------------------------------------
		section	segment1,bss,chip		; MUST BE IN CHIP !!!!!

buff2		ds.b	maxpixels	;Intermediate buffer 2
buff3		ds.b	maxpixels	;Intermediate buffer 3



Support:

