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
/*	Main loop menu stuff.*/
/*	Default Config File.*/
/*	PCX Screenshots.*/
/**/
/*-----------------------------------------------------------------------------*/

static const char rcsid[] = "$Id: m_misc.c,v 1.6 1997/02/03 22:45:10 b1 Exp $";

/*#include <sys/stat.h>*/
/*#include <sys/types.h>*/
/*#include <fcntl.h>*/
#include <stdio.h>
#include <stdlib.h>
/*#include <unistd.h>*/

#include <ctype.h>

#include "doomdef.h"

#include "z_zone.h"

#include "m_argv.h"
#include "m_swap.h"

#include "w_wad.h"

#include "i_system.h"
#include "i_video.h"
#include "v_video.h"

#include "hu_stuff.h"

/* State.*/
#include "doomstat.h"

/* Data.*/
#include "dstrings.h"

#include "m_misc.h"

/**/
/* M_DrawText*/
/* Returns the final X coordinate*/
/* HU_Init must have been called to init the font*/
/**/
extern patch_t *hu_font[HU_FONTSIZE];

int M_DrawText(int x, int y, boolean direct, char *string)
{
    int c;
    int w;

    while (*string) {
        c = toupper(*string) - HU_FONTSTART;
        string++;
        if (c < 0 || c > HU_FONTSIZE) {
            x += 4;
            continue;
        }

        w = SHORT(hu_font[c]->width);
        if (x + w > SCREENWIDTH)
            break;
        if (direct)
            V_DrawPatchDirect3(x, y, 0, hu_font[c]);
        else
            V_DrawPatch3(x, y, 0, hu_font[c]);
        x += w;
    }

    return x;
}

/**/
/* M_WriteFile*/
/**/
#ifndef O_BINARY
#define O_BINARY 0
#endif

boolean M_WriteFile(char const *name, void *source, int length)
{
    /* hallohallohallo*/
    FILE *handle;
    int count;

    handle = fopen(name, "wb");

    if (handle == NULL)
        return false;

    count = fwrite(source, 1, length, handle);
    fclose(handle);

    if (count < length)
        return false;

    return true;
}

/**/
/* M_ReadFile*/
/**/
int M_ReadFile(char const *name, byte **buffer)
{
    /* hallohallohallo*/

    FILE *handle;
    int count, length;
    /*    struct stat	fileinfo;*/
    byte *buf;

    handle = fopen(name, "rb");
    if (handle == NULL)
        I_Error("Couldn't read file %s", name);
    /*    if (fstat (handle,&fileinfo) == -1)*/
    /*	I_Error ("Couldn't read file %s", name);*/

    /*    length = fileinfo.st_size;*/

    fseek(handle, 0, SEEK_END);
    length = ftell(handle);
    fseek(handle, 0, SEEK_SET);

    buf = Z_Malloc(length, PU_STATIC, NULL);
    count = fread(buf, 1, length, handle);
    fclose(handle);

    if (count < length)
        I_Error("Couldn't read file %s", name);

    *buffer = buf;
    return length;
}

/**/
/* DEFAULTS*/
/**/
int special;
int usemouse;
int usejoystick;

extern int key_right;
extern int key_left;
extern int key_up;
extern int key_down;

extern int key_strafeleft;
extern int key_straferight;

extern int key_fire;
extern int key_use;
extern int key_strafe;
extern int key_strafe2;
extern int key_speed;
extern int key_speed2;
extern int key_lookup;
extern int key_lookdown;
extern int key_lookcenter;
extern int key_look;
extern int keylookspeed;
extern int key_jump;
extern int key_alwaysrun;
extern int key_crosshair;
extern int jumppower;
extern int skystretch;

extern int mousebfire;
extern int mousebstrafe;
extern int mousebforward;
extern int mouseblook;
extern int mousebweapon;
extern int mousebjump;

extern int joybfire;
extern int joybstrafe;
extern int joybuse;
extern int joybspeed;
extern int joyblook;
extern int joybweapon;
extern int joybjump;

extern int joy_pad;
extern int joy_port;

extern int analog_centerx;
extern int analog_centery;
extern int analog_aspect;
extern int analog_neutralzone;
extern int analog_sensitivity;
extern int analog_rmbsensitivity;

extern int viewwidth;
extern int viewheight;

extern int mouseSensitivity;
extern int showMessages;

extern int detailLevel;

extern int screenblocks;
extern int DoFastRemap;

extern int showMessages;

extern int configmodeid;
extern int REALSCREENWIDTH;
extern int REALSCREENHEIGHT;

