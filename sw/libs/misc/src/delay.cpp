#include "delay.h"
#include "core.h"

void mdelay(const uint32_t msec)
{
#ifdef SIM
    (void)msec;
    uint32_t loop_iterations{10};
#else
    uint32_t loop_iterations{msec * 5000};
#endif
    core.execute_10_cycles_loop(loop_iterations);
}

void udelay(const uint32_t usec)
{
#ifdef SIM
    (void)usec;
    uint32_t loop_iterations{5};
#else
    uint32_t loop_iterations{usec * 5};
#endif
    core.execute_10_cycles_loop(loop_iterations);
}
