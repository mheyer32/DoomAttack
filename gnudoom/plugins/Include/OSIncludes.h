#define __NOLIBBASE__

#include <devices/audio.h>
#include <devices/serial.h>
#include <graphics/copper.h>
#include <graphics/gfx.h>
#include <graphics/gfxmacros.h>
#include <graphics/videocontrol.h>
#include <intuition/pointerclass.h>
#include <libraries/iffparse.h>
#include <proto/alib.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/socket.h>

extern void InitRuntime(void);
extern void CleanupRuntime(void);
