// This start the init/exit lists. Link first into the plugins.

__attribute__((section(".list___INIT_LIST__")))
long __INIT_LIST__[] = {0};
__attribute__((section(".list___EXIT_LIST__")))
long __EXIT_LIST__[] = {0};
