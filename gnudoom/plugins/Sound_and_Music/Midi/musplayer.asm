		machine 68020
		
		incdir AINCLUDE:

		include exec/io.i
		include exec/memory.i
		include dos/dos.i
		include devices/audio.i
		include hardware/custom.i
		include hardware/cia.i
		include hardware/intbits.i
		include lvo/exec_lib.i
		include lvo/dos_lib.i
		
		xref	_SysBase
		xref	_DOSBase
		xref	_GfxBase

		xref	_snd_MusicVolume
		xref	_gametic
		xref	_I_Error

		xdef	_AudioTask
		xdef	_AudioIO
		xdef	_AudioCh
		xdef	_per
		xdef	_per2
		xdef	_AudioCh2Vol
		xdef	_AudioCh3Vol
		xdef	_AudioOK

		xdef	_Midi_StopSong
		xdef	_Midi_PauseSong
		xdef	_Midi_ResumeSong
		xdef	_Midi_RegisterSong
		xdef	_Midi_UnRegisterSong
		xdef	_Midi_PlaySong
		xdef	_Midi_FreeChannels
		xdef	_Midi_AllocChannels

		section .text
;------------------------------------------------------------------------

CHANNEL1 = aud0
CHANNEL2 = aud1
CHANNEL1BIT = 0
CHANNEL2BIT = 1

CHANNEL1MASK = 1<<CHANNEL1BIT
CHANNEL2MASK = 1<<CHANNEL2BIT
CHANNELMASK = CHANNEL1MASK + CHANNEL2MASK

AUDIOINTERRUPT = INTB_AUD0

INTMASK1 = 1 << (7 + CHANNEL1BIT)
INTMASK2 = 1 << (7 + CHANNEL2BIT)
INTMASK = INTMASK1 + INTMASK2

_custom = $DFF000

;------------------------------------------------------------------------

TICRATE		equ	35			; see doomdef.h

CALLSYS		macro	;FunctionName
		jsr	_LVO\1(a6)
		endm

CALLEXE		macro	;FunctionName
		movea.l	(_SysBase),a6
		jsr	_LVO\1(a6)
		endm

CALLDOS		macro	;FunctionName
		movea.l	(_DOSBase),a6
		jsr	_LVO\1(a6)
		endm

;------------------------------------------------------------------------
; void I_PauseSong (int handle);	// PAUSE game handling.
; Do code equiv to DoPause.

_Midi_PauseSong:
		movem.l	d0-d7/a0-a6,-(sp)
		tst.b		_AudioOK
		beq		.done

		btst		#1,Flags		; file loaded?
		beq.b		.done
		bset		#0,MusFlag		; stop
		bclr		#2,Flags		; playing?
		beq.b		.done
.stop:
		btst		#0,MusFlag		; music stopped?
		bne.b		.stop

		cmpi.b	#CHANNELMASK,_AudioCh		; locked?
		bne.b		.done
		lea		_custom,a0		; kill sound
		moveq		#0,d0
		move.w	d0,CHANNEL1+ac_vol(a0)
		move.w	d0,CHANNEL2+ac_vol(a0)

.done:
		movem.l	(sp)+,d0-d7/a0-a6
		rts

;------------------------------------------------------------------------
; void I_ResumeSong (int handle);
; Goes to J_PlayBox equiv code.

_Midi_ResumeSong:
		movem.l	d0-d7/a0-a6,-(sp)
		tst.b		_AudioOK
		beq		.exit

		btst		#1,Flags		; file loaded?
;		beq.b		.nofile
		beq.b		.exit

;		cmpi.b	#CHANNELMASK,_AudioCh		; got all channels?
;		beq.b		.allch
;		bsr		AllocChannels		; try to alloc, first
;		cmpi.b	#CHANNELMASK,_AudioCh		; now?
;		beq.b		.allch

;		move.l	#cantgetchan,-(sp)
;		jsr		_I_Error
;		bra		.exit
;
;.allch:
;		bset		#2,Flags		; playing?
;		beq.b		.ok
;.nofile:
;		rts
;
.ok:
		movea.l	MusPtr,a0
		moveq		#0,d1
		move.b	8(a0),d1		; d1 = # of channels

		moveq		#0,d0
		move.w	6(a0),d0		; score start
		ror.w		#8,d0
		adda.l	d0,a0			; a0 = start
		bclr		#3,Flags		; paused?
		bne		.paused

		move.l	a0,MusIndex		; MusIndex = start

		move.l	#QuietInst,Channel0
		move.l	#QuietInst,Channel1
		move.l	#QuietInst,Channel2
		move.l	#QuietInst,Channel3
		move.l	#QuietInst,Channel4
		move.l	#QuietInst,Channel5
		move.l	#QuietInst,Channel6
		move.l	#QuietInst,Channel7
		move.l	#QuietInst,Channel8
		move.l	#QuietInst,Channel9
		move.l	#QuietInst,Channel10
		move.l	#QuietInst,Channel11
		move.l	#QuietInst,Channel12
		move.l	#QuietInst,Channel13
		move.l	#QuietInst,Channel14
		move.l	#QuietInst,Channel15

		clr.l		MusDelay		; MusDelay = 0
		clr.b		MusFlag			; enable music
		clr.l		VoiceAvail		; all voices available

		clr.l		MyTicks			; reset my timer

.paused
		CALLEXE	Disable
		lea		_custom,a0
		move.w	#$8000+INTMASK1,intena(a0)	; int enable
		move.w	#$8000+CHANNELMASK,dmacon(a0)	; enable dma
		bsr		AudioINT2		; start audio
		CALLSYS	Enable

.exit	movem.l	(sp)+,d0-d7/a0-a6
		rts

;------------------------------------------------------------------------
; int I_RegisterSong (void *data);	// Registers a song handle to song data.
; Do code equiv to LoadMUS; no need to actually load it
; as we are passed a pointer to it here.

_Midi_RegisterSong:
		movem.l	d0-d7/a0-a6,-(sp)
		tst.b		_AudioOK
		beq		.done2

		move.l	a0,-(sp)		; save data ptr

		bsr		_Midi_StopSong			; stop current mus
		bsr		_Midi_UnRegisterSong	; kill old mus

		movea.l	(sp)+,a0

		move.l	a0,MUSMemPtr

		cmpi.l	#$4D55531A,(a0)		; "MUS",26
		bne		.uerror			; not a mus file

		move.l	MUSMemPtr(pc),MusPtr

		bsr		TestMUSFile
		beq		.berror

;--------

		move.l	InstrFile,d1
		move.l	#MODE_OLDFILE,d2
		CALLDOS	Open
		move.l	d0,InstrHandle
		beq		.midierror

		move.l	#MEMF_CLEAR,d0		; any memory
		move.l	#65536,d1		; puddle size
		move.l	#32768,d2		; threshold size
		bsr		CreatePool
		move.l	a0,InstrPool		; this was d0
		beq		.merror

		movea.l	a0,a2			; so was this
		movea.l	MusPtr,a3

		move.w	#255,d0
		lea		Instruments,a0

.setinstr
		move.l	#QuietInst,(a0)+
		dbra		d0,.setinstr

		move.w	$C(a3),d4		; instrCnt
		ror.w		#8,d4
		subq.w	#1,d4			; for dbra

		lea		$10(a3),a3		; instruments[]

