		XREF	_Graffiti_Init
		XREF	_Graffiti_SetPalette
		XREF	_Graffiti_GetInformation
		XREF	_Graffiti_Convert
		XREF	_Graffiti_Exit
		XREF	_modeid

		include "c2p.i"

		section .text
		
;**************************************************************************

		moveq	#-1,d0
		rts

		dc.b		'C2P',0

		dc.l		_Graffiti_Convert
		dc.l		InitChunky
		dc.l		_Graffiti_Exit

		dc.l		C2PF_GRAFFITI

		dc.l		_Graffiti_GetInformation
		dc.l		_Graffiti_SetPalette

;**************************************************************************
		
		;Init routine
		;4(sp) Width
		;8(sp) Height
		;12(sp) PlaneSize
		;16(sp) C2PInit 

	
InitChunky:
		move.l	16(sp),a0

		move.l	c2pi_GfxBase(a0),_GfxBase
		move.l	c2pi_IntuitionBase(a0),_IntuitionBase
		move.l	c2pi_DisplayID(a0),_modeid

		jmp		_Graffiti_Init

;**************************************************************************

		XDEF	_IntuitionBase
		XDEF	_GfxBase

_IntuitionBase:	dc.l	0
_GfxBase:			dc.l	0

	END

