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

package gpio_pkg;


/**
 * Patterns used for address decoding (memory map)
 */

`define GPIO_CR_OFFSET      12'h000     /* Control Reg offset */
`define GPIO_SR_OFFSET      12'h004     /* Status Reg offset */
`define GPIO_ODR_OFFSET     12'h008     /* Output Data Reg offset */
`define GPIO_IDR_OFFSET     12'h00c     /* Input Data Reg offset */
`define GPIO_IER_OFFSET     12'h010     /* Interrupt Enable Reg offset */
`define GPIO_ISR_OFFSET     12'h014     /* Interrupt Status Reg offset */
`define GPIO_RIER_OFFSET    12'h018     /* Rising-edge Interrupt Enable Reg offset */
`define GPIO_FIER_OFFSET    12'h01c     /* Falling-edge Interrupt Enable Reg offset */
`define GPIO_OENR_OFFSET    12'h020     /* Output Enable Reg offset */


/**
 * User defined types
 */

typedef struct packed {
    logic [31:0] res;
} gpio_cr_t;

typedef struct packed {
    logic [31:0] res;
} gpio_sr_t;

typedef struct packed {
    logic [31:0] data;
} gpio_odr_t;

typedef struct packed {
    logic [31:0] data;
} gpio_idr_t;

typedef struct packed {
    logic [31:0] data;
} gpio_ier_t;

typedef struct packed {
    logic [31:0] data;
} gpio_isr_t;

typedef struct packed {
    logic [31:0] data;
} gpio_rier_t;

typedef struct packed {
    logic [31:0] data;
} gpio_fier_t;

typedef struct packed {
    logic [31:0] data;
} gpio_oenr_t;

typedef struct packed {
    gpio_cr_t   cr;
    gpio_sr_t   sr;
    gpio_odr_t  odr;
    gpio_idr_t  idr;
    gpio_ier_t  ier;
    gpio_isr_t  isr;
    gpio_rier_t rier;
    gpio_fier_t fier;
    gpio_oenr_t oenr;
} gpio_regs_t;

endpackage
