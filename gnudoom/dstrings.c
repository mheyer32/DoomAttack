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
/* $Log:$*/
/**/
/* DESCRIPTION:*/
/*	Globally defined strings.*/
/* */
/*-----------------------------------------------------------------------------*/

static const char
rcsid[] = "$Id: m_bbox.c,v 1.1 1997/02/03 22:45:10 b1 Exp $";


#ifdef __GNUG__
#pragma implementation "dstrings.h"
#endif
#include "dstrings.h"



char* endmsg[NUM_QUITMESSAGES+1]=
{
  /* DOOM1*/
  /* QUITMSG, */
  "are you sure you want to\nquit this great game?",
  "please don't leave, there's more\ndemons to toast!",
  "let's beat it -- this is turning\ninto a bloodbath!",
  "i wouldn't leave if i were you.\ndos is much worse.",
  "you're trying to say you like dos\nbetter than me, right?",
  "don't leave yet -- there's a\ndemon around that corner!",
  "ya know, next time you come in here\ni'm gonna toast ya.",
  "go ahead and leave. see if i care.",

  /* QuitDOOM II messages*/
  "you want to quit?\nthen, thou hast lost an eighth!",
  "don't go now, there's a \ndimensional shambler waiting\nat the dos prompt!",
  "get outta here and go back\nto your boring programs.",
  "if i were your boss, i'd \n deathmatch ya in a minute!",
  "look, bud. you leave now\nand you forfeit your body count!",
  "just leave. when you come\nback, i'll be waiting with a bat.",
  "you're lucky i don't smack\nyou for thinking about leaving.",

  /* FinalDOOM?*/
  "fuck you, pussy!\nget the fuck out!",
  "you quit and i'll jizz\nin your cystholes!",
  "if you leave, i'll make\nthe lord drink my jizz.",
  "hey, ron! can we say\n'fuck' in the game?",
  "i'd leave: this is just\nmore monsters and levels.\nwhat a load.",
  "suck it down, asshole!\nyou're a fucking wimp!",
  "don't quit now! we're \nstill spending your money!",

  /* Internal debug. Different style, too.*/
  "THIS IS NO MESSAGE!\nPage intentionally left blank."
};

char *YESKEY= "y";
char *NOKEY= "n";

char * D_DEVSTR=	"Development mode ON.\n";
char *D_CDROM=	"CD-ROM Version: default.cfg from c:\\doomdata\n";

/**/
/*	M_Menu.C*/
/**/
char *PRESSKEY =	"press a key.";
char *PRESSYN= 	"press y or n.";
char *QUITMSG=	"are you sure you want to\nquit this great game?";
char *LOADNET= 	"you can't do load while in a net game!\n\npress a key.";
char *QLOADNET=	"you can't quickload during a netgame!\n\npress a key.";
char *QSAVESPOT=	"you haven't picked a quicksave slot yet!\n\npress a key.";
char *SAVEDEAD =	"you can't save if you aren't playing!\n\npress a key.";
char *QSPROMPT =	"quicksave over your game named\n\n'%s'?\n\npress y or n.";
char *QLPROMPT=	"do you want to quickload the game named\n\n'%s'?\n\npress y or n.";

char *NEWGAME = "you can't start a new game\nwhile in a network game.\n\npress a key.";

char *NIGHTMARE = "are you sure? this skill level\nisn't even remotely fair.\n\npress y or n.";

char *SWSTRING	= "this is the shareware version of doom.\n\nyou need to order the entire trilogy.\n\npress a key.";

char *MSGOFF=	"Messages OFF";
char *MSGON	=	"Messages ON";
char *NETEND=	"you can't end a netgame!\n\npress a key.";
char *ENDGAME=	"are you sure you want to end the game?\n\npress y or n.";

char *DOSY	=	"(press y to quit)";

char *DETAILHI=	"High detail";
char *DETAILLO=	"Low detail";
char *ALWAYSRUNON= "Always run ON";
char *ALWAYSRUNOFF= "Always run OFF";
char *EMPTYSTRING=	"empty slot";

