// This closes the init/exit lists. Link last into the plugins.

__attribute__((section(".list___INIT_LIST__")))
long __INIT_LIST_END[] = {0};
__attribute__((section(".list___EXIT_LIST__")))
long __EXIT_LIST_END[] = {0};
