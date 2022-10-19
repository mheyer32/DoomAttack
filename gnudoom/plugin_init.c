// This start the init/exit lists. Link first into the plugins.
#include <stabs.h>
long __INIT_LIST__[] __attribute__((section(".list___INIT_LIST__"))) = {0};
long __EXIT_LIST__[] __attribute__((section(".list___EXIT_LIST__"))) = {0};
//ADD2LIST(0,__INIT_LIST__,22);
//ADD2LIST(0,__EXIT_LIST__,22);