/**/
/*	P_inter.C*/
/**/
char *GOTARMOR=	"Picked up the armor.";
char *GOTMEGA=	"Picked up the MegaArmor!";
char *GOTHTHBONUS=	"Picked up a health bonus.";
char *GOTARMBONUS=	"Picked up an armor bonus.";
char *GOTSTIM=	"Picked up a stimpack.";
char *GOTMEDINEED=	"Picked up a medikit that you REALLY need!";
char *GOTMEDIKIT=	"Picked up a medikit.";
char *GOTSUPER=	"Supercharge!";

char *GOTBLUECARD=	"Picked up a blue keycard.";
char *GOTYELWCARD=	"Picked up a yellow keycard.";
char *GOTREDCARD=	"Picked up a red keycard.";
char *GOTBLUESKUL=	"Picked up a blue skull key.";
char *GOTYELWSKUL=	"Picked up a yellow skull key.";
char *GOTREDSKULL=	"Picked up a red skull key.";

char *GOTINVUL=	"Invulnerability!";
char *GOTBERSERK=	"Berserk!";
char *GOTINVIS=	"Partial Invisibility";
char *GOTSUIT=	"Radiation Shielding Suit";
char *GOTMAP=	"Computer Area Map";
char *GOTVISOR=	"Light Amplification Visor";
char *GOTMSPHERE=	"MegaSphere!";

char *GOTCLIP=	"Picked up a clip.";
char *GOTCLIPBOX=	"Picked up a box of bullets.";
char *GOTROCKET=	"Picked up a rocket.";
char *GOTROCKBOX=	"Picked up a box of rockets.";
char *GOTCELL=	"Picked up an energy cell.";
char *GOTCELLBOX=	"Picked up an energy cell pack.";
char *GOTSHELLS=	"Picked up 4 shotgun shells.";
char *GOTSHELLBOX=	"Picked up a box of shotgun shells.";
char *GOTBACKPACK=	"Picked up a backpack full of ammo!";

char *GOTBFG9000=	"You got the BFG9000!  Oh, yes.";
char *GOTCHAINGUN=	"You got the chaingun!";
char *GOTCHAINSAW=	"A chainsaw!  Find some meat!";
char *GOTLAUNCHER=	"You got the rocket launcher!";
char *GOTPLASMA=	"You got the plasma gun!";
char *GOTSHOTGUN=	"You got the shotgun!";
char *GOTSHOTGUN2=	"You got the super shotgun!";

/**/
/* P_Doors.C*/
/**/
char *PD_BLUEO=	"You need a blue key to activate this object";
char *PD_REDO=	"You need a red key to activate this object";
char *PD_YELLOWO=	"You need a yellow key to activate this object";
char *PD_BLUEK=	"You need a blue key to open this door";
char *PD_REDK=	"You need a red key to open this door";
char *PD_YELLOWK=	"You need a yellow key to open this door";

/**/
/*	G_game.C*/
/**/
char *GGSAVED=	"game saved.";

/**/
/*	HU_stuff.C*/
/**/
char *HUSTR_MSGU=	"[Message unsent]";


char *HUSTR_TALKTOSELF1=	"You mumble to yourself";
char *HUSTR_TALKTOSELF2=	"Who's there?";
char *HUSTR_TALKTOSELF3=	"You scare yourself";
char *HUSTR_TALKTOSELF4=	"You start to rave";
char *HUSTR_TALKTOSELF5=	"You've lost it...";

char *HUSTR_MESSAGESENT=	"[Message Sent]";

/* The following should NOT be changed unless it seems*/
/* just AWFULLY necessary*/

/**/
/*	AM_map.C*/
/**/

char *AMSTR_FOLLOWON=	"Follow Mode ON";
char *AMSTR_FOLLOWOFF=	"Follow Mode OFF";

char *AMSTR_GRIDON=	"Grid ON";
char *AMSTR_GRIDOFF=	"Grid OFF";

char *AMSTR_MARKEDSPOT=	"Marked Spot";
char *AMSTR_MARKSCLEARED=	"All Marks Cleared";

/**/
/*	ST_stuff.C*/
/**/

char *STSTR_MUS	=	"Music Change";
char *STSTR_NOMUS	=	"IMPOSSIBLE SELECTION";
char *STSTR_DQDON	=	"Degreelessness Mode On";
char *STSTR_DQDOFF=	"Degreelessness Mode Off";

