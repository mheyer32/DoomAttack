		MACHINE 68020

		OPT 0

		incdir AINCLUDE:
		
		include lvo/exec_lib.i
		include "c2p.i"

;**************************************************************************

		moveq	#-1,d0
		rts

		dc.b		'C2P',0
		dc.l		Chunky1x1
		dc.l		InitChunky
		dc.l		EndChunky
		dc.l		C2PF_VARIABLEHEIGHT

;**************************************************************************

		
BPLSIZE	equ	$1234		;dummy


	;Init routine
	;4(sp) Width
	;8(sp) Height
	;12(sp) PlaneSize
	
InitChunky:
	move.l	4(sp),d0
	move.l	8(sp),d1
	cmp.l	#400,d1
	ble.s	.heightok
	moveq	#0,d0
	rts
	
.heightok:
	lea	c2p_pixels(pc),a0
	mulu.w	d0,d1
	move.l	d1,(a0)

	;patch code
	
	move.l	12(sp),d0
	moveq	#-4,d1
	sub.l	12(sp),d1
	
	move.w	d0,patch1_1 + 2
	move.w	d0,patch1_2 + 2
	move.w	d0,patch1_3 + 2
	move.w	d0,patch1_4 + 2
	move.w	d0,patch1_5 + 2

	move.w	d1,patch1_1n + 2
	move.w	d1,patch1_2n + 2
	move.w	d1,patch1_3n + 2
	move.w	d1,patch1_4n + 2

	add.l	d0,d0	; planesize * 2
	
	move.w	d0,patch2_1 + 2
	move.w	d0,patch2_2 + 2

	add.l	d0,d0	; planesize * 4
	
	move.l	d0,patch4_1l +2

	;clear caches

	move.l	a6,-(sp)
	move.l	4.w,a6
	jsr	_LVOCacheClearU(a6)
	move.l	(sp)+,a6

	moveq	#1,d0
	rts

EndChunky:
	rts

;**************************************************************************

		;Main routine		
		;4(sp) a0 - chunkybuffer
		;8(sp) a1 - planes

Chunky1x1
	move.l	4(sp),a0
	move.l	8(sp),a1

	movem.l	d2-d7/a2-a6,-(sp)

	lea	c2p_pixels(pc),a2

	move.l	#$33333333,d5
	move.l	#$55555555,d6
	move.l	#$00ff00ff,a6

patch1_1:	add.w	#BPLSIZE,a1

	movem.l	a0-a1,-(sp)

	move.l	(a2),a2
	add.l	a0,a2
	cmp.l	a0,a2
	beq	none

	move.l	(a0)+,d0
	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3

	move.l	#$0f0f0f0f,d4		; Merge 4x1, part 1
	and.l	d4,d0
	and.l	d4,d2
	lsl.l	#4,d0
	or.l	d2,d0

	and.l	d4,d1
	and.l	d4,d3
	lsl.l	#4,d1
	or.l	d3,d1

	move.l	d1,a3

	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3
	move.l	(a0)+,d7

	and.l	d4,d1			; Merge 4x1, part 2
	and.l	d4,d2
	lsl.l	#4,d2
	or.l	d1,d2

	and.l	d4,d3
	and.l	d4,d7
	lsl.l	#4,d3
	or.l	d7,d3

	move.l	a3,d1

	swap	d2			; Swap 16x2
	move.w	d0,d7
	move.w	d2,d0
	move.w	d7,d2
	swap	d2

	swap	d3
	move.w	d1,d7
	move.w	d3,d1
	move.w	d7,d3
	swap	d3

	bra.s	start1
x1
	move.l	(a0)+,d0
	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3

patch1_2:	move.l	d7,BPLSIZE(a1)

	move.l	#$0f0f0f0f,d4		; Merge 4x1, part 1
	and.l	d4,d0
	and.l	d4,d2
	lsl.l	#4,d0
	or.l	d2,d0

	and.l	d4,d1
	and.l	d4,d3
	lsl.l	#4,d1
	or.l	d3,d1

	move.l	d1,a3

	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3
	move.l	(a0)+,d7

	move.l	a4,(a1)+

	and.l	d4,d1			; Merge 4x1, part 2
	and.l	d4,d2
	lsl.l	#4,d2
	or.l	d1,d2

	and.l	d4,d3
	and.l	d4,d7
	lsl.l	#4,d3
	or.l	d7,d3

	move.l	a3,d1

	swap	d2			; Swap 16x2
	move.w	d0,d7
	move.w	d2,d0
	move.w	d7,d2
	swap	d2

	swap	d3
	move.w	d1,d7
	move.w	d3,d1
	move.w	d7,d3
	swap	d3

patch1_1n:	move.l	a5,-BPLSIZE-4(a1)
start1
	move.l	a6,d4

	move.l	d2,d7			; Swap 2x2
	lsr.l	#2,d7
	eor.l	d0,d7
	and.l	d5,d7
	eor.l	d7,d0
	lsl.l	#2,d7
	eor.l	d7,d2

	move.l	d3,d7
	lsr.l	#2,d7
	eor.l	d1,d7
	and.l	d5,d7
	eor.l	d7,d1
	lsl.l	#2,d7
	eor.l	d7,d3

	move.l	d1,d7
	lsr.l	#8,d7
	eor.l	d0,d7
	and.l	d4,d7
	eor.l	d7,d0
	lsl.l	#8,d7
	eor.l	d7,d1

	move.l	d1,d7
	lsr.l	#1,d7
	eor.l	d0,d7
	and.l	d6,d7
	eor.l	d7,d0
