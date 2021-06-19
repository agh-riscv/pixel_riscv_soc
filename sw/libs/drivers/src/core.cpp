#include "core.h"

Core core;

uint64_t Core::get_performance_counter() const volatile
{
    union Counter {
        uint64_t value;
        struct {
            uint32_t lower_half;
            uint32_t upper_half;
        };
    };

    Counter counter;
    asm volatile ("csrr %[data], mcycle" : [data] "=r" (counter.lower_half));
    asm volatile ("csrr %[data], mcycleh" : [data] "=r" (counter.upper_half));
    return counter.value;
}

void Core::execute_10_cycles_loop(const uint32_t iterations) const
{
    int out;  /* only to notify compiler of modifications to |loops| */
    asm volatile (
        "1: nop             \n"
        "   nop             \n"
        "   nop             \n"
        "   nop             \n"
        "   nop             \n"
        "   nop             \n"
        "   addi %1, %1, -1 \n"
        "   bnez %1, 1b     \n"
        : "=&r" (out)
        : "0" (iterations)
    );
}

void Core::enable_interrupts_globally() const
{
    asm volatile ("csrrsi t0, mstatus, 1<<3");
}

void Core::enable_gpio_interrupts(void (*handler)())
{
    gpio_interrupts_handler = handler;
    asm volatile (
        "li    t0, 1<<16    \n"
        "csrrs t0, mie,  t0 \n"
    );
}

void Core::enable_timer_interrupts(void (*handler)())
{
    timer_interrupts_handler = handler;
    asm volatile (
        "li    t0, 1<<17    \n"
        "csrrs t0, mie,  t0 \n"
    );
}

extern "C" __attribute__ ((interrupt)) void gpio_irq_handler(void)
{
    core.gpio_interrupts_handler();
}

extern "C" __attribute__ ((interrupt)) void tmr_irq_handler(void)
{
    core.timer_interrupts_handler();
}