.instrloop
		moveq		#14,d0
		movea.l	a2,a0
		bsr		AllocPooled

		moveq		#0,d2
		move.b	(a3)+,d2		; instrument #
		moveq		#0,d1
		move.b	(a3)+,d1		; offset to next instr. #
		adda.l	d1,a3			; skip it (whatever it is?)

		lea		Instruments,a0
		move.l	d0,(a0,d2.w*4)
		beq		.merror

		movea.l	d0,a4			; instrument record

		bftst		(validInstr){d2:1}
		beq		.next			; no instrument

		move.l	InstrHandle,d1
		lsl.l		#2,d2
		moveq		#OFFSET_BEGINNING,d3
		CALLDOS	Seek

		move.l	InstrHandle,d1
		move.l	a4,d2
		moveq		#4,d3
		CALLSYS	Read			; get instrument offset
		addq.l	#1,d0
		beq		.ferror			; can't read file

		move.l	InstrHandle,d1
		move.l	(a4),d2
		moveq		#OFFSET_BEGINNING,d3
		CALLSYS	Seek

		move.l	InstrHandle,d1
		move.l	a4,d2
		moveq		#14,d3
		CALLSYS	Read			; get instrument header
		addq.l	#1,d0
		beq		.ferror			; can't read file

		move.l	in_Length(a4),d0
		swap		d0
		movea.l	a2,a0
		bsr		AllocPooled
		move.l	d0,in_Wave(a4)		; wave data buffer
		beq		.merror

		move.l	InstrHandle,d1
		move.l	d0,d2
		move.l	in_Length(a4),d3
		swap		d3
		CALLDOS	Read			; get instrument samples
		addq.l	#1,d0
		beq		.ferror			; can't read file

		move.b	#1,in_Flags(a4)
.next
		dbra	d4,.instrloop

		bset		#1,Flags		; file loaded
		bsr		FillEventBlocks

.done
		btst		#1,Flags		; success?
		bne.b		.exit
		bsr		_Midi_UnRegisterSong	; kill MUS and instruments

.exit
		move.l	InstrHandle,d1
		beq.b		.done2
		CALLDOS	Close
		clr.l		InstrHandle

.done2
		moveq		#1,d0			; return handle=1
		movem.l	(sp)+,d0-d7/a0-a6
		rts

;---------

.midierror	move.l	#midifileproblem,-(sp)
		move.l	_I_Error,a0
		jsr	(a0)
		bra	.done

.ferror		move.l	#dosproblem,-(sp)
		move.l	_I_Error,a0
		jsr	(a0)
		bra	.done

.merror		move.l	#memproblem,-(sp)
		move.l	_I_Error,a0
		jsr	(a0)
		bra	.done

.uerror		move.l	#notmusfile,-(sp)
		move.l	_I_Error,a0
		jsr	(a0)
		bra	.done

.berror		move.l	#damagedfile,-(sp)
		move.l	_I_Error,a0
		jsr	(a0)
		bra	.done

;------------------------------------------------------------------------
;// Called by anything that wishes to start music.
;//  plays a song, and when the song is done,
;//  starts playing it again in an endless loop.
;// Horrible thing to do, considering.
; void I_PlaySong (int handle, int looping);
; Do code equiv to J_PlayBox.

_Midi_PlaySong
		movem.l	d0-d7/a0-a6,-(sp)
		tst.b		_AudioOK
		beq		.exit

		move.l	#TICRATE*30,d0
		move.l	_gametic,a0
		add.l		(a0),d0
		move.l	d0,(musicdies)

		bsr		_Midi_ResumeSong

.exit
		movem.l	(sp)+,d0-d7/a0-a6
		rts

;------------------------------------------------------------------------
; void I_StopSong (int handle);		// Stops a song over 3 seconds.
; Do code equiv to J_StopBox.

_Midi_StopSong
		movem.l	d0-d7/a0-a6,-(sp)

		move.l	#0,(looping)
		move.l	#0,(musicdies)

		tst.b		_AudioOK
		beq		.exit

		bsr		_Midi_PauseSong
		bsr		KillAllAud

.exit
		movem.l	(sp)+,d0-d7/a0-a6
		rts

;------------------------------------------------------------------------
; void I_SysBase (int handle);	// See above (register), then think backwards
; Do code equiv to FreeUpMUS.

_Midi_UnRegisterSong
		movem.l	d0-d7/a0-a6,-(sp)

		tst.b		_AudioOK
		beq		.free

		bclr		#1,Flags		; still have anything?
		beq.b		.free

		clr.l		MUSMemPtr
		clr.l		MUSMemSize

.instr
		tst.l		InstrPool
		beq.b		.free

		movea.l	InstrPool,a0
		bsr		DeletePool
		clr.l		InstrPool

.free	
		movem.l	(sp)+,d0-d7/a0-a6
		rts

;------------------------------------------------------------------------
;------------------------------------------------------------------------

FillEventBlocks
		lea		EventBlocks,a4
		movea.l	MusPtr(pc),a0
		move.w	6(a0),d0
		ror.w		#8,d0
		lea		(a0,d0.w),a2		; a2 = start
		movea.l		a2,a1			; a1 = a2
.loop
		bsr		NextDelay
		move.l	a1,d0
		sub.l		a2,d0			; d0 = ptr - start
		move.w	d0,(a4)+		; store
		addq.l	#1,d1
		bne.b		.loop
		clr.w		(a4)			; end of offsets
		rts

NextDelay
		bsr.b		MyNextEvent
		cmpi.b	#6,d1			; score end
		beq.b		.dd
		tst.b		d0
		bpl.b		NextDelay

		moveq		#0,d1			; time = 0
.d1
		move.b	(a1)+,d0		; get byte
		bpl.b		.d2
		andi.w	#$7F,d0			; kill sign bit
		or.b		d0,d1			; time = time + 7 bits
		lsl.l		#7,d1			; * 128
		bra.b		.d1			; get next 7 bits
.d2
		or.b		d0,d1			; time = time + last 7 bits
		rts

.dd
		moveq		#-1,d1
		rts

MyNextEvent
		move.b	(a1)+,d0		; d0 = event
		moveq		#$70,d1
		and.b		d0,d1			; d1 = type<<4
		bne.b		.e1

.e0
		addq.l	#1,a1			; + value
		rts

.e1
		lsr.b		#4,d1			; d1 = type
		cmpi.b	#6,d1			; score end?
		bne.b		.e2
		subq.l	#1,a1
.ed
		rts
.e2
		cmpi.b	#5,d1			; no event
		beq.b		.ed
		cmpi.b	#7,d1			; no event
		beq.b		.ed
		cmpi.b	#1,d1			; play
		beq.b		.ep
		cmpi.b	#4,d1			; change?
		bne.b		.e0
		addq.l	#2,a1			; + value1, value2
		rts

.ep
		moveq		#0,d4
		tst.b		(a1)+			; + note
		bmi.b		.e0			; (+ volume, if b7 set)
		rts

		moveq		#1,d0
		rts

;------------------------------------------------------------------------

TestMUSFile
		movea.l	MusPtr(pc),a0
		move.l	MUSMemSize(pc),d3	; d3 = total file size
		moveq		#0,d0
		move.w	4(a0),d0
		beq		.fail
		ror.w		#8,d0			; score length
		moveq		#0,d1
		move.w	6(a0),d1
		ror.w		#8,d1			; score start
		cmpi.w	#18,d1			; start < 18? (1 instr.)
		blt		.fail
		add.l		d1,d0			; d0 = total size

