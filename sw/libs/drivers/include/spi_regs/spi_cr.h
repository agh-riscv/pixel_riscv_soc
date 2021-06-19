#pragma once

#include <cstdint>

/**
 * union Spi_cr - SPI control register
 * @cpha: the clock phase (0 - the leading edge captures, 1 - the trailing edge captures)
 * @cpol: the clock polarity (the clock idle state)
 * @res: the reserved bits
 * @val: the register value
 */
union Spi_cr {
    struct {
        uint32_t cpha : 1;
        uint32_t cpol : 1;
        uint32_t res : 30;
    };
    uint32_t val;
};
