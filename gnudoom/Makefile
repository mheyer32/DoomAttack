#disable built-in rules
.SUFFIXES:
# don't delete intermeditae .o and build directories
.PRECIOUS: %.o %/.
#enable second expansion, so we can use $(@D) as dependency
.SECONDEXPANSION:

#provide these as env variables at commandline
# i.e.  DEBUG=1 make all -j8
DEBUG ?= 0
BINDIR ?= bin
USENOIXEMUL ?= 1
VERSION060 ?= 0
PROFILE ?= 0

CC = m68k-amigaos-gcc
STRIP = m68k-amigaos-strip
ASS = vasmm68k_mot
VLINK = vlink
MKDIR = mkdir -p

PREFIX := $(shell ./getprefix.sh "$(CC)")

define source_to_object
	$(addprefix ${2},$(patsubst %.c,%.o,\
							$(patsubst %.s,%.o,\
							$(patsubst %.asm,%.o,${1}))))
endef

define create_objlist
	$(filter %tartup.o,$(call source_to_object,${1},${2}))\
	$(filter-out %tartup.o,$(call source_to_object,${1},${2}))
endef

define collect_sources
	$(strip $(filter %.c %.s %.asm,$(shell find ${1} -name \*)))
endef

define build_rules

#create build directory if needed
%/.:
	$$(MKDIR) $$(@D)

# build .c .asm and .s files into .o
# $$$$(@D)/. will be doubly-evaluated to $(@D)/. which will trigger the build directory
# target above
${1}%.o: %.c | Makefile $$$$(@D)/.
	echo $$(@D)
	$$(CC) $$(CFLAGS) -c $$< -o $$@

${1}%.o: %.asm | Makefile $$$$(@D)/.
	$$(ASS) $$(AFLAGS) $$< -o $$@

${1}%.o: %.s | Makefile $$$$(@D)/.
	$$(ASS) $$(AFLAGS) $$< -o $$@

endef

%.o.stripped: %.o
	$(STRIP) --remove-section=.stab* --strip-debug --strip-unneeded -o $@ $<


CLIB_CFLAGS = -mcrt=clib2
CLIB_LDFLAGS = -mcrt=clib2

NOIXEMUL_CFLAGS = -noixemul
NOIXEMUL_LDFLAGS = -noixemul

ifeq ($(USENOIXEMUL), 1)
	RUNTIME_CFLAGS = $(NOIXEMUL_CFLAGS)
	RUNTIME_LDFLAGS = $(NOIXEMUL_LDFLAGS)
else
	RUNTIME_CFLAGS = $(CLIB_CFLAGS)
	RUNTIME_LDFLAGS = $(CLIB_LDFLAGS)
endif

CFLAGS = $(RUNTIME_CFLAGS)
LDFLAGS = $(RUNTIME_LDFLAGS) -g -ggdb -msmall-code


CFLAGS += -msmall-code -g -ggdb
CFLAGS += -Werror -Wimplicit -Wstrict-prototypes
CFLAGS += -D__BIG_ENDIAN__ -DNORMALUNIX -DAMIGA -D__NO_NET_API
CFLAGS += -include "doomdef.h"
CFLAGS += -I./plugins/Include
CFLAGS += -I./

ifeq ($(DEBUG),1)
	#-DRANGECHECK
	CFLAGS += -DDEBUG -DDEBUG_LIB=1 -Og -fno-omit-frame-pointer
	LDFLAGS += -ldebug
else
	CFLAGS += -DNDEBUG -Ofast -ffast-math
	ifeq ($(PROFILE), 0)
		CFLAGS += -fomit-frame-pointer
	endif
endif

ifeq ($(PROFILE), 1)
	CFLAGS += -pg
	LDFLAGS += -pg
endif

AINCLUDES = -I./plugins/Include -I$(PREFIX)m68k-amigaos/ndk-include
ALIBS = -L$(PREFIX)m68k-amigaos/lib

AFLAGS = -Fhunk -phxass -warncomm -nosym -ldots -spaces $(AINCLUDES)

BUILDDIR ?=$(CURDIR)/build/

SOURCES = \
	am_map.c \
	amigaasm/am_mapamiga.asm \
	amigaasm/analogjoy.asm \
	amigaasm/clip.asm \
	d_items.c \
	d_locale.c \
	d_main.c \
	d_net.c \
	doomdef.c \
	doomstat.c \
	dstrings.c \
	f_finale.c \
	f_wipe.c \
	g_game.c \
	hu_lib.c \
	hu_stuff.c \
	i_main.c \
	i_net.c \
	i_sound.c \
	i_system.c \
	i_systemmisc.c \
	i_video.c \
	info.c \
	m_argv.c \
	m_bbox.c \
	m_cheat.c \
	m_fixed.c \
	amigaasm/m_fixedamiga.asm \
	m_menu.c \
	m_misc.c \
	m_random.c \
	m_swap.c \
	p_ceilng.c \
	p_doors.c \
	p_enemy.c \
	p_floor.c \
	p_inter.c \
	p_lights.c \
	p_map.c \
	p_maputl.c \
	p_mobj.c \
	p_plats.c \
	p_pspr.c \
	p_saveg.c \
	p_setup.c \
	p_sight.c \
	p_spec.c \
	p_switch.c \
	p_telept.c \
	p_tick.c \
	p_user.c \
	r_bsp.c \
	r_data.c \
	r_draw.c \
	amigaasm/r_engine.asm \
	r_main.c \
	r_plane.c \
	r_segs.c \
	r_sky.c \
	r_things.c \
	s_sound.c \
	sounds.c \
	st_lib.c \
	st_stuff.c \
	tables.c \
	v_video.c \
	w_wad.c \
	wi_stuff.c \
	z_zone.c


