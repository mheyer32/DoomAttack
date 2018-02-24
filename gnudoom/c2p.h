
#define C2PF_SIGNALFLIP 1

struct C2PInit
{
	struct Library *DOSBase;
	struct Library *GfxBase;
	struct Library *IntuitionBase;
	struct Task *FlipTask;
	ULONG FlipMask;
};