patch2_1:	move.l	d0,BPLSIZE*2(a1)
	add.l	d7,d7
	eor.l	d1,d7

	move.l	d3,d1
	lsr.l	#8,d1
	eor.l	d2,d1
	and.l	d4,d1
	eor.l	d1,d2
	lsl.l	#8,d1
	eor.l	d1,d3

	move.l	d3,d1
	lsr.l	#1,d1
	eor.l	d2,d1
	and.l	d6,d1
	eor.l	d1,d2
	add.l	d1,d1
	eor.l	d1,d3

	move.l	d2,a4
	move.l	d3,a5

	cmpa.l	a0,a2
	bne	x1

; step 2

patch1_3:	move.l	d7,BPLSIZE(a1)
	move.l	a4,(a1)+
patch1_2n:	move.l	a5,-BPLSIZE-4(a1)

	movem.l	(sp)+,a0-a1
patch4_1l:	add.l	#BPLSIZE*4,a1

	move.l	(a0)+,d0
	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3

	move.l	#$f0f0f0f0,d4		; Merge 4x1, part 1
	and.l	d4,d0
	and.l	d4,d2
	lsr.l	#4,d2
	or.l	d2,d0

	and.l	d4,d1
	and.l	d4,d3
	lsr.l	#4,d3
	or.l	d3,d1

	move.l	d1,a3

	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3
	move.l	(a0)+,d7

	and.l	d4,d1			; Merge 4x1, part 2
	and.l	d4,d2
	lsr.l	#4,d1
	or.l	d1,d2

	and.l	d4,d3
	and.l	d4,d7
	lsr.l	#4,d7
	or.l	d7,d3

	move.l	a3,d1

	swap	d2			; Swap 16x2
	move.w	d0,d7
	move.w	d2,d0
	move.w	d7,d2
	swap	d2

	swap	d3
	move.w	d1,d7
	move.w	d3,d1
	move.w	d7,d3
	swap	d3

	bra.s	start2
x2
	move.l	(a0)+,d0
	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3

patch1_4:	move.l	d7,BPLSIZE(a1)

	move.l	#$f0f0f0f0,d4		; Merge 4x1, part 1
	and.l	d4,d0
	and.l	d4,d2
	lsr.l	#4,d2
	or.l	d2,d0

	and.l	d4,d1
	and.l	d4,d3
	lsr.l	#4,d3
	or.l	d3,d1

	move.l	d1,a3

	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3
	move.l	(a0)+,d7

	move.l	a4,(a1)+

	and.l	d4,d1			; Merge 4x1, part 2
	and.l	d4,d2
	lsr.l	#4,d1
	or.l	d1,d2

	and.l	d4,d3
	and.l	d4,d7
	lsr.l	#4,d7
	or.l	d7,d3

	move.l	a3,d1

	swap	d2			; Swap 16x2
	move.w	d0,d7
	move.w	d2,d0
	move.w	d7,d2
	swap	d2

	swap	d3
	move.w	d1,d7
	move.w	d3,d1
	move.w	d7,d3
	swap	d3

patch1_3n:	move.l	a5,-BPLSIZE-4(a1)
start2
	move.l	a6,d4

	move.l	d2,d7			; Swap 2x2
	lsr.l	#2,d7
	eor.l	d0,d7
	and.l	d5,d7
	eor.l	d7,d0
	lsl.l	#2,d7
	eor.l	d7,d2

	move.l	d3,d7
	lsr.l	#2,d7
	eor.l	d1,d7
	and.l	d5,d7
	eor.l	d7,d1
	lsl.l	#2,d7
	eor.l	d7,d3

	move.l	d1,d7
	lsr.l	#8,d7
	eor.l	d0,d7
	and.l	d4,d7
	eor.l	d7,d0
	lsl.l	#8,d7
	eor.l	d7,d1

	move.l	d1,d7
	lsr.l	#1,d7
	eor.l	d0,d7
	and.l	d6,d7
	eor.l	d7,d0
patch2_2:	move.l	d0,BPLSIZE*2(a1)
	add.l	d7,d7
	eor.l	d1,d7

	move.l	d3,d1
	lsr.l	#8,d1
	eor.l	d2,d1
	and.l	d4,d1
	eor.l	d1,d2
	lsl.l	#8,d1
	eor.l	d1,d3

	move.l	d3,d1
	lsr.l	#1,d1
	eor.l	d2,d1
	and.l	d6,d1
	eor.l	d1,d2
	add.l	d1,d1
	eor.l	d1,d3

	move.l	d2,a4
	move.l	d3,a5

	cmpa.l	a0,a2
	bne	x2

patch1_5:	move.l	d7,BPLSIZE(a1)
	move.l	a4,(a1)+
patch1_4n:	move.l	a5,-BPLSIZE-4(a1)

none
	movem.l	(sp)+,d2-d7/a2-a6
	rts

	cnop	0,4

c2p_pixels dc.l 0

	END

