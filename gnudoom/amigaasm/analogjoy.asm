	MACHINE 68020

;--------------------------------------------------------------------------

	incdir	"ainclude:"

	include exec/types.i
	include exec/io.i
	include	dos/dos.i
	include	hardware/custom.i
	include devices/input.i
	include devices/InputEvent.i
	include devices/gameport.i
	include resources/potgo.i
	include	lvo/exec_lib.i
	include	lvo/dos_lib.i
	include	lvo/potgo_lib.i
	include	lvo/graphics_lib.i

;--------------------------------------------------------------------------

	XREF	_GfxBase
	XREF	_D_PostEvent
	XREF	_MainTask
	XREF	_joyport

	XDEF	_AnalogDriver
	XDEF	_analog_centerx
	XDEF	_analog_centery
	XDEF	_analog_neutralzone
	XDEF	_analog_sensitivity
	XDEF	_analog_aspect
	XDEF	_analog_rmbsensitivity
	XDEF	_analog_ERROR

;--------------------------------------------------------------------------

CUSTOM = $dff000
PTGF_START = 1<<0
PTGF_DATLX = 1<<8
PTGF_DATLY = 1<<10
PTGF_DATRX = 1<<12
PTGF_DATRY = 1<<14

;--------------------------------------------------------------------------

EVTYPE_MOUSE = 2

 STRUCTURE doomevent,0
  LONG	ev_type
  LONG	ev_data1
  LONG	ev_data2
  LONG	ev_data3
  LABEL	ev_SIZEOF

;--------------------------------------------------------------------------

_AnalogDriver:
	move.l	sp,stack

	move.l	#ERRTEXT_POTGO,_analog_ERROR
	bsr.w	allocpotgo
	tst.l	d0
	bne.w	exit

	move.l	#ERRTEXT_JOYPORT,_analog_ERROR
	bsr.w	allocjoyport
	tst.l	d0
	bne.w	exit

;everything OK :)
	clr.l	_analog_ERROR
	move.l	4.w,a6

	tst.w	_joyport
	bne.s	notmouseport
	
	move.l	#CUSTOM+pot0dat,PATCH1+2
	move.l	#CUSTOM+joy0dat,PATCH2+2

	jsr	_LVOCacheClearU(a6)

notmouseport:
;Tell DoomAttack that the sub task is ready for action!

	move.l	_MainTask,a1
	move.l	#SIGBREAKF_CTRL_F,d0
	jsr	_LVOSignal(a6)

	move.l	_GfxBase,a6
	jsr	_LVOWaitTOF(a6)

;-- main loop -------------------------------------------------------------

loop:
PATCH1:	move.w	CUSTOM+pot1dat,d0		;read pots
	move.w	d0,-(sp)
	moveq	#PTGF_START,d0
	bsr.w	writepotgo
	move.w	(sp)+,d0
	
	move.b	d0,d1
	ext.w	d1
	ext.l	d1		; d1 - pot y
	asr.w	#8,d0
	ext.l	d0		; d0 - pot x
	add.l	d0,d0		; *2 to make centerx and centery
	add.l	d1,d1		; integers.

	cmp.l	minx(pc),d0
	bge.s	here1		; x<minx ?
	move.l	d0,minx
here1:
	cmp.l	maxx(pc),d0
	ble.s	here2		;x>maxx ?
	move.l	d0,maxx
here2:
	cmp.l	miny(pc),d1
	bge.s	here3		;y<miny ?
	move.l	d1,miny
here3:
	cmp.l	maxy(pc),d1
	ble.s	here4		;y>maxy ?
	move.l	d1,maxy
here4:

	tst.l	asp(pc)		; calculate aspect ?
	bne.s	skipasp

	move.l	maxx(pc),d2
	sub.l	minx(pc),d2
	move.l	maxy(pc),d3
	sub.l	miny(pc),d3
	tst.l	d3
	beq.s	skipasp
	muls	#100,d2		; aspect=(maxx-minx)*100/(maxy-miny)
	divs	d3,d2
	ext.l	d2
	move.l	d2,aspect
skipasp:

	tst.l	centerx(pc)	; calculate centerx ?
	bne.s	skipx

	move.l	minx(pc),d2
	add.l	maxx(pc),d2
	asr.l	#1,d2
	move.l	d2,centerx	; centerx=(minx+maxx)/2
skipx:
	sub.l	centerx(pc),d0	; x=x-centerx

	tst.l	centery(pc)	; calculate centery ?
	bne.s	skipy

	move.l	miny(pc),d3
	add.l	maxy(pc),d3
	asr.l	#1,d3
	move.l	d3,centery	; centery=(miny-maxy)/2
skipy:
	sub.l	centery(pc),d1	; y=y-centery

; if x>0 then if x>neutralzone x=x-neutralzone else x=0
; if x<0 then if x<-neutralzone x=x+neutralzone else x=0

	move.l	neutralzone(pc),d2
	tst.l	d0
	bpl.s	dod1

	neg.l	d2
	cmp.l	d2,d0
	ble.s	nochg2
	move.l	d2,d0
