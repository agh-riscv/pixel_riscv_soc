#include <delay.hpp>
#include <libdrivers/core.hpp>

void mdelay(uint32_t msec)
{
#if defined(ASIC) || defined(SIM)
    (void)msec;
    uint32_t loop_iterations{10};
#else
    uint32_t loop_iterations{msec * 5000};
#endif
    core.execute_10_cycles_loop(loop_iterations);
}

void udelay(uint32_t usec)
{
#if defined(ASIC) || defined(SIM)
    (void)usec;
    uint32_t loop_iterations{5};
#else
    uint32_t loop_iterations{usec * 5};
#endif
    core.execute_10_cycles_loop(loop_iterations);
}
