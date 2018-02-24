		MACHINE 68020

		incdir	"AINCLUDE:"
		
		include "hardware/custom.i"
		include "dos/dos.i"
		include "lvo/exec_lib.i"
		include "lvo/graphics_lib.i"
		include "c2p.i"
		
		moveq	#-1,d0
		rts
		dc.b		'C2P',0
		dc.l		Chunky2Planar
		dc.l		InitChunky
		dc.l		EndChunky
		dc.l		C2PF_OWNSCREENFLIP

		
BPLSIZE		equ	8000


		;Init routine
		;4(sp) Width
		;8(sp) Height
		;12(sp) PlaneSize
		;16(sp) C2PInit 


; 1x1  CPU3BLIT1 C2P  (030 optimized)
; Release date: 30 Aug 96
; Do not distribute under original name in modified form, please
;
;
; This is one of the very fastest C2Ps ever made!
; It was made by me, Scout/C-Lous, a short time ago, with aid, support and
; ideas from Touchstone/Essence and Azure/Artwork.
;
; The biggest improvement in this algorithm is the new and wonderful
; merge-op.
; The "normal" merge looks like this:
;
; ; d0 data1, d1 data2, d5 mask, d6 temp, d7 temp
;       move.l  d0,d6           ;2
;       move.l  d1,d7           ;2
;       and.l   d5,d6           ;2
;       and.l   d5,d1           ;2
;       eor.l   d6,d0           ;2
;       eor.l   d1,d7           ;2
;       lsl.l   #n,d6           ;4
;       lsr.l   #n,d7           ;4
;       or.l    d6,d1           ;2
;       or.l    d7,d0           ;2
;                               ; = 24 clocks
;
; One month ago I spoke to Touchstone, and he told me that it indeed was
; possible to create more efficient merge-ops. After a while I came up with
; this:
;
; ; d0 data1, d1 data2, d5 mask, d7 temp
;       move.l  d1,d7           ;2
;       lsr.l   #n,d7           ;4
;       eor.l   d0,d7           ;2
;       and.l   d5,d7           ;2
;       eor.l   d7,d0           ;2
;       lsl.l   #n,d7           ;4
;       eor.l   d7,d1           ;2
;                               ; = 18 clocks!
;
; This is (as far as I know) the currently fastest merge-op invented.
; It gives the routine quite a speed-boost and makes it shorter (thus
; easier to fit into the cache).
;
; If you want to contact me (or any of the others for that matter)
; look on IRC in #amigascne!
; Or you can email me at kalms@vasa.gavle.se...
;
; Oh, by the way... This isn't the fastest routine possible; our current
; are a bit below this one... That's a very good reason for you to write
; your own ;) <I want to see more evolution in this field :)>

