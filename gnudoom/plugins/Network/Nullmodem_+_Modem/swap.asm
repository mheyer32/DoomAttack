
	XDEF	_SwapWORD
	
_SwapWORD:
	ror.w		#8,d0
	rts
	
	XDEF	_SwapLONG
	
_SwapLONG:
	ror.w		#8,d0
	swap		d0
	ror.w		#8,d0
	rts
	
	END
	
