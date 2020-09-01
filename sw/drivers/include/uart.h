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

/* Universal Asynchronous Receiver and Transmitter */
#define UART_BASE_ADDRESS               0x01002000
#define UART                            ((volatile struct uart *)UART_BASE_ADDRESS)

/* Bits definitions for UART control register */
#define UART_CR_EN_POS                  0
#define UART_CR_EN_MASK                 (1<<UART_CR_EN_POS)

/* Bits definitions for UART status register */
#define UART_SR_RXNE_POS                0
#define UART_SR_RXNE_MASK               (1<<UART_SR_RXNE_POS)
#define UART_SR_TXACT_POS               1
#define UART_SR_TXACT_MASK              (1<<UART_SR_TXACT_POS)
#define UART_SR_RXERR_POS               2
#define UART_SR_RXERR_MASK              (1<<UART_SR_RXERR_POS)

/* Bits definitions for UART transmitter data register */
#define UART_TDR_DATA_POS               0
#define UART_TDR_DATA_MASK              (0xFF<<UART_TDR_DATA_POS)

/* Bits definitions for UART receiver data register */
#define UART_RDR_DATA_POS               0
#define UART_RDR_DATA_MASK              (0xFF<<UART_RDR_DATA_POS)

/* Bits definitions for UART clock divider register */
#define UART_CDR_DIV_POS                0
#define UART_CDR_DIV_MASK               (0xFF<<UART_CDR_DIV_POS)

/**
 * union uart_cr - UART control register
 * @en: the peripheral enable
 * @res: the reserved bits
 * @val: the register value
 */
union uart_cr {
    struct {
        uint32_t en : 1;
        uint32_t res : 31;
    };
    uint32_t val;
};

/**
 * union uart_sr - UART status register
 * @rxne: the receiver is not ready
 * @txact: the transmitter is active
 * @rxerr: the receiver error occurred
 * @res: the reserved bits
 * @val: the register value
 */
union uart_sr {
    struct {
        uint32_t rxne : 1;
        uint32_t txact : 1;
        uint32_t rxerr : 1;
        uint32_t res : 29;
    };
    uint32_t val;
};

/**
 * union uart_tdr - UART transmitter data register
 * @data: the data to transmit
 * @res: the reserved bits
 * @val: the register value
 */
union uart_tdr {
    struct {
        uint32_t data : 8;
        uint32_t res : 24;
    };
    uint32_t val;
};

/**
 * union uart_rdr - UART receiver data register
 * @data: the received data
 * @res: the reserved bits
 * @val: the register value
 */
union uart_rdr {
    struct {
        uint32_t data : 8;
        uint32_t res : 24;
    };
    uint32_t val;
};

/**
 * union uart_cdr - UART clock divider register
 * @div: the clock divider
 * @res: the reserved bits
 * @val: the register value
 */
union uart_cdr {
    struct {
        uint32_t div : 8;
        uint32_t res : 24;
    };
    uint32_t val;
};

/**
 * struct uart - Universal Asynchronous Receiver and Transmitter
 * @CR: control register
 * @SR: status register
 * @TDR: transtmitter data register
 * @RDR: receiver data register
 * @CDR: clock divider register
 */
struct uart {
    union uart_cr CR;
    union uart_sr SR;
    union uart_tdr TDR;
    union uart_rdr RDR;
    union uart_cdr CDR;
};

void uart_init(void);
uint8_t uart_read_byte(void);
int uart_read(char *dest, uint8_t len);
void uart_write_byte(uint8_t byte);
void uart_write(const char *src);
