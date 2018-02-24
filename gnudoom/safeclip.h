static __inline void
SafeSetLimits (long x1, long y1, long x2, long y2)
{
  extern long CLP_xmin, CLP_ymin, CLP_xmax, CLP_ymax;
  CLP_xmin = x1;
  CLP_ymin = y1;
  CLP_xmax = x2;
  CLP_ymax = y2;
}

/* coords muß Platz für zusätzliche 4 LONGWORDS haben, also insgesamt 6 x 4 = 24 bytes!! */

static __inline long
ClipLine (long *coords)
{
  register long _res __asm("d0");

  __asm ("jsr _lineclip"
	 : "=r" (_res)
	 : "a0" (coords)
	 : "d0");
  return _res;
}

