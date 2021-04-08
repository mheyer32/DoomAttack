/* Emacs style mode select   -*- C++ -*- */
/*-----------------------------------------------------------------------------*/
/**/
/* $Id:$*/
/**/
/* Copyright (C) 1993-1996 by id Software, Inc.*/
/**/
/* This source is available for distribution and/or modification*/
/* only under the terms of the DOOM Source Code License as*/
/* published by id Software. All rights reserved.*/
/**/
/* The source is distributed in the hope that it will be useful,*/
/* but WITHOUT ANY WARRANTY; without even the implied warranty of*/
/* FITNESS FOR A PARTICULAR PURPOSE. See the DOOM Source Code License*/
/* for more details.*/
/**/
/**/
/* $Log:$*/
/**/
/* DESCRIPTION:*/
/*	DOOM strings, by language.*/
/**/
/*-----------------------------------------------------------------------------*/

#ifndef __DSTRINGS__
#define __DSTRINGS__

/* All important printed strings.*/
/* Language selection (message strings).*/
/* Use -DFRENCH etc.*/

/*
#ifdef FRENCH
#include "d_french.h"
#else
#include "d_englsh.h"
#endif
*/

/* Misc. other strings.*/
#define SAVEGAMENAME "doomsav"

/**/
/* File locations,*/
/*  relative to current position.*/
/* Path names are OS-sensitive.*/
/**/
#define DEVMAPS "devmaps/"
#define DEVDATA "devdata/"

/* Not done in french?*/

/* QuitDOOM messages*/
#define NUM_QUITMESSAGES 22

extern FAR const char * const endmsg[];

extern FAR const char * const YESKEY;
extern FAR const char * const NOKEY;
extern FAR const char * const D_DEVSTR;
extern FAR const char * const D_CDROM;

/**/
/*	M_Menu.C*/
/**/
extern FAR const char * const PRESSKEY;
extern FAR const char * const PRESSYN;
extern FAR const char * const QUITMSG;
extern FAR const char * const LOADNET;
extern FAR const char * const QLOADNET;
extern FAR const char * const QSAVESPOT;
extern FAR const char * const SAVEDEAD;
extern FAR const char * const QSPROMPT;
extern FAR const char * const QLPROMPT;

extern FAR const char * const NEWGAME;

extern FAR const char * const NIGHTMARE;

extern FAR const char * const SWSTRING;

extern FAR const char * const MSGOFF;
extern FAR const char * const MSGON;
extern FAR const char * const NETEND;
extern FAR const char * const ENDGAME;

extern FAR const char * const DOSY;

extern FAR const char * const DETAILHI;
extern FAR const char * const DETAILLO;
extern FAR const char * const ALWAYSRUNON;
extern FAR const char * const ALWAYSRUNOFF;

#define GAMMALVL0 "Gamma correction OFF"
#define GAMMALVL1 "Gamma correction level 1"
#define GAMMALVL2 "Gamma correction level 2"
#define GAMMALVL3 "Gamma correction level 3"
#define GAMMALVL4 "Gamma correction level 4"

extern FAR const char * const EMPTYSTRING;

/**/
/*	P_inter.C*/
/**/
extern FAR const char * const GOTARMOR;
extern FAR const char * const GOTMEGA;
extern FAR const char * const GOTHTHBONUS;
extern FAR const char * const GOTARMBONUS;
extern FAR const char * const GOTSTIM;
extern FAR const char * const GOTMEDINEED;
extern FAR const char * const GOTMEDIKIT;
extern FAR const char * const GOTSUPER;

extern FAR const char * const GOTBLUECARD;
extern FAR const char * const GOTYELWCARD;
extern FAR const char * const GOTREDCARD;
extern FAR const char * const GOTBLUESKUL;
extern FAR const char * const GOTYELWSKUL;
extern FAR const char * const GOTREDSKULL;

extern FAR const char * const GOTINVUL;
extern FAR const char * const GOTBERSERK;
extern FAR const char * const GOTINVIS;
extern FAR const char * const GOTSUIT;
extern FAR const char * const GOTMAP;
extern FAR const char * const GOTVISOR;
extern FAR const char * const GOTMSPHERE;

extern FAR const char * const GOTCLIP;
extern FAR const char * const GOTCLIPBOX;
extern FAR const char * const GOTROCKET;
extern FAR const char * const GOTROCKBOX;
extern FAR const char * const GOTCELL;
extern FAR const char * const GOTCELLBOX;
extern FAR const char * const GOTSHELLS;
extern FAR const char * const GOTSHELLBOX;
extern FAR const char * const GOTBACKPACK;

