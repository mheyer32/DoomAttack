#define GCMD_NOP 0
#define GCMD_SET_COLOR 4
#define GCMD_SET_COLMASK 5
#define GCMD_SET_RGB 6
#define GCMD_SET_READPOS 7
#define GCMD_START_LORES 8
#define GCMD_START_HIRES 24

static struct ColorSpec Colortable_320[] = {
    0, 0, 0, 0, 1, 0, 0, 1,  2, 0, 0, 8,  3, 0, 0, 9,  4, 0, 8, 0,  5, 0, 8, 1,  6, 0, 8, 8,  7, 0, 8, 9,  8,
    8, 0, 0, 9, 8, 0, 1, 10, 8, 0, 8, 11, 8, 0, 9, 12, 8, 8, 0, 13, 8, 8, 1, 14, 8, 8, 8, 15, 8, 8, 9, -1,
};