;		cmp.l		d0,d3			; = file size?
;		bne		.fail

		move.l	d0,d3
		move.l	d3,MUSMemSize

		move.w	12(a0),d2
		beq.b		.fail
		ror.w		#8,d2			; d2 = instr. count
		subq.w	#1,d2
		lea		16(a0),a1		; a1 = * instr. list

.loop
		addq.l	#1,a1			; skip instr. value
		moveq		#0,d0
		move.b	(a1)+,d0		; d0 = offset to next instr.
		adda.l	d0,a1			; skip info (?)
		dbra		d2,.loop		; next
		move.l	a1,d0			; d0 = * data following list
		sub.l		a0,d0			; - file start
		cmp.l		d0,d1			; = start?
		bne.b		.fail
		move.b	-1(a0,d3.l),d0		; get last byte
		lsr.b		#4,d0
		cmpi.b	#6,d0			; last byte = $6x? (end)
		bne.b		.fail
		moveq		#1,d0			; file okay
		rts

.fail
		moveq		#0,d0			; yikes!
		rts

;------------------------------------------------------------------------
;------------------------------------------------------------------------

; stop, clear, turn off

KillAllAud
		cmpi.b	#CHANNELMASK,_AudioCh		; locked?
		bne.b	.vk

		lea		_custom,a0
		move.l	#ClearBuf,CHANNEL1(a0)	; re-init
		move.w	#80,CHANNEL1+ac_len(a0)
		move.w	(_per,pc),CHANNEL1+ac_per(a0)
		move.l	#ClearBuf,CHANNEL2(a0)
		move.w	#80,CHANNEL2+ac_len(a0)
		move.w	(_per,pc),CHANNEL2+ac_per(a0)

.vk
		clr.b		Voice0+vc_Flags		; disable voices
		clr.b		Voice1+vc_Flags
		clr.b		Voice2+vc_Flags
		clr.b		Voice3+vc_Flags
		clr.b		Voice4+vc_Flags
		clr.b		Voice5+vc_Flags
		clr.b		Voice6+vc_Flags
		clr.b		Voice7+vc_Flags
		clr.b		Voice8+vc_Flags
		clr.b		Voice9+vc_Flags
		clr.b		Voice10+vc_Flags
		clr.b		Voice11+vc_Flags
		clr.b		Voice12+vc_Flags
		clr.b		Voice13+vc_Flags
		clr.b		Voice14+vc_Flags
		clr.b		Voice15+vc_Flags

		rts

;------------------------------------------------------------------------
;------------------------------------------------------------------------

_Midi_AllocChannels:
		move.l	a6,-(sp)
		move.l	_SysBase,a6

		lea		_AudioIO,a1
		move.w	#ADCMD_ALLOCATE,IO_COMMAND(a1)
		move.b	#ADIOF_NOWAIT+IOF_QUICK,IO_FLAGS(a1)
		move.l	#AudioAlloc,ioa_Data(a1)
		move.l	#1,ioa_Length(a1)
		movea.l	IO_DEVICE(a1),a6
		jsr		DEV_BEGINIO(a6)
		tst.l		d0
		beq		.ok

		moveq		#0,d0
		bra.s		.exit

.ok:
		lea		_AudioIO,a1
		move.w	#ADCMD_LOCK,IO_COMMAND(a1)
		CALLEXE	SendIO

		move.l	_AudioIO+IO_UNIT,d0
		move.b	d0,_AudioCh
		cmpi.b	#CHANNELMASK,d0			; all channels?
		beq		.ok2

		moveq		#0,d0
		bra.s		.exit

.ok2:
		lea		_custom,a0
		move.w	#INTMASK,intena(a0)	; kill int enable
		move.w	#INTMASK,intreq(a0)	; kill request
		move.w	#CHANNELMASK*$11,adkcon(a0)	; kill modulation
		move.w	#CHANNELMASK,dmacon(a0)	; disable dma

		move.l	#ClearBuf,CHANNEL1(a0)
		move.w	#80,CHANNEL1+ac_len(a0)
		move.w	(_per,pc),CHANNEL1+ac_per(a0)
		move.w	#0,CHANNEL1+ac_vol(a0)

		move.l	#ClearBuf,CHANNEL2(a0)
		move.w	#80,CHANNEL2+ac_len(a0)
		move.w	(_per,pc),CHANNEL2+ac_per(a0)
		move.w	#0,CHANNEL2+ac_vol(a0)

		moveq		#AUDIOINTERRUPT,d0
		lea		AInt2,a1
		CALLEXE	SetIntVector
		move.l	d0,OldAInt2

		moveq		#1,d0

.exit
		move.l	(sp)+,a6
		rts

;------------------------------------------------------------------------

_Midi_FreeChannels:
		move.l	a6,-(sp)
		move.l	_SysBase,a6

		cmpi.b	#CHANNELMASK,_AudioCh
		bne.b		.exit			; no channels

		lea		_custom,a0
		move.w	#INTMASK,intena(a0)	; kill int enable
		move.w	#INTMASK,intreq(a0)	; kill request

		moveq		#AUDIOINTERRUPT,d0
		movea.l	OldAInt2,a1
		CALLEXE	SetIntVector

		moveq		#CHANNELMASK,d0
		move.w	d0,_custom+dmacon	; dma off
		lea		_AudioIO,a1
		move.w	#ADCMD_FREE,IO_COMMAND(a1)
		move.b	#IOF_QUICK,IO_FLAGS(a1)
		movea.l	IO_DEVICE(a1),a6
		jsr		DEV_BEGINIO(a6)
		clr.l		_AudioIO+IO_UNIT
		clr.b		_AudioCh

.exit:
		move.l	(sp)+,a6
		rts


;--------------------------------------------------------------------

		cnop	0,16

AudioINT2
		movem.l	d2-d6/a2-a4/a6,-(a7)
		btst		#0,MusFlag
		beq.b		.cont

		lea		_custom,a0
		move.w	#INTMASK,intena(a0)	; kill int enable
		move.w	#INTMASK,intreq(a0)	; kill request

		clr.b		MusFlag
		bra		.exit

.cont
		subq.l	#1,MusDelay
		bpl.b		.setaudio

		bsr		NextEvent

.setaudio
		bchg		#1,MusFlag		; switch buffers

		btst		#6,Flags		; gadget down?
		bne.b		.gad
		addq.l	#1,MyTicks		; increment my timer

.gad
		lea		Voice0,a0		; music voices
		lea		_AudioCh2Buf,a2
		bsr		FillBuffer

		lea		_custom,a0
		move.w	#INTMASK1,intreq(a0)

		move.l	_AudioCh2Ptr,CHANNEL1(a0)
		move.w	#40,CHANNEL1+ac_len(a0)		; 80 samples
		move.w	(_per2,pc),CHANNEL1+ac_per(a0)	; 11048Hz
		move.w	_AudioCh2Vol,CHANNEL1+ac_vol(a0)

		move.l	_AudioCh2Ptr,CHANNEL2(a0)
		move.w	#40,CHANNEL2+ac_len(a0)		; 80 samples
		move.w	(_per2,pc),CHANNEL2+ac_per(a0)	; 11048Hz
		move.w	_AudioCh2Vol,CHANNEL2+ac_vol(a0)

.exit
		movem.l	(a7)+,d2-d6/a2-a4/a6
		moveq		#0,d0
		rts

