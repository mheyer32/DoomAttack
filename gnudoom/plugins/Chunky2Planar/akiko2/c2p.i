
	IFND EXEC_TYPES_I
	include "exec/types.i"
	ENDC
	
C2PF_SIGNALFLIP	= 1		;*You* want to tell DoomAttack when to change the screen
						;buffers by signalling c2pi_FlipTask with c2pi_FlipMask
						;and c2pi_DoomTask with c2pi_DoomTask

C2PF_VARIABLEHEIGHT = 2 ;The c2p routine supports screens with heights different
						;from 200.

C2PF_GRAFFITI = 4

C2PF_NODOUBLEBUFFER = 8

C2PF_VARIABLEWIDTH = 16

 STRUCTURE C2PInit,0
 	APTR	c2pi_DOSBase
 	APTR	c2pi_GfxBase
 	APTR	c2pi_IntuitionBase
 	APTR	c2pi_FlipTask
 	ULONG	c2pi_FlipMask
 	APTR	c2pi_DoomTask
 	ULONG	c2pi_DoomMask
 	ULONG c2pi_DisplayID
 	LABEL	c2pi_SIZE