all: DoomAttack DoomAttack060 Plugins

clean:
	rm -rf $(BUILDDIR)

define make_exe
${1}_SRC = $$(call collect_sources,$$(SOURCES))
${1}_OBJS = $$(call create_objlist,$$(${1}_SRC),${2})
${1}_TARGET = $$(BINDIR)/${1}

$$(eval $$(call build_rules,${2}))

${1} : $$(BUILDDIR)=${2}
${1} : $$(${1}_OBJS)
	$$(MKDIR) $$(dir $$(${1}_TARGET))
	$$(CC) $$^ $$(LDFLAGS) -o $$(<D)/${1}
	$$(STRIP) $$(<D)/${1} -o $$(${1}_TARGET)
endef

DoomAttack060: CFLAGS+=-m68060 -Dversion060
DoomAttack060: LDFLAGS+=-m68060 -Dversion060
DoomAttack060: AFLAGS+=-m68060 -Dversion060
$(eval $(call make_exe,DoomAttack060,$(BUILDDIR)/060/))

DoomAttack: CFLAGS+=-m68030
DoomAttack: LDFLAGS+=-m68030
DoomAttack: AFLAGS+=-m68020up
$(eval $(call make_exe,DoomAttack,$(BUILDDIR)/030/))

profile:
	m68k-amigaos-gprof --brief $(BUILDDIR))/DoomAttack $(BINDIR)/gmon.out | gprof2dot.py | dot -s -Tpdf -oDoomAttack.pdf

define make_plugin
$$(eval $$(call build_rules,$$(BUILDDIR)))
${1}_DIR = ${2}
${1}_SRC = $$(call collect_sources,$$(${1}_DIR)) plugin_runtime.c
${1}_OBJS = $$(call create_objlist,$$(${1}_SRC), $$(BUILDDIR))
${1}_OBJS_STRIPPED = $$(patsubst %,%.stripped,$$(${1}_OBJS))
${1}_TARGET = $$(BINDIR)/${3}

${1} : CFLAGS+=-D__ASM_ROUTINES__
${1} : $$(${1}_OBJS)
	$$(MKDIR) $$(dir $$(${1}_TARGET))
	$$(CC) $$^ $$(LDFLAGS) -nostartfiles -lstubs -o $$(<D)/${1}
	$$(STRIP)  $$(<D)/${1} -o $$(${1}_TARGET)
endef

#Chunky-To-Planar Plugins
$(eval $(call make_plugin,c2p_Graffiti,plugins/Chunky2Planar/Graffiti/,DoomAttackSupport/c2p/c2p_graffiti))
$(eval $(call make_plugin,c2p_020_Blitter, plugins/Chunky2Planar/020_Blitter/,DoomAttackSupport/c2p/c2p_020_blitter))
$(eval $(call make_plugin,c2p_020_Optimized, plugins/Chunky2Planar/020_Optimized/,DoomAttackSupport/c2p/c2p_020_optimized))
$(eval $(call make_plugin,c2p_040, plugins/Chunky2Planar/040/,DoomAttackSupport/c2p/c2p_040))
$(eval $(call make_plugin,c2p_040+, plugins/Chunky2Planar/040+/,DoomAttackSupport/c2p/c2p_040+))
$(eval $(call make_plugin,c2p_akiko, plugins/Chunky2Planar/akiko/,DoomAttackSupport/c2p/c2p_akiko))
$(eval $(call make_plugin,c2p_akiko2, plugins/Chunky2Planar/akiko2/,DoomAttackSupport/c2p/c2p_akiko2))

# Music and Sound Plugins
$(eval $(call make_plugin,music_debug, plugins/Sound_and_Music/Debug/,DoomAttackSupport/plugin/DAMusic_Debug.plugin))
$(eval $(call make_plugin,music_doomsound, plugins/Sound_and_Music/DoomSound_Library/,DoomAttackSupport/plugin/DAMusic_DoomSndLibrary.plugin))
$(eval $(call make_plugin,music_p61a, plugins/Sound_and_Music/P61A/,DoomAttackSupport/plugin/DAMusic_P61A.plugin))
$(eval $(call make_plugin,music_midi, plugins/Sound_and_Music/Midi/,DoomAttackSupport/plugin/DAMusic_Midi.plugin))

#Network
$(eval $(call make_plugin,net_tcp, plugins/Network/TCP/,DoomAttackSupport/plugin/DANet_TCP.plugin))
$(eval $(call make_plugin,net_local, plugins/Network/Local/,DoomAttackSupport/plugin/DANet_Local.plugin))
$(eval $(call make_plugin,net_ipx, plugins/Network/IPX/,DoomAttackSupport/plugin/DANet_IPX.plugin))
$(eval $(call make_plugin,net_nullmodem, plugins/Network/Nullmodem_+_Modem/,DoomAttackSupport/plugin/DANet_NullModem.plugin))

#DEHacked
$(eval $(call make_plugin,dehacked, plugins/DeHacked/,DoomAttackSupport/plugin/DeHackEd))

Plugins: BUILDDIR=$(CURDIR)/build/
Plugins: CFLAGS+=-m68030
Plugins: LDFLAGS+=-m68030
Plugins: AFLAGS+=-m68020up
Plugins : c2p_Graffiti \
		  c2p_020_Blitter \
		  c2p_020_Optimized \
		  c2p_040 \
		  c2p_040 \
		  c2p_akiko \
		  c2p_akiko2 \
		  music_p61a \
		  music_doomsound \
		  music_midi \
		  music_debug \
		  net_tcp \
		  net_local \
		  net_nullmodem \
		  dehacked
#############################################################
#
#############################################################

