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

const logic [11:0] GPIO_ODR_OFFSET = 12'h000,   /* Output Data Reg offset */
                   GPIO_IDR_OFFSET = 12'h004,   /* Input Data Reg offset */
                   GPIO_RIER_OFFSET = 12'h008,  /* Rising-edge Interrupt Enable Reg offset */
                   GPIO_RISR_OFFSET = 12'h00c,  /* Rising-edge Interrupt Status Reg offset */
                   GPIO_FIER_OFFSET = 12'h010,  /* Falling-edge Interrupt Enable Reg offset */
                   GPIO_FISR_OFFSET = 12'h014;  /* Falling-edge Interrupt Status Reg offset */


/**
 * User defined types
 */

typedef struct packed {
    logic [31:0] odr;
    logic [31:0] idr;
    logic [31:0] rier;
    logic [31:0] risr;
    logic [31:0] fier;
    logic [31:0] fisr;
} gpio_regs_t;

endpackage