nochg2:
	bra.s	next1

dod1:	cmp.l	d2,d0
	bge.s	nochg1
	move.l	d2,d0
nochg1:
next1:	sub.l	d2,d0

; the same as above for y

	move.l	neutralzone(pc),d2
	tst.l	d1
	bpl.s	dod2

	neg.l	d2
	cmp.l	d2,d1
	ble.s	nochg4
	move.l	d2,d1
nochg4:
	bra.s	next2

dod2:	cmp.l	d2,d1
	bge.s	nochg3
	move.l	d2,d1
nochg3:
next2:	sub.l	d2,d1

	move.l	d0,d2
	move.l	d1,d3

	move.l	sensitivity(pc),d2
	tst.b	button2
	beq.s	normb
	move.l	rmbsensitivity(pc),d2

normb:
	muls	d2,d0		; x=x*sens
	muls	d2,d1		; y=y*sens
	add.b	d0,rx
	bcc.s	nocarx		; lo byte overflow ?
	add.l	#$100,d0	; add correction
nocarx:
	asr.l	#8,d0		; x=x/256
	
	move.l	aspect(pc),d2	; make aspect scale from 0-100 to 0-256
	asl.l	#8,d2		; *256
	divs	#100,d2		; /100
	ext.l	d2
	ext.l	d1
	muls	d2,d1		; y=y*aspect
	asr.l	#8,d1		; y=y/256
	add.b	d1,ry
	bcc.s	nocary		; lo byte overflow ?
	add.l	#$100,d1	; add correction
nocary:
	asr.l	#8,d1		; y=y/256

	sf	sendevent
	
PATCH2:	move.w	CUSTOM+joy1dat,d4		;read buttons
	btst	#9,d4
	bne.s	down1
	tst.b	button1
	beq.s	nextb1
	move.b	#0,button1
	st	sendevent
	bra.s	nextb1

down1:
	tst.b	button1
	bne.s	nextb1
	move.b	#1,button1
	st	sendevent

nextb1:
	btst	#1,d4
	bne.s	down2
	tst.b	button2
	beq.s	nextb2
	move.b	#0,button2
	st	sendevent
	bra.s	nextb2

down2:
	tst.b	button2
	bne.s	nextb2
	move.b	#1,button2
	st	sendevent

nextb2:
	tst.l	d0
	bne.s	mustsend
	tst.l	d1
	bne.s	mustsend
	tst.b	sendevent
	beq.s	ret
	
mustsend:
	lea	myevent(pc),a0
	move.l	a0,-(sp)	;for D_PostEvent(struct event_t *ev);

	addq.l	#ev_data1,a0

	moveq	#0,d2
	move.b	button2(pc),d2
	add	d2,d2
	add.b	button1(pc),d2
	
	move.l	d2,(a0)+	; button state

	asl.l	#3,d0		; << 3
	asl.l	#3,d1		; << 3
	neg.l	d1
	movem.l	d0/d1,(a0)	; mouse x and mousey
	
	jsr	_D_PostEvent
	addq.l	#4,sp
		
ret:	move.l	_GfxBase,a6
	jsr	_LVOWaitTOF(a6)		; WaitTOF()

	move.l	4.w,a6
	clr.l	d0
	clr.l	d1
	jsr	_LVOSetSignal(a6)
	and.l	#SIGBREAKF_CTRL_C,d0	; Ctrl-C ?
	beq.w	loop

;-- cleanup ---------------------------------------------------------------
	
exit:
	move.l	stack(pc),sp

	bsr.w	freejoyport
	bsr.w	freepotgo

	moveq	#0,d0
	
	move.l	4.w,a6
	move.l	_MainTask,a1
	move.l	#SIGBREAKF_CTRL_F,d0
	jsr	_LVOSignal(a6)
	
;wait forever
	moveq	#0,d0
	jsr	_LVOWait(a6)
	illegal

;--------------------------------------------------------------------------

	even

minx:	dc.l	1000
maxx:	dc.l	-1000

_analog_centerx:
centerx:
	dc.l	0
miny:	dc.l	1000
maxy:	dc.l	-1000

_analog_centery:
centery:
	dc.l	0

aspect:
	dc.l	0

_analog_neutralzone:
neutralzone:
	dc.l	4

_analog_sensitivity:
sensitivity:
	dc.l	120

_analog_rmbsensitivity:
rmbsensitivity:
	dc.l	120
rx:	dc.b	0
ry:	dc.b	0

button1:
	dc.b	0
button2:
	dc.b	0
sendevent:
	dc.b	0

	even

; -------------------------------------------------------------------------
; open potgo.resource, alloc bits

allocpotgo:
	lea	potgoname(pc),a1
	move.l	4.w,a6
	jsr	_LVOOpenResource(a6)
	move.l	d0,potgobase
	beq.s	potgoerr

	move.l	#PTGF_DATRX+PTGF_DATRY+PTGF_START,d2
	tst.w	_joyport
	bne.s	notthemouseport
	move.l	#PTGF_DATLX+PTGF_DATLY+PTGF_START,d2
	
