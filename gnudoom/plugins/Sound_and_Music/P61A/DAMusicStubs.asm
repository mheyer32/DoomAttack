	XDEF		_DAM_Init
	XDEF		_DAM_InitMusic
	XDEF		_DAM_ShutdownMusic
	XDEF		_DAM_SetMusicVolume
	XDEF		_DAM_PauseSong
	XDEF		_DAM_ResumeSong
	XDEF		_DAM_StopSong
	XDEF		_DAM_RegisterSong
	XDEF		_DAM_PlaySong
	XDEF		_DAM_UnRegisterSong
	XDEF		_DAM_QrySongPlaying
	
	XREF		_C_DAM_Init
	XREF		_C_DAM_InitMusic
	XREF		_C_DAM_ShutdownMusic
	XREF		_C_DAM_SetMusicVolume
	XREF		_C_DAM_PauseSong
	XREF		_C_DAM_ResumeSong
	XREF		_C_DAM_StopSong
	XREF		_C_DAM_RegisterSong
	XREF		_C_DAM_PlaySong
	XREF		_C_DAM_UnRegisterSong
	XREF		_C_DAM_QrySongPlaying

_DAM_Init:
	move.l	a0,-(sp)
	jsr		_C_DAM_Init
	addq.l	#4,sp
	rts
	
_DAM_InitMusic:
	jsr		_C_DAM_InitMusic
	rts
	
_DAM_ShutdownMusic:
	jsr		_C_DAM_ShutdownMusic
	rts
	
_DAM_SetMusicVolume:
	move.l	d0,-(sp)
	jsr		_C_DAM_SetMusicVolume
	addq.l	#4,sp
	rts
	
_DAM_PauseSong:
	move.l	d0,-(sp)
	jsr		_C_DAM_PauseSong
	addq.l	#4,sp
	rts
	
_DAM_ResumeSong:
	move.l	d0,-(sp)
	jsr		_C_DAM_ResumeSong
	addq.l	#4,sp
	rts
	
_DAM_StopSong:
	move.l	d0,-(sp)
	jsr		_C_DAM_StopSong
	addq.l	#4,sp
	rts
	
_DAM_RegisterSong:
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	jsr		_C_DAM_RegisterSong
	addq.l	#8,sp
	rts
	
_DAM_PlaySong:
	move.l	d1,-(sp)
	move.l	d0,-(sp)
	jsr		_C_DAM_PlaySong
	addq.l	#8,sp
	rts
	
_DAM_UnRegisterSong:
	move.l	d0,-(sp)
	jsr		_C_DAM_UnRegisterSong
	addq.l	#4,sp
	rts
	
_DAM_QrySongPlaying:
	move.l	d0,-(sp)
	jsr		_C_DAM_QrySongPlaying
	addq.l	#4,sp
	rts


	END
	

