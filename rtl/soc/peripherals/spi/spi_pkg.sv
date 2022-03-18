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

package spi_pkg;


/**
 * Patterns used for address decoding (memory map)
 */

const logic [11:0] SPI_CR_OFFSET = 12'h000,     /* Control Reg offset */
                   SPI_SR_OFFSET = 12'h004,     /* Status Reg offset*/
                   SPI_TDR_OFFSET = 12'h008,    /* Transmitter Data Reg offset */
                   SPI_RDR_OFFSET = 12'h00c,    /* Receiver Data Reg offset */
                   SPI_CDR_OFFSET = 12'h010,    /* Clock Divider Reg offset*/
                   SPI_IER_OFFSET = 12'h014,    /* Interrupt Enable Reg offset */
                   SPI_ISR_OFFSET = 12'h018;    /* Interrupt Status Reg offset */


/**
 * User defined types
 */

typedef struct packed {
    logic [28:0] res;
    logic        cpol;
    logic        cpha;
    logic        active_ss;
} spi_cr_t;

typedef struct packed {
    logic [27:0] res;
    logic        tx_fifo_empty;
    logic        tx_fifo_full;
    logic        rx_fifo_empty;
    logic        rx_fifo_full;
} spi_sr_t;

typedef struct packed {
    logic [23:0] res;
    logic [7:0]  data;
} spi_tdr_t;

typedef struct packed {
    logic [23:0] res;
    logic [7:0]  data;
} spi_rdr_t;

typedef struct packed {
    logic [23:0] res;
    logic [7:0]  data;
} spi_cdr_t;

typedef struct packed {
    logic [30:0] res;
    logic        txfeie;    /* tx fifo empty */
} spi_ier_t;

typedef struct packed {
    logic [30:0] res;
    logic        txfef;
} spi_isr_t;

typedef struct packed {
    spi_cr_t  cr;
    spi_sr_t  sr;
    spi_tdr_t tdr;
    spi_rdr_t rdr;
    spi_cdr_t cdr;
    spi_ier_t ier;
    spi_isr_t isr;
} spi_regs_t;

endpackage
