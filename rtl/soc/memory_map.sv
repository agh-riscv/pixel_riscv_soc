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

`define BOOT_ROM_ADDRESS_SPACE 32'h0000_0???                /* 0x0000_0000 - 0x0000_0FFF (4 kB) */
`define CODE_RAM_ADDRESS_SPACE {16'h0001, 4'b00??, 12'h???} /* 0x0001_0000 - 0x0001_3FFF (16 kB) */
`define DATA_RAM_ADDRESS_SPACE {16'h0010, 4'b00??, 12'h???} /* 0x0010_0000 - 0x0010_3FFF (16 kB) */
`define GPIO_ADDRESS_SPACE     32'h0100_0???                /* 0x0100_0000 - 0x0100_0FFF (4 kB) */
`define SPI_ADDRESS_SPACE      32'h0100_1???                /* 0x0100_1000 - 0x0100_1FFF (4 kB) */
`define UART_ADDRESS_SPACE     32'h0100_2???                /* 0x0100_2000 - 0x0100_2FFF (4 kB) */
`define TIMER_ADDRESS_SPACE    32'h0100_3???                /* 0x0100_3000 - 0x0100_3FFF (4 kB) */
`define PMC_ADDRESS_SPACE      32'h0101_????                /* 0x0101_0000 - 0x0101_FFFF (64 kB) */

endpackage
