
	include exec/types.i

ZONEID =	$1d4a11
PU_PURGELEVEL = 100
MINFRAGMENT = 64

 STRUCTURE memblock,0
	LONG	mb_size
	APTR	mb_user
	LONG	mb_tag
	LONG	mb_id
	APTR	mb_next
	APTR	mb_prev
	LABEL	mb_SIZEOF
	;// 24 Bytes

 STRUCTURE memzone,0
	LONG	mz_size
	STRUCT mz_blocklist,mb_SIZEOF
	APTR	mz_rover
	LABEL	mz_SIZEOF
	;// 32 Bytes
	

