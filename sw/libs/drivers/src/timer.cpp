#include "timer.h"

static constexpr uint32_t timer_base_address{0x0100'3000};
static constexpr uint8_t cr_offset{0x00};
static constexpr uint8_t sr_offset{0x04};
static constexpr uint8_t cntr_offset{0x08};
static constexpr uint8_t cmpr_offset{0x0C};

Timer timer{timer_base_address};

Timer::Timer(const uint32_t base_address)
    :   cr{reinterpret_cast<volatile Timer_cr *>(base_address + cr_offset)},
        sr{reinterpret_cast<volatile Timer_sr *>(base_address + sr_offset)},
        cntr{reinterpret_cast<volatile uint32_t *>(base_address + cntr_offset)},
        cmpr{reinterpret_cast<volatile uint32_t *>(base_address + cmpr_offset)}
{ }

void Timer::enable() const volatile
{
    cr->trg = true;
}

void Timer::disable() const volatile
{
    cr->trg = false;
}

void Timer::clear_matched() const volatile
{
    sr->mtch = false;
}