extern char *NetPlugin;
extern char *MusicPlugin;
extern char *StartOptions;

extern int full_keys;
extern int full_mouse;
extern int configkb_used;
extern int configfree_fast;
extern int ConfigCacheSound;
extern int soundfilter;
extern int maxammo[];
extern int MAXIMUM_HEALTH;
extern int MAXIMUM_ARMOR;
extern int ConfigNoRangeCheck;
extern int french_keymap;
extern int configcoolmap;
extern int hudmap;
extern int hudmaptrans;
extern int usemmu;
extern int hidemouse;
extern int NoMouseRun;
extern int mouselookspeed;
extern int GRAVITY;
extern int noautoaim;
extern int crosshair;
extern int autocenterlook;
extern int autocenterlookspeed;
extern int alwaysrun;
extern int invertlook;
extern int windowpatch;
extern int crosshaircolor;
extern int maxvisplanes;
extern int maxvissprites;
extern int maxdrawsegs;
extern int uselocale;

extern char *c2p_routine;

/* machine-independent sound params*/
extern int numChannels;

/* UNIX hack, to be removed.*/
#ifdef SNDSERV
extern char *sndserver_filename;
extern int mb_used;
#endif

#ifdef LINUX
char *mousetype;
char *mousedev;
#endif

extern char *chat_macros[];

enum
{
    DTYP_INTEGER,
    DTYP_STRING
};

typedef struct
{
    char *name;
    int *location;
    int defaultvalue;
    int defaulttype;
    int scantranslate; /* PC scan code hack*/
    int untranslated;  /* lousy hack*/
} default_t;