;       The routine itself
;
; It has some features -- you'll probably notice them :)
;
; It uses graphics.library/QBlit(), which may be of trouble to those
; of you who throw out all of the system. (You probably have homebrew
; blitterqueues then, and it's easy to modify the blitter-routs herein.)
;
; C2P_DOUBLEBUFFER: If nonzero, then 2 chipmem-blitbufs will be used.
;                   It takes double the amount of chipmem, but
;                   it speeds up if the blitterpass is slower than the
;                   effect (and the blitterpass thus collides with
;                   the next frame's cpupass)
;
; An example of how to use this routine:
;
;       move.w  #320,d0
;       move.w  #256,d1
;       clr.w   d3
;       move.l  #10240,d5
;       bsr     c2p1x1_cpu3blit1_queue_init
;       ...
;main:
;       lea     chunkyscreen,a0
;       move.l  screenptr,a1
;       bsr     c2p1x1_cpu3blit1_queue
;       bsr     effect
;       btst    #6,$bfe001
;       bne.s   main
;
; The screenswapping should be done in the c2p_waitblit routine,
; which is called by the C2P rout.
;
; I hope I didn't forget anything... :)
;

        IFND    C2P_DOUBLEBUFFER
C2P_DOUBLEBUFFER EQU 0
        ENDC
        IFND    CHUNKYXMAX
CHUNKYXMAX EQU  320
        ENDC
        IFND    CHUNKYYMAX
CHUNKYYMAX EQU  200
        ENDC

        section c2p,code

qblit
; Use this or put your own queue-handler here
        move.l  a6,-(sp)
        move.l  gfxbase(pc),a6
        jsr     _LVOQBlit(a6)
        move.l  (sp)+,a6
        rts

;/**** Chunky2Planar init routine *****************************************/
	
InitChunky:
		move.l	4.w,_SysBase

		move.l	16(sp),a0
		move.l	c2pi_GfxBase(a0),gfxbase
		move.l	c2pi_ScreenFlipRoutine(a0),fliproutine
		
        movem.l d2-d5,-(sp)
		move.l	4+16(sp),d0
		move.l	8+16(sp),d1
		moveq	#0,d3
		move.l	12+16(sp),d5
		
; d0.w  chunkyx [chunky-pixels]
; d1.w  chunkyy [chunky-pixels]
; d3.w  scroffsy [screen-pixels]
; d5.l  bplsize [bytes] -- offset between one row in one bpl and the next bpl

        lea     c2p_datanew(pc),a0
        andi.l  #$ffff,d0
        andi.l  #$ffff,d2
        move.l  d5,c2p_bplsize-c2p_data(a0)
        move.w  d1,c2p_chunkyy-c2p_data(a0)
        add.w   d3,d1
        mulu.w  d0,d1
        lsr.l   #3,d1
        subq.l  #2,d1
        move.l  d1,c2p_scroffs2-c2p_data(a0)
        mulu.w  d0,d3
        lsr.l   #3,d3
        move.l  d3,c2p_scroffs-c2p_data(a0)
        move.w  c2p_chunkyy-c2p_data(a0),d1
        mulu.w  d0,d1
        move.l  d1,c2p_pixels-c2p_data(a0)
        lsr.l   #4,d1
        move.l  d1,c2p_pixels16-c2p_data(a0)

        movem.l (sp)+,d2-d5
        
		move.l	a6,-(sp)
		move.l	_SysBase(pc),a6

		sub.l	a1,a1
		jsr		_LVOFindTask(a6)
		move.l	d0,thistask
		move.l	d0,a1

		moveq	#-1,d0
		jsr		_LVOAllocSignal(a6)
		
		cmp.l	#-1,d0
		beq.s	.error
		
		move.l	d0,qblitsig
		moveq	#1,d1
		lsl.l	d0,d1
		move.l	d1,qblitmask

		bsr		MakeFlipTask
		tst.l	fliptask(pc)
		beq.s	.error

.ok:
		move.l	(sp)+,a6
        moveq	#1,d0
        rts

.error:
		move.l	(sp)+,a6
		moveq	#0,d0
        rts

;/**** MakeFlipTask *******************************************************/

		XREF	_CreateTask

MakeFlipTask:
		move.l	a6,-(sp)

		pea		4096.w				;stack
		pea		MyFlipTask(pc)		;function
		pea		5.w					;priority
		pea		FlipTaskName(pc)	;taskname
		jsr		_CreateTask
		lea		4*4(sp),sp
		
		move.l	d0,fliptask
		beq.s	.done
		
		move.l	_SysBase(pc),a6
		move.l	#SIGBREAKF_CTRL_F,d0
		jsr		_LVOWait(a6)
		
		tst		fliptaskok(pc)
		bne.s	.done
		
		bsr.s	KillFlipTask
		
.done:
		move.l	(sp)+,a6
		rts

FlipTaskName: dc.b 'DoomAttack Flip Task',0

		even

;/**** KillFlipTask *******************************************************/

		XREF	_DeleteTask

KillFlipTask:
		movem.l	d2/a6,-(sp)

		move.l	fliptask(pc),d2
		beq.s	.done
		
		move.l	_SysBase(pc),a6
		move.l	d2,a1
		move.l	#SIGBREAKF_CTRL_C,d0
		jsr		_LVOSignal(a6)			;send quit

		move.l	#SIGBREAKF_CTRL_E,d0
		jsr		_LVOWait(a6)
		
		move.l	d2,-(sp)
		jsr		_DeleteTask
		addq.l	#4,sp

		clr.l	fliptask

.done:
		movem.l	(sp)+,d2/a6
		rts
	
;/**** Chunky2Planar cleanup routine **************************************/

EndChunky:
		bsr.s	KillFlipTask

		move.l	a6,-(sp)
		move.l	qblitsig(pc),d0
		cmp.l	#-1,d0
		beq.s	.done
		
		move.l	_SysBase(pc),a6
		jsr		_LVOFreeSignal(a6)
.done:
		move.l	(sp)+,a6
		rts

;/**** MyFlipTask ********** **********************************************/

MyFlipTask:
		move.l	a6,-(sp)

		move.l	_SysBase(pc),a6			;get ExecBase
		moveq	#-1,d0					;any signal is O.K.
		jsr		_LVOAllocSignal(a6)		;alloc signal
		move.l	d0,flipsig
		cmp.l	#-1,d0
		beq.s	.arrrgh					;no signal?
		
		moveq	#1,d1
		lsl.l	d0,d1
		move.l	d1,flipmask

		move	#1,fliptaskok
		clr		done

.arrrgh:
		move.l	thistask(pc),a1
		move.l	#SIGBREAKF_CTRL_F,d0
		jsr		_LVOSignal(a6)			;we're ready!
		
.loop:
		tst		done(pc)
		bne.s	.exit
		
		move.l	flipmask(pc),d0
		or.l	#SIGBREAKF_CTRL_C,d0
		jsr		_LVOWait(a6)
		
		move.l	d0,d1
		and.l	#SIGBREAKF_CTRL_C,d1
		beq.s	.nobreak
		move	#1,done
		
.nobreak:
		and.l	flipmask(pc),d0
		beq.s	.noflip
		
		jsr		([fliproutine,pc])
.noflip:
		bra.s	.loop

.exit:
		move.l	flipsig(pc),d0
		cmp.l	#-1,d0
		beq.s	.nosig
		
		jsr		_LVOFreeSignal(a6)

.nosig:
		move.l	thistask(pc),a1
		move.l	#SIGBREAKF_CTRL_E,d0
		jsr		_LVOSignal(a6)
		
		moveq	#0,d0
		jsr		_LVOWait(a6)

		move.l	(sp)+,a6
		rts

done:	dc.w 1

;/**** QBlit cleanup routine **********************************************/
	
c2p_blitcleanup
		move.l	a6,-(sp)
		move.l	_SysBase(pc),a6
		move.l	thistask(pc),a1
		move.l	qblitmask(pc),d0
		jsr		_LVOSignal(a6)
		
		move.l	fliptask(pc),a1
		move.l	flipmask(pc),d0
		jsr		_LVOSignal(a6)
        move.l	(sp)+,a6
        rts


;/**** c2p_waitblit *******************************************************/

c2p_waitblit
		move.l	a6,-(sp)

		tst.w	first(pc)
		beq.s	.ok
		clr.w	first
		bra.s	.skip

.ok:
		; wait for signal from QBlit cleanup routine
		move.l	_SysBase(pc),a6
		move.l	qblitmask(pc),d0
		jsr		_LVOWait(a6)

; This is where you would add your swap-screens-code.

;		jsr		([fliproutine,pc])
.skip:

		move.l	(sp)+,a6
        rts

; a0    c2pscreen
; a1    bitplanes

		XDEF	_SysBase

_SysBase:	dc.l 0
gfxbase:	dc.l 0
fliproutine: dc.l 0

thistask:	dc.l 0
qblitmask:	dc.l 0
qblitsig:	dc.l -1

fliptask:	dc.l 0
flipmask:	dc.l 0
flipsig:	dc.l -1
first:		dc.w 1
fliptaskok:	dc.w 0

		cnop	0,8

Chunky2Planar:
        movem.l d2-d7/a2-a6,-(sp)

        IFEQ    C2P_DOUBLEBUFFER
        bsr.s   c2p_waitblit
        ENDC

		move.l	4+11*4(sp),a0	;chunky
		move.l	8+11*4(sp),a1	;planes

        lea     c2p_datanew(pc),a2
        move.l  a1,c2p_screen-c2p_data(a2)

        move.l  #$0f0f0f0f,a4
        move.l  #$00ff00ff,a5
        move.l  #$55555555,a6

        move.l  c2p_bufptrs,a1
        move.l  c2p_pixels-c2p_data(a2),a2
        add.l   a0,a2
        cmpa.l  a0,a2
        beq     .none
 
        move.l  (a0)+,d0
        move.l  (a0)+,d6
        move.l  (a0)+,a3
        move.l  (a0)+,d7
        move.l  a4,d5
        move.l  d6,d1                   ; Swap 4x1
        lsr.l   #4,d1
        eor.l   d0,d1
        and.l   d5,d1
        eor.l   d1,d0
        lsl.l   #4,d1
        eor.l   d6,d1

        move.l  a3,d6
        move.l  d7,d4
        lsr.l   #4,d4
        eor.l   d6,d4
        and.l   d5,d4
        eor.l   d4,d6
        lsl.l   #4,d4
        eor.l   d4,d7

        move.l  a5,d5
        move.l  d6,d2                   ; Swap 8x2, part 1
        lsr.l   #8,d2
        eor.l   d0,d2
        and.l   d5,d2
        eor.l   d2,d0
        lsl.l   #8,d2
        eor.l   d6,d2

        bra.s   .start
.x
        move.l  (a0)+,d0
        move.l  (a0)+,d6
        move.l  (a0)+,a3
        move.l  (a0)+,d7
        move.l  d1,(a1)+
        move.l  a4,d5
        move.l  d6,d1                   ; Swap 4x1
        lsr.l   #4,d1
        eor.l   d0,d1
        and.l   d5,d1
        eor.l   d1,d0
        lsl.l   #4,d1
        eor.l   d6,d1

        move.l  a3,d6
        move.l  d7,d4
        lsr.l   #4,d4
        move.l  d2,(a1)+
        eor.l   d6,d4
        and.l   d5,d4
        eor.l   d4,d6
        lsl.l   #4,d4
        eor.l   d4,d7

        move.l  a5,d5
        move.l  d6,d2                   ; Swap 8x2, part 1
        lsr.l   #8,d2
        eor.l   d0,d2
        and.l   d5,d2
        eor.l   d2,d0
        move.l  d3,(a1)+
        lsl.l   #8,d2
        eor.l   d6,d2
.start
        move.l  a6,d4
        move.l  d2,d3                   ; Swap 1x2, part 1
        lsr.l   #1,d3
        eor.l   d0,d3
        and.l   d4,d3
        eor.l   d3,d0
        add.l   d3,d3
        eor.l   d3,d2

        move.l  d7,d3                   ; Swap 8x2, part 2
        lsr.l   #8,d3
        move.l  d0,(a1)+
        eor.l   d1,d3
        and.l   d5,d3
        eor.l   d3,d1
        lsl.l   #8,d3
        eor.l   d7,d3

        move.l  d3,d6                   ; Swap 1x2, part 2
        lsr.l   #1,d6
        eor.l   d1,d6
        and.l   d4,d6
        eor.l   d6,d1
        add.l   d6,d6
        eor.l   d6,d3

        move.l  (a0)+,d0
        move.l  (a0)+,d6
        move.l  (a0)+,a3
        move.l  (a0)+,d7
        move.l  d1,(a1)+
        move.l  a4,d5
        move.l  d6,d1                   ; Swap 4x1
        lsr.l   #4,d1
        eor.l   d0,d1
        and.l   d5,d1
        eor.l   d1,d0
        lsl.l   #4,d1
        eor.l   d6,d1

        move.l  a3,d6
        move.l  d7,d4
        lsr.l   #4,d4
        move.l  d2,(a1)+
        eor.l   d6,d4
        and.l   d5,d4
        eor.l   d4,d6
        lsl.l   #4,d4
        eor.l   d4,d7

        move.l  a5,d5
        move.l  d6,d2                   ; Swap 8x2, part 1
        lsr.l   #8,d2
        eor.l   d0,d2
        and.l   d5,d2
        eor.l   d2,d0
        move.l  d3,(a1)+
        lsl.l   #8,d2
        eor.l   d6,d2

        move.l  a6,d4
        move.l  d2,d3                   ; Swap 1x2, part 1
        lsr.l   #1,d3
        eor.l   d0,d3
        and.l   d4,d3
        eor.l   d3,d0
        add.l   d3,d3
        eor.l   d3,d2

        move.l  d7,d3                   ; Swap 8x2, part 2
        lsr.l   #8,d3
        move.l  d0,(a1)+
        eor.l   d1,d3
        and.l   d5,d3
        eor.l   d3,d1
        lsl.l   #8,d3
        eor.l   d7,d3

        move.l  d3,d6                   ; Swap 1x2, part 2
        lsr.l   #1,d6
        eor.l   d1,d6
        and.l   d4,d6
        eor.l   d6,d1
        add.l   d6,d6
        eor.l   d6,d3

        cmp.l   a0,a2
        bne     .x
.x2
        move.l  d1,(a1)+
        move.l  d2,(a1)+
        move.l  d3,(a1)+

        IFNE    C2P_DOUBLEBUFFER
        bsr     c2p_waitblit
        move.l  c2p_bufptrs,d0
        move.l  c2p_bufptrs+4,c2p_bufptrs
        move.l  d0,c2p_bufptrs+4
        ENDC

        bsr     c2p_copyinitblock

        lea     c2p_data(pc),a2
        sf      c2p_blitfin-c2p_data(a2)
        st      c2p_blitactive-c2p_data(a2)
        lea     c2p_bltnode(pc),a1
        move.l  #c2p1x1_cpu3blit1_queue_41,c2p_bltroutptr-c2p_bltnode(a1)
        jsr     qblit

.none
        movem.l (sp)+,d2-d7/a2-a6
        rts

c2p1x1_cpu3blit1_queue_41               ; Pass 4, subpass 1, ascending
        move.w  #-1,bltafwm(a0)
        move.w  #-1,bltalwm(a0)
        move.l  c2p_bufptrs+4,d0
        add.l   #12,d0
        move.l  d0,bltapt(a0)
        addq.l  #2,d0
        move.l  d0,bltbpt(a0)
        move.l  c2p_bplsize-c2p_bltnode(a1),d0
        add.l   d0,d0
        add.l   c2p_screen-c2p_bltnode(a1),d0
        add.l   c2p_scroffs-c2p_bltnode(a1),d0
        move.l  d0,bltdpt(a0)
        move.w  #14,bltamod(a0)
        move.w  #14,bltbmod(a0)
        move.w  #0,bltdmod(a0)
        move.w  #$cccc,bltcdat(a0)
        move.w  #$0de4,bltcon0(a0)
        move.w  #$2000,bltcon1(a0)
        move.w  c2p_pixels16+2-c2p_bltnode(a1),bltsizv(a0)
        move.w  #1,bltsizh(a0)
        move.l  #c2p1x1_cpu3blit1_queue_42,c2p_bltroutptr-c2p_bltnode(a1)
        rts

c2p1x1_cpu3blit1_queue_42               ; Pass 4, subpass 2, ascending
        move.l  c2p_bufptrs+4,d0
        addq.l  #8,d0
        move.l  d0,bltapt(a0)
        addq.l  #2,d0
        move.l  d0,bltbpt(a0)
        move.l  c2p_bplsize-c2p_bltnode(a1),d0
        add.l   d0,d0
        add.l   c2p_bplsize-c2p_bltnode(a1),d0
        add.l   d0,d0
        add.l   c2p_screen-c2p_bltnode(a1),d0
        add.l   c2p_scroffs-c2p_bltnode(a1),d0
        move.l  d0,bltdpt(a0)
        move.w  c2p_pixels16+2-c2p_bltnode(a1),bltsizv(a0)
        move.w  #1,bltsizh(a0)
        move.l  #c2p1x1_cpu3blit1_queue_43,c2p_bltroutptr-c2p_bltnode(a1)
        rts

c2p1x1_cpu3blit1_queue_43               ; Pass 4, subpass 3, ascending
        move.l  c2p_bufptrs+4,d0
        addq.l  #4,d0
        move.l  d0,bltapt(a0)
        addq.l  #2,d0
        move.l  d0,bltbpt(a0)
        move.l  c2p_bplsize-c2p_bltnode(a1),d0
        add.l   d0,d0
        add.l   c2p_bplsize-c2p_bltnode(a1),d0
        add.l   c2p_screen-c2p_bltnode(a1),d0
        add.l   c2p_scroffs-c2p_bltnode(a1),d0
        move.l  d0,bltdpt(a0)
        move.w  c2p_pixels16+2-c2p_bltnode(a1),bltsizv(a0)
        move.w  #1,bltsizh(a0)
        move.l  #c2p1x1_cpu3blit1_queue_44,c2p_bltroutptr-c2p_bltnode(a1)
        rts

c2p1x1_cpu3blit1_queue_44               ; Pass 4, subpass 4, ascending
        move.l  c2p_bufptrs+4,d0
        move.l  d0,bltapt(a0)
        addq.l  #2,d0
        move.l  d0,bltbpt(a0)
        move.l  c2p_bplsize-c2p_bltnode(a1),d0
        lsl.l   #3,d0
        sub.l   c2p_bplsize-c2p_bltnode(a1),d0
        add.l   c2p_screen-c2p_bltnode(a1),d0
        add.l   c2p_scroffs-c2p_bltnode(a1),d0
        move.l  d0,bltdpt(a0)
        move.w  c2p_pixels16+2-c2p_bltnode(a1),bltsizv(a0)
        move.w  #1,bltsizh(a0)
        move.l  #c2p1x1_cpu3blit1_queue_45,c2p_bltroutptr-c2p_bltnode(a1)
        rts

c2p1x1_cpu3blit1_queue_45               ; Pass 4, subpass 5, descending
        move.l  c2p_bufptrs+4,d0
        subq.l  #4,d0
        add.l   c2p_pixels-c2p_bltnode(a1),d0
        move.l  d0,bltapt(a0)
        addq.l  #2,d0
        move.l  d0,bltbpt(a0)
        move.l  c2p_screen-c2p_bltnode(a1),d0
        add.l   c2p_scroffs2-c2p_bltnode(a1),d0
        move.l  d0,bltdpt(a0)
        move.w  #$2de4,bltcon0(a0)
        move.w  #$0002,bltcon1(a0)
        move.w  c2p_pixels16+2-c2p_bltnode(a1),bltsizv(a0)
        move.w  #1,bltsizh(a0)
        move.l  #c2p1x1_cpu3blit1_queue_46,c2p_bltroutptr-c2p_bltnode(a1)
        rts

c2p1x1_cpu3blit1_queue_46               ; Pass 4, subpass 6, descending
        move.l  c2p_bufptrs+4,d0
        subq.l  #8,d0
        add.l   c2p_pixels-c2p_bltnode(a1),d0
        move.l  d0,bltapt(a0)
        addq.l  #2,d0
        move.l  d0,bltbpt(a0)
        move.l  c2p_bplsize-c2p_bltnode(a1),d0
        lsl.l   #2,d0
        add.l   c2p_screen-c2p_bltnode(a1),d0
        add.l   c2p_scroffs2-c2p_bltnode(a1),d0
        move.l  d0,bltdpt(a0)
        move.w  c2p_pixels16+2-c2p_bltnode(a1),bltsizv(a0)
        move.w  #1,bltsizh(a0)
        move.l  #c2p1x1_cpu3blit1_queue_47,c2p_bltroutptr-c2p_bltnode(a1)
        rts

c2p1x1_cpu3blit1_queue_47               ; Pass 4, subpass 7, descending
        move.l  c2p_bufptrs+4,d0
        sub.l   #12,d0
        add.l   c2p_pixels-c2p_bltnode(a1),d0
        move.l  d0,bltapt(a0)
        addq.l  #2,d0
        move.l  d0,bltbpt(a0)
        move.l  c2p_bplsize-c2p_bltnode(a1),d0
        add.l   c2p_screen-c2p_bltnode(a1),d0
        add.l   c2p_scroffs2-c2p_bltnode(a1),d0
        move.l  d0,bltdpt(a0)
        move.w  c2p_pixels16+2-c2p_bltnode(a1),bltsizv(a0)
        move.w  #1,bltsizh(a0)
        move.l  #c2p1x1_cpu3blit1_queue_48,c2p_bltroutptr-c2p_bltnode(a1)
        rts

c2p1x1_cpu3blit1_queue_48               ; Pass 4, subpass 8, descending
        move.l  c2p_bufptrs+4,d0
        sub.l   #16,d0
        add.l   c2p_pixels-c2p_bltnode(a1),d0
        move.l  d0,bltapt(a0)
        addq.l  #2,d0
        move.l  d0,bltbpt(a0)
        move.l  c2p_bplsize-c2p_bltnode(a1),d0
        lsl.l   #2,d0
        add.l   c2p_bplsize-c2p_bltnode(a1),d0
        add.l   c2p_screen-c2p_bltnode(a1),d0
        add.l   c2p_scroffs2-c2p_bltnode(a1),d0
        move.l  d0,bltdpt(a0)
        move.w  c2p_pixels16+2-c2p_bltnode(a1),bltsizv(a0)
        move.w  #1,bltsizh(a0)
        moveq   #0,d0
        rts


c2p_copyinitblock
        movem.l a0-a1,-(sp)
        lea     c2p_datanew,a0
        lea     c2p_data,a1
        moveq   #16-1,d0
.copy   move.l  (a0)+,(a1)+
        dbf     d0,.copy
        movem.l (sp)+,a0-a1
        rts

        cnop 0,4
c2p_bltnode
        dc.l    0
c2p_bltroutptr
        dc.l    0
        dc.b    $40,0
        dc.l    0
c2p_bltroutcleanup
        dc.l    c2p_blitcleanup
c2p_blitfin dc.b 1
c2p_blitactive dc.b 0

        cnop    0,4

c2p_data
c2p_screen dc.l 0
c2p_scroffs dc.l 0
c2p_scroffs2 dc.l 0
c2p_bplsize dc.l 0
c2p_pixels dc.l 0
c2p_pixels16 dc.l 0
c2p_chunkyy dc.w 0
        ds.l    16

        cnop 0,4
c2p_datanew
        ds.l    16

c2p_bufptrs
        dc.l    c2p_blitbuf
        IFEQ    C2P_DOUBLEBUFFER
        dc.l    c2p_blitbuf
        ELSE
        dc.l    c2p_blitbuf+CHUNKYXMAX*CHUNKYYMAX
        ENDC

        section bss_c,bss_c
 
c2p_blitbuf
        ds.b    CHUNKYXMAX*CHUNKYYMAX
        IFNE    C2P_DOUBLEBUFFER
        ds.b    CHUNKYXMAX*CHUNKYYMAX
        ENDC
 
