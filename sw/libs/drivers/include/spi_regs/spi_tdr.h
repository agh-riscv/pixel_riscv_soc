#pragma once

#include <cstdint>

/**
 * union Spi_tdr - SPI transmitter data register
 * @data: the data to transmit
 * @res: the reserved bits
 * @val: the register value
 */
union Spi_tdr {
    struct {
        uint32_t data : 8;
        uint32_t res : 24;
    };
    uint32_t val;
};