default_t defaults[] = {{"mouse_sensitivity", &mouseSensitivity, 5, DTYP_INTEGER},
                        {"sfx_volume", &snd_SfxVolume, 8, DTYP_INTEGER},
                        {"music_volume", &snd_MusicVolume, 8, DTYP_INTEGER},
                        {"show_messages", &showMessages, 1, DTYP_INTEGER},

#ifdef NORMALUNIX
                        {"key_right", &key_right, KEY_RIGHTARROW, DTYP_INTEGER},
                        {"key_left", &key_left, KEY_LEFTARROW, DTYP_INTEGER},
                        {"key_up", &key_up, 'w', DTYP_INTEGER},
                        {"key_down", &key_down, 's', DTYP_INTEGER},
                        {"key_strafeleft", &key_strafeleft, 'a', DTYP_INTEGER},
                        {"key_straferight", &key_straferight, 'd', DTYP_INTEGER},

                        {"key_fire", &key_fire, ' ', DTYP_INTEGER},
                        {"key_use", &key_use, 'f', DTYP_INTEGER},
                        {"key_strafe", &key_strafe, KEY_LALT, DTYP_INTEGER},
                        {"key_strafe2", &key_strafe2, KEY_RALT, DTYP_INTEGER},
                        {"key_speed", &key_speed, KEY_LSHIFT, DTYP_INTEGER},
                        {"key_speed2", &key_speed2, KEY_RSHIFT, DTYP_INTEGER},
                        {"key_lookup", &key_lookup, KEY_NUM7, DTYP_INTEGER},
                        {"key_lookdown", &key_lookdown, KEY_NUM1, DTYP_INTEGER},
                        {"key_lookcenter", &key_lookcenter, KEY_NUM4, DTYP_INTEGER},
                        {"key_forcelook", &key_look, 'z', DTYP_INTEGER},
                        {"key_lookspeed", &keylookspeed, 1000 / 64, DTYP_INTEGER},
                        {"key_jump", &key_jump, KEY_NUM0, DTYP_INTEGER},
                        {"key_alwaysrun", &key_alwaysrun, 'r', DTYP_INTEGER},
                        {"key_crosshair", &key_crosshair, 'x', DTYP_INTEGER},
                        {"jumppower", &jumppower, FRACUNIT * 8, DTYP_INTEGER},
                        {"skystretch", &skystretch, 3, DTYP_INTEGER},

/* UNIX hack, to be removed. */
#ifdef SNDSERV
                        {"sndserver", (int *)&sndserver_filename, (int)"sndserver", DTYP_STRING},
                        {"mb_used", &mb_used, 2, DTYP_INTEGER},
#endif

#endif

#ifdef LINUX
                        {"mousedev", (int *)&mousedev, (int)"/dev/ttyS0", DTYP_STRING},
                        {"mousetype", (int *)&mousetype, (int)"microsoft", DTYP_STRING},
#endif

                        {"use_mouse", &usemouse, 1, DTYP_INTEGER},
                        {"mouseb_fire", &mousebfire, 0, DTYP_INTEGER},
                        {"mouseb_strafe", &mousebstrafe, 1, DTYP_INTEGER},
                        {"mouseb_forward", &mousebforward, 2, DTYP_INTEGER},
                        {"mouseb_look", &mouseblook, 3, DTYP_INTEGER},
                        {"mouseb_weapon", &mousebweapon, 3, DTYP_INTEGER},
                        {"mouseb_jump", &mousebjump, 3, DTYP_INTEGER},
                        {"nomouserun", &NoMouseRun, 1, DTYP_INTEGER},
                        {"mouselookspeed", &mouselookspeed, 32, DTYP_INTEGER},

                        {"use_joystick", &usejoystick, 0, DTYP_INTEGER},
                        {"joyb_fire", &joybfire, 0, DTYP_INTEGER},
                        {"joyb_strafe", &joybstrafe, 1, DTYP_INTEGER},
                        {"joyb_use", &joybuse, 3, DTYP_INTEGER},
                        {"joyb_speed", &joybspeed, 2, DTYP_INTEGER},
                        {"joyb_look", &joyblook, 4, DTYP_INTEGER},
                        {"joyb_weapon", &joybweapon, 4, DTYP_INTEGER},
                        {"joyb_jump", &joybjump, 4, DTYP_INTEGER},
                        {"joy_pad", &joy_pad, 0, DTYP_INTEGER},
                        {"joy_port", &joy_port, 1, DTYP_INTEGER},

                        {"analog_centerx", &analog_centerx, 0, DTYP_INTEGER},
                        {"analog_centery", &analog_centery, 0, DTYP_INTEGER},
                        {"analog_aspect", &analog_aspect, 0, DTYP_INTEGER},
                        {"analog_neutralzone", &analog_neutralzone, 4, DTYP_INTEGER},
                        {"analog_sensitivity", &analog_sensitivity, 120, DTYP_INTEGER},
                        {"analog_b2sensitivity", &analog_rmbsensitivity, 120, DTYP_INTEGER},

                        {"screenblocks", &screenblocks, 9, DTYP_INTEGER},
                        {"detaillevel", &detailLevel, 0, DTYP_INTEGER},

                        /*    {"snd_channels",&numChannels, 4},*/
                        {"displayid", &configmodeid, -1, DTYP_INTEGER}, /* invalid id */
                        {"screenwidth", &REALSCREENWIDTH, 320, DTYP_INTEGER},
                        {"screenheight", &REALSCREENHEIGHT, 200, DTYP_INTEGER},
                        {"fastremap", &DoFastRemap, 0, DTYP_INTEGER},

                        {"usegamma", &usegamma, 0, DTYP_INTEGER},

                        {"chatmacro0", (int *)&chat_macros[0], (int)HUSTR_CHATMACRO0, DTYP_STRING},
                        {"chatmacro1", (int *)&chat_macros[1], (int)HUSTR_CHATMACRO1, DTYP_STRING},
                        {"chatmacro2", (int *)&chat_macros[2], (int)HUSTR_CHATMACRO2, DTYP_STRING},
                        {"chatmacro3", (int *)&chat_macros[3], (int)HUSTR_CHATMACRO3, DTYP_STRING},
                        {"chatmacro4", (int *)&chat_macros[4], (int)HUSTR_CHATMACRO4, DTYP_STRING},
                        {"chatmacro5", (int *)&chat_macros[5], (int)HUSTR_CHATMACRO5, DTYP_STRING},
                        {"chatmacro6", (int *)&chat_macros[6], (int)HUSTR_CHATMACRO6, DTYP_STRING},
                        {"chatmacro7", (int *)&chat_macros[7], (int)HUSTR_CHATMACRO7, DTYP_STRING},
                        {"chatmacro8", (int *)&chat_macros[8], (int)HUSTR_CHATMACRO8, DTYP_STRING},
                        {"chatmacro9", (int *)&chat_macros[9], (int)HUSTR_CHATMACRO9, DTYP_STRING},

                        {"music_plugin", (int *)&MusicPlugin, (int)"", DTYP_STRING},
                        {"sound_cache", &ConfigCacheSound, 0, DTYP_INTEGER},
                        {"soundfilter", &soundfilter, 0, DTYP_INTEGER},
                        {"net_plugin", (int *)&NetPlugin, (int)"", DTYP_STRING},
                        {"full_keys", &full_keys, 0, DTYP_INTEGER},
                        {"full_mouse", &full_mouse, 0, DTYP_INTEGER},
                        {"zone_size", &configkb_used, 6 * 1024, DTYP_INTEGER},
                        {"zone_freefast", &configfree_fast, 1024, DTYP_INTEGER},
                        {"c2p_routine", (int *)&c2p_routine, (int)"PROGDIR:DoomAttackSupport/c2p/c2p_blitter", DTYP_STRING},
                        {"max_health", &MAXIMUM_HEALTH, 200, DTYP_INTEGER},
                        {"max_armor", &MAXIMUM_ARMOR, 200, DTYP_INTEGER},
                        {"max_ammo1", &maxammo[0], 200, DTYP_INTEGER},
                        {"max_ammo2", &maxammo[1], 50, DTYP_INTEGER},
                        {"max_ammo3", &maxammo[2], 300, DTYP_INTEGER},
                        {"max_ammo4", &maxammo[3], 50, DTYP_INTEGER},
                        {"norangecheck", &ConfigNoRangeCheck, 0, DTYP_INTEGER},
                        {"french_keymap", &french_keymap, 0, DTYP_INTEGER},
                        {"coolmap", &configcoolmap, 0, DTYP_INTEGER},
                        {"maptype", &hudmap, 0, DTYP_INTEGER},
                        {"hudmaptrans", &hudmaptrans, 0, DTYP_INTEGER},
                        {"mmu", &usemmu, 0, DTYP_INTEGER},
                        {"hidemouse", &hidemouse, 1, DTYP_INTEGER},
                        {"startoptions", (int *)&StartOptions, (int)"", DTYP_STRING},
                        {"gravity", &GRAVITY, FRACUNIT, DTYP_INTEGER},
                        {"noautoaim", &noautoaim, 0, DTYP_INTEGER},
                        {"crosshair", &crosshair, 0, DTYP_INTEGER},
                        {"autocenterlook", &autocenterlook, 0, DTYP_INTEGER},
                        {"autocenterlookspeed", &autocenterlookspeed, 2000 / 64, DTYP_INTEGER},
                        {"alwaysrun", &alwaysrun, 0, DTYP_INTEGER},
                        {"invertlook", &invertlook, 0, DTYP_INTEGER},
                        {"windowpatch", &windowpatch, 0, DTYP_INTEGER},
                        {"crosshaircolor", &crosshaircolor, 176, DTYP_INTEGER},
                        {"maxvisplanes", &maxvisplanes, 128, DTYP_INTEGER},
                        {"maxvissprites", &maxvissprites, 128, DTYP_INTEGER},
                        {"maxdrawsegs", &maxdrawsegs, 256, DTYP_INTEGER},
                        {"special", &special, 0, DTYP_INTEGER},
                        {"uselocale", &uselocale, 1, DTYP_INTEGER}};

