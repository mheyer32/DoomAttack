#provide these as env variables at commandline
# i.e.  DEBUG=1 make all -j8
DEBUG ?= 0
BINDIR ?= bin
USENOIXEMUL ?= 1
VERSION060 ?= 0
PROFILE ?= 0

CC = m68k-amigaos-gcc
STRIP = m68k-amigaos-strip
PHXASS = vasmm68k_mot
VLINK = vlink

PREFIX = $(shell ./getprefix.sh "$(CC)")

CLIB_CFLAGS = -mcrt=clib2 -DUSECLIB2
CLIB_LDFLAGS =

NOIXEMUL_CFLAGS = -noixemul -DUSENOIXEMUL
NOIXEMUL_LDFLAGS =

ifeq ($(USENOIXEMUL), 1)
	RUNTIME_CFLAGS = $(NOIXEMUL_CFLAGS)
	RUNTIME_LDFLAGS = $(NOIXEMUL_LDFLAGS)
else
	RUNTIME_CFLAGS = $(CLIB_CFLAGS)
	RUNTIME_LDFLAGS = $(CLIB_LDFLAGS)
endif

CFLAGS = $(RUNTIME_CFLAGS)
LDFLAGS = $(RUNTIME_LDFLAGS) -g -ggdb

ifeq ($(VERSION060), 1)
	CFLAGS += -m68060 -Dversion060
else
	CFLAGS += -m68030
endif

CFLAGS += -msmall-code -g -ggdb
CFLAGS += -Werror -Wimplicit -Wstrict-prototypes
CFLAGS += -include "doomdef.h"

ifeq ($(DEBUG),1))
	CFLAGS += -DDEBUG -Og -fno-omit-frame-pointer
else
	CFLAGS += -DNDEBUG -Ofast
	ifeq ($(PROFILE), 0)
		CFLAGS += -fomit-frame-pointer
	endif
endif

ifeq ($(PROFILE), 1)
	CFLAGS += -pg
	LDFLAGS += -pg
endif

#-DRANGECHECK
CFLAGS += -D__BIG_ENDIAN__ -DNORMALUNIX -DAMIGA

PINCLUDES = -I$(PREFIX)/m68k-amigaos/ndk-include

PFLAGS = -Fhunk -phxass -warncomm -nosym -ldots -spaces $(PINCLUDES)
ifeq ($(VERSION060), 1)
	PFLAGS += -m68060 -Dversion060
else
	PFLAGS += -m68020up
endif

INTERMEDIATE =$(CURDIR)/build/
OUT = $(CURDIR)/bin/

OBJS = \
	am_map.o \
	am_mapamiga.o \
	analogjoy.o \
	clip.o \
	d_items.o \
	d_locale.o \
	d_main.o \
	d_net.o \
	doomdef.o \
	doomstat.o \
	dstrings.o \
	f_finale.o \
	f_wipe.o \
	g_game.o \
	hu_lib.o \
	hu_stuff.o \
	i_main.o \
	i_net.o \
	i_sound.o \
	i_system.o \
	i_systemmisc.o \
	i_video.o \
	info.o \
	m_argv.o \
	m_bbox.o \
	m_cheat.o \
	m_fixed.o \
	m_fixedamiga.o \
	m_menu.o \
	m_misc.o \
	m_random.o \
	m_swap.o \
	p_ceilng.o \
	p_doors.o \
	p_enemy.o \
	p_floor.o \
	p_inter.o \
	p_lights.o \
	p_map.o \
	p_maputl.o \
	p_mobj.o \
	p_plats.o \
	p_pspr.o \
	p_saveg.o \
	p_setup.o \
	p_sight.o \
	p_spec.o \
	p_switch.o \
	p_telept.o \
	p_tick.o \
	p_user.o \
	r_bsp.o \
	r_data.o \
	r_draw.o \
	r_engine.o \
	r_main.o \
	r_plane.o \
	r_segs.o \
	r_sky.o \
	r_things.o \
	s_sound.o \
	sounds.o \
	st_lib.o \
	st_stuff.o \
	tables.o \
	v_video.o \
	w_wad.o \
	wi_stuff.o \
	z_zone.o

OUTOBJS = $(addprefix $(INTERMEDIATE), $(OBJS))


all: c2p DoomAttack
	cp -r $(OUT)DoomAttackSupport $(BINDIR)

clean:
	rm -f *.o ;
	rm -f amigaasm/*.o ;
	rm -f $(OUT)/DoomAttack ;
	rm -f $(OUT)/DoomAttackSupport/c2p/c2p*


DoomAttack: $(OBJS) Makefile
	$(CC) $(CFLAGS) $(LDFLAGS) $(OBJS) -o $@
	$(STRIP) --strip-debug --strip-unneeded $@ -o $(BINDIR)/$@

profile:
	m68k-amigaos-gprof --brief DoomAttack $(BINDIR)/gmon.out | gprof2dot.py | dot -s -Tpdf -oDoomAttack.pdf

am_mapamiga.o: amigaasm/am_mapamiga.asm Makefile
	$(PHXASS) $(PFLAGS) amigaasm/am_mapamiga.asm -o am_mapamiga.o

m_fixedamiga.o: amigaasm/m_fixedamiga.asm Makefile
	$(PHXASS) $(PFLAGS) amigaasm/m_fixedamiga.asm -o m_fixedamiga.o

r_engine.o: amigaasm/r_engine.asm amigaasm/r_engine.i amigaasm/doom.i Makefile
	$(PHXASS) $(PFLAGS) amigaasm/r_engine.asm -o r_engine.o

analogjoy.o: amigaasm/analogjoy.asm Makefile
	$(PHXASS) $(PFLAGS) amigaasm/analogjoy.asm -o analogjoy.o

clip.o: amigaasm/clip.asm Makefile
	$(PHXASS) $(PFLAGS) amigaasm/clip.asm -o clip.o

C2PFILES = $(notdir $(basename $(wildcard amigaasm/c2p_*.s)))

c2p: $(C2PFILES) Makefile

c2p_%:  amigaasm/c2p_%.s Makefile
	$(PHXASS) $(PINCLUDES) -Fhunk -phxass -nosym -warncomm -ldots $< -o $(basename $<).o
	$(VLINK) -Bdynamic -nostdlib $(basename $<).o -o $(OUT)DoomAttackSupport/c2p/$(notdir $(basename $<))


%.o:	%.c  Makefile
	$(CC) $(CFLAGS) -c $< -o $@

%.s:	%.c  Makefile
	$(CC) $(CFLAGS) -Wa,-adhln -g -c $<  > $@

#############################################################
#
#############################################################
