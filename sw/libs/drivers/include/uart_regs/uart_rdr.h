#pragma once

#include <cstdint>

/**
 * union Uart_rdr - UART receiver data register
 * @data: the received data
 * @res: the reserved bits
 * @val: the register value
 */
union Uart_rdr {
    struct {
        uint32_t data : 8;
        uint32_t res : 24;
    };
    uint32_t val;
};
