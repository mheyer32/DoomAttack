static __inline void DANCall_Init(struct DANInitialization *daninit)
{
    register struct DANInitialization *a0 __asm("a0") = daninit;
    register void *a1 __asm("a1") = DAN->DAN_Init;

    __asm __volatile("jsr (a1)"
                     : /* no result */
                     : "r"(a0), "r"(a1)
                     : "d0", "d1", "a0", "a1", "memory");
}
