#ifndef DOOMATTACKMUSIC_H
#define DOOMATTACKMUSIC_H

#ifdef   __MAXON__
#ifndef  EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif
#else
#ifndef  EXEC_LIBRARIES
#include <exec/libraries.h>
#endif /* EXEC_LIBRARIES_H */
#endif

struct DAMInitialization
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
		
	int *gametic;				// pointer to variable!!!
	int *snd_MusicVolume;	// pointer to variable!!!
	
	char	**myargv;
	int	myargc;
	
	/* Returned information from the library */
	
	int	numchannels;
};

#endif /* DOOMATTACKMUSIC_H */

