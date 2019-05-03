#include <OSIncludes.h>

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "deh.h"
#include "dehinit.h"

static struct DEHInit *init;
static FILE *fp;
static char s[502], *sp;
static short linenumber, i;
static long MAXOBJ[NUMDATA];
static long RETURNCODE = RETURN_OK;

static char *VERSTRING =
    "$VER: DADeHackEd 0.5 ("__TIMESTAMP__
    ")";
static char *AUTHSTRING = "$AUTH: Georg Steger";

static int GetLine(void)
{
    short i;
    char c;

    while (fgets(s, 500, fp)) {
        linenumber++;

        i = strlen(s);

        // kill white spaces at the EOL
        while (i) {
            c = s[i - 1];
            if (c == ' ' || c == '\t' || c == '\r' || c == '\n') {
                i--;
            } else
                break;
        }
        s[i] = '\0';

        // kill white spaces at the start of the line

        sp = s;
        while (1) {
            c = *sp;
            if (c && (c == ' ' || c == '\t' || c == '\r' || c == '\n')) {
                sp++;
            } else
                break;
        }

        if (*sp && (*sp != '#'))
            return 1;
    }

    return 0;
}

static int ProcessLine(char **line2)
{
    int i = 0, j = 0;

    // Search line for an =
    while (sp[i] != 0 && sp[i] != '=')
        i++;

    // If we found one...
    if (sp[i] == '=') {
        // Search for the first non-space after the =.
        j = i--;
        while (isspace(sp[++j]))
            ;

        // It was all whitespace, error... should be equal to something
        if (sp[j] == 0)
            return -1;

        // Set line2 to the first non-space after an =
        *line2 = sp + j;

        // Kill any whitespace before the =...
        while (i >= 0 && isspace(sp[i]))
            i--;

        // It was all whitespace, error... should be something before =
        if (i == -1)
            return -2;

        // OK, put in an end-of-string character to kill the space(s)
        sp[i + 1] = 0;

        // Successful
        return 1;
    }
    // Otherwise, the line should have two separate words on it
    else {
        // Search for first space on the line
        while (sp[j] != 0 && !isspace(sp[j]))
            j++;

        // Only one word on line, didn't find any spaces at all
        if (sp[j] == 0)
            return -3;

        // Found some space(s), now search for the second word
        i = j;
        while (isspace(sp[++i]))
            ;

        // No non-spaces after the first word
        if (sp[i] == 0)
            return -3;

        // Set this to the first letter of the second word
        *line2 = sp + i;

        // Terminate the first word's string
        sp[j] = 0;

        // Successful
        return 2;
    }
}

