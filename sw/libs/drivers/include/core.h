#pragma once

#include <cstdint>

class Core final {
public:
    Core() = default;
    Core(const Core &) = delete;
    Core(Core &&) = delete;
    Core &operator=(const Core &) = delete;
    Core &operator=(Core &&) = delete;

    uint64_t get_performance_counter() const volatile;
    void execute_10_cycles_loop(const uint32_t iterations) const;

    void set_exceptions_handler(void (*handler)());

    void enable_interrupts() const;
    void disable_interrupts() const;
    void enable_gpio_interrupts(void (*handler)());
    void disable_gpio_interrupts();
    void enable_timer_interrupts(void (*handler)());
    void disable_timer_interrupts();

    void (*exceptions_handler)(){nullptr};
    void (*gpio_interrupts_handler)(){nullptr};
    void (*timer_interrupts_handler)(){nullptr};
};

extern Core core;
