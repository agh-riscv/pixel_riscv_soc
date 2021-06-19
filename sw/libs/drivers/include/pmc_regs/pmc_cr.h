#pragma once

#include <cstdint>

/**
 * union Pmc_cr - Pixel Matrix Controller control register
 * @pmcc_rst_n: the PMCC reset
 * @pmcc_trg: the PMCC trigger
 * @res: the reserved bits
 * @val: the register value
 */
union Pmc_cr {
    struct {
        uint32_t pmcc_rst_n : 1;
        uint32_t pmcc_trg : 1;
        uint32_t res : 30;
    };
    uint32_t val;
};
