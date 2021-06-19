#pragma once

#include <cstdint>

/**
 * union Uart_cr - UART control register
 * @en: the peripheral enable
 * @res: the reserved bits
 * @val: the register value
 */
union Uart_cr {
    struct {
        uint32_t en : 1;
        uint32_t res : 31;
    };
    uint32_t val;
};
