PLANESIZE = 16000

;/***************************************************/
	
	XDEF	_ConvertPalette
	
_ConvertPalette:		;// (UBYTE *pal, UBYTE *gamma, APTR *setcoloffsets)
	movem.l	a2/a3,-(sp)
	
	movem.l	8+4(sp),a0/a1/a2
	
	;' SKIP color 0 (must be back = 00,00,00)

	addq.l	#3,a0
	lea		3*4(a2),a2
	
	move		#256-1,d0
	moveq		#0,d1
	bra.s		.loopentry

.loop:
	;'RED
	
	move.b	(a0)+,d1
	move.b	(a1,d1.w),d1
	lsr.b		#2,d1
	
	move.l	(a2)+,a3
	move.b	d1,(a3)

	;'GREEN
	
	move.b	(a0)+,d1
	move.b	(a1,d1.w),d1
	lsr.b		#2,d1
	
	move.l	(a2)+,a3
	move.b	d1,(a3)

	;'BLUE
	
	move.b	(a0)+,d1
	move.b	(a1,d1.w),d1
	lsr.b		#2,d1
	
	move.l	(a2)+,a3
	move.b	d1,(a3)
		
	
.loopentry:
	dbf		d0,.loop

	movem.l	(sp)+,a2/a3
	rts

;/***************************************************/

	XDEF		_ConvertGraphic

_ConvertGraphic:		;// (UBYTE * chunky, APTR plane1)
	movem.l	d2-d5/a2-a4,-(sp)
	
	movem.l	7*4+4(sp),a0/a1
	
											;'a0 = chunky

											;'a1 = plane 1
	lea		PLANESIZE(a1),a2		;'a2 = plane 2
	lea		PLANESIZE(a2),a3		;'a3 = plane 3
	lea		PLANESIZE(a3),a4		;'a4 = plane 4

	move		#320*200/16,d5
	bra.s		.loopentry
	
	CNOP		0,4
	
.loop:
	movem.l	(a0)+,d0-d3				;'16 Pixels
	
	move.b	d0,d4
	rol.l		#8,d4
	
	move.b	d1,d4
	rol.l		#8,d4
	
	move.b	d2,d4
	rol.l		#8,d4
	
	move.b	d3,d4
	
	move.l	d4,(a4)+


	ror.l		#8,d0
	move.b	d0,d4
	rol.l		#8,d4
	
	ror.l		#8,d1
	move.b	d1,d4
	rol.l		#8,d4
	
	ror.l		#8,d2
	move.b	d2,d4
	rol.l		#8,d4
	
	ror.l		#8,d3
	move.b	d3,d4
	
	move.l	d4,(a3)+

	ror.l		#8,d0
	move.b	d0,d4
	rol.l		#8,d4
	
	ror.l		#8,d1
	move.b	d1,d4
	rol.l		#8,d4
	
	ror.l		#8,d2
	move.b	d2,d4
	rol.l		#8,d4
	
	ror.l		#8,d3
	move.b	d3,d4
	
	move.l	d4,(a2)+


	ror.l		#8,d0
	move.b	d0,d4
	rol.l		#8,d4
	
	ror.l		#8,d1
	move.b	d1,d4
	rol.l		#8,d4
	
	ror.l		#8,d2
	move.b	d2,d4
	rol.l		#8,d4
	
	ror.l		#8,d3
	move.b	d3,d4
	
	move.l	d4,(a1)+

.loopentry:
	dbf		d5,.loop
	
	movem.l	(sp)+,d2-d5/a2-a4
	rts
	
	END
	