;------------------------------------------------------------------------

		CNOP	0,16

FillBuffer
		moveq		#0,d0
		btst		#1,MusFlag
		beq.b		.swap
		move.l	#80,d0
		
.swap
		movea.l	(a2),a4			; chip buffer
		adda.l	d0,a4
		move.l	a4,4(a2)		; AudioChxPtr

		lea		tempAudio,a1
		moveq		#4,d0

.cloop
		clr.l		(a1)+
		clr.l		(a1)+
		clr.l		(a1)+
		clr.l		(a1)+
		dbra		d0,.cloop

.next
		move.l	vc_Next(a0),d0		; next voice
		bne.b		.chkvoice

		lea		tempAudio,a1
		moveq		#4,d0

.mloop
		move.l	(a1)+,(a4)+
		move.l	(a1)+,(a4)+
		move.l	(a1)+,(a4)+
		move.l	(a1)+,(a4)+
		dbra		d0,.mloop
		rts

.chkvoice
		movea.l	d0,a0
		btst		#0,vc_Flags(a0)
		beq.b		.next			; not enabled


;------------------
; do voice

		lea		tempAudio,a1

		btst		#1,vc_Flags(a0)
		beq.b		.1			; not releasing

		subq.b	#1,vc_Vol(a0)
		bpl.b		.1
		clr.b		vc_Vol(a0)
		clr.b		vc_Flags(a0)		; voice off
		bra.b		.next

.1
		move.b	vc_Vol(a0),d5
		bfffo		d5{24:8},d5		; 0-127 -> 32-24
		subi.b	#24,d5			;          8-0
		addq.b	#2,d5			; /4

		movem.l	vc_Index(a0),d1-d4	; index,step,loop,length

		movea.l	vc_Channel(a0),a3
		move.l	ch_Pitch(a3),d0
		muls.l	d0,d6:d2
		move.w	d6,d2
		swap		d2
		add.l		vc_Step(a0),d2		; final sample rate

		movea.l	vc_Wave(a0),a3		; sample data

		moveq		#79,d6			; 80 samples

.floop
		moveq		#0,d0
		swap		d1
		move.b	(a3,d1.w),d0		; sample
		swap		d1
		asr.b		d5,d0
		add.b		d0,(a1)+

		add.l		d2,d1
		cmp.l		d4,d1
		blo.b		.2
		sub.l		d4,d1
		add.l		d3,d1
		tst.l		d3
		beq.b		.3			; no looping

.2
		dbra		d6,.floop
		bra.b		.done			; done with voice 1

; ran out of data
.3
		clr.b	vc_Flags(a0)		; voice off

.done
		move.l	d1,vc_Index(a0)
		bra		.next

;------------------------------------------------------------------------

		CNOP	0,16

NextEvent
		movea.l	MusIndex,a1

.0
		move.b	(a1)+,d0		; get next event
		move.b	d0,d1
		lsr.b		#3,d1
		andi.w	#$E,d1			; d1 = event type * 2
		lea		EventTable,a0
		move.w	(a0,d1.w),d1
		jsr		(a0,d1.w)		; do event
		tst.b		d0
		bpl.b		.0			; more events

		moveq		#0,d1			; time = 0
.1
		move.b	(a1)+,d0		; get byte
		bpl.b		.2

		andi.w	#$7F,d0			; kill sign bit
		or.b		d0,d1			; time = time + 7 bits
		lsl.l		#7,d1			; * 128
		bra.b		.1			; get next 7 bits

.2
		or.b		d0,d1			; time = time + last 7 bits
		subq.l	#1,d1			; delay = time - 1
		bmi.b		.0			; (no delay)

		btst		#6,Flags		; gadget down?
		beq.b		.nogad
		btst		#7,Flags
		beq.b		.rev
		add.l		d1,MyTicks		; add to my timer
		addq.l	#1,MyTicks		; + 1
		lsr.l		#3,d1			; delay = delay / 8
		bra.b		.nogad

.rev
		bsr.b		PrevBlock

.nogad
		move.l	d1,MusDelay		; store delay
		move.l	a1,MusIndex		; store index
		rts

PrevBlock
		move.l	PrevDelay,d0
		sub.l		d0,MyTicks		; sub previous value
		addq.l	#1,d1
		move.l	d1,PrevDelay
		move.l	a1,d1			; d1 = current ptr
		movea.l	MusPtr(pc),a0
		move.w	6(a0),d0
		ror.w		#8,d0
		lea		(a0,d0.w),a0		; a0 = start
		cmp.l		a0,d1			; at start?
		beq.b		.done
		lea		EventBlocks,a1

.loop
		moveq		#0,d0
		move.w	(a1)+,d0		; offset
		beq.b		.done			; (not found)
		add.l		a0,d0			; ptr
		cmp.l		d1,d0			; = current?
		bne.b		.loop
		subq.l	#4,a1
		cmpa.l	#EventBlocks,a1		; 2nd block?
		bls.b		.done
		moveq		#0,d0
		move.w	-(a1),d0		; offset prev block
		add.l		a0,d0
		movea.l	d0,a1			; ptr = prev block
		moveq		#0,d1			; delay = 0
		rts

.done
		movea.l	a0,a1			; ptr = start
		moveq		#0,d1			; delay = 0
		clr.l		MyTicks			; reset timer
		rts

;------------------------------------------------------------------------

Release
		moveq		#15,d1
		and.b		d0,d1			; d1 = channel

		lea		Channels,a0
		movea.l	(a0,d1.w*4),a0		; channel record
		movea.l	ch_Map(a0),a0		; channel map

		move.b	(a1)+,d1		; note #
		moveq		#0,d2
		move.b	(a0,d1.w),d2		; voice #
		beq.b		.exit			; no mapping

		clr.b		(a0,d1.w)		; clear mapping
		move.l	VoiceAvail,d3
		bclr		d2,d3			; voice free for use
		move.l	d3,VoiceAvail

		lea		Voices,a0
		movea.l	(a0,d2.w*4),a0		; voice
		bset		#1,vc_Flags(a0)		; do release

.exit
		rts

;------------------------------------------------------------------------

PlayNote
		moveq		#15,d1
		and.b		d0,d1			; d1 = channel

		lea		Channels,a0
		movea.l	(a0,d1.w*4),a2		; channel record
		movea.l	ch_Map(a2),a0		; channel map

		moveq		#-1,d2			; no volume change
		move.b	(a1)+,d1		; note #
		bclr		#7,d1
		beq.b		.getvc			; no volume

		moveq		#0,d2
		move.b	(a1)+,d2		; volume

.getvc
		moveq		#0,d3
		move.l	VoiceAvail,d4

.vloop
		bset		d3,d4
		beq.b		.foundfree
		addq.b	#1,d3
		cmpi.b	#16,d3
		bne.b		.vloop
; no free voices
		rts


.foundfree
		move.b	d3,(a0,d1.w)		; voice mapping
		move.l	d4,VoiceAvail

		lea		Voices,a0
		movea.l	(a0,d3.w*4),a3		; voice
		btst		#7,vc_Flags(a3)
		bne.b		.exit			; sfx using channel

		tst.b		d2
		bmi.b		.skip
		move.b	d2,ch_Vol(a2)		; new channel volume
