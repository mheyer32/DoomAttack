;AMIGAAMIGA equ 1
	
	include exec/io.i
	include exec/io.i
	include devices/serial.i
	include lvo/exec_lib.i
	include "d_net.i"
	include "nullmodem.i"
	
	XREF	_doomcom
	XREF	_netbuffer
	XREF	_packet
	XREF	_I_Error
	XREF	_SerWriting
	XREF	_SerWriteIO
	XREF	_SerReadIO
	XREF	_SerialBase
	XREF	_buffer

;/***************************************************/

	XDEF	_DAN_NetCmd

_DAN_NetCmd:
	move.l	_doomcom,a0
	move		dc_command(a0),d0
	subq		#1,d0
	beq		.send
	subq		#1,d0
	beq.s		.get
	
	moveq		#0,d0
	move		dc_command(a0),d0

	move.l	d0,-(sp)
	pea		ERR_BADCMD(pc)
	move.l	_I_Error,a0
	jsr		(a0)
	;// does not return

;'******* GET ********

.get:
	bsr		_PacketGet
	tst		d0
	beq.s		.badpacket
	move.l	packetlen(pc),d0
	cmp.l		#dd_SIZEOF,d0
	bgt.s		.badpacket

	IFD	AMIGAAMIGA
	
	move.l	_doomcom,a0
	move		#1,dc_remotenode(a0)
	move		d0,dc_datalength(a0)
	
	lea		_packet,a0
	move.l	_netbuffer,a1
	move.l	(a1),a1
	lsr		#2,d0
	subq		#1,d0
	bmi.s		.getdone

.copy2:
	move.l	(a0)+,(a1)+
	dbf		d0,.copy2

.getdone
	rts
	
	ELSE

	move.l	_doomcom,a0
	move		#1,dc_remotenode(a0)
	move		d0,dc_datalength(a0)
	
	lea		_packet,a0
	move.l	_netbuffer,a1
	move.l	(a1),a1
	
	move.l	(a0)+,d1
	ror.w		#8,d1
	swap		d1
	ror.w		#8,d1
	move.l	d1,(a1)+
	move.l	(a0)+,(a1)+
	
	cmp.l		#8,d0
	blt.s		.getdone

	moveq		#0,d1
	move.b	-1(a0),d1
	ble.s		.getdone
	subq		#1,d1
	cmp		#BACKUPTICS,d1
	blt.s		.getticloop
	
	pea		ERR_TICSGET(pc)
	move.l	_I_Error,a0
	jsr		(a0)
	;//	does not return
	
.getticloop:
	move		(a0)+,(a1)+
	move.l	(a0)+,d0
	ror.w		#8,d0
	swap		d0
	ror.w		#8,d0
	swap		d0
	move.l	d0,(a1)+
	move		(a0)+,(a1)+
	dbf		d1,.getticloop
	
.getdone:
	rts

	ENDC

.badpacket:
	move.l	_doomcom,a0
	move		#-1,dc_remotenode(a0)
	rts
	
	

;'******* SEND *******
	
	IFD	AMIGAAMIGA

.send:
	lea		senddata(pc),a1
	move		dc_datalength(a0),d0
	move		d0,d1
	lsr		#2,d1
	subq		#1,d1
	move.l	_netbuffer,a0
	move.l	(a0),a0

.copy:
	move.l	(a0)+,(a1)+
	dbf		d1,.copy
	
	lea		senddata(pc),a0
	bsr.s		_PacketSend
	rts

	ELSE

.send:
	move		dc_datalength(a0),d0
	lea		senddata(pc),a1
	move.l	_netbuffer,a0
	move.l	(a0),a0

	move.l	(a0)+,d1						;'checksum
	ror.w		#8,d1
	swap		d1
	ror.w		#8,d1
	move.l	d1,(a1)+
	move.l	(a0)+,(a1)+
	
	move.l	d2,-(sp)
	moveq		#0,d2
	move.b	-1(a0),d2
	ble.s		.notics
	subq		#1,d2
	cmp		#BACKUPTICS,d2
	blt.s		.sendticloop
	
	pea		ERR_TICSSEND(pc)
	move.l	_I_Error,a0
	jsr		(a0)

.sendticloop:
	move		(a0)+,(a1)+			;// forwardmove + sidemove
	move.l	(a0)+,d1				;// angleturn + consistancy
	ror.w		#8,d1
	swap		d1
	ror.w		#8,d1
	swap		d1
	move.l	d1,(a1)+
	move		(a0)+,(a1)+			;// chatchar + buttons
	dbf		d2,.sendticloop

.notics:
	move.l	(sp)+,d2
	
	lea		senddata(pc),a0
	bsr.s		_PacketSend
	rts
	
	ENDC
	