char *STSTR_KFAADDED=	"Very Happy Ammo Added";
char *STSTR_FAADDED=	"Ammo (no keys) Added";

char *STSTR_NCON	=	"No Clipping Mode ON";
char *STSTR_NCOFF	=	"No Clipping Mode OFF";

char *STSTR_BEHOLD=	"inVuln, Str, Inviso, Rad, Allmap, or Lite-amp";
char *STSTR_BEHOLDX=	"Power-up Toggled";

char *STSTR_CHOPPERS=	"... doesn't suck - GM";
char *STSTR_CLEV	=	"Changing Level...";

/**/
/*	F_Finale.C*/
/**/
char *E1TEXT =
"Once you beat the big badasses and\n"
"clean out the moon base you're supposed\n"
"to win, aren't you? Aren't you? Where's\n"
"your fat reward and ticket home? What\n"
"the hell is this? It's not supposed to\n"
"end this way!\n"
"\n"
"It stinks like rotten meat, but looks\n"
"like the lost Deimos base.  Looks like\n"
"you're stuck on The Shores of Hell.\n"
"The only way out is through.\n"
"\n"
"To continue the DOOM experience, play\n"
"The Shores of Hell and its amazing\n"
"sequel, Inferno!\n";


char *E2TEXT =
"You've done it! The hideous cyber-\n"
"demon lord that ruled the lost Deimos\n"
"moon base has been slain and you\n"
"are triumphant! But ... where are\n"
"you? You clamber to the edge of the\n"
"moon and look down to see the awful\n"
"truth.\n" 
"\n"
"Deimos floats above Hell itself!\n"
"You've never heard of anyone escaping\n"
"from Hell, but you'll make the bastards\n"
"sorry they ever heard of you! Quickly,\n"
"you rappel down to  the surface of\n"
"Hell.\n"
"\n" 
"Now, it's on to the final chapter of\n"
"DOOM! -- Inferno.";


char *E3TEXT =
"The loathsome spiderdemon that\n"
"masterminded the invasion of the moon\n"
"bases and caused so much death has had\n"
"its ass kicked for all time.\n"
"\n"
"A hidden doorway opens and you enter.\n"
"You've proven too tough for Hell to\n"
"contain, and now Hell at last plays\n"
"fair -- for you emerge from the door\n"
"to see the green fields of Earth!\n"
"Home at last.\n" 
"\n"
"You wonder what's been happening on\n"
"Earth while you were battling evil\n"
"unleashed. It's good that no Hell-\n"
"spawn could have come through that\n"
"door with you ...";


char *E4TEXT =
"the spider mastermind must have sent forth\n"
"its legions of hellspawn before your\n"
"final confrontation with that terrible\n"
"beast from hell.  but you stepped forward\n"
"and brought forth eternal damnation and\n"
"suffering upon the horde as a true hero\n"
"would in the face of something so evil.\n"
"\n"
"besides, someone was gonna pay for what\n"
"happened to daisy, your pet rabbit.\n"
"\n"
"but now, you see spread before you more\n"
"potential pain and gibbitude as a nation\n"
"of demons run amok among our cities.\n"
"\n"
"next stop, hell on earth!";


/* after level 6, put this:*/

char *C1TEXT =
"YOU HAVE ENTERED DEEPLY INTO THE INFESTED\n"
"STARPORT. BUT SOMETHING IS WRONG. THE\n"
"MONSTERS HAVE BROUGHT THEIR OWN REALITY\n"
"WITH THEM, AND THE STARPORT'S TECHNOLOGY\n"
"IS BEING SUBVERTED BY THEIR PRESENCE.\n" 
"\n"
"AHEAD, YOU SEE AN OUTPOST OF HELL, A\n" 
"FORTIFIED ZONE. IF YOU CAN GET PAST IT,\n" 
"YOU CAN PENETRATE INTO THE HAUNTED HEART\n" 
"OF THE STARBASE AND FIND THE CONTROLLING\n" 
"SWITCH WHICH HOLDS EARTH'S POPULATION\n" 
"HOSTAGE.";

/* After level 11, put this:*/

