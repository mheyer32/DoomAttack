extern void DAN_Init(REGA0(struct DANInitialization *daninit));
extern int DAN_InitNetwork(void);
extern void DAN_NetCmd(void);
extern void DAN_CleanupNetwork(void);

extern WORD SwapWORD(REGD0(WORD val));
extern LONG SwapLONG(REGD0(LONG val));
