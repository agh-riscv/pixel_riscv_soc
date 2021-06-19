#pragma once

#include <cstdint>

/**
 * struct Pmc_ac - Pixel Matrix Controller analog configuration
 * @regs: analog configuration registers
 */
struct Pmc_ac {
    uint32_t regs[4];
};
