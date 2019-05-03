/*
**      $VER: compiler.h 37.12 (29.6.97)
**
**      Compiler independent register (and SAS/C extensions) handling
**
**      (C) Copyright 1997 Andreas R. Kleinert
**      All Rights Reserved.
*/

/* Basically, Amiga C compilers must reach the goal to be
   as SAS/C compatible as possible. But on the other hand,
   when porting AmigaOS to other platforms, one perhaps
   can't expect GCC becoming fully SAS/C compatible...

   There are two ways to make your sources portable:

    - using non ANSI SAS/C statements and making these
      "available" to the other compilers (re- or undefining)
    - using replacements for SAS/C statements and smartly
      redefining these for any compiler

   The last mentioned is the most elegant, but may require to
   rewrite your source codes, so this compiler include file
   basically does offer both.

   For some compilers, this may have been done fromout project or
   makefiles for the first method (e.g. StormC) to ensure compileablity.

   Basically, you should include this header file BEFORE any other stuff.
*/

/* ********************************************************************* */
/* Method 1: redefining SAS/C keywords                                   */
/*                                                                       */
/* Sorry, this method does not work with register definitions for the current
gcc version (V2.7.2.1), as it expects register attributes after the parameter
description. (This is announced to be fixed with gcc V2.8.0).
Moreover the __asm keyword has another meaning with GCC.
Therefore ASM must be used. */

#ifdef __MAXON__  // ignore this switches of SAS/Storm
#define __aligned
#define __asm
#define __regargs
#define __saveds
#define __stdargs
#endif

#ifdef __GNUC__  // ignore this switches of SAS/Storm
#define __d0
#define __d1
#define __d2
#define __d3
#define __d4
#define __d5
#define __d6
#define __d7
#define __a0
#define __a1
#define __a2
#define __a3
#define __a4
#define __a5
#define __a6
#define __a7
#endif

/* for SAS/C we don't need this, for StormC this is done in the
   makefile or projectfile */

/*                                                                       */
/* ********************************************************************* */

/* ********************************************************************* */
/* Method 2: defining our own keywords                                   */
/*                                                                       */
#ifdef __SASC

#define REG(r) register __##r
#define GNUCREG(r)
#define SAVEDS __saveds
#define ASM __asm
#define REGARGS __regargs
#define STDARGS __stdargs
#define ALIGNED __aligned

#else
#ifdef __MAXON__

#ifdef REG
#undef REG
#endif

#define REG(r) register __##r
#define GNUCREG(r)
#define SAVEDS
#define ASM
#define REGARGS
#define STDARGS
#define ALIGNED

#else
#ifdef __STORM__

#define REG(r) register __##r
#define GNUCREG(r)
#define SAVEDS __saveds
#define ASM
#define REGARGS
#define STDARGS
#define ALIGNED

#else
#ifdef __GNUC__

#define REG(r)
#define GNUCREG(r) __asm(#r)
#define SAVEDS __saveds
#define ASM
#define REGARGS __regargs
#define STDARGS __stdargs
#define ALIGNED __aligned

#else /* any other compiler, to be added here */

#define REG(r)
#define GNUCREG(r)
#define SAVEDS
#define ASM
#define REGARGS
#define STDARGS
#define ALIGNED

#endif /* __GNUC__ */
#endif /* __STORM__ */
#endif /* __MAXON__ */
#endif /* __SASC */
/*                                                                       */
/* ********************************************************************* */
