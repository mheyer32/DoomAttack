
#include <libraries/locale.h>
#include <inline/exec.h>
#include <inline/locale.h>

#include "dstrings.h"
#include "info.h"

typedef struct
{
	char *name;
	mobjtype_t type;
} castinfo_t;

extern char *gammamsg[];
extern char *mapnames[];
extern char *mapnames2[];
extern char *mapnamesp[];
extern char *mapnamest[];
extern char *player_names[];

extern castinfo_t castorder[];

static char **stringarray[] =
{
	&YESKEY,
	&NOKEY,
	&D_DEVSTR,
	&D_CDROM,
	
	&PRESSKEY,
	&PRESSYN,
	&QUITMSG,
	&LOADNET,
	&QLOADNET,
	&QSAVESPOT,
	&SAVEDEAD,
	&QSPROMPT,
	&QLPROMPT,
	
	&NEWGAME,
	
	&NIGHTMARE,
	
	&SWSTRING	,
	
	&MSGOFF,
	&MSGON	,
	&NETEND,
	&ENDGAME,
	
	&DOSY	,
	
	&DETAILHI,
	&DETAILLO,
	&ALWAYSRUNON,
	&ALWAYSRUNOFF,
	
	&gammamsg[0],
	&gammamsg[1],
	&gammamsg[2],
	&gammamsg[3],
	&gammamsg[4],
	
	&EMPTYSTRING,
	
	&GOTARMOR,
	&GOTMEGA,
	&GOTHTHBONUS,
	&GOTARMBONUS,
	&GOTSTIM,
	&GOTMEDINEED,
	&GOTMEDIKIT,
	&GOTSUPER,
	
	&GOTBLUECARD,
	&GOTYELWCARD,
	&GOTREDCARD,
	&GOTBLUESKUL,
	&GOTYELWSKUL,
	&GOTREDSKULL,
	
	&GOTINVUL,
	&GOTBERSERK,
	&GOTINVIS,
	&GOTSUIT,
	&GOTMAP,
	&GOTVISOR,
	&GOTMSPHERE,
	
	&GOTCLIP,
	&GOTCLIPBOX,
	&GOTROCKET,
	&GOTROCKBOX,
	&GOTCELL,
	&GOTCELLBOX,
	&GOTSHELLS,
	&GOTSHELLBOX,
	&GOTBACKPACK,
	
	&GOTBFG9000,
	&GOTCHAINGUN,
	&GOTCHAINSAW,
	&GOTLAUNCHER,
	&GOTPLASMA,
	&GOTSHOTGUN,
	&GOTSHOTGUN2,
	
	/**/
	/* P_Doors.C*/
	/**/
	&PD_BLUEO,
	&PD_REDO,
	&PD_YELLOWO,
	&PD_BLUEK,
	&PD_REDK,
	&PD_YELLOWK,
	
	/**/
	/*	G_game.C*/
	/**/
	&GGSAVED,
	
	/**/
	/*	HU_stuff.C*/
	/**/
	&HUSTR_MSGU,
	
	&mapnames[0],
	&mapnames[1],
	&mapnames[2],
	&mapnames[3],
	&mapnames[4],
	&mapnames[5],
	&mapnames[6],
	&mapnames[7],
	&mapnames[8],

	&mapnames[9],
	&mapnames[10],
	&mapnames[11],
	&mapnames[12],
	&mapnames[13],
	&mapnames[14],
	&mapnames[15],
	&mapnames[16],
	&mapnames[17],
	
	&mapnames[18],
	&mapnames[19],
	&mapnames[20],
	&mapnames[21],
	&mapnames[22],
	&mapnames[23],
	&mapnames[24],
	&mapnames[25],
	&mapnames[26],
	
	&mapnames[27],
	&mapnames[28],
	&mapnames[29],
	&mapnames[30],
	&mapnames[31],
	&mapnames[32],
	&mapnames[33],
	&mapnames[34],
	&mapnames[35],
	
	&mapnames2[0],
	&mapnames2[1],
	&mapnames2[2],
	&mapnames2[3],
	&mapnames2[4],
	&mapnames2[5],
	&mapnames2[6],
	&mapnames2[7],
	&mapnames2[8],
	&mapnames2[9],
	&mapnames2[10],
	&mapnames2[11],
	&mapnames2[12],
	&mapnames2[13],
	&mapnames2[14],
	&mapnames2[15],
	&mapnames2[16],
	&mapnames2[17],
	&mapnames2[18],
	&mapnames2[19],
	&mapnames2[20],
	&mapnames2[21],
	&mapnames2[22],
	&mapnames2[23],
	&mapnames2[24],
	&mapnames2[25],
	&mapnames2[26],
	&mapnames2[27],
	&mapnames2[28],
	&mapnames2[29],
	&mapnames2[30],
	&mapnames2[31],

	&mapnamesp[0],
	&mapnamesp[1],
	&mapnamesp[2],
	&mapnamesp[3],
	&mapnamesp[4],
	&mapnamesp[5],
	&mapnamesp[6],
	&mapnamesp[7],
	&mapnamesp[8],
	&mapnamesp[9],
	&mapnamesp[10],
	&mapnamesp[11],
	&mapnamesp[12],
	&mapnamesp[13],
	&mapnamesp[14],
	&mapnamesp[15],
	&mapnamesp[16],
	&mapnamesp[17],
	&mapnamesp[18],
	&mapnamesp[19],
	&mapnamesp[20],
	&mapnamesp[21],
	&mapnamesp[22],
	&mapnamesp[23],
	&mapnamesp[24],
	&mapnamesp[25],
	&mapnamesp[26],
	&mapnamesp[27],
	&mapnamesp[28],
	&mapnamesp[29],
	&mapnamesp[30],
	&mapnamesp[31],
	
	&mapnamest[0],
	&mapnamest[1],
	&mapnamest[2],
	&mapnamest[3],
	&mapnamest[4],
	&mapnamest[5],
	&mapnamest[6],
	&mapnamest[7],
	&mapnamest[8],
	&mapnamest[9],
	&mapnamest[10],
	&mapnamest[11],
	&mapnamest[12],
	&mapnamest[13],
	&mapnamest[14],
	&mapnamest[15],
	&mapnamest[16],
	&mapnamest[17],
	&mapnamest[18],
	&mapnamest[19],
	&mapnamest[20],
	&mapnamest[21],
	&mapnamest[22],
	&mapnamest[23],
	&mapnamest[24],
	&mapnamest[25],
	&mapnamest[26],
	&mapnamest[27],
	&mapnamest[28],
	&mapnamest[29],
	&mapnamest[30],
	&mapnamest[31],

	&HUSTR_TALKTOSELF1,
	&HUSTR_TALKTOSELF2,
	&HUSTR_TALKTOSELF3,
	&HUSTR_TALKTOSELF4,
	&HUSTR_TALKTOSELF5,
	
	&HUSTR_MESSAGESENT,
	
	&player_names[0],
	&player_names[1],
	&player_names[2],
	&player_names[3],

	&AMSTR_FOLLOWON,
	&AMSTR_FOLLOWOFF,
	
	&AMSTR_GRIDON,
	&AMSTR_GRIDOFF,
	
	&AMSTR_MARKEDSPOT,
	&AMSTR_MARKSCLEARED,
	
	/**/
	/*	ST_stuff.C*/
	/**/
	
	&STSTR_MUS	,
	&STSTR_NOMUS	,
	&STSTR_DQDON	,
	&STSTR_DQDOFF,
	
	&STSTR_KFAADDED,
	&STSTR_FAADDED,
	
	&STSTR_NCON	,
	&STSTR_NCOFF	,
	
	&STSTR_BEHOLD,
	&STSTR_BEHOLDX,
	
	&STSTR_CHOPPERS,
	&STSTR_CLEV	,
	
	/**/
	/*	F_Finale.C*/
	/**/
	&E1TEXT,
	
	&E2TEXT,
	
	&E3TEXT,
	
	&E4TEXT,
	
	/* after level 6, put this:*/
	
	&C1TEXT,
	
	/* After level 11, put this:*/
	
	&C2TEXT,
	
	/* After level 20, put this:*/
	
	&C3TEXT,
	
	/* After level 29, put this:*/
	
	&C4TEXT,
	
	/* Before level 31, put this:*/
	
	&C5TEXT,
	
	/* Before level 32, put this:*/
	
	&C6TEXT,
	
	/* after map 06	*/
	
	&P1TEXT,
	
	/* after map 11*/
	
	&P2TEXT,
	
	/* after map 20*/
	
	&P3TEXT,
	
	/* after map 30*/
	
	&P4TEXT,
	
	/* before map 31*/
	
	&P5TEXT,
	
	/* before map 32*/
	
	&P6TEXT,
	
	&T1TEXT,
	
	&T2TEXT,
	
	&T3TEXT,
	
	&T4TEXT,
	
	&T5TEXT,
	
	&T6TEXT,
	
	/**/
	/* extern character cast strings F_FINALE.C*/
	/**/
	
	&castorder[0].name,
	&castorder[1].name,
	&castorder[2].name,
	&castorder[3].name,
	&castorder[4].name,
	&castorder[5].name,
	&castorder[6].name,
	&castorder[7].name,
	&castorder[8].name,
	&castorder[9].name,
	&castorder[10].name,
	&castorder[11].name,
	&castorder[12].name,
	&castorder[13].name,
	&castorder[14].name,
	&castorder[15].name,
	&castorder[16].name,
	
	&endmsg[1],
	&endmsg[2],
	&endmsg[3],
	&endmsg[4],
	&endmsg[5],
	&endmsg[6],
	&endmsg[7],

	&endmsg[8],
	&endmsg[9],
	&endmsg[10],
	&endmsg[11],
	&endmsg[12],
	&endmsg[13],
	&endmsg[14],


	&endmsg[15],
	&endmsg[16],
	&endmsg[17],
	&endmsg[18],
	&endmsg[19],
	&endmsg[20],
	&endmsg[21]
};

int uselocale;

void I_InitLocale(void)
{
	struct Library *LocaleBase;
	struct Catalog *MyCatalog;
	int	i;

	if (uselocale)
	{
		if ((LocaleBase=OpenLibrary("locale.library",39)))
		{
			if ((MyCatalog=OpenCatalog(0,"DoomAttack.catalog",
									OC_BuiltInLanguage,(ULONG)"english",
									OC_Version,1,
									TAG_DONE)))
			{
				for(i=0;i<(sizeof(stringarray) / sizeof(char *));i++)
				{
					*(stringarray[i]) = GetCatalogStr(MyCatalog,i,*(stringarray[i]));
				}
				
				CloseCatalog(MyCatalog);
			}

			CloseLibrary(LocaleBase);

		} /* if ((LocaleBase=OpenLibrary("locale.library",39))) */

	} /* if (uselocale) */
}

void I_CleanupLocale(void)
{
}

