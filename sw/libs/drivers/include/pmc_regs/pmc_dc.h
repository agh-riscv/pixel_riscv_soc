#pragma once

#include <cstdint>

struct Pmc_dc {
    union Pmc_dc_reg_0 {
        struct {
            uint32_t th : 8;
            uint32_t res : 24;
        };
        uint32_t val;
    } reg0;
};

// /**
//  * union pmc_dc_reg_0 - Pixel Matrix Controller digital configuration register 0
//  * @th: the threshold
//  * @res: the reserved bits
//  * @val: the register value
//  */
// union pmc_dc_reg_0 {
//     struct {
//         uint32_t th : 8;
//         uint32_t res : 24;
//     };
//     uint32_t val;
// };

// /**
//  * struct pmc_dc - Pixel Matrix Controller digital configuration
//  * @REG_0: digital configuration register 0
//  */
// struct pmc_dc {
//     union pmc_dc_reg_0 reg0;
// };
