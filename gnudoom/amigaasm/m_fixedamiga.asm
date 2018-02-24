	MACHINE 68040
	PMMU

	incdir AINCLUDE:
	
	include exec/types.i
	include hardware/cia.i
	include lvo/exec_lib.i

	include "DoomFont.i"
	include "amiga_mmu.i"
	include "d_engine.i"

	xref	_ciaa
	
SLOPERANGE=2048

MAXWIDTH=320
MAXHEIGHT=512

SCREENWIDTH=320
SCREENHEIGHT=200

FUZZTABLE=50

	SECTION mfixedamiga,CODE

;/*= SWAPLONG ===================================================================*/

	XDEF	_SWAPLONG
	CNOP	0,4

_SWAPLONG:
	move.l	4(sp),d0
	ror.w		#8,d0
	swap		d0
	ror.w		#8,d0
	rts

;/*= mmu_mark ===================================================================*/

	IFND    TRUE
TRUE EQU    1
	ENDC

	IFND    FALSE
FALSE EQU   0
	ENDC

*
*   FUNCTION
*       UBYTE __asm mmu_mark (register __a0 UBYTE *start,
*                             register __d0 ULONG length,
*                             register __d1 ULONG cm,
*                             register __a6 struct ExecBase *SysBase);
*
*   SYNOPSIS
*       Changes the cache mode for the specified memory area. This
*       area  must be aligned by 4kB and be multiple of 4kB in size.
*
*   RESULT
*       Returns the old cache mode for the memory area.
*
*   NOTES
*       Works only after setpatch has been issued and in such
*       systems where 68040.library/68060.library is correctly
*       installed.
*

		XDEF	_mmu_mark
		CNOP	0,4

_mmu_mark:
		move.l	a6,-(sp)

		move.l	4+4(sp),a0
		move.l	4+8(sp),d0
		move.l	4+12(sp),d1
		move.l	4+16(sp),a6
		bsr.s		mmu_mark
		
		move.l	(sp)+,a6
		rts

mmu_mark
		movem.l	d2/d3/d7/a2/a4/a6,-(sp)

		move.l	a1,a4
		movem.l	d0/d1/a0,-(sp)
		jsr	(_LVOSuperState,a6)
		movec	tc,d3			; translation code register
		movec	urp,d2			; user root pointer
		jsr	(_LVOUserState,a6)
		movem.l	(sp)+,d0/d1/a0

		btst	#TCB_E,d3
		beq	.error
		btst	#TCB_P,d3
		bne	.error

		move.l	d1,-(sp)
		move.l	d0,d1

		lsr.l	#8,d0
		lsr.l	#4,d0

		move.l	a0,a1

		and.w	#$fff,d1
		beq.s	.skip_a
		addq.l	#1,d0
.skip_a
		move.l	(sp)+,d1
		subq.l	#1,d0
		move.l	d0,d7

; a1 - chunkybuffer
; d7 - counter
; d2 - urp
; d1 - cache mode

.loop
		move.l	d2,-(sp)
		move.l	a1,d0
		rol.l	#8,d0
		lsl.l	#1,d0
		and.w	#%1111111000000000,d2
		and.w	#%0000000111111100,d0
		or.w	d0,d2
		move.l	d2,a2
		move.l	(a2),d2
		btst	#TDB_UDT0,d2
		beq	.skip			; if 0
		btst	#TDB_UDT1,d2		; if 1
		beq	.end
		bra	.skip2
.skip
		btst	#TDB_UDT1,d2
		bne	.end
.skip2
		move.l	a1,d0
		lsr.l	#8,d0
		lsr.l	#8,d0
		and.w	#%1111111000000000,d2
		and.w	#%0000000111111100,d0
		or.w	d0,d2
		move.l	d2,a2
		move.l	(a2),d2
		btst	#TDB_UDT0,d2
		beq	.skip1			; if 0
		btst	#TDB_UDT1,d2		; if 1
		beq	.end
		bra	.skip3
.skip1
		btst	#TDB_UDT1,d2
		bne	.end
.skip3
		move.l	a1,d0
		lsr.l	#8,d0
		lsr.l	#2,d0
		and.w	#%1111111100000000,d2
		and.w	#%0000000011111100,d0
		or.w	d0,d2

		move.l	d2,a2
		btst	#PDB_PDT1,(3,a2)
		bne	.skip4
		btst	#PDB_PDT0,(3,a2)
		beq	.end
		bra	.skip5
