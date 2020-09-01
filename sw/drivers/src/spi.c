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

#include "spi.h"

/**
 * spi_read_byte - SPI synchronous single-byte read
 *
 * It performs dummy byte write for a slave clocking.
 *
 * Return: the read byte
 */
uint8_t spi_read_byte(void)
{
    SPI->TDR.data = 0;
    while (!(SPI->SR.rxne)) { }
    return SPI->RDR.data;
}

/**
 * spi_read_word - SPI synchronous single-word read
 *
 * It performs 4 single-byte readouts and concatenates read bytes into a single 32-bit word.
 *
 * Return: the read word
 */
uint32_t spi_read_word(void)
{
    union {
        uint8_t bytes[4];
        uint32_t word;
    } received_data;

    for (int i = 0; i < 4; ++i)
        received_data.bytes[i] = spi_read_byte();
    return received_data.word;
}

/**
 * spi_write_byte - SPI synchronous single-byte write
 * @byte: the byte to send
 */
void spi_write_byte(uint8_t byte)
{
    SPI->TDR.data = byte;
    while (SPI->SR.txact) { }
    (void)SPI->RDR.data;
}