;/***************************************************/

	XDEF	_PacketSend

_PacketSend:
	movem.l	d2/a6,-(sp)

;//	if (!len || (len > MAXPACKET)) return; 
	tst		d0
	ble.s		.exit
	cmp		#MAXPACKET,d0
	bgt.s		.exit

;//	if (SerWriting)
;//	{
	tst		_SerWriting
	beq.s		.notwriting

;//		WaitIO((struct IORequest *)SerWriteIO);
;//	}
	
	movem.l	d0/a0,-(sp)

	move.l	4.w,a6
	move.l	_SerWriteIO,a1
	jsr		_LVOWaitIO(a6)
	
	movem.l	(sp)+,d0/a0

.notwriting:
	lea		localbuffer,a1
	moveq		#2,d1
	add		d0,d1					;' d1 = length = 2 + datalength
	subq		#1,d0
	
.loop:
	move.b	(a0)+,d2
	cmp.b		#FRAMECHAR,d2
	bne.s		.loop2
	move.b	#FRAMECHAR,(a1)+
	addq		#1,d1					;' length+=1
.loop2:
	move.b	d2,(a1)+
	dbf		d0,.loop
	
	move.b	#FRAMECHAR,(a1)+
	clr.b		(a1)
	
	move.l	_SerWriteIO,a1
	move		#CMD_WRITE,IO_COMMAND(a1)
	move.l	#localbuffer,IO_DATA(a1)
	move.l	d1,IO_LENGTH(a1)
	and.b		#~IOF_QUICK,IO_FLAGS(a1)

	move.l	_SerialBase,a6
	jsr		DEV_BEGINIO(a6)

	move.w	#1,_SerWriting

.exit:
	movem.l	(sp)+,d2/a6
	rts
	
;/***************************************************/

	XDEF	_PacketGet
	
_PacketGet:
;//	if (newpacket) 
;//	{ 
	tst.b		newpacket(pc)
	beq.s		.notnewpacket

;//		packetlen = 0; 
;//		newpacket = FALSE; 

	clr.l		packetlen
	clr.b		newpacket

;//	} 
	
.notnewpacket:
	movem.l	d2-d3/a2-a3/a6,-(sp)

;//	do 
;//	{ 

.forever:
;//		if (unreadbytes < MAXPACKET)
;//		{

	move.l	unreadbytes(pc),d0
	cmp.l		#MAXPACKET,d0
	bge		.dontgetnewdata

;//			SerReadIO->IOSer.io_Command=SDCMD_QUERY;

	move.l	_SerReadIO,a2				;'a2 = SerReadIO
	move.l	a2,a1
	move		#SDCMD_QUERY,IO_COMMAND(a1)

;//			DoIO((struct IORequest *)SerReadIO);
	move.l	4.w,a6
	jsr		_LVODoIO(a6)

;//			if ((len = SerReadIO->IOSer.io_Actual))
;//			{
	move.l	IO_ACTUAL(a2),d2			;'d2 = bytes in serial buffer
	beq		.dontgetnewdata
	
;//				if ((unreadbytes + len) > BUFFERLEN)
;//				{
	move.l	unreadbytes(pc),d0		;'d0 = unreadbytes
	move.l	d2,d1
	add.l		d0,d1
	cmp.l		#BUFFERLEN,d1
	ble.s		.mustgetdata

;//					len = BUFFERLEN - unreadbytes;
;//				}		

	move.l	#BUFFERLEN,d2
	sub.l		d0,d2

;//.bytesOK:
;//	tst.l		d2
;//	beq		.dontgetnewdata

.mustgetdata:
	move.l	bufferpos(pc),d3			;'d3 = copypos = bufferpos ...
	add.l		d0,d3							;'+ unreadbytes

;//					if (copypos >= BUFFERLEN) copypos -= BUFFERLEN;

	and.l		#BUFFERLEN-1,d3
;//	cmp.l		#BUFFERLEN,d3
;//	blt.s		.copyposOK
;//	sub.l		#BUFFERLEN,d3
	
;//.copyposOK:
;//					if ((copypos + len) <= BUFFERLEN)
;//					{

	move.l	d3,d1
	add.l		d2,d1
	cmp.l		#BUFFERLEN,d1
	bgt.s		.splittedcopy

;//						SerReadIO->IOSer.io_Command = CMD_READ;
;//						SerReadIO->IOSer.io_Data = &buffer[copypos];
;//						SerReadIO->IOSer.io_Length = len;

	move.l	a2,a1
	move		#CMD_READ,IO_COMMAND(a1)
	lea		_buffer,a0
	add.l		d3,a0
	move.l	a0,IO_DATA(a1)
	move.l	d2,IO_LENGTH(a1)

