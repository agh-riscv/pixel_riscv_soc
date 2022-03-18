#pragma once

#include <cstdint>

class Iomux final {
public:
    enum class Mode {input, output, alternative};

    Iomux(uint32_t base_address);
    Iomux(const Iomux &) = delete;
    Iomux(Iomux &&) = delete;
    Iomux &operator=(const Iomux &) = delete;
    Iomux &operator=(Iomux &&) = delete;

    void set_pin_mode(uint8_t pin, Mode mode) const;
    Mode get_pin_mode(uint8_t pin) const;

private:
    volatile uint32_t * const regs;
};

extern Iomux iomux;