char *C2TEXT =
"YOU HAVE WON! YOUR VICTORY HAS ENABLED\n" 
"HUMANKIND TO EVACUATE EARTH AND ESCAPE\n"
"THE NIGHTMARE.  NOW YOU ARE THE ONLY\n"
"HUMAN LEFT ON THE FACE OF THE PLANET.\n"
"CANNIBAL MUTATIONS, CARNIVOROUS ALIENS,\n"
"AND EVIL SPIRITS ARE YOUR ONLY NEIGHBORS.\n"
"YOU SIT BACK AND WAIT FOR DEATH, CONTENT\n"
"THAT YOU HAVE SAVED YOUR SPECIES.\n"
"\n"
"BUT THEN, EARTH CONTROL BEAMS DOWN A\n"
"MESSAGE FROM SPACE: \"SENSORS HAVE LOCATED\n"
"THE SOURCE OF THE ALIEN INVASION. IF YOU\n"
"GO THERE, YOU MAY BE ABLE TO BLOCK THEIR\n"
"ENTRY.  THE ALIEN BASE IS IN THE HEART OF\n"
"YOUR OWN HOME CITY, NOT FAR FROM THE\n"
"STARPORT.\" SLOWLY AND PAINFULLY YOU GET\n"
"UP AND RETURN TO THE FRAY.";


/* After level 20, put this:*/

char *C3TEXT =
"YOU ARE AT THE CORRUPT HEART OF THE CITY,\n"
"SURROUNDED BY THE CORPSES OF YOUR ENEMIES.\n"
"YOU SEE NO WAY TO DESTROY THE CREATURES'\n"
"ENTRYWAY ON THIS SIDE, SO YOU CLENCH YOUR\n"
"TEETH AND PLUNGE THROUGH IT.\n"
"\n"
"THERE MUST BE A WAY TO CLOSE IT ON THE\n"
"OTHER SIDE. WHAT DO YOU CARE IF YOU'VE\n"
"GOT TO GO THROUGH HELL TO GET TO IT?";


/* After level 29, put this:*/

char *C4TEXT =
"THE HORRENDOUS VISAGE OF THE BIGGEST\n"
"DEMON YOU'VE EVER SEEN CRUMBLES BEFORE\n"
"YOU, AFTER YOU PUMP YOUR ROCKETS INTO\n"
"HIS EXPOSED BRAIN. THE MONSTER SHRIVELS\n"
"UP AND DIES, ITS THRASHING LIMBS\n"
"DEVASTATING UNTOLD MILES OF HELL'S\n"
"SURFACE.\n"
"\n"
"YOU'VE DONE IT. THE INVASION IS OVER.\n"
"EARTH IS SAVED. HELL IS A WRECK. YOU\n"
"WONDER WHERE BAD FOLKS WILL GO WHEN THEY\n"
"DIE, NOW. WIPING THE SWEAT FROM YOUR\n"
"FOREHEAD YOU BEGIN THE LONG TREK BACK\n"
"HOME. REBUILDING EARTH OUGHT TO BE A\n"
"LOT MORE FUN THAN RUINING IT WAS.\n";



/* Before level 31, put this:*/

char *C5TEXT =
"CONGRATULATIONS, YOU'VE FOUND THE SECRET\n"
"LEVEL! LOOKS LIKE IT'S BEEN BUILT BY\n"
"HUMANS, RATHER THAN DEMONS. YOU WONDER\n"
"WHO THE INMATES OF THIS CORNER OF HELL\n"
"WILL BE.";


/* Before level 32, put this:*/

char *C6TEXT =
"CONGRATULATIONS, YOU'VE FOUND THE\n"
"SUPER SECRET LEVEL!  YOU'D BETTER\n"
"BLAZE THROUGH THIS ONE!\n";


/* after map 06	*/

char *P1TEXT  =
"You gloat over the steaming carcass of the\n"
"Guardian.  With its death, you've wrested\n"
"the Accelerator from the stinking claws\n"
"of Hell.  You relax and glance around the\n"
"room.  Damn!  There was supposed to be at\n"
"least one working prototype, but you can't\n"
"see it. The demons must have taken it.\n"
"\n"
"You must find the prototype, or all your\n"
"struggles will have been wasted. Keep\n"
"moving, keep fighting, keep killing.\n"
"Oh yes, keep living, too.";


/* after map 11*/

