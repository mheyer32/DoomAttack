
#include "plugins/Include/OSIncludes.h"

//#define DEBUG_LIB 1
//#include <debuglib.h>

#include <limits.h>

struct InitListItem
{
    void (*func)(void);
    int priority;
};

extern const long __INIT_LIST__[];
extern const long __EXIT_LIST__[];

extern struct ExecBase *SysBase;  // referring to LibNix's SysBase

struct WBStartup *_WBenchMsg = NULL;

void InitRuntime()
{
    SysBase = *(struct ExecBase **)4;

    int lastPrio = INT_MIN;

    // First element it __INIT_LIST is the number of LONGs in there,
    // the actual list items start behind that
    const struct InitListItem *initList = (const struct InitListItem *)(__INIT_LIST__ + 1);

    while (1) {
        int nextPrio = INT_MAX;
        {
            const struct InitListItem *initItem = initList;
            while (initItem->func) {
                if (initItem->priority < nextPrio && initItem->priority > lastPrio) {
                    nextPrio = initItem->priority;
                }
                initItem++;
            }
        }
        if (nextPrio == INT_MAX) {
            break;
        }
        {
            const struct InitListItem *initItem = initList;
            while (initItem->func) {
                if (initItem->priority == nextPrio) {
                    initItem->func();
                }
                initItem++;
            }
        }
        lastPrio = nextPrio;
    }
}

void CleanupRuntime()
{
    int lastPrio = INT_MIN;

    // First element it __EXIT_LIST__ is the number of LONGs in there,
    // the actual list items start behind that
    const struct InitListItem *exitList = (const struct InitListItem *)(__EXIT_LIST__ + 1);

    while (1) {
        int nextPrio = INT_MIN;
        {
            const struct InitListItem *exitItem = exitList;
            while (exitItem->func) {
                if (exitItem->priority > nextPrio && exitItem->priority < lastPrio) {
                    nextPrio = exitItem->priority;
                }
                exitItem++;
            }
        }
        if (nextPrio == INT_MIN) {
            break;
        }
        {
            const struct InitListItem *initItem = exitList;
            while (initItem->func) {
                if (initItem->priority == nextPrio) {
                    initItem->func();
                }
                initItem++;
            }
        }
        lastPrio = nextPrio;
    }
}

__stdargs void exit(int status)
{
    //    Exit(status);
    while (1)
        ;
}

void __nocommandline(void){};
