// This closes the init/exit lists. Link last into the plugins.
#include <stabs.h>
long _term0__INIT_LIST[] __attribute__((section(".list___INIT_LIST__"))) = {0};
long _term0__EXIT_LIST[] __attribute__((section(".list___EXIT_LIST__"))) = {0};

//#define ENDLIST(a) \
//    asm(".globl __term0" #a); \
//    asm(".section\t.list_" #a ",\"aw\""); \
//    asm("__term0_" #a ":\t.long 0"); \
//    asm(".text");

//#define ENDLIST(a) \
//    asm(".section\t.list_" #a ",\"aw\""); \
//    asm("\t.long 0"); \
//    asm(".text");


//ENDLIST(__INIT_LIST__)
//ENDLIST(__EXIT_LIST__)
