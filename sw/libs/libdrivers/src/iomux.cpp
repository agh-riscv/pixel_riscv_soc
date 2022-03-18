#include <iomux.hpp>
#include <common.hpp>
#include <memory_map.hpp>

static constexpr uint32_t mr0_offset{0x000};
static constexpr uint32_t mr1_offset{0x004};

static constexpr uint8_t mode_bits{2};
static constexpr uint32_t mode_mask{0x03};

Iomux iomux{iomux_base_address};

Iomux::Iomux(uint32_t base_address)
    :   regs{reinterpret_cast<volatile uint32_t *>(base_address)}
{ }

void Iomux::set_pin_mode(uint8_t pin, Mode mode) const
{
    if (pin < 16) {
        set_reg_bits(regs, mr0_offset,
            pin * mode_bits, mode_mask, static_cast<uint32_t>(mode));
    } else {
        set_reg_bits(regs, mr1_offset,
            (pin - 16) * mode_bits, mode_mask, static_cast<uint32_t>(mode));
    }
}

Iomux::Mode Iomux::get_pin_mode(uint8_t pin) const
{
    uint32_t mode;

    if (pin < 16)
        mode = get_reg_bits(regs, mr0_offset, pin * mode_bits, mode_mask);
    else
        mode = get_reg_bits(regs, mr1_offset, (pin - 16) * mode_bits, mode_mask);

    switch (mode) {
    case 0x00:
        return Mode::input;
    case 0x01:
        return Mode::output;
    case 0x02:
        return Mode::alternative;
    default:
        return Mode::input;
    }
}
