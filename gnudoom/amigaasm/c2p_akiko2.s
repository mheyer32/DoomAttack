					MACHINE 68020

					INCDIR AINCLUDE:

					INCLUDE exec/libraries.i
					INCLUDE lvo/exec_lib.i
					INCLUDE c2p.i

;**************************************************************************

					MOVEQ	#-1,D0
                    RTS

                    DC.B           "C2P",0
                    DC.L           Chunky2Planar
                    DC.L           InitChunky
                    DC.L           EndChunky
                    DC.L		   C2PF_VARIABLEHEIGHT|C2PF_VARIABLEWIDTH

;**************************************************************************

					;Init routine
					;4(sp) Width
					;8(sp) Height
					;12(sp) PlaneSize
					;16(sp) C2PInit 

InitChunky:
					move.l	a6,-(sp)

					move.l	4+12(sp),d0
					move.l	d0,bitplanesize
					cmp.l	#32767,d0
					bgt.s	.badplanesize
					
					sub		#4,d0
					move	d0,patch1 + 2
					move	d0,patch2 + 2
					move	d0,patch3 + 2
					
					move.l	4.w,a6
					jsr		_LVOCacheClearU(a6)

					move.l	4+16(sp),a0
					move.l	c2pi_GfxBase(a0),a6
					
					cmp.w	#40,LIB_VERSION(a6)
					blt.s	.nogfx40
					
					move.l	508(a6),d0
					beq.s	.noakiko

					move.l	d0,C2Pp

					move.l	4+4(sp),d0
					move.l	4+8(sp),d1
					mulu	d0,d1
					lsr.l	#5,d1
					subq	#1,d1
					move	d1,size
					
					move.l	#1,rc

.badplanesize:
.noakiko:
.nogfx40:			move.l	(sp)+,a6

					move.l	rc(pc),d0
					rts

rc:					dc.l	0

;**************************************************************************

					;4(sp) chunky
					;8(sp) planes

Chunky2Planar:      MOVEA.L        $4(SP),A0
                    MOVEA.L        $8(SP),A1

					; a0 - chunky
					; a1 - bitplanes

                    MOVEM.L        D2-D7/A2-A6,-(SP)

					jsr		_chunky2planar


return:             MOVEM.L        (SP)+,D2-D7/A2-A6
                    RTS

                    NOP
EndChunky           RTS

	section	c2p,code

BPLSIZE equ 8000

_chunky2planar:		move.l	C2Pp(pc),a2
					move.w	size(pc),d7
					
					move.l	bitplanesize(pc),d1
											;a1 = plane1
					lea		(a1,d1.w),a3	;a3 = plane2
					lea		(a3,d1.w),a4	;a4 = plane3
					lea		(a4,d1.w*2),a5	;a5 = plane5
					lea		(a5,d1.w*2),a6	;a6 = plane7
					
c2pal:
					move.l	(a0)+,(A2)
					move.l	(a0)+,(A2)
					move.l	(a0)+,(A2)
					move.l	(a0)+,(A2)
					move.l	(a0)+,(A2)
					move.l	(a0)+,(A2)
					move.l	(a0)+,(A2)
					move.l	(a0)+,(A2)

					move.l	(a2),(a1)+				;plane1
					move.l	(a2),(a3)+				;plane2
					move.l	(a2),(a4)+				;plane3
patch1:				move.l	(a2),BPLSIZE(a4)		;plane4
					move.l	(a2),(a5)+				;plane5
patch2:				move.l	(a2),BPLSIZE(a5)		;plane6
					move.l	(a2),(a6)+				;plane7
patch3:				move.l	(a2),BPLSIZE(a6)		;plane8
					dbf	d7,c2pal
					rts

					cnop	0,4

C2Pp:				dc.l	0
bitplanesize:		dc.l	0
size:				dc.w	0
	