.skip4
		btst	#PDB_PDT0,(3,a2)
		beq	.indirect
.skip5
		move.b	(3,a2),d3
		and.b	#~CM_MASK,(3,a2)
		or.b	d1,(3,a2)

.indirect
		lea	(4096,a1),a1

		move.l	(sp)+,d2
		dbf	d7,.loop

		and.b	#CM_MASK,d3
		jsr	(_LVOSuperState,a6)
		pflusha
		jsr	(_LVOUserState,a6)

		moveq	#0,d0
		move.b	d3,d0

		movem.l	(sp)+,d2/d3/d7/a2/a4/a6
		rts
.end
		move.l	(sp)+,d2
.error
		movem.l	(sp)+,d2/d3/d7/a2/a4/a6
		moveq	#0,d0
		rts

;/*= mmu_stuff2 =================================================================*/

	XDEF	_mmu_stuff2
	CNOP	0,4
	
_mmu_stuff2:
	move.l	a6,-(sp)

	move.l	4.w,a6
	jsr		_LVOSuperState(a6)        ; must be executed in supervisor mode

	moveq		#0,d1           ; set up
	movec		d1,DTT1         ; MMU registers
	movec		d1,ITT1
	movec		d1,ITT0
	move.l	#$0106e020,d1
	movec		d1,DTT0         ; to return to the original state, write
									 ; zero to this register.

; Meaning of bits in ITT/DTT (Instruction/Data Transparent Translation)
; registers:

; %BBBBBBBBMMMMMMMMESS000UU0CC00W00

; B - Logical Address Base - compared with address bits A31-A24. Addresses
;                            that match in this comparision are
;                            transparently translated
; M - Logical Address Mask - setting a bit in this field causes
;                            corresponding bit in Base field to be ignored
; E - Enable Bit - 1 - translation enabled; 0 - disabled
; S - Supervisor Mode - 00 - match only in user mode
;                       01 - match only in supervisor mode
;                       1x - ignore mode when matching
; U - User Page Attributes - ignored by 040
; C - Cache mode - 00 - Cacheable, Write-through
;                  01 - Cacheable, Copyback
;                  10 - Noncacheable, Serialized
;                  11 - Noncacheable
; W - Write protect - 0 - write permitted; 1 - write disabled

;//	move.l	4.w,a6
	jsr		_LVOUserState(a6)        ; return to user mode

	move.l	(sp)+,a6
	rts
        
;/*= mmu_stuff2_cleanup =========================================================*/

	XDEF	_mmu_stuff2_cleanup
	CNOP	0,4
	
_mmu_stuff2_cleanup:
	move.l	a6,-(sp)

	move.l	4.w,a6
	jsr		_LVOSuperState(a6)        ; must be executed in supervisor mode
	
	moveq		#0,d1
	movec		d1,DTT0         ; to return to the original state, write
									 ; zero to this register.
	
	jsr		_LVOUserState(a6)
	
	move.l	(sp)+,a6
	rts

;/*= TextChunky =================================================================*/

;4(sp) = framebuffer; 8(sp) = text; 12(sp) = textlen ; 16(sp) = posx ; 20(sp) = posy;24(sp) = color a;28(sp) = color b

	XDEF	_TextChunky
	XREF	_yoffsettable
	CNOP	0,4
	
_TextChunky:
	movem.l	d2-d7/a2-a3,-(sp)
	
	move.l	8*4+20(sp),d0

	lea		_yoffsettable,a0
	move.l	4(a0),d6
	move.l	d6,d7
	subq.l	#8,d6					;d6 = zeichenmodulo
	lsl.l		#3,d7
	neg.l		d7
	addq.l	#8,d7					;d7 = zielzeichenmodulo
	
	move.l	(a0,d0.w*4),a0
	add.l		8*4+4(sp),a0
	add.l		8*4+16(sp),a0		;a0 = ziel
	
	move.l	8*4+8(sp),a1			;a1 = text
	lea		DoomFontData,a2	;a2 = Font
	move.l	8*4+12(sp),d1
	subq		#1,d1				;d1 = loopcounter

	move.l	8*4+24(sp),d2		;d2 = FG
	move.l	8*4+28(sp),d3		;d3 = BG

.charloop:
	moveq		#0,d0
	move.b	(a1)+,d0
	lea		(a2,d0.w*8),a3		;a3 = Zeichen
	
	moveq	#7,d0

