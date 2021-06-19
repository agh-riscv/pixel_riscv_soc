#pragma once

#include <cstdint>

/**
 * union Pmc_ctrl - Pixel Matrix Controller control signals register
 * @data: the control signals set by PMCC
 * @res: the reserved bits
 * @val: the register value
 */
union Pmc_ctrl {
    struct {
        uint32_t data : 16;
        uint32_t res : 16;
    };
    uint32_t val;
};
