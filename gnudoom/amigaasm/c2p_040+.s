	MACHINE 68020
	OPT 0

	incdir AINCLUDE:

	include lvo/exec_lib.i
	include "c2p.i"

;**************************************************************************

                    MOVEQ	#-1,D0
                    RTS

                    DC.B           "C2P",0
                    DC.L           Chunky2Planar
                    DC.L           InitChunky
                    DC.L           EndChunky
                    DC.L	   C2PF_VARIABLEHEIGHT|C2PF_VARIABLEWIDTH

;**************************************************************************

					;Init routine
					;4(sp) Width
					;8(sp) Height
					;12(sp) PlaneSize
					;16(sp) C2PInit 


InitChunky:         MOVE.L         $4(SP),D0
                    MOVE.L         $8(SP),D1
		    		MOVE.L         12(sp),psize
		    		CMP.L		   #32767,psize
		    		BLE.S		   .PlaneSizeOK
		    		MOVEQ		   #0,D0
		    		RTS

.PlaneSizeOK:
                    LEA            size,A0
                    MULU.W         D0,D1
                    MOVE.L         D1,(A0)

; make patches
	move.l	psize,d0
	move.w	d0,pat0+4
	move.w	d0,pat5+4
	move.w	d0,pat4+4
	move.w	d0,pat9+4
	neg.l	d0
	move.w	d0,pat1+4
	move.w	d0,pat2+4
	move.w	d0,pat3+4
	move.w	d0,pat6+4
	move.w	d0,pat7+4
	move.w	d0,pat8+4
	add.w	#-4,pat4+4
	add.w	#-4,pat9+4

next
	; round down address of c2p
	lea	c2p,a0
	move.l	a0,d0
	and.b	#%11110000,d0
	move.l	d0,a1
	
	; patch jmp
	move.l	d0,_Chunky2Planar+2
	move.w	#(end-c2p)-1,d0
loop	move.b	(a0)+,(a1)+
	dbra	d0,loop

clearcache:
	;tidy cache
	movem.l	d1/a0/a1/a6,-(sp)	
	move.l	$4.w,a6
	jsr	_LVOCacheClearU(a6)
	movem.l	(sp)+,d1/a0/a1/a6

                    MOVEQ          #1,D0
                    RTS



;**************************************************************************

					;4(sp) chunky
					;8(sp) planes

Chunky2Planar:      MOVEA.L        $4(SP),A0
                    MOVEA.L        $8(SP),A1

		; a0 - chunky
		; a1 - bitplanes

                    MOVEM.L        D2-D7/A2-A6,-(SP)

		jsr	_Chunky2Planar


return:             MOVEM.L        (SP)+,D2-D7/A2-A6
                    RTS

                    NOP

size:               DC.L           $0
psize:		    DC.L	   $0
stack:		    DC.L	   $0

;**************************************************************************

EndChunky:          RTS

;**************************************************************************

	section	c2p,code

; Chunky2Planar algorithm.
;
; 	Cpu only solution VERSION 2
;	Optimised for 040+fastram
;	analyse instruction offsets to check performance

;quad_begin:
;	cnop	0,16

;	xdef	_Chunky2Planar

;  a0 -> chunky pixels
;  a1 -> plane0

width		equ	320		; must be multiple of 32
height		equ	200
plsiz		equ	(width/8)*height	;dummy

merge	MACRO in1,in2,tmp3,tmp4,mask,shift
	;		\1 = abqr
	;		\2 = ijyz
	move.l	\2,\4
	move.l	#\5,\3
	and.l	\3,\2	;\2 = 0j0z
	and.l	\1,\3	;\3 = 0b0r
	eor.l	\3,\1	;\1 = a0q0
	eor.l	\2,\4	;\4 = i0y0
	IFEQ	\6-1
	add.l	\3,\3
	ELSE
	lsl.l	#\6,\3	;\3 = b0r0
	ENDC
	lsr.l	#\6,\4	;\4 = 0i0y
	or.l	\3,\2	;\2 = bjrz
	or.l	\4,\1	;\1 = aiqy
	ENDM


_Chunky2Planar:
	jmp	c2p

	cnop	0,16
c2p:
		movem.l	d2-d7/a2-a6,-(sp)
		move.l	a7,stack

		; a0 = chunky buffer
		; a1 = output area

		move.l	a1,a4
		adda.l	psize,a4		; plane 1
		adda.l	psize,a1
		adda.l	psize,a1
		adda.l	psize,a1
		adda.l	psize,a1		; plane 4
		move.l	a1,a3
		adda.l	psize,a3
		adda.l	psize,a3
		adda.l	psize,a3		; plane 7
		
		move.l	a0,d0
		add.l	#15,d0
		and.b	#%11110000,d0
		move.l	d0,a0

		move.l	a0,a2

		adda.l	size,a2			;end of chunky buffer

		lea	p0(pc),a7		
		bra.s	mainloop

	cnop	0,16
