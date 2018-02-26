#ifndef _AMIGA_MACROS_H
#define _AMIGA_MACROS_H

/*
 *  amiga_macros.h - small macros for compiler specific stuff
 *  This file is public domain.
 */

#include <exec/types.h>

/*
 * macros for function definitions and declarations
 */

#ifdef __GNUC__
#define REG(xn, parm) parm __asm(#xn)
#define REGARGS __regargs
#define STDARGS __stdargs
#define SAVEDS __saveds
#define ALIGNED __attribute__ ((aligned(4))
#define FAR __far
#define CHIP __chip
#define INTERRUPT __interrupt
#define INLINE __inline__
#define NOINLINE __attribute__((noinline))
#else /* of __GNUC__ */

#ifdef __SASC
#define REG(xn, parm) register __##xn parm
#define REGARGS __asm
#define SAVEDS __saveds
#define ALIGNED __aligned
#define STDARGS __stdargs
#define FAR __far
#define CHIP __chip
#define INLINE __inline
#else /* of __SASC */

#ifdef _DCC
#define REG(xn, parm) __##xn parm
#define REGARGS
#define SAVEDS __geta4
#define FAR __far
#define CHIP __chip
#define INLINE
#endif /* _DCC */

#endif /* __SASC */

#endif /* __GNUC__ */

#define REGD0(x) REG(d0, x)
#define REGD1(x) REG(d1, x)
#define REGD2(x) REG(d2, x)
#define REGD3(x) REG(d3, x)
#define REGD4(x) REG(d4, x)
#define REGD5(x) REG(d5, x)
#define REGD6(x) REG(d6, x)
#define REGD7(x) REG(d7, x)

#define REGA0(x) REG(a0, x)
#define REGA1(x) REG(a1, x)
#define REGA2(x) REG(a2, x)
#define REGA3(x) REG(a3, x)
#define REGA4(x) REG(a4, x)
#define REGA5(x) REG(a5, x)
#define REGA6(x) REG(a6, x)

// static inline void myMemCpy(void * restrict dst, const void * restrict src, size_t size)
//{
////    UBYTE align = (UBYTE)(ULONG)src | (UBYTE)(ULONG)dst | (UBYTE)size;
////    if (!(align & 3)) {
//    if (!((ULONG)src & 3) &&  !((ULONG)dst & 3) && !(size & 3)) {
//        size /= 4;
//        const ULONG *srcLng = (const ULONG *)src;
//        ULONG *dstLng = (ULONG *)dst;
//        while (size--) {
//            *dstLng++ = *srcLng++;
//        }
////    } else if (!(align & 1)) {
//    } else if (!((ULONG)src & 1) &&  !((ULONG)dst & 1) && !(size & 1)) {

//        const UWORD *srcWrd = (const UWORD *)src;
//        UWORD *dstWrd = (UWORD *)dst;
//        size /= 2;
//        while (size--) {
//            *dstWrd++ = *srcWrd++;
//        }
//    } else {
//        const UBYTE *srcByte = (const UBYTE *)src;
//        UBYTE *dstByte = (UBYTE*)dst;
//        while (size--) {
//            *dstByte++ = *srcByte++;
//        }
//    }
//}

// static inline void myMemSet(void * restrict dst, UBYTE value, size_t size)
//{
//    if (!((ULONG)dst & 3) && !(size & 3)) {
//        size /= 4;
//        ULONG *dstLng = (ULONG *)dst;
//        ULONG valLng = value | value << 8 | value << 16 | value <<24;
//        while (size--) {
//            *dstLng++ = valLng;
//        }
//    } else if (!((ULONG)dst & 1) && !(size & 1)) {
//        UWORD *dstWrd = (UWORD *)dst;
//        UWORD valWrd = value | value << 8;
//        size /= 2;
//        while (size--) {
//            *dstWrd++ = valWrd;
//        }
//    } else {
//        UBYTE *dstByte = (UBYTE*)dst;
//        while (size--) {
//            *dstByte++ = value;
//        }
//    }
//}

//#define memcpy(dst, src, size) myMemCpy(dst, src, size)
//#define memset(dst, val, size) myMemSet(dst, val, size)

//#define memcpy(dst, src, size) __builtin_memcpy(dst, src, size)
//#define memset(dst, val, size) __builtin_memset(dst, val, size)

#endif /* _AMIGA_MACROS_H */
