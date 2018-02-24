/* amiga.h */


#define C2PF_SIGNALFLIP 1
#define C2PF_VARIABLEHEIGHT 2
#define C2PF_GRAFFITI 4
#define C2PF_NODOUBLEBUFFER 8
#define C2PF_VARIABLEWIDTH 16

struct C2PInit
{
	struct Library *DOSBase;
	struct Library *GfxBase;
	struct Library *IntuitionBase;
	struct Task *FlipTask;
	ULONG	 FlipMask;
	struct Task *DoomTask;
	ULONG	 DoomMask;
	ULONG	 DisplayID;
};

struct c2pfile
{
	void	*NextSeg;
	WORD	moveqcode;
	WORD	rtscode;
	char	id[4];
	void	(*Chunky2Planar)(void *ChunkyBuffer,void *Planes);
	BOOL	(*InitChunky2Planar)(int Width,int Height,int PlaneSize,struct C2PInit *init);
	void	(*EndChunky2Planar)(void);
	ULONG	Flags;
	void	(*Graffiti_GetInformation)(struct Window **win,struct ScreenBuffer **sbuf1,struct ScreenBuffer **sbuf2);
	void	(*Graffiti_SetPalette)(UBYTE *palette,UBYTE *gammatable);
};

extern struct c2pfile *C2P;
extern BPTR C2PFile;
extern BOOL DoC2P;
extern BOOL DoDoubleBuffer;
extern BOOL OS31;
extern BOOL DoGraffiti;

extern struct RastPort TempRP;
