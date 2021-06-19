#pragma once

#include <cstdint>

/**
 * union Spi_sr - SPI status register
 * @rxne: the receiver is not ready
 * @txact: the transmitter is active
 * @res: the reserved bits
 * @val: the register value
 */
union Spi_sr {
    struct {
        uint32_t rxne : 1;
        uint32_t txact : 1;
        uint32_t res : 30;
    };
    uint32_t val;
};