mainloop:
	move.l	0(a0),d0
	move.l	2(a0),d4
 	move.l	4(a0),d2
	move.l	6(a0),d6
 	move.l	8(a0),d1
 	move.l	10(a0),d5
	move.l	12(a0),d3
	move.l	14(a0),d7

 	move.w	16(a0),d0
 	move.w	18(a0),d4
	move.w	20(a0),d2
	move.w	22(a0),d6
 	move.w	24(a0),d1
 	move.w	26(a0),d5
	move.w	28(a0),d3
	move.w	30(a0),d7
	
	adda.w	#32,a0
	move.l	d6,a5
	move.l	d7,a6

	merge	d0,d1,d6,d7,$00FF00FF,8
	merge	d2,d3,d6,d7,$00FF00FF,8

	merge	d0,d2,d6,d7,$0F0F0F0F,4	
	merge	d1,d3,d6,d7,$0F0F0F0F,4

	exg.l	d0,a5
	exg.l	d1,a6	
	
	merge	d4,d5,d6,d7,$00FF00FF,8
	merge	d0,d1,d6,d7,$00FF00FF,8
	
	merge	d4,d0,d6,d7,$0F0F0F0F,4
	merge	d5,d1,d6,d7,$0F0F0F0F,4

	merge	d2,d0,d6,d7,$33333333,2
	merge	d3,d1,d6,d7,$33333333,2	

	merge	d2,d3,d6,d7,$55555555,1
	merge	d0,d1,d6,d7,$55555555,1
	move.l	d3,2*4(a7)	;plane2
	move.l	d2,3*4(a7)	;plane3
	move.l	d1,0*4(a7)	;plane0
	move.l	d0,1*4(a7)	;plane1

	move.l	a5,d2
	move.l	a6,d3

	merge	d2,d4,d6,d7,$33333333,2
	merge	d3,d5,d6,d7,$33333333,2

	merge	d2,d3,d6,d7,$55555555,1
	merge	d4,d5,d6,d7,$55555555,1
	move.l	d3,6*4(a7)		;bitplane6
	move.l	d2,7*4(a7)		;bitplane7
	move.l	d5,4*4(a7)		;bitplane4
	move.l	d4,5*4(a7)		;bitplane5


inner:
	move.l	0(a0),d0
	move.l	2(a0),d4
 	move.l	4(a0),d2
	move.l	6(a0),d6
 	move.l	8(a0),d1
 	move.l	10(a0),d5
	move.l	12(a0),d3
	move.l	14(a0),d7

 	move.w	16(a0),d0
 	move.w	18(a0),d4
	move.w	20(a0),d2
	move.w	22(a0),d6
 	move.w	24(a0),d1
 	move.w	26(a0),d5
	move.w	28(a0),d3
	move.w	30(a0),d7
	
	adda.w	#32,a0
	move.l	d6,a5
	move.l	d7,a6

	; write	bitplane 7	

pat0:	move.l	2*4(a7),plsiz(a4)	;plane2
	merge	d0,d1,d6,d7,$00FF00FF,8
	merge	d2,d3,d6,d7,$00FF00FF,8

	; write	
pat1:	move.l	3*4(a7),-plsiz(a1)	;plane3
	merge	d0,d2,d6,d7,$0F0F0F0F,4	
	merge	d1,d3,d6,d7,$0F0F0F0F,4

	exg.l	d0,a5
	exg.l	d1,a6	
	
	; write
pat2:	move.l	0*4(a7),-plsiz(a4)	;plane0
	merge	d4,d5,d6,d7,$00FF00FF,8
	merge	d0,d1,d6,d7,$00FF00FF,8
	
	; write	
	move.l	1*4(a7),(a4)+ ;plane1
	merge	d4,d0,d6,d7,$0F0F0F0F,4
	merge	d5,d1,d6,d7,$0F0F0F0F,4

	; write	
pat3:	move.l	6*4(a7),-plsiz(a3)	;bitplane6
	merge	d2,d0,d6,d7,$33333333,2
	merge	d3,d1,d6,d7,$33333333,2	

	; write
	move.l	7*4(a7),(a3)+		;bitplane7
	merge	d2,d3,d6,d7,$55555555,1
	merge	d0,d1,d6,d7,$55555555,1
	move.l	d3,2*4(a7)	;plane2
	move.l	d2,3*4(a7)	;plane3
	move.l	d1,0*4(a7)	;plane0
	move.l	d0,1*4(a7)	;plane1

	move.l	a5,d2
	move.l	a6,d3

	move.l	4*4(a7),(a1)+		;bitplane4	
	merge	d2,d4,d6,d7,$33333333,2
	merge	d3,d5,d6,d7,$33333333,2

pat4:	move.l	5*4(a7),-4+plsiz(a1)	;bitplane5
	merge	d2,d3,d6,d7,$55555555,1
	merge	d4,d5,d6,d7,$55555555,1
	move.l	d3,6*4(a7)		;bitplane6
	move.l	d2,7*4(a7)		;bitplane7
	move.l	d5,4*4(a7)		;bitplane4
	move.l	d4,5*4(a7)		;bitplane5

	cmpa.l	a0,a2
	bne.w	inner

pat5:	move.l	2*4(a7),plsiz(a4)	;plane2
pat6:	move.l	3*4(a7),-plsiz(a1)	;plane3
pat7:	move.l	0*4(a7),-plsiz(a4)	;plane0
	move.l	1*4(a7),(a4)+	 	;plane1
pat8:	move.l	6*4(a7),-plsiz(a3)	;bitplane6
	move.l	7*4(a7),(a3)+		;bitplane7
	move.l	4*4(a7),(a1)+		;bitplane4	
pat9:	move.l	5*4(a7),-4+1*plsiz(a1)	;bitplane5

exit
	move.l	stack,a7
	movem.l	(sp)+,d2-d7/a2-a6
	rts

;**************************************************************************

	cnop	0,4
end:
	ds.b	4096
p0	dc.l	0
p1	dc.l	0
p2	dc.l	0
p3	dc.l	0
p4	dc.l	0
p5	dc.l	0
p6	dc.l	0
p7	dc.l	0

;**************************************************************************

	END
	
