#include "deh.h"

char *datanames[NUMDATA] = {
    "Thing",   //	#defined to be... 0
    "Sound",   // 1
    "Frame",   // 2
    "Sprite",  // 3
    "Ammo",    // 4
    "Weapon",  // 5
    "Text"     // 6
};

// [mobjinfo_t] in "info.c"
// Name for all the fields of all the data types... whew...
char *thingfields[THING_FIELDS] = {"ID #",
                                   "Initial frame",
                                   "Hit points",
                                   "First moving frame",
                                   "Alert sound",
                                   "Reaction time",
                                   "Attack sound",
                                   "Injury frame",
                                   "Pain chance",
                                   "Pain sound",
                                   "Close attack frame",
                                   "Far attack frame",
                                   "Death frame",
                                   "Exploding frame",
                                   "Death sound",
                                   "Speed",
                                   "Width",
                                   "Height",
                                   "Mass",
                                   "Missile damage",
                                   "Action sound",
                                   "Bits",
                                   "Respawn frame"};

// S_sfx in "sounds.c" (sfxinfo_t)
char *soundfields[SOUND_FIELDS] = {"Offset",     "Zero/One", "Value",  "Zero 1", "Neg. One 1",
                                   "Neg. One 2", "Zero 2",   "Zero 3", "Zero 4"};

// states in "info.c"
char *framefields[FRAME_FIELDS] = {"Sprite number", "Sprite subnumber", "Duration", "Action pointer",
                                   "Next frame",    "Unknown 1",        "Unknown 2"};

// weaponinfo in "d_items.c"
char *weaponfields[WEAPON_FIELDS] = {"Ammo type",     "Deselect frame", "Select frame",
                                     "Bobbing frame", "Shooting frame", "Firing frame"};

// init. max ammo und ammo per item in "p_inter.c"
// maxammo[NUMAMMO] clipammo[NUMAMMO]
