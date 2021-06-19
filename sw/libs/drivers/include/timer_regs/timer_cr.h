#pragma once

#include <cstdint>

/**
 * union Timer_cr - timer control register
 * @trg: the trigger
 * @halt: the halt
 * @sngl: the single-shot mode
 * @val: the register value
 */
union Timer_cr {
    struct {
        uint32_t trg : 1;
        uint32_t hlt : 1;
        uint32_t sngl : 1;
        uint32_t res : 29;
    };
    uint32_t val;
};
