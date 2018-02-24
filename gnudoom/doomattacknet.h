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
	struct Library *TimerBase;
	
	doomdata_t	**netbuffer;	/* Pointer to var!! */
	doomcom_t	*doomcom;
	
	char	**myargv;
	int	myargc;
};
