/**
 * Copyright (C) 2021  AGH University of Science and Technology
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

package memory_map;

const logic [31:0] BOOT_ROM_BASE_ADDRESS = 32'h0000_0000,
                   BOOT_ROM_END_ADDRESS = 32'h0000_1fff,

                   CODE_RAM_BASE_ADDRESS = 32'h0001_0000,
                   CODE_RAM_END_ADDRESS = 32'h0001_3fff,

                   DATA_RAM_BASE_ADDRESS = 32'h0010_0000,
                   DATA_RAM_END_ADDRESS = 32'h0010_3fff,

                   IOMUX_BASE_ADDRESS = 32'h0100_0000,
                   IOMUX_END_ADDRESS = 32'h0100_0fff,

                   GPIO_BASE_ADDRESS = 32'h0100_1000,
                   GPIO_END_ADDRESS = 32'h0100_1fff,

                   UART_BASE_ADDRESS = 32'h0100_2000,
                   UART_END_ADDRESS = 32'h0100_2fff,

                   SPI_BASE_ADDRESS = 32'h0100_3000,
                   SPI_END_ADDRESS = 32'h0100_3fff,

                   TIMER_BASE_ADDRESS = 32'h0100_4000,
                   TIMER_END_ADDRESS = 32'h0100_4fff,

                   PMC_BASE_ADDRESS = 32'h0101_0000,
                   PMC_END_ADDRESS = 32'h0101_ffff;

endpackage
