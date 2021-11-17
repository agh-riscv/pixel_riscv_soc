#pragma once

#include <cstdint>

/**
 * union Pmc_cr - Pixel Matrix Controller control register
 * @pmcc_rst_n: the PMCC reset
 * @pmcc_trg: the PMCC trigger
 * @direct_ctrl: enable direct control mode
 * @ext_gate: enable external gate control
 * @ext_strobe: enable external strobe control
 * @res: the reserved bits
 * @val: the register value
 */
union Pmc_cr {
    struct {
        uint32_t pmcc_rst_n : 1;
        uint32_t pmcc_trg : 1;
        uint32_t direct_ctrl : 1;
        uint32_t ext_gate : 1;
        uint32_t ext_strobe : 1;
        uint32_t res : 27;
    };
    uint32_t val;
};
