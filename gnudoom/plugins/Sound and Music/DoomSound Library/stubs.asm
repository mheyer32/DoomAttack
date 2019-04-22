SFX_SETVOL		= -30
SFX_START		= -36
SFX_UPDATE		= -42
SFX_STOP			= -48
SFX_DONE			= -54
MUS_SETVOL		= -60
MUS_REGISTER	= -66
MUS_UNREGISTER	= -72
MUS_PLAY			= -78
MUS_STOP			= -84
MUS_PAUSE		= -90
MUS_RESUME		= -96
MUS_DONE			= -102



;/*===================================================*/

	XDEF	_DAM_Init
	XREF	_C_DAM_Init

_DAM_Init:
	move.l	a0,-(sp)
	jsr		_C_DAM_Init
	addq.l	#4,sp
	rts
		
;/*===================================================*/

	XDEF	_DAM_SetMusicVolume

_DAM_SetMusicVolume:
	tst		_NoMusic(pc)
	bne.s		.done

	move.l	a6,-(sp)
	move.l	_DoomSoundBase(pc),a6

	lea		volumetab(pc),a0
	move.l	(a0,d0.w*4),d0
;	lsl		#3,d0
	jsr		MUS_SETVOL(a6)

	move.l	(sp)+,a6
.done:
	rts

;/*===================================================*/

	XDEF	_DAM_PauseSong
	
_DAM_PauseSong:
	tst		_NoMusic(pc)
	bne.s		.done
	
	move.l	a6,-(sp)
	move.l	_DoomSoundBase(pc),a6
	jsr		MUS_PAUSE(a6)
	move.l	(sp)+,a6
.done:
	rts

;/*===================================================*/

	XDEF	_DAM_ResumeSong
	
_DAM_ResumeSong:
	tst		_NoMusic(pc)
	bne.s		.done
	
	move.l	a6,-(sp)
	move.l	_DoomSoundBase(pc),a6
	jsr		MUS_RESUME(a6)
	move.l	(sp)+,a6
	
.done:
	rts

;/*===================================================*/

	XDEF	_DAM_StopSong
	
_DAM_StopSong:
	tst		_NoMusic(pc)
	bne.s		.done

	move.l	a6,-(sp)
	move.l	_DoomSoundBase(pc),a6
	jsr		MUS_STOP(a6)
	move.l	(sp)+,a6

.done:
	rts

;/*===================================================*/

	XDEF	_DAM_RegisterSong
	
_DAM_RegisterSong:
	tst		_NoMusic(pc)
	bne.s		.done
	
	move.l	a6,-(sp)
	move.l	_DoomSoundBase(pc),a6
	jsr		MUS_REGISTER(a6)
	move.l	(sp)+,a6

.done:
	rts
	

;/*===================================================*/

	XDEF	_DAM_PlaySong
	
_DAM_PlaySong:
	tst		_NoMusic(pc)
	bne.s		.done
	
	move.l	a6,-(sp)
	move.l	_DoomSoundBase(pc),a6
	jsr		MUS_PLAY(a6)
	move.l	(sp)+,a6
	
.done:
	rts
	

;/*===================================================*/

	XDEF	_DAM_UnRegisterSong
	
_DAM_UnRegisterSong:
	tst		_NoMusic(pc)
	bne.s		.done
	
	move.l	a6,-(sp)
	move.l	_DoomSoundBase(pc),a6
	jsr		MUS_UNREGISTER(a6)
	move.l	(sp)+,a6

.done:
	rts

;/*===================================================*/

	XDEF	_DAM_QrySongPlaying
	
_DAM_QrySongPlaying:
	tst		_NoMusic(pc)
	bne.s		.done
	
	move.l	a6,-(sp)
	move.l	_DoomSoundBase(pc),a6
	jsr		MUS_DONE(a6)
	move.l	(sp)+,a6
	
.done:
	rts
	
;/*===================================================*/

	XDEF	_DAS_SetVol
	
_DAS_SetVol:
	tst		_NoSound(pc)
	bne.s		.done
	
	move.l	a6,-(sp)
	move.l	_DoomSoundBase(pc),a6

;	lea		volumetab(pc),a0
;	move.l	(a0,d0.w*4),d0
	lsl		#3,d0
	jsr		SFX_SETVOL(a6)
	
	move.l	(sp)+,a6

.done:
	rts

;/*===================================================*/

	XDEF	_DAS_Start
	
_DAS_Start:
	tst		_NoSound(pc)
	bne.s		.done
	
	movem.l	d0/a6,-(sp)
	move.l	_DoomSoundBase(pc),a6

;	lea		volumetab(pc),a1
;	move.l	(a1,d2.w*4),d2
	lsl		#3,d2
	jsr		SFX_START(a6)
	movem.l	(sp)+,d0/a6

.done:
	rts

;/*===================================================*/

	XDEF	_DAS_Update
	
_DAS_Update:
	tst		_NoSound(pc)
	bne.s		.done
	
	move.l	a6,-(sp)
	move.l	_DoomSoundBase(pc),a6

;	lea		volumetab(pc),a1
;	move.l	(a1,d2.w*4),d2
	lsl		#3,d2
	jsr		SFX_UPDATE(a6)
	move.l	(sp)+,a6

.done:
	rts

;/*===================================================*/

	XDEF	_DAS_Stop
	
_DAS_Stop:
	tst		_NoSound(pc)
	bne.s		.done
	
	move.l	a6,-(sp)
	move.l	_DoomSoundBase(pc),a6

	jsr		SFX_STOP(a6)
	move.l	(sp)+,a6

.done:
	rts

;/*===================================================*/

	XDEF	_DAS_Done
	
_DAS_Done:
	tst		_NoSound(pc)
	bne.s		.done
	
	move.l	a6,-(sp)
	move.l	_DoomSoundBase(pc),a6
	jsr		SFX_DONE(a6)
	move.l	(sp)+,a6
	
.done:
	rts

;/*===================================================*/

	XDEF	_DoomSoundBase
	XDEF	_NoMusic
	XDEF	_NoSound

	CNOP	0,4

_DoomSoundBase:	dc.l	0
_NoMusic:			dc.w	0
_NoSound:			dc.w	0
	
volumetab:
	dc.l	0,5,10,15,20,24,28,32,36,40,44,48,52,56,60,64,64,64

	END

