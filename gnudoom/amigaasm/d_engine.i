
	include exec/types.i

ZONEID =	$1d4a11
PU_PURGELEVEL = 100
MINFRAGMENT = 64

 STRUCTURE memblock,0
	LONG	mb_size
	APTR	mb_user
	LONG	mb_tag
	LONG	mb_id
	LONG	mb_pad1
	LONG	mb_pad2
	APTR	mb_next
	APTR	mb_prev
	LABEL	mb_SIZEOF
	;// 32 Bytes

 STRUCTURE memzone,0
	LONG	mz_size
	STRUCT mz_blocklist,mb_SIZEOF
	APTR	mz_rover
	LONG	mz_pad1
	LONG	mz_pad2
	LABEL	mz_SIZEOF
	;// 48 Bytes
	