.skip
		move.b	ch_Vol(a2),vc_Vol(a3)

		moveq		#15,d2
		and.b		d0,d2
		cmpi.b	#15,d2
		beq.b		.percussion

		move.l	ch_Instr(a2),a4		; instrument record

		lea		NoteTable,a0
		moveq		#72,d2			; middle c
		sub.b		in_Base(a4),d2
		add.b		d1,d2
		move.l	(a0,d2.w*4),vc_Step(a3)	; step value for note

		clr.l		vc_Index(a3)

		move.l	a2,vc_Channel(a3)	; back link (for pitch wheel)

		move.l	in_Wave(a4),vc_Wave(a3)
		move.l	in_Loop(a4),vc_Loop(a3)
		move.l	in_Length(a4),vc_Length(a3)
		move.b	in_Flags(a4),vc_Flags(a3)

.exit
		rts

; for the percussion channel, the note played sets the percussion instrument

.percussion
		move.l	#65536,vc_Step(a3)	; sample rate always 1.0

		clr.l		vc_Index(a3)

		move.l	a2,vc_Channel(a3)	; back link

		addi.b	#100,d1			; percussion instruments

		lea		Instruments,a0
		move.l	(a0,d1.w*4),a0		; instrument record
		move.l	in_Wave(a0),vc_Wave(a3)
		move.l	in_Loop(a0),vc_Loop(a3)
		move.l	in_Length(a0),vc_Length(a3)
		move.b	in_Flags(a0),vc_Flags(a3)
		rts

;------------------------------------------------------------------------

Pitch
		moveq		#15,d1
		and.b		d0,d1			; d1 = channel

		lea		Channels,a0
		movea.l	(a0,d1.w*4),a2		; channel record

		moveq		#0,d1
		move.b	(a1)+,d1		; pitch wheel setting
		lea		PitchTable,a0
		move.l	(a0,d1.w*4),ch_Pitch(a2)
		rts

;------------------------------------------------------------------------

Tempo
		addq.l	#1,a1			; skip value
		rts

;------------------------------------------------------------------------

ChangeCtrl
		moveq		#15,d1
		and.b		d0,d1			; d1 = channel

		lea		Channels,a0
		movea.l	(a0,d1.w*4),a2		; channel

		move.b	(a1)+,d1		; get controller

		moveq		#0,d2
		move.b	(a1)+,d2		; value

		tst.b		d1
		bne.b		.1

; set channel instrument

		lea		Instruments,a0
		move.l	(a0,d2.w*4),ch_Instr(a2)
		bne.b		.0
		move.l	#QuietInst,ch_Instr(a2)
.0		rts

.1		cmpi.b	#3,d1			; volume?
		bne.b	.2

; set channel volume

		move.b	d2,ch_Vol(a2)
		rts

.2		cmpi.b	#4,d1			; pan?
		bne.b		.exit

; set channel pan

		move.b	d2,ch_Pan(a2)
.exit
		rts

;------------------------------------------------------------------------

NoEvent		rts

;------------------------------------------------------------------------

EndScore
		btst		#4,Flags		; loop?
		beq.b		.loop

		lea		_custom,a0
		move.w	#INTMASK,intena(a0)	; kill int enable
		move.w	#INTMASK,intreq(a0)	; kill request
		clr.b		MusFlag			; clear mus flag
		bclr		#2,Flags		; kill playing flag
		moveq		#0,d0
		move.w	d0,CHANNEL1+ac_vol(a0)	; kill old audio
		move.w	d0,CHANNEL2+ac_vol(a0)
		bsr		KillAllAud
		addq.l	#8,a7			; pop NextEvent, AudioInt
		movem.l	(a7)+,d2-d6/a2-a4/a6	; return from interrupt
		moveq		#0,d0
		rts

.loop
		movea.l	MusPtr,a1
		moveq		#0,d1
		move.w	6(a1),d1		; score start
		ror.w		#8,d1
		adda.l	d1,a1			; a1 = start

		clr.l		MyTicks			; reset my timer
		rts

;------------------------------------------------------------------------
;--------------------------------------------------------------------

		cnop	0,4

CreatePool
		movea.l	_SysBase,a1
		cmpi.w	#39,LIB_VERSION(a1)
		blt.b		.nopools		; change to bra for debugging

		move.l	a6,-(sp)
		movea.l	a1,a6
		CALLSYS	CreatePool
		movea.l	(sp)+,a6
		rts

.nopools
		movem.l	d2-d7/a2-a6,-(sp)
		move.l	d0,d4			; memory attributes
		move.l	d1,d3			; amount to allocate when low
		move.l	d2,d5			; size of when not to use pool

		exg.l		d0,d1			; swap flags and size
		movea.l	a1,a6
		CALLSYS	AllocMem		; get first block
		movea.l	d0,a0
		tst.l		d0
		beq.b		.exit			; no memory!

		movem.l	d3-d5,(a0)		; puddleSize, Flags,Threshold
		clr.l		12(a0)			; no next block
		lea		24(a0),a1		; first free location here
		move.l	a1,16(a0)
		subi.l	#24,d3			; for header info
		move.l	d3,20(a0)		; amount free in this block

.exit
		movem.l	(sp)+,d2-d7/a2-a6
		rts

		cnop	0,4

DeletePool
		movea.l	_SysBase,a1
		cmpi.w	#39,LIB_VERSION(a1)
		blt.b		.nopools		; change to bra for debugging

		move.l	a6,-(sp)
		movea.l	a1,a6
		CALLSYS	DeletePool
		movea.l	(sp)+,a6
		rts

.nopools
		movem.l	d2-d7/a2-a6,-(sp)
		move.l	a0,d2			; first block
		beq.b		.exit			; safety check

		movea.l	a1,a6

.loop
		movea.l	d2,a1			; pointer to block
		move.l	(a1),d0			; size of block
		move.l	12(a1),d2		; next block
		CALLSYS	FreeMem
		tst.l		d2
		bne.b		.loop

.exit
		movem.l	(sp)+,d2-d7/a2-a6
		rts

		cnop	0,4

AllocPooled
		movea.l	_SysBase,a1
		cmpi.w	#39,LIB_VERSION(a1)
		blt.b		.nopools		; change to bra for debugging

		move.l	a6,-(sp)
		movea.l	a1,a6
		CALLSYS	AllocPooled
		movea.l	(sp)+,a6
		rts

.nopools
		movem.l	d2-d7/a2-a6,-(sp)
		move.l	a0,d2
		beq.b		.exit			; safety check

		addq.l	#3,d0
		andi.b	#$FC,d0			; long align size

		movea.l	a1,a6

		cmp.l		8(a0),d0		; check threshold
		blt.b		.chkpuddles		; allocate from puddles

		addi.l	#24,d0			; for header
		move.l	d0,d3			; save size
		move.l	4(a0),d1		; mem attrs
		CALLSYS	AllocMem
		movea.l	d0,a0
		tst.l		d0
		beq.b		.exit			; no memory

		move.l	d3,(a0)			; size of block
		clr.l		20(a0)			; no free space in here

		movea.l	d2,a1			; pool header
		move.l	12(a1),d1
		move.l	a0,12(a1)		; splice in block
		move.l	d1,12(a0)		; relink next block
		lea		24(a0),a0		; skip over header

.exit
		move.l	a0,d0
		movem.l	(sp)+,d2-d7/a2-a6
		rts

		cnop	0,4

.chkpuddles
		cmp.l		20(a0),d0		; check free space
		blt.b		.gotspace

		movea.l	12(a0),a0		; next block
		move.l	a0,d1
		bne.b		.chkpuddles

