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

`define SPI_CR_OFFSET  12'h000
`define SPI_SR_OFFSET  12'h004
`define SPI_TDR_OFFSET 12'h008
`define SPI_RDR_OFFSET 12'h00C
`define SPI_CDR_OFFSET 12'h010


/**
 * User defined types
 */

typedef enum logic [2:0] {
    SPI_CR,         /* Control Register */
    SPI_SR,         /* Status Register */
    SPI_TDR,        /* Transmitter Data Register */
    SPI_RDR,        /* Receiver Data Register */
    SPI_CDR,        /* Clock Divider Register */
    SPI_NONE
} spi_reg_t;

typedef struct packed {
    logic [29:0] res;
    logic        cpol;
    logic        cpha;
} spi_cr_t;

typedef struct packed {
    logic [29:0] res;
    logic        txact;
    logic        rxne;
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
    spi_cr_t cr;
    spi_sr_t sr;
    spi_tdr_t tdr;
    spi_rdr_t rdr;
    spi_cdr_t cdr;
} spi_t;

endpackage
