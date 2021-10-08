#include "gpio.h"

static constexpr uint32_t gpio_base_address{0x0100'0000};
static constexpr uint8_t cr_offset{0x00};
static constexpr uint8_t sr_offset{0x04};
static constexpr uint8_t odr_offset{0x08};
static constexpr uint8_t idr_offset{0x0C};
static constexpr uint8_t ier_offset{0x10};
static constexpr uint8_t isr_offset{0x14};
static constexpr uint8_t rier_offset{0x18};
static constexpr uint8_t fier_offset{0x1C};
static constexpr uint8_t oenr_offset{0x20};

static constexpr uint8_t codeload_skipping_pin{17};
static constexpr uint8_t codeload_source_pin{16};
static constexpr uint8_t bootloader_finished_pin{15};

Gpio gpio{gpio_base_address};

Gpio::Gpio(const uint32_t base_address)
    :   cr{reinterpret_cast<volatile uint32_t *>(base_address + cr_offset)},
        sr{reinterpret_cast<volatile uint32_t *>(base_address + sr_offset)},
        odr{reinterpret_cast<volatile uint32_t *>(base_address + odr_offset)},
        idr{reinterpret_cast<volatile uint32_t *>(base_address + idr_offset)},
        ier{reinterpret_cast<volatile uint32_t *>(base_address + ier_offset)},
        isr{reinterpret_cast<volatile uint32_t *>(base_address + isr_offset)},
        rier{reinterpret_cast<volatile uint32_t *>(base_address + rier_offset)},
        fier{reinterpret_cast<volatile uint32_t *>(base_address + fier_offset)},
        oenr{reinterpret_cast<volatile uint32_t *>(base_address + oenr_offset)}
{ }

void Gpio::set_pin_direction(const uint8_t pin, const Direction direction) const volatile
{
    uint32_t reg = *oenr;
    reg &= ~(1<<pin);
    reg |= (static_cast<uint32_t>(direction) & 0x01)<<pin;
    *oenr = reg;
}

Gpio::Direction Gpio::get_pin_direction(const uint8_t pin) const volatile
{
    return (*oenr & 1<<pin) ? Direction::in : Direction::out;
}

void Gpio::set_pin(const uint8_t pin, const bool value) const volatile
{
    set_mask_bits(1<<pin, value<<pin);
}

bool Gpio::get_pin(const uint8_t pin) const volatile
{
    return *idr & 1<<pin;
}

void Gpio::toggle_pin(const uint8_t pin) const volatile
{
    set_pin(pin, !get_pin(pin));
}

void Gpio::set_mask_bits(const uint32_t mask, const uint32_t bits) const volatile
{
    uint32_t reg = *odr;
    reg &= ~mask;
    reg |= bits & mask;
    *odr = reg;
}

bool Gpio::get_codeload_skipping_pin() const volatile
{
    return get_pin(codeload_skipping_pin);
}

bool Gpio::get_codeload_source_pin() const volatile
{
    return get_pin(codeload_source_pin);
}

void Gpio::set_bootloader_finished_pin(const bool value) const volatile
{
    set_pin_direction(bootloader_finished_pin, Direction::out);
    set_pin(bootloader_finished_pin, value);
}