.zeilenloop:
	moveq	#7,d4
	
.pixelloop:
	move.b	(a3)+,d5
	beq.s		.bg
	
	move.b	d2,(a0)+
	bra.s		.nextpixel
	
.bg:
	move.b	d3,(a0)+
	
.nextpixel:
	dbf		d4,.pixelloop
	
	lea		DOOMFONTWIDTH-8(a3),a3
	add.w		d6,a0
	dbf		d0,.zeilenloop
	add.w		d7,a0
	dbf		d1,.charloop

	movem.l	(sp)+,d2-d7/a2-a3
	rts

	
	
;/*= Chunky2Planar for ILBM saver ===============================================*/

Quelle=11*4+4
Ziel=11*4+4+4
bytes=11*4+4+8
Planes=11*4+4+12

	XDEF	_Chunky2Planar
	CNOP	0,4
	
_Chunky2Planar:
	movem.l	d2-d7/a2-a6,-(sp)
	
	move.l	Ziel(sp),a1
	move.l	Quelle(sp),a3
	move.l	bytes(sp),d0
	lea		0(a3,d0.l),a3
	move.l	a3,Quelle(sp)
	move	d0,d4
	lsr		#4,d0
	moveq	#0,d1
	move	d0,d1
	add		d1,d1				;(* d1 = Modulo *)
	subq	#1,d0				;(* d0 = Counter X *)
	move.l	Planes(sp),d3		;(* d3 = Counter Planes *)
	lea		0(a1,d1),a1
	add		d1,d1
	subq	#1,d3

.Loop1:
	move.l	Quelle(sp),a3
	move	d0,d2
.Loop2:
	move.b	-(a3),d5
	ror.l	#1,d5
	move.b	d5,(a3)
	move.b	-(a3),d5
	ror.l	#1,d5
	move.b	d5,(a3)
	move.b	-(a3),d5
	ror.l	#1,d5
	move.b	d5,(a3)
	move.b	-(a3),d5
	ror.l	#1,d5
	move.b	d5,(a3)
	move.b	-(a3),d5
	ror.l	#1,d5
	move.b	d5,(a3)
	move.b	-(a3),d5
	ror.l	#1,d5
	move.b	d5,(a3)
	move.b	-(a3),d5
	ror.l	#1,d5
	move.b	d5,(a3)
	move.b	-(a3),d5
	ror.l	#1,d5
	move.b	d5,(a3)
	move.b	-(a3),d5
	ror.l	#1,d5
	move.b	d5,(a3)
	move.b	-(a3),d5
	ror.l	#1,d5
	move.b	d5,(a3)
	move.b	-(a3),d5
	ror.l	#1,d5
	move.b	d5,(a3)
	move.b	-(a3),d5
	ror.l	#1,d5
	move.b	d5,(a3)
	move.b	-(a3),d5
	ror.l	#1,d5
	move.b	d5,(a3)
	move.b	-(a3),d5
	ror.l	#1,d5
	move.b	d5,(a3)
	move.b	-(a3),d5
	ror.l	#1,d5
	move.b	d5,(a3)
	move.b	-(a3),d5
	ror.l	#1,d5
	move.b	d5,(a3)
	swap	d5
	move	d5,-(a1)
	dbf		d2,.Loop2
	add.l	d1,a1
	dbf		d3,.Loop1
	movem.l	(sp)+,d2-d7/a2-a6
	rts


;/*= RemapScreen for Window mode =================================================*/

	;4(sp) source
	;8(sp) dest
	;12(sp) size in bytes
	
	XDEF	_RemapScreen
	XREF	_RemapTablePTR			;// WORDs !! 65536
	XREF	_paletteindex
	XREF	_DoFastRemap
	CNOP	0,4
	
_RemapScreen:
	movem.l	d2-d3/a2,-(sp)

	lea		_RemapTablePTR,a0
	move.l	_paletteindex,d0
	move.l	(a0,d0.w*4),a0			;// a0 = remaptable

	move.l	3*4+4(sp),a1				;// a1 = source
	move.l	3*4+8(sp),a2				;// a2 = dest
	move.l	3*4+12(sp),d0			;// d0 = size
	lsr.l		#5,d0					;// size / 32
	subq		#1,d0
	move.l	a0,d1
	tst.l		_DoFastRemap
	beq.s		.slowloop
	moveq		#0,d1
	
