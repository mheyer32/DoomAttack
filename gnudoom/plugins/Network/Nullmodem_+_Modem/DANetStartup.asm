	XREF		_DAN_Init
	XREF		_DAN_InitNetwork
	XREF		_DAN_NetCmd
	XREF		_DAN_CleanupNetwork
	
				section .text

	moveq		#-1,d0
	rts

	dc.b		'DANW'			;(D)oom(A)ttack(N)et(w)ork
	
	dc.l		_DAN_Init
	dc.l		_DAN_InitNetwork
	dc.l		_DAN_NetCmd
	dc.l		_DAN_CleanupNetwork
	
	blk.l		8,0
	
	
	END
	
