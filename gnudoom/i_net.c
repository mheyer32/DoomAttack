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
/**/
/*-----------------------------------------------------------------------------*/

static const char rcsid[] = "$Id: m_bbox.c,v 1.1 1997/02/03 22:45:10 b1 Exp $";

#include <proto/dos.h>
#include <proto/exec.h>

#include <exec/devices.h>
#include <graphics/gfxbase.h>
#include <intuition/intuitionbase.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "d_event.h"
#include "d_net.h"
#include "i_system.h"
#include "m_argv.h"

#include "doomstat.h"

#ifdef __GNUG__
#pragma implementation "i_net.h"
#endif
#include "i_net.h"

#include "plugins/Include/DoomAttackNet.h"

// The inlines refer to DAN
static struct DANFile *DAN;
#include "plugins/Include/DoomAttackNetInline.h"

extern struct Library *IntuitionBase;
extern struct Library *GfxBase;
extern struct Library *KeymapBase;
extern struct Library *TimerBase;

static struct DANInitialization daninit;
static BPTR DANFile;
static void (*DAN_NetCmd)(void);

char *NetPlugin;

static LONG oldfpustate;

static void GetDANPlugin(void)
{
    int p;
    char id[5];

    DANFile = LoadSeg(NetPlugin);

    if (!DANFile) {
        fprintf(stderr, "I_Net: Couldn't load plugin \"%s\"!", NetPlugin);
    } else {
        DAN = (struct DANFile *)BADDR(DANFile);
        memcpy(id, DAN->id, 4);
        id[4] = '\0';
        if (strcmp(id, "DANW")) {
            fprintf(stderr, "I_Net: Invalid plugin (\"DANet.plugin\")!", NetPlugin);
            DAN = 0;
        } else {
            daninit.I_Error = I_Error;
            daninit.M_CheckParm = M_CheckParm;

            daninit.SysBase = SysBase;
            daninit.DOSBase = (struct Library*)DOSBase;
            daninit.IntuitionBase = IntuitionBase;
            daninit.GfxBase = GfxBase;
            daninit.KeymapBase = KeymapBase;
            daninit.TimerBase = (struct Device*)TimerBase;

            daninit.netbuffer = &netbuffer;
            daninit.doomcom = doomcom;
            daninit.myargv = myargv;
            daninit.myargc = myargc;

#ifdef version060
            __asm __volatile(
                "move.l	d0,-(sp) \n\t"
                "fmove.l	fpcr,d0 \n\t"
                "move.l	d0,_oldfpustate \n\t"
                "move.l	(sp)+,d0"
                :
                :
                : "memory");
#endif

            DANCall_Init(&daninit);

#ifdef version060
            __asm __volatile(
                "move.l	d0,-(sp) \n\t"
                "move.l	_oldfpustate,d0 \n\t"
                "fmove.l	d0,fpcr \n\t"
                "move.l	(sp)+,d0"
                :
                :
                : "memory");
#endif
        }
    }
}

void I_InitNetwork(void)
{
    BOOL ok;

    boolean trueval = true;
    int i;
    int p;
    struct hostent *hostentry; /* host information entry*/

    doomcom = malloc(sizeof(*doomcom));
    memset(doomcom, 0, sizeof(*doomcom));

    /* set up for network*/
    i = M_CheckParm("-dup");
    if (i && i < myargc - 1) {
        doomcom->ticdup = myargv[i + 1][0] - '0';
        if (doomcom->ticdup < 1)
            doomcom->ticdup = 1;
        if (doomcom->ticdup > 9)
            doomcom->ticdup = 9;
    } else
        doomcom->ticdup = 1;

    if (M_CheckParm("-extratic"))
        doomcom->extratics = 1;
    else
        doomcom->extratics = 0;

    /*    p = M_CheckParm ("-port");
        if (p && p<myargc-1)
        {
        DOOMPORT = atoi (myargv[p+1]);
        printf ("using alternate port %i\n",DOOMPORT);
        }*/

    ok = FALSE;

    /* parse network game options,*/
    /*  -net <consoleplayer> <host> <host> ...*/
    i = M_CheckParm("-net");

    if (i) {
        if (NetPlugin) {
            if (*NetPlugin)
                ok = TRUE;
        }
    }

    if (!ok) {
        /* single player game*/
        netgame = false;
        doomcom->id = DOOMCOM_ID;
        doomcom->numplayers = doomcom->numnodes = 1;
        doomcom->deathmatch = false;
        doomcom->consoleplayer = 0;
        return;
    }

    GetDANPlugin();

    ok = FALSE;
    if (DAN) {
        ok = DAN->DAN_InitNetwork();
    }

    if (!ok) {
        /* single player game*/
        doomcom->id = DOOMCOM_ID;
        doomcom->numplayers = doomcom->numnodes = 1;
        doomcom->deathmatch = false;
        doomcom->consoleplayer = 0;

        return;
    }

    DAN_NetCmd = DAN->DAN_NetCmd;

    netgame = true;
}

void I_NetCmd(void)
{
    if (netgame)
        DAN_NetCmd();
}

void I_CleanupNetwork(void)
{
    if (DAN) {
        DAN->DAN_CleanupNetwork();
    }

    if (DANFile)
        UnLoadSeg(DANFile);
}