char *P2TEXT =
"Even the deadly Arch-Vile labyrinth could\n"
"not stop you, and you've gotten to the\n"
"prototype Accelerator which is soon\n"
"efficiently and permanently deactivated.\n"
"\n"
"You're good at that kind of thing.";


/* after map 20*/

char *P3TEXT =
"You've bashed and battered your way into\n"
"the heart of the devil-hive.  Time for a\n"
"Search-and-Destroy mission, aimed at the\n"
"Gatekeeper, whose foul offspring is\n"
"cascading to Earth.  Yeah, he's bad. But\n"
"you know who's worse!\n"
"\n"
"Grinning evilly, you check your gear, and\n"
"get ready to give the bastard a little Hell\n"
"of your own making!";

/* after map 30*/

char *P4TEXT =
"The Gatekeeper's evil face is splattered\n"
"all over the place.  As its tattered corpse\n"
"collapses, an inverted Gate forms and\n"
"sucks down the shards of the last\n"
"prototype Accelerator, not to mention the\n"
"few remaining demons.  You're done. Hell\n"
"has gone back to pounding bad dead folks \n"
"instead of good live ones.  Remember to\n"
"tell your grandkids to put a rocket\n"
"launcher in your coffin. If you go to Hell\n"
"when you die, you'll need it for some\n"
"final cleaning-up ...";

/* before map 31*/

char *P5TEXT =
"You've found the second-hardest level we\n"
"got. Hope you have a saved game a level or\n"
"two previous.  If not, be prepared to die\n"
"aplenty. For master marines only.";

/* before map 32*/

char *P6TEXT =
"Betcha wondered just what WAS the hardest\n"
"level we had ready for ya?  Now you know.\n"
"No one gets out alive.";


char *T1TEXT =
"You've fought your way out of the infested\n"
"experimental labs.   It seems that UAC has\n"
"once again gulped it down.  With their\n"
"high turnover, it must be hard for poor\n"
"old UAC to buy corporate health insurance\n"
"nowadays..\n"
"\n"
"Ahead lies the military complex, now\n"
"swarming with diseased horrors hot to get\n"
"their teeth into you. With luck, the\n"
"complex still has some warlike ordnance\n"
"laying around.";


char *T2TEXT =
"You hear the grinding of heavy machinery\n"
"ahead.  You sure hope they're not stamping\n"
"out new hellspawn, but you're ready to\n"
"ream out a whole herd if you have to.\n"
"They might be planning a blood feast, but\n"
"you feel about as mean as two thousand\n"
"maniacs packed into one mad killer.\n"
"\n"
"You don't plan to go down easy.";


char *T3TEXT =
"The vista opening ahead looks real damn\n"
"familiar. Smells familiar, too -- like\n"
"fried excrement. You didn't like this\n"
"place before, and you sure as hell ain't\n"
"planning to like it now. The more you\n"
"brood on it, the madder you get.\n"
"Hefting your gun, an evil grin trickles\n"
"onto your face. Time to take some names.";

char *T4TEXT =
"Suddenly, all is silent, from one horizon\n"
"to the other. The agonizing echo of Hell\n"
"fades away, the nightmare sky turns to\n"
"blue, the heaps of monster corpses start \n"
"to evaporate along with the evil stench \n"
"that filled the air. Jeeze, maybe you've\n"
"done it. Have you really won?\n"
"\n"
"Something rumbles in the distance.\n"
"A blue light begins to glow inside the\n"
"ruined skull of the demon-spitter.";


char *T5TEXT =
"What now? Looks totally different. Kind\n"
"of like King Tut's condo. Well,\n"
"whatever's here can't be any worse\n"
"than usual. Can it?  Or maybe it's best\n"
"to let sleeping gods lie..";


char *T6TEXT =
"Time for a vacation. You've burst the\n"
"bowels of hell and by golly you're ready\n"
"for a break. You mutter to yourself,\n"
"Maybe someone else can kick Hell's ass\n"
"next time around. Ahead lies a quiet town,\n"
"with peaceful flowing water, quaint\n"
"buildings, and presumably no Hellspawn.\n"
"\n"
"As you step off the transport, you hear\n"
"the stomp of a cyberdemon's iron shoe.";



/**/
/* Character cast strings F_FINALE.C*/
/**/

/*-----------------------------------------------------------------------------*/
/**/
/* $Log:$*/
/**/



