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
    void enable_interrupts_globally() const;
    void enable_gpio_interrupts(void (*handler)());
    void enable_timer_interrupts(void (*handler)());

    void (*gpio_interrupts_handler)(){nullptr};
    void (*timer_interrupts_handler)(){nullptr};
};

extern Core core;
