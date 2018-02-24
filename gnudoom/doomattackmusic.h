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
	struct Library *TimerBase;
		
	int *gametic;				/* pointer to variable!!! */
	int *snd_MusicVolume;	/* pointer to variable!!! */
	
	char	**myargv;
	int	myargc;
	
	/* Returned information from the library */
	
	int	numchannels;
};

#define DAMF_SOUNDFX 0x80000000
#define DAMF_FASTRAM 0x40000000
