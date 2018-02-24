#NO_APP
gcc2_compiled.:
___gnu_compiled_c:
.text
_rcsid:
	.ascii "$Id: m_bbox.c,v 1.1 1997/02/03 22:45:10 b1 Exp $\0"
	.even
.globl _FixedDiv
_FixedDiv:
	moveml #0x3800,sp@-
	movel sp@(16),d0
	movel sp@(20),d2
	movel d0,d1
	jge L10
	negl d1
L10:
	movel d1,d3
	moveq #14,d4
	asrl d4,d3
	movel d2,d1
	jge L11
	negl d1
L11:
	cmpl d3,d1
	jgt L9
	eorl d2,d0
	movel #2147483647,d1
	tstl d0
	jge L12
	movel #-2147483648,d1
L12:
	movel d1,d0
	jra L14
L9:
	fmovel d0,fp0
	fdivl d2,fp0
	fscalel #16,fp0
	fintrzx fp0,fp0
	fmovel fp0,d0
L14:
	moveml sp@+,#0x1c
	rts
