#pragma once

#include <cstdint>

/**
 * union Timer_sr - timer status register
 * @mtch: the compare value matched
 * @act: the timer is active
 * @val: the register value
 */
union Timer_sr {
    struct {
        uint32_t mtch : 1;
        uint32_t hlt : 1;
        uint32_t res : 30;
    };
    uint32_t val;
};
