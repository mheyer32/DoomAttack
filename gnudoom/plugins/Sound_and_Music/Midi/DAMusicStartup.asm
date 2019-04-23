	xref		_DAM_Init
	xref		_DAM_InitMusic
	xref		_DAM_ShutdownMusic
	xref		_DAM_SetMusicVolume
	xref		_DAM_PauseSong
	xref		_DAM_StopSong
	xref		_DAM_ResumeSong
	xref		_DAM_RegisterSong
	xref		_DAM_PlaySong
	xref		_DAM_UnRegisterSong
	xref		_DAM_QrySongPlaying
	
	xref		_DAS_SetVol
	xref		_DAS_Start
	xref		_DAS_Update
	xref		_DAS_Stop
	xref		_DAS_Done
	
				section .text

	moveq		#-1,d0
	rts

	dc.b		'DAMS'			;(D)oom(A)ttack(M)u(s)ic
	
	dc.l		_DAM_Init
	dc.l		_DAM_InitMusic
	dc.l		_DAM_ShutdownMusic
	dc.l		_DAM_SetMusicVolume
	dc.l		_DAM_PauseSong
	dc.l		_DAM_ResumeSong
	dc.l		_DAM_StopSong
	dc.l		_DAM_RegisterSong
	dc.l		_DAM_PlaySong
	dc.l		_DAM_UnRegisterSong
	dc.l		_DAM_QrySongPlaying

	dc.l		0; _DAS_SetVol
	dc.l		0; _DAS_Start
	dc.l		0; _DAS_Update
	dc.l		0; _DAS_Stop
	dc.l		0; _DAS_Done
	
	blk.l		3,0
	
	
	END
	

