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

#include "DoomAttackMusic.h"
#include "funcs.h"
#include "musicIDs.h"

/*=====================*/

int *gametic;
int *snd_MusicVolume;

static char	**myargv;
static int	myargc;

static void (*I_Error)(char *error, ...);
static int (*M_CheckParm)(char *check);

/*=====================*/

static struct SignalSemaphore mysem;
static BPTR		MyHandle;
static UBYTE	*MusicBuffer;
static UBYTE	*SampleBuffer;
static BOOL		SongOK,SemAdded;

static char 	*ConfigBuffer;
static char		*Filename[NUM_MUSIC];
static char		*SEMNAME;

extern "ASM"
{	
	LONG xP61_Init(register __a0 APTR module,register __a1 APTR samples,register __a2 APTR samplebuffer,register __d0 LONG flags);
	void xP61_Music(void);
	void xP61_End(void);
	
	WORD P61_Play;
	WORD P61_Master;
	WORD P61_FadeTo;

};

static WORD voltable[16] =
{
	0,
	5,
	10,
	15,
	20,
	24,
	28,
	32,
	36,
	40,
	44,
	48,
	52,
	56,
	60,
	64,
};

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
		
		daminit->numchannels = 2;

}

/*********************************************************/

int C_DAM_InitMusic(void)
{
	ULONG	len;
	char	*fpos,*linepos,c;
	int	i,qcount,rc=FALSE;
	BOOL	ok;

	// Let's be sure that this plugin isn't used twice when
	// one is using the DANetL.plugin (two players on one computer)
	// The P61 Init routine does not seem to be aware of this
	
	SEMNAME="DoomAttack P61 Music plugin";

	ok=FALSE;
	Forbid();
	if (!FindSemaphore(SEMNAME))
	{
		InitSemaphore(&mysem);
		mysem.ss_Link.ln_Name=SEMNAME;
		mysem.ss_Link.ln_Pri=-128;
		AddSemaphore(&mysem);
		SemAdded=TRUE;
		ok=TRUE;
	}
	Permit();

	if (ok)
	{
		if ((MyHandle=Open("DoomAttackSupport/config/DAMusic_P61A.config",MODE_OLDFILE)))
		{
			Seek(MyHandle,0,OFFSET_END);
			len=Seek(MyHandle,0,OFFSET_BEGINNING);
			
			if (len>0 && (ConfigBuffer=AllocVec(len+2,MEMF_CLEAR)))
			{
				if (Read(MyHandle,ConfigBuffer,len) == len)
				{
					i=qcount=0;
					fpos=linepos=ConfigBuffer;
					while ((c = *fpos++))
					{
						switch (c)
						{
							case '\n':
								fpos[-1]='\0';
								if ((linepos[0] != '\0') && (linepos[0] != ' ') && (linepos[0] != '\t'))
								{
									Filename[i++]=linepos;
								} else {
									Filename[i++]=0;
								}
								linepos=fpos;
								qcount=0;
								if (i==NUM_MUSIC) fpos=ConfigBuffer+len;
								break;
							
							case '"':
								qcount++;
								if (qcount==1)
								{
									linepos++;
								} else {
									fpos[-1]='\0';
								}
								break;
	
							case '\t':
							case ' ':
							case ';':
							case '*':
								if (qcount != 1)
								{
									fpos[-1]='\0';
								}
								break;
						}
	
					} // while (c = *fpos++)
	
					if (i>0) rc=TRUE;
	
				} // if (Read(MyHandle,ConfigBuffer,len) == len)
	
			} // if (len>0 && (ConfigBuffer=AllocVec(len+2,MEMF_CLEAR)))
			
			if (!rc)
			{
				if (ConfigBuffer)
				{
					FreeVec(ConfigBuffer);
					ConfigBuffer=0;
				}
				RemSemaphore(&mysem);
			}
	
			Close(MyHandle);MyHandle=0;
	
		} // if ((MyHandle=Open("PROGDIR:.musicrc",MODE_OLDFILE)))

	} // if (mysem)

	return rc;
}

/*********************************************************/

void C_DAM_ShutdownMusic(void)
{
	DAM_UnRegisterSong(0);

 	if (ConfigBuffer) FreeVec(ConfigBuffer);
	if (SemAdded) RemSemaphore(&mysem);

	#ifdef __MAXON__
	CleanupModules();
	#endif
}

/*********************************************************/

void C_DAM_SetMusicVolume(int volume)
{
// volume range is 0 .. 15
//	*snd_MusicVolume=volume;
	
	P61_Master=voltable[volume];
	P61_FadeTo=voltable[volume];
}

/*********************************************************/

void C_DAM_PauseSong(int handle)
{
	P61_Play=0;
}

/*********************************************************/

void C_DAM_ResumeSong(int handle)
{
	P61_Play=1;
}

void C_DAM_StopSong(int handle)
{
	P61_Play=0;
}

/*********************************************************/

int C_DAM_RegisterSong(void *data,int songnum)
{
	char *file;
	int mysongnum=songnum;
	LONG len;

	file=Filename[mysongnum] ? Filename[mysongnum] : Filename[0];

	MyHandle=Open(file,MODE_OLDFILE);
	if (MyHandle)
	{
		Seek(MyHandle,0,OFFSET_END);
		len=Seek(MyHandle,0,OFFSET_BEGINNING);
		if (len>0)
		{
			MusicBuffer=AllocVec(len,MEMF_CHIP);
			if (MusicBuffer)
			{
				if (Read(MyHandle,MusicBuffer,len) == len)
				{
					// Check if the samples are packed

					if ( ((ULONG *)MusicBuffer)[0] == MAKE_ID('P','6','1','A'))
					{
						len=3+4;
					} else {
						len=3;
					}
					if (MusicBuffer[len] & 0x40)
					{
						// Can this be in FAST RAM?????
						SampleBuffer=AllocVec( ((WORD *)MusicBuffer)[(len+1)/2],MEMF_CHIP);
						if (SampleBuffer) SongOK=TRUE;
					} else SongOK=TRUE;

				} // if (Read(MyHandle,MusicBuffer,len) == len)

				if (SongOK)
				{
					P61_Play=0;
					if (xP61_Init(MusicBuffer,0,SampleBuffer,0))
					{
						
						SongOK=FALSE;
					}
				}
				
			} // if (MusicBuffer)

		} // if (len>0)
		
		Close(MyHandle);MyHandle=0;

	} // if (MyHandle)
	
	if (!SongOK)
	{
		if (MusicBuffer) FreeVec(MusicBuffer);MusicBuffer=0;
		if (SampleBuffer) FreeVec(SampleBuffer);SampleBuffer=0;
	}
	
	return 0;
}

/*********************************************************/

void C_DAM_PlaySong(int handle,int looping)
{
	P61_Play=1;
}

/*********************************************************/

void C_DAM_UnRegisterSong(int handle)
{
	if (SongOK)
	{
		P61_Play=0;
		xP61_End();
		SongOK=FALSE;
	}
	
	if (MusicBuffer)
	{
		FreeVec(MusicBuffer);
		MusicBuffer=0;
	}
	if (SampleBuffer)
	{
		FreeVec(SampleBuffer);
		SampleBuffer=0;
	}
}

/*********************************************************/

int C_DAM_QrySongPlaying(int handle)
{
	return P61_Play;
}

