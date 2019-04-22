		INCDIR  AINCLUDE:
		INCLUDE c2p.i

**************************************************************************
*                                                                        *
* C2P Header                                                             *
*                                                                        *
**************************************************************************

		moveq		#-1,d0
		rts

		dc.b		'C2P',0				;Identifiy string
		dc.l		Chunky2Planar		;Chunky2Planar Routine
		dc.l		InitChunky			;Initialiazation
		dc.l		EndChunky			;Cleanup
		dc.l		0					;Flags

		
**************************************************************************
*                                                                        *
* Init routine: Set up everything and return TRUE (<> 0) if everything   *
*               is OK. Otherwise return FALSE 0.                         *
*                                                                        *
* Parameters:   4(sp) Width in Pixels                                    *
*               8(sp) Height in Pixels                                   *
*              12(sp) PlaneSize in Bytes                                 *
*              16(sp) Pointer to a C2PInit structure containing GfxBase  *
*                     and some more stuff                                *
*                                                                        *
**************************************************************************


	
InitChunky:
	moveq	#1,d0
	rts


	
**************************************************************************
*                                                                        *
* Cleanup routine: Is called when you quit DoomAttack. Cleanup every-    *
*                  thing.                                                *
*                                                                        *
* Parameters: <none>                                                     *
*                                                                        *
**************************************************************************

EndChunky:
	rts

**************************************************************************
*                                                                        *
* Chunky2Planar routine: Convert the chunky data to planar data          *
*                                                                        *
* Parameters: 4(sp) Pointer to the Chunky Buffer                         *
*             8(sp) Pointer to the Planes in CHIP RAM                    *
*                                                                        *
**************************************************************************


Chunky2Planar:
	move.l	4(sp),a0
	move.l	8(sp),a1
	
	movem.l	d2-d7/a2-a6,-(sp)
	
;	...
	
	movem.l	(sp)+,d2-d7/a2-a6
	rts
	
	END
	
