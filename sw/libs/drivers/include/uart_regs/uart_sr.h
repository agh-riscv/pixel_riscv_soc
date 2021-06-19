#pragma once

#include <cstdint>

/**
 * union Uart_sr - UART status register
 * @rxne: the receiver is not ready
 * @txact: the transmitter is active
 * @rxerr: the receiver error occurred
 * @res: the reserved bits
 * @val: the register value
 */
union Uart_sr {
    struct {
        uint32_t rxne : 1;
        uint32_t txact : 1;
        uint32_t rxerr : 1;
        uint32_t res : 29;
    };
    uint32_t val;
};
