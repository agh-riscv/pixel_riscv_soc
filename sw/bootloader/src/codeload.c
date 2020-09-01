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

#include "codeload.h"
#include "code_ram.h"
#include "spi.h"
#include "uart.h"

/**
 * codeload_spi - load code through SPI
 */
void codeload_spi(void)
{
    SPI->CR.cpha = 1;
    SPI->CDR.div = 3;

    for (int i = 0; i < CODE_RAM_SIZE; ++i)
        CODE_RAM->bytes[i] = spi_read_byte();
}

/**
 * codeload_uart - load code through UART
 */
void codeload_uart(void)
{
    for (int i = 0; i < CODE_RAM_SIZE; ++i)
        CODE_RAM->bytes[i] = uart_read_byte();
}