;//						DoIO((struct IORequest *)SerReadIO);

	jsr		_LVODoIO(a6)	
	bra.s		.aftercopy

;//					} else {

.splittedcopy:
;//						SerReadIO->IOSer.io_Command = CMD_READ;
;//						SerReadIO->IOSer.io_Data = &buffer[copypos];
;//						SerReadIO->IOSer.io_Length = BUFFERLEN - copypos;

	move.l	a2,a1
	move		#CMD_READ,IO_COMMAND(a1)
	lea		_buffer,a0
	add.l		d3,a0
	move.l	a0,IO_DATA(a1)
	move.l	#BUFFERLEN,d0
	sub.l		d3,d0
	move.l	d0,IO_LENGTH(a1)

;//						DoIO((struct IORequest *)SerReadIO);
	jsr		_LVODoIO(a6)

;//						SerReadIO->IOSer.io_Command = CMD_READ;
;//						SerReadIO->IOSer.io_Data = &buffer[0];
;//						SerReadIO->IOSer.io_Length = (len - (BUFFERLEN - copypos));
	
	move.l	a2,a1
	move		#CMD_READ,IO_COMMAND(a1)
	move.l	#_buffer,IO_DATA(a1)
	move.l	d2,d0
	sub.l		#BUFFERLEN,d0
	add.l		d3,d0
	move.l	d0,IO_LENGTH(a1)

;//						DoIO((struct IORequest *)SerReadIO);
	jsr		_LVODoIO(a6)

.aftercopy:
;//					unreadbytes += len;
	add.l		d2,unreadbytes

.dontgetnewdata:
;//		if (!unreadbytes)
;//		{
	move.l	unreadbytes(pc),d3			;'d3 = unreadbytes
	bne.s		.muchwork

;//			bufferpos=0;
;//			return FALSE;
;//		}
	clr.l		bufferpos
	moveq		#0,d0
	bra.s		.exit

.muchwork:
	lea		_buffer,a2						;'a2 = buffer
	lea		_packet,a3						;'a3 = packet

;//		while (unreadbytes)
;//		{

.while:
;//			c=buffer[bufferpos++];
	move.l	bufferpos(pc),d1
	move.b	(a2,d1.l),d0					;'d0 = char

;//			if (bufferpos == BUFFERLEN) bufferpos=0;
	addq.l	#1,d1
	cmp.l		#BUFFERLEN,d1
	bne.s		.bufferposOK
	moveq		#0,d1
	
.bufferposOK:
	move.l	d1,bufferpos

;//			unreadbytes--;
	subq.l	#1,d3
	move.l	d3,unreadbytes
	
;//			if (inescape)
;//			{
	tst.b		inescape(pc)
	beq.s		.else
	
;//				inescape=FALSE;
	clr.b		inescape

;//				if (c != FRAMECHAR)
;//				{
	cmp.b		#FRAMECHAR,d0
	beq.s		.weiter

;//					newpacket = TRUE;
;//					return TRUE;
	st.b		newpacket
	moveq		#1,d0
	bra.s		.exit
;//				}

.else:
;//			} else if (c == FRAMECHAR)
;//			{
	cmp.b		#FRAMECHAR,d0
	bne.s		.weiter

;//				inescape=TRUE;
;//				continue;
	st.b		inescape
	bra.s		.continue

;//			}

.weiter:
;//			if (packetlen >= MAXPACKET)
;//			{
;//				 continue;			// oversize packet 
;//			}
	move.l	packetlen(pc),d1
	cmp.l		#MAXPACKET,d1
	bge.s		.continue
	
;//			packet[packetlen] = c;
;//			packetlen++; 
	move.b	d0,(a3,d1.l)
	addq.l	#1,d1
	move.l	d1,packetlen
	
.continue:
	tst.l		d3
	bne.s		.while
	
	
	bra		.forever


.exit:
	movem.l	(sp)+,d2-d3/a2-a3/a6
	rts
	
;/***************************************************/

	CNOP	0,4

	XDEF	_packetlen
	
bufferpos:
	dc.l	0
_packetlen
packetlen:
	dc.l	0
unreadbytes:
	dc.l	0
senddata:
	blk.b		dd_SIZEOF,0

newpacket:
	dc.b	0
inescape:
	dc.b	0

	
ERR_BADCMD:
	dc.b	"DANet_Nullmodem: Bad net cmd: % i",10,0
ERR_TICSGET:
	dc.b	"DANet_Nullmodem: Too many tics [get]",10,0
ERR_TICSSEND:
	dc.b	"DANet_Nullmodem: Too many tics [send]",10,0

	SECTION Data,DATA
	
localbuffer:
	ds.b		MAXPACKET*2+2

	END

