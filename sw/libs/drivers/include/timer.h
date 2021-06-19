#pragma once

#include "timer_cr.h"
#include "timer_sr.h"

class Timer final {
public:
    Timer(const uint32_t base_address);
    Timer(const Timer &) = delete;
    Timer(Timer &&) = delete;
    Timer &operator=(const Timer &) = delete;
    Timer &operator=(Timer &&) = delete;

    void set_cmpr(const uint32_t cmpr) const volatile { *this->cmpr = cmpr; };

    void trigger() const volatile;
    void clear_matched() const volatile;

private:
    volatile Timer_cr * const cr;
    volatile Timer_sr * const sr;
    volatile uint32_t * const cntr;
    volatile uint32_t * const cmpr;
};

extern Timer timer;