extern FAR const char * const GOTBFG9000;
extern FAR const char * const GOTCHAINGUN;
extern FAR const char * const GOTCHAINSAW;
extern FAR const char * const GOTLAUNCHER;
extern FAR const char * const GOTPLASMA;
extern FAR const char * const GOTSHOTGUN;
extern FAR const char * const GOTSHOTGUN2;

/**/
/* P_Doors.C*/
/**/
extern FAR const char * const PD_BLUEO;
extern FAR const char * const PD_REDO;
extern FAR const char * const PD_YELLOWO;
extern FAR const char * const PD_BLUEK;
extern FAR const char * const PD_REDK;
extern FAR const char * const PD_YELLOWK;

/**/
/*	G_game.C*/
/**/
extern FAR const char * const GGSAVED;

/**/
/*	HU_stuff.C*/
/**/
extern FAR const char * const HUSTR_MSGU;

#define HUSTR_E1M1 "E1M1: Hangar"
#define HUSTR_E1M2 "E1M2: Nuclear Plant"
#define HUSTR_E1M3 "E1M3: Toxin Refinery"
#define HUSTR_E1M4 "E1M4: Command Control"
#define HUSTR_E1M5 "E1M5: Phobos Lab"
#define HUSTR_E1M6 "E1M6: Central Processing"
#define HUSTR_E1M7 "E1M7: Computer Station"
#define HUSTR_E1M8 "E1M8: Phobos Anomaly"
#define HUSTR_E1M9 "E1M9: Military Base"

#define HUSTR_E2M1 "E2M1: Deimos Anomaly"
#define HUSTR_E2M2 "E2M2: Containment Area"
#define HUSTR_E2M3 "E2M3: Refinery"
#define HUSTR_E2M4 "E2M4: Deimos Lab"
#define HUSTR_E2M5 "E2M5: Command Center"
#define HUSTR_E2M6 "E2M6: Halls of the Damned"
#define HUSTR_E2M7 "E2M7: Spawning Vats"
#define HUSTR_E2M8 "E2M8: Tower of Babel"
#define HUSTR_E2M9 "E2M9: Fortress of Mystery"

#define HUSTR_E3M1 "E3M1: Hell Keep"
#define HUSTR_E3M2 "E3M2: Slough of Despair"
#define HUSTR_E3M3 "E3M3: Pandemonium"
#define HUSTR_E3M4 "E3M4: House of Pain"
#define HUSTR_E3M5 "E3M5: Unholy Cathedral"
#define HUSTR_E3M6 "E3M6: Mt. Erebus"
#define HUSTR_E3M7 "E3M7: Limbo"
#define HUSTR_E3M8 "E3M8: Dis"
#define HUSTR_E3M9 "E3M9: Warrens"

#define HUSTR_E4M1 "E4M1: Hell Beneath"
#define HUSTR_E4M2 "E4M2: Perfect Hatred"
#define HUSTR_E4M3 "E4M3: Sever The Wicked"
#define HUSTR_E4M4 "E4M4: Unruly Evil"
#define HUSTR_E4M5 "E4M5: They Will Repent"
#define HUSTR_E4M6 "E4M6: Against Thee Wickedly"
#define HUSTR_E4M7 "E4M7: And Hell Followed"
#define HUSTR_E4M8 "E4M8: Unto The Cruel"
#define HUSTR_E4M9 "E4M9: Fear"

#define HUSTR_1 "level 1: entryway"
#define HUSTR_2 "level 2: underhalls"
#define HUSTR_3 "level 3: the gantlet"
#define HUSTR_4 "level 4: the focus"
#define HUSTR_5 "level 5: the waste tunnels"
#define HUSTR_6 "level 6: the crusher"
#define HUSTR_7 "level 7: dead simple"
#define HUSTR_8 "level 8: tricks and traps"
#define HUSTR_9 "level 9: the pit"
#define HUSTR_10 "level 10: refueling base"
#define HUSTR_11 "level 11: 'o' of destruction!"

#define HUSTR_12 "level 12: the factory"
#define HUSTR_13 "level 13: downtown"
#define HUSTR_14 "level 14: the inmost dens"
#define HUSTR_15 "level 15: industrial zone"
#define HUSTR_16 "level 16: suburbs"
#define HUSTR_17 "level 17: tenements"
#define HUSTR_18 "level 18: the courtyard"
#define HUSTR_19 "level 19: the citadel"
#define HUSTR_20 "level 20: gotcha!"