; not enough free space in existing puddles, create another

		move.l	d0,d6			; save size

		movea.l	d2,a0			; pool header
		movem.l	(a0),d3-d5
		movem.l	(a0),d0-d1
		CALLSYS	AllocMem		; get block
		movea.l	d0,a0
		tst.l		d0
		beq.b		.out			; no memory!

		movea.l	d2,a1			; pool header
		movem.l	d3-d5,(a0)		; puddleSize, Flags,Threshold
		move.l	12(a1),12(a0)		; next block
		move.l	a0,12(a1)		; splice in block
		lea		24(a0),a1		; first free location here
		move.l	a1,16(a0)
		subi.l	#24,d3			; for header info
		move.l	d3,20(a0)		; amount free in this block

		move.l	d6,d0			; restore size

.gotspace
		sub.l		d0,20(a0)		; sub from amount free
		bmi.b		.err			; threshold >= puddlesize!

		move.l	16(a0),a1		; free space
		add.l		d0,16(a0)		; next free space

		movea.l	a1,a0
		bra.b		.out

.err
		add.l		d0,20(a0)		; restore free space
		moveq		#0,d0
		suba.l	a0,a0			; no memory

.out
		move.l	a0,d0
		movem.l	(sp)+,d2-d7/a2-a6
		rts

;------------------------------------------------------------------------
;------------------------------------------------------------------------
;------------------------------------------------------------------------
;------------------------------------------------------------------------

MUSMemPtr	dc.l	0
MUSMemSize	dc.l	0

;------------------------------------------------------------------------

midifileproblem	dc.b	"Error opening MIDI_Instruments file!",0

dosproblem	dc.b	"Error reading MIDI_Instruments file!",0

memproblem	dc.b	"Not enough memory for music!",0

notmusfile	dc.b	"Music lump in WAD file is not .MUS format!",0

damagedfile	dc.b	"Damaged MIDI_Instruments or WAD file!",0

cantopenaud	dc.b	"Can't open audio.device for music!",0

cantgetchan	dc.b	"Can't allocate channels for music!",0

		cnop	0,4

;------------------------------------------------------------------------
; bit 0 = close, bit 1 = file loaded, bit 2 = playing, bit 3 = paused
; bit 4 = loop, bit 5 = attention, bit 6 = gadget down, bit 7 = rev/FF
Flags		dc.b	0
Flags2		dc.b	0			; backup of Flags

; bit 0,1 = dotick
Flags3		dc.b	0

		cnop	0,4
_per		dc.w	0
_per2		dc.w	0	; _period for 11048 Hz

;------------------------------------------------------------------------
		cnop	0,4

EventTable	dc.w	Release-EventTable
		dc.w	PlayNote-EventTable
		dc.w	Pitch-EventTable
		dc.w	Tempo-EventTable
		dc.w	ChangeCtrl-EventTable
		dc.w	NoEvent-EventTable
		dc.w	EndScore-EventTable
		dc.w	NoEvent-EventTable

;------------------------------------------------------------------------

		cnop	0,4

looping		dc.l	0
musicdies	dc.l	-1

MyTicks		dc.l	0

PrevDelay	dc.l	0

AudioPort	dc.l	0,0
		dc.b	NT_MSGPORT,0		; LN_TYPE, LN_PRI
		dc.l	0			; LN_NAME
		dc.b	PA_SIGNAL		; mp_Flags
		dc.b	0			; mp_SigBit
_AudioTask	dc.l	0			; mp_SigTask
.1		dc.l	.2
.2		dc.l	0
		dc.l	.1

		cnop	0,4

_AudioIO		dc.l	0,0
		dc.b	NT_REPLYMSG,0		; LN_TYPE, LN_PRI
		dc.l	0			; LN_NAME
		dc.l	AudioPort		; mn_ReplyPort
		dc.w	68			; mn_Length
		dc.l	0			; IO_DEVICE
		dc.l	0			; IO_UNIT
		dc.w	0			; IO_COMMAND
		dc.b	0			; IO_FLAGS
		dc.b	0			; IO_ERROR
		dc.w	0			; ioa_AllocKey
		dc.l	0			; ioa_Data
		dc.l	0			; ioa_Length
		dc.w	0			; ioa_Period
		dc.w	0			; ioa_Volume
		dc.w	0			; ioa_Cycles
		dc.l	0,0			; ioa_WriteMsg
		dc.b	0,0
		dc.l	0
		dc.l	0
		dc.w	0

		cnop	0,4

AInt2		dc.l	0,0
		dc.b	NT_INTERRUPT,0		; LN_TYPE, LN_PRI
		dc.l	TPortName		; LN_NAME
		dc.l	0			; IS_DATA
		dc.l	AudioINT2		; IS_CODE

MusPtr		dc.l	0
MusIndex	dc.l	0
MusDelay	dc.l	0
OldAInt2	dc.l	0

AudioAlloc	dc.b	CHANNELMASK			; Amiga channels to allocate

AudioName	dc.b	'audio.device',0
TPortName	dc.b	'DoomAttack MUS plugin',0
_AudioOK		dc.b	0
_AudioCh		dc.b	0

;--------------------------------------

		CNOP	0,4

; bit set if voice is in use (0-15=music voices,16-31=sfx voices)

VoiceAvail	dc.l	0


; bit 0 = stop processing, bit 1 = buffer indicator

MusFlag		dc.b	0

;--------------------------------------------------------------------

		CNOP	0,4

NoteTable	dc.l	65536/64,69433/64,73562/64,77936/64,82570/64,87480/64,92682/64,98193/64,104032/64,110218/64,116772/64,123715/64
		dc.l	65536/32,69433/32,73562/32,77936/32,82570/32,87480/32,92682/32,98193/32,104032/32,110218/32,116772/32,123715/32
		dc.l	65536/16,69433/16,73562/16,77936/16,82570/16,87480/16,92682/16,98193/16,104032/16,110218/16,116772/16,123715/16
		dc.l	65536/8,69433/8,73562/8,77936/8,82570/8,87480/8,92682/8,98193/8,104032/8,110218/8,116772/8,123715/8
		dc.l	65536/4,69433/4,73562/4,77936/4,82570/4,87480/4,92682/4,98193/4,104032/4,110218/4,116772/4,123715/4
		dc.l	65536/2,69433/2,73562/2,77936/2,82570/2,87480/2,92682/2,98193/2,104032/2,110218/2,116772/2,123715/2
		dc.l	65536,69433,73562,77936,82570,87480,92682,98193,104032,110218,116772,123715
		dc.l	65536*2,69433*2,73562*2,77936*2,82570*2,87480*2,92682*2,98193*2,104032*2,110218*2,116772*2,123715*2
		dc.l	65536*4,69433*4,73562*4,77936*4,82570*4,87480*4,92682*4,98193*4,104032*4,110218*4,116772*4,123715*4
		dc.l	65536*8,69433*8,73562*8,77936*8,82570*8,87480*8,92682*8,98193*8,104032*8,110218*8,116772*8,123715*8
		dc.l	65536*16,69433*16,73562*16,77936*16,82570*16,87480*16,92682*16,98193*16

;------------------------------------------------------------------------

PitchTable:

pitch_ix	SET	128

		REPT	128
		dc.l	-3678*pitch_ix/64