int numdefaults;
char *defaultfile;

/**/
/* M_SaveDefaults*/
/**/

void M_SaveDefaults(void)
{
    static char *tabs = "\t\t\t";
    int i, l;
    int v;
    FILE *f;

    f = fopen(defaultfile, "w");
    if (!f)
        return; /* can't write the file, but don't complain*/

    /* hallohallohallo */

    for (i = 0; i < numdefaults; i++) {
        l = strlen(defaults[i].name) / 8;

        if (defaults[i].defaulttype == DTYP_INTEGER) {
            v = *defaults[i].location;
            fprintf(f, "%s\%s%i\n", defaults[i].name, tabs + l, v);
        } else {
            fprintf(f, "%s\%s\"%s\"\n", defaults[i].name, tabs + l, *(char **)(defaults[i].location));
        }
    }

    fclose(f);
}

/**/
/* M_LoadDefaults*/
/**/
extern byte scantokey[128];

extern char *I_GetCommentConfig(void);
extern void I_InitConfigArgs(void);

void M_LoadDefaults(void)
{
    int i;
    int len;
    FILE *f;
    char def[80];
    char strparm[100];
    char *newstring;
    int parm;
    boolean isstring;

    /* set everything to base values*/
    numdefaults = sizeof(defaults) / sizeof(defaults[0]);
    for (i = 0; i < numdefaults; i++)
        *defaults[i].location = defaults[i].defaultvalue;

    /* check for a custom default file*/
    i = M_CheckParm("-config");
    if (i && i < myargc - 1) {
        defaultfile = myargv[i + 1];
        printf("	default file: %s\n", defaultfile);
    } else {
        if ((newstring = I_GetCommentConfig())) {
            defaultfile = newstring;
        } else {
            defaultfile = basedefault;
        }
    }

    /* read the file in, overriding any set defaults*/
    f = fopen(defaultfile, "r");
    if (f) {
        while (!feof(f)) {
            isstring = false;
            if (fscanf(f, "%79s %[^\n]\n", def, strparm) == 2) {
                if (strparm[0] == '"') {
                    /* get a string default*/
                    isstring = true;
                    len = strlen(strparm);
                    newstring = (char *)malloc(len);
                    strparm[len - 1] = 0;
                    strcpy(newstring, strparm + 1);
                } else if (strparm[0] == '0' && strparm[1] == 'x')
                    sscanf(strparm + 2, "%x", &parm);
                else
                    sscanf(strparm, "%i", &parm);
                for (i = 0; i < numdefaults; i++)
                    if (!strcmp(def, defaults[i].name)) {
                        if (!isstring)
                            *defaults[i].location = parm;
                        else
                            *defaults[i].location = (int)newstring;
                        break;
                    }
            }
        }

        fclose(f);

        I_InitConfigArgs();
    }
}

