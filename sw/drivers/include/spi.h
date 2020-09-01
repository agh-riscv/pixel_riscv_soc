/**
 * Copyright (C) 2020  AGH University of Science and Technology
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

#pragma once

#include <stdint.h>

/* Serial Peripheral Interface */
#define SPI_BASE_ADDRESS                0x01001000
#define SPI                             ((volatile struct spi *)SPI_BASE_ADDRESS)

/* Bits definitions for SPI control register */
#define SPI_CR_CPHA_POS                 0
#define SPI_CR_CPHA_MASK                (1<<SPI_CR_CPHA_POS)
#define SPI_CR_CPOL_POS                 1
#define SPI_CR_CPOL_MASK                (1<<SPI_CR_CPOL_POS)

/* Bits definitions for SPI status register */
#define SPI_SR_RXNE_POS                 0
#define SPI_SR_RXNE_MASK                (1<<SPI_SR_RXNE_POS)
#define SPI_SR_TXACT_POS                1
#define SPI_SR_TXACT_MASK               (1<<SPI_SR_TXACT_POS)

/* Bits definitions for SPI transmitter data register */
#define SPI_TDR_DATA_POS                0
#define SPI_TDR_DATA_MASK               (0xFF<<SPI_TDR_DATA_POS)

/* Bits definitions for SPI receiver data register */
#define SPI_RDR_DATA_POS                0
#define SPI_RDR_DATA_MASK               (0xFF<<SPI_RDR_DATA_POS)

/* Bits definitions for SPI clock divider register */
#define SPI_CDR_DIV_POS                 0
#define SPI_CDR_DIV_MASK                (0xFF<<SPI_CDR_DIV_POS)

/**
 * union spi_cr - SPI control register
 * @cpha: the clock phase (0 - the leading edge captures, 1 - the trailing edge captures)
 * @cpol: the clock polarity (the clock idle state)
 * @res: the reserved bits
 * @val: the register value
 */
union spi_cr {
    struct {
        uint32_t cpha : 1;
        uint32_t cpol : 1;
        uint32_t res : 30;
    };
    uint32_t val;
};

/**
 * union spi_sr - SPI status register
 * @rxne: the receiver is not ready
 * @txact: the transmitter is active
 * @res: the reserved bits
 * @val: the register value
 */
union spi_sr {
    struct {
        uint32_t rxne : 1;
        uint32_t txact : 1;
        uint32_t res : 30;
    };
    uint32_t val;
};

/**
 * union spi_tdr - SPI transmitter data register
 * @data: the data to transmit
 * @res: the reserved bits
 * @val: the register value
 */
union spi_tdr {
    struct {
        uint32_t data : 8;
        uint32_t res : 24;
    };
    uint32_t val;
};

/**
 * union spi_rdr - SPI receiver data register
 * @data: the received data
 * @res: the reserved bits
 * @val: the register value
 */
union spi_rdr {
    struct {
        uint32_t data : 8;
        uint32_t res : 24;
    };
    uint32_t val;
};

/**
 * union spi_cdr - SPI clock divider register
 * @div: the clock divider
 * @res: the reserved bits
 * @val: the register value
 */
union spi_cdr {
    struct {
        uint32_t div : 8;
        uint32_t res : 24;
    };
    uint32_t val;
};

/**
 * struct spi - Serial Peripheral Interface
 * @CR: control register
 * @SR: status register
 * @TDR: transmitter data register
 * @RDR: receiver data register
 * @CDR: clock divider register
 */
struct spi {
    union spi_cr CR;
    union spi_sr SR;
    union spi_tdr TDR;
    union spi_rdr RDR;
    union spi_cdr CDR;
};

uint8_t spi_read_byte(void);
uint32_t spi_read_word(void);
void spi_write_byte(uint8_t byte);