pitch_ix	SET	pitch_ix-1
		ENDR

		REPT	128
		dc.l	3897*pitch_ix/64
pitch_ix	SET	pitch_ix+1
		ENDR

;------------------------------------------------------------------------

		CNOP	0,4

_AudioCh2Buf	dc.l	chipbuffer2
_AudioCh2Ptr	dc.l	chipbuffer2
_AudioCh2Vol	dc.w	64

		CNOP	0,4

_AudioCh3Buf	dc.l	chipbuffer3
_AudioCh3Ptr	dc.l	chipbuffer3
_AudioCh3Vol	dc.w	64

;------------------------------------------------------------------------

		STRUCTURE MusChannel,0
		APTR	ch_Instr
		APTR	ch_Map
		ULONG	ch_Pitch
		BYTE	ch_Vol
		BYTE	ch_Pan


		CNOP	0,4

Channels	dc.l	Channel0,Channel1,Channel2,Channel3
		dc.l	Channel4,Channel5,Channel6,Channel7
		dc.l	Channel8,Channel9,Channel10,Channel11
		dc.l	Channel12,Channel13,Channel14,Channel15


		CNOP	0,4

Channel0	dc.l	0		; instrument
		dc.l	Channel0Map	; note to voice map
		dc.l	0		; pitch wheel setting
		dc.b	0		; volume
		dc.b	0		; pan setting

		CNOP	0,4

Channel1	dc.l	0		; instrument
		dc.l	Channel1Map	; note to voice map
		dc.l	0		; pitch wheel setting
		dc.b	0		; volume
		dc.b	0		; pan setting

		CNOP	0,4

Channel2	dc.l	0		; instrument
		dc.l	Channel2Map	; note to voice map
		dc.l	0		; pitch wheel setting
		dc.b	0		; volume
		dc.b	0		; pan setting

		CNOP	0,4

Channel3	dc.l	0		; instrument
		dc.l	Channel3Map	; note to voice map
		dc.l	0		; pitch wheel setting
		dc.b	0		; volume
		dc.b	0		; pan setting

		CNOP	0,4

Channel4	dc.l	0		; instrument
		dc.l	Channel4Map	; note to voice map
		dc.l	0		; pitch wheel setting
		dc.b	0		; volume
		dc.b	0		; pan setting

		CNOP	0,4

Channel5	dc.l	0		; instrument
		dc.l	Channel5Map	; note to voice map
		dc.l	0		; pitch wheel setting
		dc.b	0		; volume
		dc.b	0		; pan setting

		CNOP	0,4

Channel6	dc.l	0		; instrument
		dc.l	Channel6Map	; note to voice map
		dc.l	0		; pitch wheel setting
		dc.b	0		; volume
		dc.b	0		; pan setting

		CNOP	0,4

Channel7	dc.l	0		; instrument
		dc.l	Channel7Map	; note to voice map
		dc.l	0		; pitch wheel setting
		dc.b	0		; volume
		dc.b	0		; pan setting

		CNOP	0,4

Channel8	dc.l	0		; instrument
		dc.l	Channel8Map	; note to voice map
		dc.l	0		; pitch wheel setting
		dc.b	0		; volume
		dc.b	0		; pan setting

		CNOP	0,4

Channel9	dc.l	0		; instrument
		dc.l	Channel9Map	; note to voice map
		dc.l	0		; pitch wheel setting
		dc.b	0		; volume
		dc.b	0		; pan setting

		CNOP	0,4

Channel10	dc.l	0		; instrument
		dc.l	Channel10Map	; note to voice map
		dc.l	0		; pitch wheel setting
		dc.b	0		; volume
		dc.b	0		; pan setting

		CNOP	0,4

Channel11	dc.l	0		; instrument
		dc.l	Channel11Map	; note to voice map
		dc.l	0		; pitch wheel setting
		dc.b	0		; volume
		dc.b	0		; pan setting

		CNOP	0,4

Channel12	dc.l	0		; instrument
		dc.l	Channel12Map	; note to voice map
		dc.l	0		; pitch wheel setting
		dc.b	0		; volume
		dc.b	0		; pan setting

		CNOP	0,4

Channel13	dc.l	0		; instrument
		dc.l	Channel13Map	; note to voice map
		dc.l	0		; pitch wheel setting
		dc.b	0		; volume
		dc.b	0		; pan setting

		CNOP	0,4

Channel14	dc.l	0		; instrument
		dc.l	Channel14Map	; note to voice map
		dc.l	0		; pitch wheel setting
		dc.b	0		; volume
		dc.b	0		; pan setting

		CNOP	0,4

Channel15	dc.l	0		; instrument
		dc.l	Channel15Map	; note to voice map
		dc.l	0		; pitch wheel setting
		dc.b	0		; volume
		dc.b	0		; pan setting


		CNOP	0,4

Channel0Map	dcb.b	128,0
Channel1Map	dcb.b	128,0
Channel2Map	dcb.b	128,0
Channel3Map	dcb.b	128,0
Channel4Map	dcb.b	128,0
Channel5Map	dcb.b	128,0
Channel6Map	dcb.b	128,0
Channel7Map	dcb.b	128,0
Channel8Map	dcb.b	128,0
Channel9Map	dcb.b	128,0
Channel10Map	dcb.b	128,0
Channel11Map	dcb.b	128,0
Channel12Map	dcb.b	128,0
Channel13Map	dcb.b	128,0
Channel14Map	dcb.b	128,0
Channel15Map	dcb.b	128,0

;--------------------------------------

		STRUCTURE AudioVoice,0
		APTR	vc_Next
		APTR	vc_Channel
		APTR	vc_Wave
		ULONG	vc_Index
		ULONG	vc_Step
		ULONG	vc_Loop
		ULONG	vc_Length
		BYTE	vc_Vol
		BYTE	vc_Flags	; b7 = SFX, b1 = RLS, b0 = EN

		CNOP	0,4

Voices		dc.l	Voice0,Voice1,Voice2,Voice3
		dc.l	Voice4,Voice5,Voice6,Voice7
		dc.l	Voice8,Voice9,Voice10,Voice11
		dc.l	Voice12,Voice13,Voice14,Voice15

		CNOP	0,4

Voice0		dc.l	Voice1
		dc.l	0		; channel back-link
		dc.l	0		; instrument wave data
		dc.l	0		; sample index
		dc.l	0		; sample rate
		dc.l	0		; instrument loop point
		dc.l	0		; instrument data length
		dc.b	0		; voice volume scale
		dc.b	0		; voice flags

		CNOP	0,4

Voice1		dc.l	Voice2
		dc.l	0		; channel back-link
		dc.l	0		; instrument wave data
		dc.l	0		; sample index
		dc.l	0		; sample rate
		dc.l	0		; instrument loop point
		dc.l	0		; instrument data length
		dc.b	0		; voice volume scale
		dc.b	0		; voice flags

		CNOP	0,4

Voice2		dc.l	Voice3
		dc.l	0		; channel back-link
		dc.l	0		; instrument wave data
		dc.l	0		; sample index
		dc.l	0		; sample rate
		dc.l	0		; instrument loop point
		dc.l	0		; instrument data length
		dc.b	0		; voice volume scale
		dc.b	0		; voice flags

		CNOP	0,4

Voice3		dc.l	Voice4
		dc.l	0		; channel back-link
		dc.l	0		; instrument wave data
		dc.l	0		; sample index
		dc.l	0		; sample rate
		dc.l	0		; instrument loop point
		dc.l	0		; instrument data length
		dc.b	0		; voice volume scale
		dc.b	0		; voice flags

		CNOP	0,4