#define HUSTR_21 "level 21: nirvana"
#define HUSTR_22 "level 22: the catacombs"
#define HUSTR_23 "level 23: barrels o' fun"
#define HUSTR_24 "level 24: the chasm"
#define HUSTR_25 "level 25: bloodfalls"
#define HUSTR_26 "level 26: the abandoned mines"
#define HUSTR_27 "level 27: monster condo"
#define HUSTR_28 "level 28: the spirit world"
#define HUSTR_29 "level 29: the living end"
#define HUSTR_30 "level 30: icon of sin"

#define HUSTR_31 "level 31: wolfenstein"
#define HUSTR_32 "level 32: grosse"

#define PHUSTR_1 "level 1: congo"
#define PHUSTR_2 "level 2: well of souls"
#define PHUSTR_3 "level 3: aztec"
#define PHUSTR_4 "level 4: caged"
#define PHUSTR_5 "level 5: ghost town"
#define PHUSTR_6 "level 6: baron's lair"
#define PHUSTR_7 "level 7: caughtyard"
#define PHUSTR_8 "level 8: realm"
#define PHUSTR_9 "level 9: abattoire"
#define PHUSTR_10 "level 10: onslaught"
#define PHUSTR_11 "level 11: hunted"

#define PHUSTR_12 "level 12: speed"
#define PHUSTR_13 "level 13: the crypt"
#define PHUSTR_14 "level 14: genesis"
#define PHUSTR_15 "level 15: the twilight"
#define PHUSTR_16 "level 16: the omen"
#define PHUSTR_17 "level 17: compound"
#define PHUSTR_18 "level 18: neurosphere"
#define PHUSTR_19 "level 19: nme"
#define PHUSTR_20 "level 20: the death domain"

#define PHUSTR_21 "level 21: slayer"
#define PHUSTR_22 "level 22: impossible mission"
#define PHUSTR_23 "level 23: tombstone"
#define PHUSTR_24 "level 24: the final frontier"
#define PHUSTR_25 "level 25: the temple of darkness"
#define PHUSTR_26 "level 26: bunker"
#define PHUSTR_27 "level 27: anti-christ"
#define PHUSTR_28 "level 28: the sewers"
#define PHUSTR_29 "level 29: odyssey of noises"
#define PHUSTR_30 "level 30: the gateway of hell"

#define PHUSTR_31 "level 31: cyberden"
#define PHUSTR_32 "level 32: go 2 it"

#define THUSTR_1 "level 1: system control"
#define THUSTR_2 "level 2: human bbq"
#define THUSTR_3 "level 3: power control"
#define THUSTR_4 "level 4: wormhole"
#define THUSTR_5 "level 5: hanger"
#define THUSTR_6 "level 6: open season"
#define THUSTR_7 "level 7: prison"
#define THUSTR_8 "level 8: metal"
#define THUSTR_9 "level 9: stronghold"
#define THUSTR_10 "level 10: redemption"
#define THUSTR_11 "level 11: storage facility"

#define THUSTR_12 "level 12: crater"
#define THUSTR_13 "level 13: nukage processing"
#define THUSTR_14 "level 14: steel works"
#define THUSTR_15 "level 15: dead zone"
#define THUSTR_16 "level 16: deepest reaches"
#define THUSTR_17 "level 17: processing area"
#define THUSTR_18 "level 18: mill"
#define THUSTR_19 "level 19: shipping/respawning"
#define THUSTR_20 "level 20: central processing"

#define THUSTR_21 "level 21: administration center"
#define THUSTR_22 "level 22: habitat"
#define THUSTR_23 "level 23: lunar mining project"
#define THUSTR_24 "level 24: quarry"
#define THUSTR_25 "level 25: baron's den"
#define THUSTR_26 "level 26: ballistyx"
#define THUSTR_27 "level 27: mount pain"
#define THUSTR_28 "level 28: heck"
#define THUSTR_29 "level 29: river styx"
#define THUSTR_30 "level 30: last call"

#define THUSTR_31 "level 31: pharaoh"
#define THUSTR_32 "level 32: caribbean"

#define HUSTR_CHATMACRO1 "I'm ready to kick butt!"
#define HUSTR_CHATMACRO2 "I'm OK."
#define HUSTR_CHATMACRO3 "I'm not looking too good!"
#define HUSTR_CHATMACRO4 "Help!"
#define HUSTR_CHATMACRO5 "You suck!"
#define HUSTR_CHATMACRO6 "Next time, scumbag..."
#define HUSTR_CHATMACRO7 "Come here!"
#define HUSTR_CHATMACRO8 "I'll take care of it."
#define HUSTR_CHATMACRO9 "Yes"
#define HUSTR_CHATMACRO0 "No"