notthemouseport:
	move.l	d2,d0
	move.l	potgobase(pc),a6
	jsr	_LVOAllocPotBits(a6)
	move.l	d0,allocatedb
	cmp.l	d2,d0
	bne.s	potgoerr

	moveq	#0,d0
	rts

potgoerr:
	moveq	#1,d0
	rts

;--------------------------------------------------------------------------
; free potgo bits

freepotgo:
	tst.l	potgobase(pc)
	beq.s	nopotgo

	move.l	potgobase(pc),a6
	move.l	allocatedb(pc),d0
	jsr	_LVOFreePotBits(a6)

nopotgo:
	rts

;--------------------------------------------------------------------------
; d0 - word

writepotgo:
	move.l	allocatedb(pc),d1
	move.l	potgobase(pc),a6
	jsr	_LVOWritePotgo(a6)
	rts

potgoname:	dc.b	'potgo.resource',0
		even
potgobase:	dc.l	0
allocatedb:	dc.l	0

;--------------------------------------------------------------------------
; open gameport.device, alloc controller

allocjoyport:
	suba.l	a1,a1			; a1 = 0 = find our task
	move.l	4.w,a6
	jsr	_LVOFindTask(a6)
	lea	gameportPort(pc),a1	; reply port
	move.l	d0,MP_SIGTASK(a1)	; signal us when msg received
	move.l	4.w,a6
	jsr	_LVOAddPort(a6)
	move.b	#1,gpportadded
	
	lea	gameportDevName(pc),a0
	lea	gameportIOReq(pc),a1
	move.l	#gameportPort,MN_REPLYPORT(a1)
	moveq.l	#1,d0			; unit number
	moveq.l	#0,d1			; flags
	move.l	4.w,a6
	jsr	_LVOOpenDevice(a6)
	move.l	d0,gameporterr
	tst.l	d0
	bne.s	jperr

	jsr	_LVOForbid(a6)

	lea	gameportIOReq(pc),a1
	move.w	#GPD_ASKCTYPE,IO_COMMAND(a1)
	move.l	#contr_type,IO_DATA(a1)
	move.l	#1,IO_LENGTH(a1)
	jsr	_LVODoIO(a6)

	tst.b	contr_type
	bne.s	contr_used

; port free, allocating...
	lea	gameportIOReq(pc),a1		
	move.w	#GPD_SETCTYPE,IO_COMMAND(a1)
	move.b	#GPCT_ALLOCATED,contr_type
	move.l	#contr_type,IO_DATA(a1)
	move.l	#1,IO_LENGTH(a1)
	jsr	_LVODoIO(a6)

	jsr	_LVOPermit(a6)

	moveq	#0,d0
	rts

contr_used:
	jsr	_LVOPermit(a6)

jperr:	moveq	#1,d0
	rts

;--------------------------------------------------------------------------

gameporterr:	dc.l	0
contr_type:	dc.b	0
gpportadded:	dc.b	0
		even

;--------------------------------------------------------------------------
; free gameport, close gameport.device

freejoyport:
	tst.b	gpportadded(pc)
	beq.w	return
	tst.l	gameporterr(pc)
	bne.s	notopened
	lea	gameportIOReq(pc),a1		
	move.w	#GPD_SETCTYPE,IO_COMMAND(a1)
	move.b	#GPCT_NOCONTROLLER,contr_type
	move.l	#contr_type,IO_DATA(a1)
	move.l	#1,IO_LENGTH(a1)
	move.l	4.w,a6
	jsr	_LVODoIO(a6)
	move.l	4.w,a6
	lea	gameportIOReq(pc),a1		
	jsr	_LVOCloseDevice(a6)

notopened:
	lea	gameportPort(pc),a1		; ptr to the msgport
	move.l	4.w,a6
	jsr	_LVORemPort(a6)

return:
	rts

;--------------------------------------------------------------------------

_analog_aspect:
asp:
	dc.l	0

_analog_ERROR:
	dc.l	0

; -------------------------------------------------------------------------

InputDevName:	dc.b	'input.device',0
gameportDevName:
		dc.b	'gameport.device',0
		even

ERRTEXT_POTGO: dc.b 'Analog Joystick driver: Could not allocate potgo bits',10,0
ERRTEXT_JOYPORT: dc.b 'Analog Joystick driver: Could not allocate joystick port',10,0

; -------------------------------------------------------------------------

InputE:		blk.b	ie_SIZEOF,0
InputIOReq:	blk.b	IOSTD_SIZE,0
InputPort:	blk.b	MP_SIZE,0
gameportPort:	blk.b	MP_SIZE,0
gameportIOReq:	blk.b	IOSTD_SIZE,0

	CNOP 0,4

myevent:	dc.l	EVTYPE_MOUSE
		dc.l	0
		dc.l	0
		dc.l	0

		even

; -------------------------------------------------------------------------

state:
	dc.l	0
stack:
	dc.l	0

;--------------------------------------------------------------------------

	END
