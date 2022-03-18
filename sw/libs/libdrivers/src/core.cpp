#include <core.hpp>

Core core;

uint64_t Core::get_performance_counter() const
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

void Core::execute_10_cycles_loop(uint32_t iterations) const
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

void Core::set_exceptions_handler(void (*handler)())
{
    exceptions_handler = handler;
}

void Core::enable_interrupts() const
{
    asm volatile ("csrrsi t0, mstatus, 1<<3");
}

void Core::disable_interrupts() const
{
    asm volatile ("csrrci t0, mstatus, 1<<3");
}

void Core::enable_gpio_interrupts(void (*handler)())
{
    gpio_interrupts_handler = handler;
    asm volatile (
        "li    t0, 1<<16    \n"
        "csrrs t0, mie,  t0 \n"
    );
}

void Core::disable_gpio_interrupts()
{
    gpio_interrupts_handler = nullptr;
    asm volatile (
        "li    t0, 1<<16    \n"
        "csrrc t0, mie,  t0 \n"
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

void Core::disable_timer_interrupts()
{
    timer_interrupts_handler = nullptr;
    asm volatile (
        "li    t0, 1<<17    \n"
        "csrrc t0, mie,  t0 \n"
    );
}

void Core::enable_uart_interrupts(void (*handler)())
{
    uart_interrupts_handler = handler;
    asm volatile (
        "li    t0, 1<<18    \n"
        "csrrs t0, mie,  t0 \n"
    );
}

void Core::disable_uart_interrupts()
{
    uart_interrupts_handler = nullptr;
    asm volatile (
        "li    t0, 1<<18    \n"
        "csrrc t0, mie,  t0 \n"
    );
}

void Core::enable_spi_interrupts(void (*handler)())
{
    spi_interrupts_handler = handler;
    asm volatile (
        "li    t0, 1<<19    \n"
        "csrrs t0, mie,  t0 \n"
    );
}

void Core::disable_spi_interrupts()
{
    spi_interrupts_handler = nullptr;
    asm volatile (
        "li    t0, 1<<19    \n"
        "csrrc t0, mie,  t0 \n"
    );
}

extern "C" __attribute__ ((interrupt)) void exceptions_handler(void)
{
    if (core.exceptions_handler) {
        static constexpr uint32_t full_size_instr_mask{0x3};
        uint32_t mepc, instr;

        asm volatile ("csrr %0, mepc" : "=&r" (mepc));
        instr = *((volatile uint32_t *)mepc);
        mepc += (instr & full_size_instr_mask) ? 4 : 2;
        asm volatile ("csrw mepc, %0" : : "r" (mepc));

        core.exceptions_handler();
    } else {
        while (true) { }
    }
}

extern "C" __attribute__ ((interrupt)) void gpio_irq_handler(void)
{
    core.gpio_interrupts_handler();
}

extern "C" __attribute__ ((interrupt)) void timer_irq_handler(void)
{
    core.timer_interrupts_handler();
}

extern "C" __attribute__ ((interrupt)) void uart_irq_handler(void)
{
    core.uart_interrupts_handler();
}

extern "C" __attribute__ ((interrupt)) void spi_irq_handler(void)
{
    core.spi_interrupts_handler();
}