extern FAR const char * const HUSTR_TALKTOSELF1;
extern FAR const char * const HUSTR_TALKTOSELF2;
extern FAR const char * const HUSTR_TALKTOSELF3;
extern FAR const char * const HUSTR_TALKTOSELF4;
extern FAR const char * const HUSTR_TALKTOSELF5;

extern FAR const char * const HUSTR_MESSAGESENT;

/* The following should NOT be changed unless it seems*/
/* just AWFULLY necessary*/

#define HUSTR_PLRGREEN "Green: "
#define HUSTR_PLRINDIGO "Indigo: "
#define HUSTR_PLRBROWN "Brown: "
#define HUSTR_PLRRED "Red: "

#define HUSTR_KEYGREEN 'g'
#define HUSTR_KEYINDIGO 'i'
#define HUSTR_KEYBROWN 'b'
#define HUSTR_KEYRED 'r'

/**/
/*	AM_map.C*/
/**/

extern FAR const char * const AMSTR_FOLLOWON;
extern FAR const char * const AMSTR_FOLLOWOFF;

extern FAR const char * const AMSTR_GRIDON;
extern FAR const char * const AMSTR_GRIDOFF;

extern FAR const char * const AMSTR_MARKEDSPOT;
extern FAR const char * const AMSTR_MARKSCLEARED;

/**/
/*	ST_stuff.C*/
/**/

extern FAR const char * const STSTR_MUS;
extern FAR const char * const STSTR_NOMUS;
extern FAR const char * const STSTR_DQDON;
extern FAR const char * const STSTR_DQDOFF;

extern FAR const char * const STSTR_KFAADDED;
extern FAR const char * const STSTR_FAADDED;

extern FAR const char * const STSTR_NCON;
extern FAR const char * const STSTR_NCOFF;

extern FAR const char * const STSTR_BEHOLD;
extern FAR const char * const STSTR_BEHOLDX;

extern FAR const char * const STSTR_CHOPPERS;
extern FAR const char * const STSTR_CLEV;

/**/
/*	F_Finale.C*/
/**/
extern FAR const char * const E1TEXT;

extern FAR const char * const E2TEXT;

extern FAR const char * const E3TEXT;

extern FAR const char * const E4TEXT;

/* after level 6, put this:*/

extern FAR const char * const C1TEXT;

/* After level 11, put this:*/

extern FAR const char * const C2TEXT;

/* After level 20, put this:*/

extern FAR const char * const C3TEXT;

/* After level 29, put this:*/

extern FAR const char * const C4TEXT;

/* Before level 31, put this:*/

extern FAR const char * const C5TEXT;

/* Before level 32, put this:*/

extern FAR const char * const C6TEXT;

/* after map 06	*/

extern FAR const char * const P1TEXT;

/* after map 11*/

extern FAR const char * const P2TEXT;

/* after map 20*/

extern FAR const char * const P3TEXT;

/* after map 30*/

extern FAR const char * const P4TEXT;

/* before map 31*/

extern FAR const char * const P5TEXT;

/* before map 32*/

extern FAR const char * const P6TEXT;

extern FAR const char * const T1TEXT;

extern FAR const char * const T2TEXT;

extern FAR const char * const T3TEXT;

extern FAR const char * const T4TEXT;

extern FAR const char * const T5TEXT;

extern FAR const char * const T6TEXT;

/**/
/* extern FAR character cast strings F_FINALE.C*/
/**/

#define CC_ZOMBIE "ZOMBIEMAN"
#define CC_SHOTGUN "SHOTGUN GUY"
#define CC_HEAVY "HEAVY WEAPON DUDE"
#define CC_IMP "IMP"
#define CC_DEMON "DEMON"
#define CC_LOST "LOST SOUL"
#define CC_CACO "CACODEMON"
#define CC_HELL "HELL KNIGHT"
#define CC_BARON "BARON OF HELL"
#define CC_ARACH "ARACHNOTRON"
#define CC_PAIN "PAIN ELEMENTAL"
#define CC_REVEN "REVENANT"
#define CC_MANCU "MANCUBUS"
#define CC_ARCH "ARCH-VILE"
#define CC_SPIDER "THE SPIDER MASTERMIND"
#define CC_CYBER "THE CYBERDEMON"
#define CC_HERO "OUR HERO"

#endif
/*-----------------------------------------------------------------------------*/
/**/
/* $Log:$*/
/**/
/*-----------------------------------------------------------------------------*/