.loop:

	REPT		8

	move.w	(a1)+,d1
	move.w	(a0,d1.l*2),d2
	swap		d2
	move.w	(a1)+,d1
	move.w	(a0,d1.l*2),d2
	move.l	d2,(a2)+

	ENDR

	dbf		d0,.loop
	bra.s		.done

.slowloop:

	REPT		8

	move.l	(a1)+,d3			;ABCD
	rol.l		#8,d3				;BCDA

	move.b	d3,d1
	move.l	d1,a0
	move		(a0),d2			;??A?
	
	rol.l		#8,d3				;CDAB
	move.b	d3,d1
	move.l	d1,a0
	move.b	(a0),d2			;??AB
	
	rol.l		#8,d3				;DABC
	move.b	d3,d1
	swap		d2					;AB??
	move.l	d1,a0
	move		(a0),d2			;ABC?
	
	rol.l		#8,d3				;ABCD
	move.b	d3,d1
	move.l	d1,a0
	move.b	(a0),d2			;ABCD
	
	move.l	d2,(a2)+
	ENDR

	dbf		d0,.slowloop

.done:
	movem.l	(sp)+,d2-d3/a2
	rts
	
;/*= MyInputHandler ===================================================================*/

	XDEF	_MyInputHandler
	XREF	_C_MyInputHandler
	CNOP	0,4
	
_MyInputHandler:
	move.l	a0,-(sp)
	jsr		_C_MyInputHandler
	addq.l	#4,sp
	rts


;/*= SoundFilter_Get ==============================================================*/

	XDEF	_SoundFilter_Get
	CNOP	0,4
	
_SoundFilter_Get:
	move.l	a6,-(sp)
	move.l	4.w,a6

	jsr		_LVODisable(a6)
	
	lea		_ciaa,a0
	moveq		#0,d0
	move.b	ciapra(a0),d0
	
	jsr		_LVOEnable(a6)

	and.b		#CIAF_LED,d0
	sne		d1
	neg.b		d1
	and.b		d1,d0
	
	move.l	(sp)+,a6
	rts


;/*= SoundFilter_Set ==============================================================*/

	XDEF	_SoundFilter_Set
	CNOP	0,4
	
_SoundFilter_Set:
	move.l	a6,-(sp)
	move.l	4.w,a6

	jsr		_LVODisable(a6)
	
	lea		_ciaa,a0
	move.b	ciapra(a0),d0
	
	tst.l		4+4(sp)
	beq.s		.clear
	
	or.b		#CIAF_LED,d0
	bra.s		.done

.clear:
	and.b		#~CIAF_LED,d0
	
.done
	move.b	d0,ciapra(a0)
	jsr		_LVOEnable(a6)

	move.l	(sp)+,a6
	rts

;/*= Z_Free ====================================================================*/

	XDEF	_Z_Free
	XREF	_mainzone
	XREF	_I_Error

	CNOP	0,4
	
_Z_Free:			;// (void *ptr)
	move.l	4(sp),a0

_Z_Free_ASM:
	move.l	a2,d1				;' save a2

;//    memblock_t*		block;
;//    memblock_t*		other;
	
;//    block = (memblock_t *) ( (byte *)ptr - sizeof(memblock_t));

	lea		-mb_SIZEOF(a0),a0
	
;//    if (block->id != ZONEID)
;//	I_Error ("Z_Free: freed a pointer without ZONEID");
	cmp.l		#ZONEID,mb_id(a0)
	bne.s		.error
	
;//    if (block->user > (void **)0x100)
;//    {
	move.l	mb_user(a0),a1
	cmp.l		#$100,a1
	bls.s		.not

;//	/* smaller values are not pointers*/
;//	/* Note: OS-dependend?*/
	
;//	/* clear the user's mark*/
;//	*block->user = 0;
	clr.l		(a1)
;//    }

.not:

;//    /* mark as free*/
;//    block->user = NULL;	
;//    block->tag = 0;
;//    block->id = 0;
	clr.l		mb_user(a0)
	clr.l		mb_tag(a0)
	clr.l		mb_id(a0)

;//    other = block->prev;
	move.l	mb_prev(a0),a1				;'a1 = other

;//    if (!other->user)
;//    {
	tst.l		mb_user(a1)
	bne.s		.has_user

;//	/* merge with previous free block*/
;//	other->size += block->size;
	move.l	mb_size(a0),d0
	add.l		d0,mb_size(a1)