static void Action(void)
{
    char *param;
    long result;
    long curtype = -1;
    long curnumber = -1;
    long min, max;
    boolean matched, valid;

    if (!GetLine())
        return;

    while (GetLine()) {
        matched = NO;
        valid = YES;

        result = ProcessLine(&param);
        if (result < 0) {
            printf("DeHackEd: Parse error in line %d!\n", linenumber);
            return;
        } else if (result == 2) {
            // KEYWORD VALUE
            // sections
            for (i = 0; i < NUMDATA; i++) {
                if (!stricmp(sp, datanames[i])) {
                    matched = YES;
                    curtype = i;
                    if (!sscanf(param, "%ld", &curnumber)) {
                        printf("DeHackED: Line %d: Unreadable number (%s)!\n", linenumber, param);
                        return;
                    }
                    if (curtype == DATA_THING) {
                        min = 1;
                        max = MAXOBJ[DATA_THING];
                    } else {
                        min = 0;
                        max = MAXOBJ[curtype] - 1;
                    }

                    if (curnumber < min || curnumber > max) {
                        printf("DeHackED: Line %d: Number out of range!\n", linenumber);
                        return;
                    }
                    break;
                }
            }
        } else if (result == 1) {
            // KEYWORD = VALUE

            if (!stricmp(sp, "doom version")) {
                matched = YES;
                printf("DeHackED: Doom Version %s\n", param);
            } else if (!stricmp(sp, "patch format")) {
                matched = YES;
                printf("DeHackED: Patch format %s\n", param);

                // THINGS ** EVERYTHING :) **
            } else if (curtype == DATA_THING) {
                for (i = 0; i < THING_FIELDS; i++) {
                    if (!stricmp(thingfields[i], sp)) {
                        matched = YES;
                        if (sscanf(param, "%ld", &(init->dehi_things[curnumber - 1][i])) == 0)
                            valid = NO;
                        break;
                    }
                }

                // FRAMES ** EVERYTHING BUT "Action Pointer" :| **
            } else if (curtype == DATA_FRAME) {
                for (i = 0; i < FRAME_FIELDS; i++) {
                    if (!stricmp(framefields[i], sp)) {
                        matched = YES;
                        // ignore "Action Pointer"
                        if (i != 3) {
                            if (sscanf(param, "%ld", &(init->dehi_frames[curnumber][i])) == 0)
                                valid = NO;
                        }
                        break;
                    }
                }

                // SOUNDS ** EVERYTHING BUT "Offset" :| **
            } else if (curtype == DATA_SOUND) {
                for (i = 0; i < SOUND_FIELDS; i++) {
                    if (!stricmp(soundfields[i], sp)) {
                        matched = YES;
                        if (i != 0) {
                            if (sscanf(param, "%ld", &(init->dehi_sounds[curnumber][i])) == 0)
                                valid = NO;
                        }
                        break;
                    }
                }

                // SPRITES ** NOTHING :( **
            } else if (curtype == DATA_SPRITE) {
                if (!stricmp(sp, "offset")) {
                    matched = YES;
                }

                // AMMO ** EVERYTHING :) **
            } else if (curtype == DATA_AMMO) {
                if (!stricmp(sp, "Max ammo")) {
                    matched = YES;
                    if (sscanf(param, "%ld", &(init->dehi_maxammo[curnumber])) == 0)
                        valid = NO;
                } else if (!stricmp(sp, "Per ammo")) {
                    matched = YES;
                    if (sscanf(param, "%ld", &(init->dehi_perammo[curnumber])) == 0)
                        valid = NO;
                }

                // WEAPON ** EVERYTHING :) **
            } else if (curtype == DATA_WEAPON) {
                for (i = 0; i < WEAPON_FIELDS; i++) {
                    if (!stricmp(weaponfields[i], sp)) {
                        matched = YES;
                        if (sscanf(param, "%ld", &(init->dehi_weapons[curnumber][i])) == 0)
                            valid = NO;
                        break;
                    }
                }
            }

        }  // else if (result == 1)

        if (matched == NO) {
            printf("DeHackEd: Line %d: Unknown line!\n", linenumber);
            if (RETURNCODE < RETURN_WARN)
                RETURNCODE = RETURN_WARN;
        }
        if (valid == NO) {
            printf("DeHackED: Line %d: Unreadable value in a \"%s\" field!\n", linenumber, datanames[curtype]);
            if (RETURNCODE < RETURN_ERROR)
                RETURNCODE = RETURN_ERROR;
        }
    }  // while (GetLine())
}

long DeHackEd(char *filename, struct DEHInit *i)
{
    InitRuntime();

    init = i;
    if (!(fp = fopen(filename, "rb"))) {
        printf("DeHackED: Could not open \"%s\"!\n", filename);
        RETURNCODE = RETURN_FAIL;

    } else {
        MAXOBJ[DATA_THING] = init->dehi_NUMTHINGS;
        MAXOBJ[DATA_SOUND] = init->dehi_NUMSOUNDS;
        MAXOBJ[DATA_FRAME] = init->dehi_NUMFRAMES;
        MAXOBJ[DATA_WEAPON] = init->dehi_NUMWEAPONS;
        MAXOBJ[DATA_AMMO] = init->dehi_NUMAMMOS;
        MAXOBJ[DATA_SPRITE] = init->dehi_NUMSPRITES;

        Action();

        fclose(fp);
    }

    CleanupRuntime();

    return RETURNCODE;
}