Voice4		dc.l	Voice5
		dc.l	0		; channel back-link
		dc.l	0		; instrument wave data
		dc.l	0		; sample index
		dc.l	0		; sample rate
		dc.l	0		; instrument loop point
		dc.l	0		; instrument data length
		dc.b	0		; voice volume scale
		dc.b	0		; voice flags

		CNOP	0,4

Voice5		dc.l	Voice6
		dc.l	0		; channel back-link
		dc.l	0		; instrument wave data
		dc.l	0		; sample index
		dc.l	0		; sample rate
		dc.l	0		; instrument loop point
		dc.l	0		; instrument data length
		dc.b	0		; voice volume scale
		dc.b	0		; voice flags

		CNOP	0,4

Voice6		dc.l	Voice7
		dc.l	0		; channel back-link
		dc.l	0		; instrument wave data
		dc.l	0		; sample index
		dc.l	0		; sample rate
		dc.l	0		; instrument loop point
		dc.l	0		; instrument data length
		dc.b	0		; voice volume scale
		dc.b	0		; voice flags

		CNOP	0,4

Voice7		dc.l	Voice8
		dc.l	0		; channel back-link
		dc.l	0		; instrument wave data
		dc.l	0		; sample index
		dc.l	0		; sample rate
		dc.l	0		; instrument loop point
		dc.l	0		; instrument data length
		dc.b	0		; voice volume scale
		dc.b	0		; voice flags

		CNOP	0,4

Voice8		dc.l	Voice9
		dc.l	0		; channel back-link
		dc.l	0		; instrument wave data
		dc.l	0		; sample index
		dc.l	0		; sample rate
		dc.l	0		; instrument loop point
		dc.l	0		; instrument data length
		dc.b	0		; voice volume scale
		dc.b	0		; voice flags

		CNOP	0,4

Voice9		dc.l	Voice10
		dc.l	0		; channel back-link
		dc.l	0		; instrument wave data
		dc.l	0		; sample index
		dc.l	0		; sample rate
		dc.l	0		; instrument loop point
		dc.l	0		; instrument data length
		dc.b	0		; voice volume scale
		dc.b	0		; voice flags

		CNOP	0,4

Voice10		dc.l	Voice11
		dc.l	0		; channel back-link
		dc.l	0		; instrument wave data
		dc.l	0		; sample index
		dc.l	0		; sample rate
		dc.l	0		; instrument loop point
		dc.l	0		; instrument data length
		dc.b	0		; voice volume scale
		dc.b	0		; voice flags

		CNOP	0,4

Voice11		dc.l	Voice12
		dc.l	0		; channel back-link
		dc.l	0		; instrument wave data
		dc.l	0		; sample index
		dc.l	0		; sample rate
		dc.l	0		; instrument loop point
		dc.l	0		; instrument data length
		dc.b	0		; voice volume scale
		dc.b	0		; voice flags

		CNOP	0,4

Voice12		dc.l	Voice13
		dc.l	0		; channel back-link
		dc.l	0		; instrument wave data
		dc.l	0		; sample index
		dc.l	0		; sample rate
		dc.l	0		; instrument loop point
		dc.l	0		; instrument data length
		dc.b	0		; voice volume scale
		dc.b	0		; voice flags

		CNOP	0,4

Voice13		dc.l	Voice14
		dc.l	0		; channel back-link
		dc.l	0		; instrument wave data
		dc.l	0		; sample index
		dc.l	0		; sample rate
		dc.l	0		; instrument loop point
		dc.l	0		; instrument data length
		dc.b	0		; voice volume scale
		dc.b	0		; voice flags

		CNOP	0,4

Voice14		dc.l	Voice15
		dc.l	0		; channel back-link
		dc.l	0		; instrument wave data
		dc.l	0		; sample index
		dc.l	0		; sample rate
		dc.l	0		; instrument loop point
		dc.l	0		; instrument data length
		dc.b	0		; voice volume scale
		dc.b	0		; voice flags

		CNOP	0,4

Voice15		dc.l	0
		dc.l	0		; channel back-link
		dc.l	0		; instrument wave data
		dc.l	0		; sample index
		dc.l	0		; sample rate
		dc.l	0		; instrument loop point
		dc.l	0		; instrument data length
		dc.b	0		; voice volume scale
		dc.b	0		; voice flags

;--------------------------------------

		STRUCTURE InstrumentRec,0
		APTR	in_Wave
		ULONG	in_Loop
		ULONG	in_Length
		BYTE	in_Flags
		BYTE	in_Base


		CNOP	0,4

Instruments	dcb.l	256,0

		CNOP	0,4

QuietInst	dc.l	0
		dc.l	0
		dc.l	0
		dc.b	0
		dc.b	0


		CNOP	0,4

InstrHandle	dc.l	0
InstrFile	dc.l	InstrName
InstrPool	dc.l	0

InstrName	dc.b	'PROGDIR:MIDI_Instruments',0

		CNOP	0,4

validInstr	dc.b	%11111111	; (00-07) Piano
		dc.b	%11111111	; (08-0F) Chrom Perc
		dc.b	%11111111	; (10-17) Organ
		dc.b	%11111111	; (18-1F) Guitar
		dc.b	%11111111	; (20-27) Bass
		dc.b	%11111111	; (28-2F) Strings
		dc.b	%11111111	; (30-37) Ensemble
		dc.b	%11111111	; (38-3F) Brass
		dc.b	%11111111	; (40-47) Reed
		dc.b	%11111111	; (48-4F) Pipe
		dc.b	%11111111	; (50-57) Synth Lead
		dc.b	%11111111	; (58-5F) Synth Pad
		dc.b	%11111111	; (60-67) Synth Effects
		dc.b	%11111111	; (68-6F) Ethnic
		dc.b	%11111111	; (70-77) Percussive
		dc.b	%11111111	; (78-7F) SFX
		dc.b	%00000001	; (80-87) invalid,Drum
		dc.b	%11111111	; (88-8F) Drums/Clap/Hi-Hat
		dc.b	%11111111	; (90-97) Hi-Hats/Toms/Cymb1
		dc.b	%11111111	; (98-9F) Cymbals/Bells/Slap
		dc.b	%11111111	; (A0-A7) Bongos/Congas/Timb
		dc.b	%11111111	; (A8-AF) Agogo/Whistles/Gui
		dc.b	%11111100	; (B0-B7) Claves/Block/Trian
		dc.b	%00000000	; (B8-BF) invalid
		dc.b	%00000000	; (C0-C7)
		dc.b	%00000000	; (C8-CF)
		dc.b	%00000000	; (D0-D7)
		dc.b	%00000000	; (D8-DF)
		dc.b	%00000000	; (E0-E7)
		dc.b	%00000000	; (E8-EF)
		dc.b	%00000000	; (F0-F7)
		dc.b	%00000000	; (F8-FF)

;--------------------------------------------------------------------
		section	PlayMusChip,data_c

ClearBuf	dcb.b	160,0


chipbuffer2	dcb.b	320,0
chipbuffer3	dcb.b	320,0

;------------------------------------------------------------------------
		section	PlayMusBSS,bss

EventBlocks	ds.w	32768


tempAudio	ds.b	160

;------------------------------------------------------------------------

		END

