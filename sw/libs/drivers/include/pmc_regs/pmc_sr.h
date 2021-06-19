#pragma once

#include <cstdint>

/**
 * union Pmc_sr - Pixel Matrix Controller status register
 * @pmcc_wtt: the PMCC waiting for a trigger flag
 * @res: the reserved bits
 * @val: the register value
 */
union Pmc_sr {
    struct {
        uint32_t pmcc_wtt : 1;
        uint32_t res : 31;
    };
    uint32_t val;
};