;//	other->next = block->next;
	move.l	mb_next(a0),a2
	move.l	a2,mb_next(a1)

;//	other->next->prev = other;
	move.l	a1,mb_prev(a2)

;//	if (block == mainzone->rover)
;//	    mainzone->rover = other;
	move.l	_mainzone,a2
	cmp.l		mz_rover(a2),a0
	bne.s		.nein

	move.l	a1,mz_rover(a2)

.nein:
;//	block = other;
	move.l	a1,a0

;//    }

.has_user:	
;//    other = block->next;
	move.l	mb_next(a0),a1				;'a1 = other

;//    if (!other->user)
;//    {
	tst.l		mb_user(a1)
	bne.s		.has_user2

;//	/* merge the next free block onto the end*/
;//	block->size += other->size;
	move.l		mb_size(a1),d0
	add.l			d0,mb_size(a0)

;//	block->next = other->next;
	move.l	mb_next(a1),a2
	move.l	a2,mb_next(a0)
	
;//	block->next->prev = block;
	move.l	a0,mb_prev(a2)
	
;//	if (other == mainzone->rover)
;//	    mainzone->rover = block;
	move.l	_mainzone,a2
	cmp.l		mz_rover(a2),a1
	bne.s		.nein2
	move.l	a0,mz_rover(a2)

.nein2:
;//    }

.has_user2:
	move.l	d1,a2				;'restore a2
	rts
	
.error:
	pea		_ERRTEXT_ZFree(pc)
	jsr		_I_Error
	;// does not return

;/*= Z_Malloc ====================================================================*/

	XDEF _Z_Malloc

ZMSPOFF = 8
	
_Z_Malloc:			;// (int size, int tag, void *user)
;//    int		extra;
;//    memblock_t*	start;
;//    memblock_t* rover;
;//    memblock_t* newblock;
;//    memblock_t*	base;

	movem.l	a2/a3,-(sp)

;//    size = (size + 3) & ~3;
	moveq		#mb_SIZEOF+3,d0
	add.l		ZMSPOFF+4(sp),d0
;//	moveq		#~3,d1
	moveq		#-4,d1

	and.l		d1,d0									;' d0 = size
    
;//    /* scan through the block list,*/
;//    /* looking for the first free block*/
;//    /* of sufficient size,*/
;//    /* throwing out any purgable blocks along the way.*/

;//    /* account for size of block header*/

;//    size += sizeof(memblock_t);
;' siehe oben!
    
;//    /* if there is a free block behind the rover,*/
;//    /*  back up over them*/
;//    base = mainzone->rover;
	move.l	_mainzone,a0					;'a0 = mainzone
	move.l	mz_rover(a0),a1				;'a1 = base
    
;//    if (!base->prev->user)
;//	base = base->prev;
	move.l	mb_prev(a1),a2
	tst.l		mb_user(a2)
	bne.s		.isok
	
	move.l	a2,a1
	
.isok:
;//    rover = base;
	move.l	a1,a2								;'a2 = rover

;//    start = base->prev;
	move.l	mb_prev(a1),a3					;'a3 = start

;//    do
;//    {
.while:
;//	if (rover == start)
;//	{
;//	    /* scanned all the way around the list*/
;//	    I_Error ("Z_Malloc: failed on allocation of %i bytes", size);
;//	}
	cmp.l		a2,a3
	beq.s		.error1
	
;//	if (rover->user)
;//	{
	tst.l		mb_user(a2)
	beq.s		.noroveruser

;//	    if (rover->tag < PU_PURGELEVEL)
;//	    {
	moveq		#PU_PURGELEVEL,d1
	cmp.l		mb_tag(a2),d1
	ble.s		.badpurgelevel
	
;//		/* hit a block that can't be purged,*/
;//		/*  so move base past it*/
;//		base = rover = rover->next;
	move.l	mb_next(a2),a2
	move.l	a2,a1

;//	    }
;//	bra.s		.later
	bra.s		.whilecheck
	

;//	    else
;//	    {
.badpurgelevel:
;//		/* free the rover block (adding the size to base)*/

;//		/* the rover can be the base block*/
;//		base = base->prev;
	move.l	mb_prev(a1),a1

;//		Z_Free ((byte *)rover+sizeof(memblock_t));
	movem.l	d0/a0/a1,-(sp)
	lea		mb_SIZEOF(a2),a0
	bsr.s		_Z_Free_ASM
	movem.l	(sp)+,d0/a0/a1
	
