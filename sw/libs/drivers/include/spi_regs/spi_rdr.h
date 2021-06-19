#pragma once

#include <cstdint>

/**
 * union Spi_rdr - SPI receiver data register
 * @data: the received data
 * @res: the reserved bits
 * @val: the register value
 */
union Spi_rdr {
    struct {
        uint32_t data : 8;
        uint32_t res : 24;
    };
    uint32_t val;
};
