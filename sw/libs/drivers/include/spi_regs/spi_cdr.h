#pragma once

#include <cstdint>

/**
 * union Spi_cdr - SPI clock divider register
 * @div: the clock divider
 * @res: the reserved bits
 * @val: the register value
 */
union Spi_cdr {
    struct {
        uint32_t div : 8;
        uint32_t res : 24;
    };
    uint32_t val;
};
