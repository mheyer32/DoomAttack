#include <OSIncludes.h>

#pragma header

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <linkerfunc.h>

#ifdef __MAXON__
#include <pragma/exec_lib.h>
#include <pragma/dos_lib.h>
#else
#include <proto/exec.h>
#include <proto/dos.h>
#endif

//#include "compiler.h"
#include "/DoomAttackMusic/DoomAttackMusic.h"
#include "/DoomAttackMusic/funcs.h"

/*=====================*/

static int *gametic;
static int *snd_MusicVolume;

static char	**myargv;
static int	myargc;

static void (*I_Error)(char *error, ...);
static int (*M_CheckParm)(char *check);

/*=====================*/

#define SNDSERVERNAME "ADoom_SndSrvr"

static BOOL serverOK;

extern struct Library *DoomSoundBase;
extern BOOL NoMusic;
extern BOOL NoSound;

/*********************************************************/

void C_DAM_Init(struct DAMInitialization *daminit)
{
		// link function pointers to DoomAttack routines
		
		#ifdef __MAXON__
		InitModules();
		#endif
		
		
		I_Error=daminit->I_Error;
		M_CheckParm=daminit->M_CheckParm;

		// setups vars
				
		gametic         = daminit->gametic;
		snd_MusicVolume = daminit->snd_MusicVolume;
		myargv			 = daminit->myargv;
		myargc			 = daminit->myargc;
		
		// Tell DoomAttack the informations, it needs
		
		daminit->numchannels = 16 | DAMF_SOUNDFX | DAMF_FASTRAM;

}

static char *PREFSNAME = "DoomAttackSupport/config/DAMusic_DoomSndLibrary.config";
static char s[202];

#define ARG_TEMPLATE "MUSICONLY/S,SOUNDFXONLY/S"
enum {ARG_MUSONLY,ARG_FXONLY,NUM_ARGS};

static LONG Args[NUM_ARGS];

static void LoadSettings(void)
{
	struct RDArgs *MyArgs;
	BPTR MyHandle;
	LONG l;
	
	if (!(MyHandle=Open(PREFSNAME,MODE_OLDFILE)))
	{
		printf("DAMusic_DoomSoundLibrary: Could not open config file (%s)!\n",PREFSNAME);
	} else {
		Seek(MyHandle,0,OFFSET_END);
		l=Seek(MyHandle,0,OFFSET_BEGINNING);
		if (l<1 || l>200)
		{
			printf("DAMusic_DoomSoundLibrary: Config file has bad size!\n");
		} else {
			if (Read(MyHandle,s,l) == l)
			{			
				s[l++]='\n';
				s[l++]='\0';
				
				if ((MyArgs=AllocDosObject(DOS_RDARGS,0)))
				{
					MyArgs->RDA_Source.CS_Buffer=s;
					MyArgs->RDA_Source.CS_Length=strlen(s);
					MyArgs->RDA_Flags=RDAF_NOPROMPT;

					if (ReadArgs(ARG_TEMPLATE,Args,MyArgs))
					{
						if (Args[ARG_MUSONLY])
						{
							NoSound=TRUE;
						}
						if (Args[ARG_FXONLY])
						{
							NoMusic=TRUE;
						}

						FreeArgs(MyArgs);
					}
					
					FreeDosObject(DOS_RDARGS,MyArgs);
				}
			}
		}
		Close(MyHandle);
	}

	CacheClearU();
}

/*********************************************************

DAM_InitMusic:

Do initialization and return TRUE if everything went OK.
If you return FALSE you must free already alloced resour-
ces as DoomAttack will not call DAM_ShutdownMusic in this
case!!


*********************************************************/



int DAM_InitMusic(void)
{
	int rc=FALSE;
	
	DoomSoundBase=OpenLibrary("PROGDIR:libs/doomsound.library",37);
	if (!DoomSoundBase) DoomSoundBase=OpenLibrary("PROGDIR:doomsound.library",37);
	if (!DoomSoundBase) DoomSoundBase=OpenLibrary("doomsound.library",37);
	
	if (!DoomSoundBase)
	{
		printf("DAMusic_DoomSoundLibrary: Could not open \"doomsound.library\"!\n");
	} else {
		LoadSettings();
		serverOK = rc = TRUE;
	}
	return rc;
}

/*********************************************************

DAM_ShutdownMusic:

Cleanup routine. Called when the user quits DoomAttack.


*********************************************************/


void DAM_ShutdownMusic(void)
{
	if (serverOK)
	{
		serverOK=FALSE;
		if (DoomSoundBase)
		{
			CloseLibrary(DoomSoundBase);
			DoomSoundBase=0;
		}
	}
	
	#ifdef __MAXON__
	CleanupModules();
	#endif
}