;//		base = base->next;
	move.l	mb_next(a1),a1

;//		rover = base->next;
	move.l	mb_next(a1),a2

;//	    }
;//.later:
;//	bra.s		.whilecheck
	bra.s		.whilecheck

;//	}
;//	else

.noroveruser:
;//	    rover = rover->next;
	move.l	mb_next(a2),a2  

;//    } while (base->user || base->size < size);
.whilecheck:
	tst.l		mb_user(a1)
	bne.s		.while
	cmp.l		mb_size(a1),d0
	bgt.s		.while

;//    /* found a block big enough*/
;//    extra = base->size - size;
	move.l	mb_size(a1),a3
	sub.l		d0,a3						;'a3 = extra
    
;//    if (extra >  MINFRAGMENT)
;//    {
	moveq		#MINFRAGMENT,d1
	cmp.l		d1,a3
	ble.s		.tosmall

;//	/* there will be a free fragment after the allocated block*/
;//	newblock = (memblock_t *) ((byte *)base + size );
	move.l	a1,a2
	add.l		d0,a2						;'a2 = newblock

;//	newblock->size = extra;
	move.l	a3,mb_size(a2)
	
;//	/* NULL indicates free block.*/
;//	newblock->user = NULL;	
	clr.l		mb_user(a2)

;//	newblock->tag = 0;
	clr.l		mb_tag(a2)

;//	newblock->prev = base;
	move.l	a1,mb_prev(a2)

;//	newblock->next = base->next;
	move.l	mb_next(a1),a3
	move.l	a3,mb_next(a2)

;//	newblock->next->prev = newblock;
	move.l	a2,mb_prev(a3)

;//	base->next = newblock;
	move.l	a2,mb_next(a1)

;//	base->size = size
	move.l	d0,mb_size(a1)

;//    }

.tosmall:
;//    if (user)
;//    {
	move.l	ZMSPOFF+12(sp),d1
	beq.s		.keinuser

;//	/* mark as an in use block*/
;//	base->user = user;
	move.l	d1,mb_user(a1)

;//	*(void **)user = (void *) ((byte *)base + sizeof(memblock_t));
	lea		mb_SIZEOF(a1),a3
	move.l	d1,a2
	move.l	a3,(a2)

;//    }
	bra.s		.weiter

;//    else
;//    {
.keinuser:
;//	if (tag >= PU_PURGELEVEL)
;//	    I_Error ("Z_Malloc: an owner is required for purgable blocks");
	moveq		#PU_PURGELEVEL,d1
	cmp.l		ZMSPOFF+8(sp),d1
	ble.s		.error2

;//	/* mark as in use, but unowned	*/
;//	base->user = (void *)2;		
	moveq		#2,d1
	move.l	d1,mb_user(a1)

;//    }

.weiter:
;//    base->tag = tag;
	move.l	ZMSPOFF+8(sp),mb_tag(a1)

;//    /* next allocation will start looking here*/
;//    mainzone->rover = base->next;	
	move.l	mb_next(a1),mz_rover(a0)
	
;//    base->id = ZONEID;
	move.l	#ZONEID,mb_id(a1)
    
;//    return (void *) ((byte *)base + sizeof(memblock_t));
	moveq		#mb_SIZEOF,d0
	add.l		a1,d0
	
	movem.l	(sp)+,a2/a3
	rts

;//----

.error1:
	move.l	d0,-(sp)
	pea		_ERRTEXT_ZMalloc(pc)
	jsr		_I_Error
	;// does not return

.error2:
	pea		_ERRTEXT_ZMalloc2(pc)
	jsr		_I_Error
	;// does not return




;/*= STRINGS STRINGS STRINGS STRINGS STRINGS ====================================*/
	
	XDEF	_ERRTEXT_CacheLumpNum
	
_ERRTEXT_CacheLumpNum:
	dc.b "W_CacheLumpNum: %i >= numlumps",0

_ERRTEXT_ZFree:
	dc.b	"Z_Free: freed a pointer without ZONEID",0

_ERRTEXT_ZMalloc:
	dc.b	"Z_Malloc: failed on allocation of %i bytes",0

_ERRTEXT_ZMalloc2:
	dc.b	"Z_Malloc: an owner is required for purgable blocks",0

	END
	