/**/
/* SCREEN SHOTS*/
/**/

typedef struct
{
    char manufacturer;
    char version;
    char encoding;
    char bits_per_pixel;

    unsigned short xmin;
    unsigned short ymin;
    unsigned short xmax;
    unsigned short ymax;

    unsigned short hres;
    unsigned short vres;

    unsigned char palette[48];

    char reserved;
    char color_planes;
    unsigned short bytes_per_line;
    unsigned short palette_type;

    char filler[58];
    unsigned char data; /* unbounded*/
} pcx_t;

/**/
/* WritePCXfile*/
/**/
static void WritePCXfile(char *filename, byte *data, int width, int height, byte *palette)
{
    int i;
    int length;
    pcx_t *pcx;
    byte *pack;

    pcx = Z_Malloc(width * height * 2 + 1000, PU_STATIC, NULL);

    pcx->manufacturer = 0x0a; /* PCX id*/
    pcx->version = 5;         /* 256 color*/
    pcx->encoding = 1;        /* uncompressed*/
    pcx->bits_per_pixel = 8;  /* 256 color*/
    pcx->xmin = 0;
    pcx->ymin = 0;
    pcx->xmax = SHORT(width - 1);
    pcx->ymax = SHORT(height - 1);
    pcx->hres = SHORT(width);
    pcx->vres = SHORT(height);
    memset(pcx->palette, 0, sizeof(pcx->palette));
    pcx->color_planes = 1; /* chunky image*/
    pcx->bytes_per_line = SHORT(width);
    pcx->palette_type = SHORT(2); /* not a grey scale*/
    memset(pcx->filler, 0, sizeof(pcx->filler));

    /* pack the image*/
    pack = &pcx->data;

    for (i = 0; i < width * height; i++) {
        if ((*data & 0xc0) != 0xc0)
            *pack++ = *data++;
        else {
            *pack++ = 0xc1;
            *pack++ = *data++;
        }
    }

    /* write the palette*/
    *pack++ = 0x0c; /* palette ID byte*/
    for (i = 0; i < 768; i++)
        *pack++ = *palette++;

    /* write output file*/
    length = pack - (byte *)pcx;
    M_WriteFile(filename, pcx, length);

    Z_Free(pcx);
}

/**/
/* M_ScreenShot*/
/**/
void M_ScreenShot(void)
{
    FILE *handle;

    int i;
    byte *linear;
    char lbmname[12];

    /* munge planar buffer to linear*/
    linear = screens[2];
    I_ReadScreen(linear);

    /* hallohallohallo */
    /* find a file name to save it to*/
    strcpy(lbmname, "DOOM00.IFF");

    for (i = 0; i <= 99; i++) {
        lbmname[4] = i / 10 + '0';
        lbmname[5] = i % 10 + '0';
        if ((handle = fopen(lbmname, "rb")) == NULL)
            break; /* file doesn't exist*/
        fclose(handle);
    }

    /* hallohallohallo */

    I_IFFScreenShot(lbmname, linear, REALSCREENWIDTH, REALSCREENHEIGHT, W_CacheLumpName("PLAYPAL", PU_CACHE));

    /* save the pcx file*/
    /*    WritePCXfile (lbmname, linear,
              SCREENWIDTH, SCREENHEIGHT,
              W_CacheLumpName ("PLAYPAL",PU_CACHE));*/

    theconsoleplayer->message = "Screen Shot";
}
