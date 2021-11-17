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

package uart_pkg;


/**
 * Patterns used for address decoding (memory map)
 */

`define UART_CR_OFFSET      12'h000     /* Control Reg offset */
`define UART_SR_OFFSET      12'h004     /* Status Reg offset */
`define UART_TDR_OFFSET     12'h008     /* Transmitter Data Reg offset */
`define UART_RDR_OFFSET     12'h00c     /* Receiver Data Reg offset */
`define UART_CDR_OFFSET     12'h010     /* Clock Divider Reg offset */


/**
 * User defined types
 */

typedef struct packed {
    logic [30:0] res;
    logic        en;
} uart_cr_t;

typedef struct packed {
    logic [28:0] res;
    logic        rxerr;
    logic        txact;
    logic        rxne;
} uart_sr_t;

typedef struct packed {
    logic [23:0] res;
    logic [7:0]  data;
} uart_tdr_t;

typedef struct packed {
    logic [23:0] res;
    logic [7:0]  data;
} uart_rdr_t;

typedef struct packed {
    logic [23:0] res;
    logic [7:0]  data;
} uart_cdr_t;

typedef struct packed {
    uart_cr_t  cr;
    uart_sr_t  sr;
    uart_tdr_t tdr;
    uart_rdr_t rdr;
    uart_cdr_t cdr;
} uart_regs_t;

endpackage
