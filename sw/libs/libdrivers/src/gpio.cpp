#include <gpio.hpp>
#include <common.hpp>
#include <iomux.hpp>
#include <memory_map.hpp>

static constexpr uint32_t odr_offset{0x000};
static constexpr uint32_t idr_offset{0x004};
static constexpr uint32_t rier_offset{0x008};
static constexpr uint32_t risr_offset{0x00c};
static constexpr uint32_t fier_offset{0x010};
static constexpr uint32_t fisr_offset{0x014};

Gpio gpio{gpio_base_address};

Gpio::Gpio(uint32_t base_address)
    :   regs{reinterpret_cast<volatile uint32_t *>(base_address)}
{ }

void Gpio::set_pin_direction(uint8_t pin, Direction direction) const
{
    iomux.set_pin_mode(pin,
        (direction == Direction::out) ? Iomux::Mode::output : Iomux::Mode::input);
}

Gpio::Direction Gpio::get_pin_direction(uint8_t pin) const
{
    return (iomux.get_pin_mode(pin) == Iomux::Mode::output) ? Direction::out : Direction::in;
}

void Gpio::set_pin(uint8_t pin, bool val) const
{
    set_reg_bits(regs, odr_offset, pin, 0x01, val);
}

bool Gpio::get_pin(uint8_t pin) const
{
    if (get_pin_direction(pin) == Direction::out)
        return get_reg_bits(regs, odr_offset, pin, 0x01);
    else
        return get_reg_bits(regs, idr_offset, pin, 0x01);
}

void Gpio::toggle_pin(uint8_t pin) const
{
    toggle_reg_bits(regs, odr_offset, pin, 0x01);
}

void Gpio::enable_rising_edge_interrupts(uint8_t pin) const
{
    set_reg_bits(regs, rier_offset, pin, 0x01, true);
}

void Gpio::disable_rising_edge_interrupts(uint8_t pin) const
{
    set_reg_bits(regs, rier_offset, pin, 0x01, false);
}

bool Gpio::is_rising_edge_interrupt_pending(uint8_t pin) const
{
    return get_reg_bits(regs, risr_offset, pin, 0x01);
}

void Gpio::clear_rising_edge_interrupt(uint8_t pin) const
{
    set_reg_bits(regs, risr_offset, pin, 0x01, false);
}

void Gpio::enable_falling_edge_interrupts(uint8_t pin) const
{
    set_reg_bits(regs, fier_offset, pin, 0x01, true);
}

void Gpio::disable_falling_edge_interrupts(uint8_t pin) const
{
    set_reg_bits(regs, fier_offset, pin, 0x01, false);
}

bool Gpio::is_falling_edge_interrupt_pending(uint8_t pin) const
{
    return get_reg_bits(regs, fisr_offset, pin, 0x01);
}

void Gpio::clear_falling_edge_interrupt(uint8_t pin) const
{
    set_reg_bits(regs, fisr_offset, pin, 0x01, false);
}
