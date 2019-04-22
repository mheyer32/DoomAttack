#ifndef DOOMATTACKNET_H
#define DOOMATTACKNET_H

#ifdef   __MAXON__
#ifndef  EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif
#else
#ifndef  EXEC_LIBRARIES
#include <exec/libraries.h>
#endif /* EXEC_LIBRARIES_H */
#endif

struct DANInitialization
{
	/* Routines */

	void (*I_Error) (char *error, ...);
	int (*M_CheckParm) (char *check);

	/* Vars */
	
	struct ExecBase *SysBase;
	struct Library *DOSBase;
	struct Library *IntuitionBase;
	struct Library *GfxBase;
	struct Library *KeymapBase;
	struct Device  *TimerBase;
	
	doomdata_t	**netbuffer;	// pointer to var!! */
	doomcom_t	*doomcom;
	
	char	**myargv;
	int	myargc;
};


#endif /* DOOMATTACKNET_H */
