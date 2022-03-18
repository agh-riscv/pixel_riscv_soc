#pragma once

#include <cstdint>

class Timer final {
public:
    Timer(uint32_t base_address);
    Timer(const Timer &) = delete;
    Timer(Timer &&) = delete;
    Timer &operator=(const Timer &) = delete;
    Timer &operator=(Timer &&) = delete;

    void set_cmpr(uint32_t val) const;
    void enable() const;
    void disable() const;
    void clear_matched() const;

    void enable_interrupts() const;
    void disable_interrupts() const;
    bool is_interrupt_pending() const;
    void clear_interrupt() const;

private:
    volatile uint32_t * const regs;
};

extern Timer timer;
