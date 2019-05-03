
struct DEHInit
{
    long (*dehi_things)[THING_FIELDS];
    long (*dehi_sounds)[SOUND_FIELDS];
    long (*dehi_frames)[FRAME_FIELDS];
    long (*dehi_weapons)[WEAPON_FIELDS];
    long *dehi_maxammo;
    long *dehi_perammo;
    long *dehi_sprites;

    long dehi_NUMTHINGS;
    long dehi_NUMSOUNDS;
    long dehi_NUMFRAMES;
    long dehi_NUMWEAPONS;
    long dehi_NUMAMMOS;
    long dehi_NUMSPRITES;
};
