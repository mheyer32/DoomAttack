static __inline void DAMCall_Init(struct DAMInitialization *daminit)
{
    register struct DAMInitialization *a0 __asm("a0") = daminit;
    register void *a1 __asm("a1") = DAM->DAM_Init;

    __asm __volatile("jsr (a1)"
                     : /* no result */
                     : "r"(a0), "r"(a1)
                     : "d0", "d1", "a0", "a1", "memory");
}

static __inline void DAMCall_SetMusicVolume(int volume)
{
    register int d0 __asm("d0") = volume;
    register void *a1 __asm("a1") = DAM->DAM_SetMusicVolume;

    __asm __volatile("jsr (a1)"
                     : /* no result */
                     : "r"(d0), "r"(a1)
                     : "d0", "d1", "a0", "a1", "memory");
}

static __inline void DAMCall_PauseSong(int handle)
{
    register int d0 __asm("d0") = handle;
    register void *a1 __asm("a1") = DAM->DAM_PauseSong;

    __asm __volatile("jsr (a1)"
                     : /* no result */
                     : "r"(d0), "r"(a1)
                     : "d0", "d1", "a0", "a1", "memory");
}

static __inline void DAMCall_ResumeSong(int handle)
{
    register int d0 __asm("d0") = handle;
    register void *a1 __asm("a1") = DAM->DAM_ResumeSong;

    __asm __volatile("jsr (a1)"
                     : /* no result */
                     : "r"(d0), "r"(a1)
                     : "d0", "d1", "a0", "a1", "memory");
}

static __inline void DAMCall_StopSong(int handle)
{
    register int d0 __asm("d0") = handle;
    register void *a1 __asm("a1") = DAM->DAM_StopSong;

    __asm __volatile("jsr (a1)"
                     : /* no result */
                     : "r"(d0), "r"(a1)
                     : "d0", "d1", "a0", "a1", "memory");
}

static __inline int DAMCall_RegisterSong(void *data, int songnum)
{
    register int _res __asm("d0");

    register void *a0 __asm("a0") = data;
    register int d0 __asm("d0") = songnum;

    register void *a1 __asm("a1") = DAM->DAM_RegisterSong;

    __asm __volatile("jsr (a1)" : "=r"(_res) : "r"(a0), "r"(d0), "r"(a1) : "d1", "a0", "a1", "memory");

    return _res;
}

static __inline void DAMCall_PlaySong(int handle, int looping)
{
    register int d0 __asm("d0") = handle;
    register int d1 __asm("d1") = looping;

    register void *a1 __asm("a1") = DAM->DAM_PlaySong;

    __asm __volatile("jsr (a1)"
                     : /* no result */
                     : "r"(d0), "r"(d1), "r"(a1)
                     : "d0", "d1", "a0", "a1", "memory");
}

static __inline void DAMCall_UnRegisterSong(int handle)
{
    register int d0 __asm("d0") = handle;
    register void *a1 __asm("a1") = DAM->DAM_UnRegisterSong;

    __asm __volatile("jsr (a1)"
                     : /* no result */
                     : "r"(d0), "r"(a1)
                     : "d0", "d1", "a0", "a1", "memory");
}

static __inline int DAMCall_QrySongPlaying(int handle)
{
    register int _res __asm("d0");

    register int d0 __asm("d0") = handle;
    register void *a1 __asm("a1") = DAM->DAM_QrySongPlaying;

    __asm __volatile("jsr (a1)" : "=r"(_res) : "r"(d0), "r"(a1) : "d1", "a0", "a1", "memory");

    return _res;
}

static __inline void DASCall_SetVol(int vol)
{
    register int d0 __asm("d0") = vol;

    register void *a1 __asm("a1") = DAM->DAS_SetVol;

    __asm __volatile("jsr (a1)"
                     : /* no result */
                     : "r"(d0), "r"(a1)
                     : "d0", "d1", "a0", "a1", "memory");
}

static __inline int DASCall_Start(APTR wave, int cnum, int pitch, int vol, int sep, int length)
{
    register int _res __asm("d0");

    register APTR a0 __asm("a0") = wave;
    register int d0 __asm("d0") = cnum;
    register int d1 __asm("d1") = pitch;
    register int d2 __asm("d2") = vol;
    register int d3 __asm("d3") = sep;
    register int d4 __asm("d4") = length;

    register void *a1 __asm("a1") = DAM->DAS_Start;

    __asm __volatile("jsr (a1)"
                     : "=r"(_res)
                     : "r"(a0), "r"(a1), "r"(d0), "r"(d1), "r"(d2), "r"(d3), "r"(d4)
                     : "d1", "a0", "a1", "memory");

    return _res;
}

static __inline void DASCall_Update(APTR wave, int cnum, int pitch, int vol, int sep)
{
    register APTR a0 __asm("a0") = wave;
    register int d0 __asm("d0") = cnum;
    register int d1 __asm("d1") = pitch;
    register int d2 __asm("d2") = vol;
    register int d3 __asm("d3") = sep;

    register void *a1 __asm("a1") = DAM->DAS_Update;

    __asm __volatile("jsr (a1)"
                     : /* no result */
                     : "r"(a0), "r"(a1), "r"(d0), "r"(d1), "r"(d2), "r"(d3)
                     : "d0", "d1", "a0", "a1", "memory");
}

static __inline void DASCall_Stop(int cnum)
{
    register int d0 __asm("d0") = cnum;

    register void *a1 __asm("a1") = DAM->DAS_Stop;

    __asm __volatile("jsr (a1)"
                     : /* no result */
                     : "r"(a1), "r"(d0)
                     : "d0", "d1", "a0", "a1", "memory");
}

static __inline int DASCall_Done(int cnum)
{
    register int _res __asm("d0");

    register int d0 __asm("d0") = cnum;

    register void *a1 __asm("a1") = DAM->DAS_Done;

    __asm __volatile("jsr (a1)" : "=r"(_res) : "r"(a1), "r"(d0) : "d1", "a0", "a1", "memory");

    return _res;
}
