#define NUMDATA 7
#define THING_FIELDS 23
#define FRAME_FIELDS 7
#define SOUND_FIELDS 9
#define WEAPON_FIELDS 6

typedef enum { NO, YES } boolean;

enum
{
    DATA_THING,
    DATA_SOUND,
    DATA_FRAME,
    DATA_SPRITE,
    DATA_AMMO,
    DATA_WEAPON,
    DATA_TEXT
};

extern char *datanames[];
extern char *thingfields[];
extern char *soundfields[];
extern char *framefields[];
extern char *weaponfields[];
extern char *fullwepfields[];

struct DEHInit;

long DeHackEd(char *filename, struct DEHInit *i);
