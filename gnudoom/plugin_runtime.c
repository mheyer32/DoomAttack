
#include "plugins/Include/OSIncludes.h"

#include <debuglib.h>

#include <limits.h>

struct InitListItem
{
    void (*func)(void);
    long priority;
};

extern const long __INIT_LIST__[];
extern const long __EXIT_LIST__[];

struct ExecBase *SysBase;
struct WBStartup *_WBenchMsg;

// Walk the __INIT_LIST__ or __EXIT_LIST__ in ascending(0) or descending(-1) order
static void callFuncs(const struct InitListItem *list, long order)
{
    long lastPrio = INT_MIN;
    while (1) {
        long nextPrio = INT_MAX;
        {
            const struct InitListItem *item = list;
            while (item->func) {
                long itemPrio = item->priority ^ order;
                if (itemPrio == lastPrio) {
                    // While searching the next priority, call all the functions
                    // with the  priority identified in the prior pass
                    item->func();
                } else {
                    if (itemPrio < nextPrio && itemPrio > lastPrio) {
                        nextPrio = itemPrio;
                    }
                }
                item++;
            }
        }
        if (nextPrio == INT_MAX) {
            // didn't identify any entry beyond the current priority
            break;
        }
        lastPrio = nextPrio;
    }
}

void InitRuntime()
{
    SysBase = *(struct ExecBase **)4;

    // First element it __INIT_LIST is the number of LONGs in there,
    // the actual list items start behind that
    const struct InitListItem *initList = (const struct InitListItem *)(__INIT_LIST__ + 1);
    callFuncs(initList, 0);
}

void CleanupRuntime()
{
    int lastPrio = INT_MIN;

    // First element it __EXIT_LIST__ is the number of LONGs in there,
    // the actual list items start behind that
    const struct InitListItem *exitList = (const struct InitListItem *)(__EXIT_LIST__ + 1);
    callFuncs(exitList, -1);
}

__stdargs void exit(int status)
{
    CleanupRuntime();

    // FIXME: need to use proper exit here, likely calling back into Doom's Quit routine
    while (1) {
    }
}

void __nocommandline(void){};
