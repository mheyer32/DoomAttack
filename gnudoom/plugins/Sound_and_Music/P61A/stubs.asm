
	XDEF _xP61_Init
	XDEF _xP61_Music
	XDEF _xP61_End
	
	XREF	_P61_Init
	XREF	_P61_Music
	XREF	_P61_End
	
	
_xP61_Init:
	movem.l	d2-d7/a2-a6,-(sp)
	lea		$dff000,a6
	jsr		P61_Init
	movem.l	(sp)+,d2-d7/a2-a6
	rts
	
_xP61_Music:
	movem.l	d2-d7/a2-a6,-(sp)
	lea		$dff000,a6
	jsr		P61_Music
	movem.l	(sp)+,d2-d7/a2-a6
	rts
	
_xP61_End:
	movem.l	d2-d7/a2-a6,-(sp)
	lea		$dff000,a6
	jsr		P61_End
	movem.l	(sp)+,d2-d7/a2-a6
	rts

	XDEF	_DAS_Start
	
_DAS_Start:
	rts
	
	XDEF	_DAS_Stop

_DAS_Stop:
	rts
	
	XDEF	_DAS_Done
	
_DAS_Done:
	rts
	
	XDEF	_DAS_Update
	
_DAS_Update:
	rts

	XDEF	_DAS_SetVol

_DAS_SetVol:
	rts

	END

