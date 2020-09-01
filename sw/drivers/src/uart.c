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

#include "uart.h"

/**
 * uart_init - initialize UART
 */
void uart_init(void)
{
#ifdef SIM
    UART->CDR.div = 2;
#elif defined ASIC || defined FPGA
    UART->CDR.div = 6;  /* when frequency is equal to 50 MHz */
#endif
    UART->CR.en = 1;
}

/**
 * uart_read_byte - UART synchronous single-byte read
 *
 * Return: the read byte
 */
uint8_t uart_read_byte(void)
{
    while (!(UART->SR.rxne)) { }
    return UART->RDR.data;
}

/**
 * uart_read - UART synchronous mutli-byte read
 * @dest: data buffer
 * @len: data buffer size
 *
 * Return: 0 if whole message was written to buffer, else -1
 */
int uart_read(char *dest, uint8_t len)
{
    for (int i = 0; i < len; ++i) {
        dest[i] = uart_read_byte();
        if (dest[i] == '\n') {
            dest[i] = '\0';
            return 0;
        }
    }
    return 1;
}

/**
 * uart_write_byte - UART synchronous single-byte write
 */
void uart_write_byte(uint8_t byte)
{
    UART->TDR.data = byte;
    while (UART->SR.txact) { }
}

/**
 * uart_write - UART synchronous multi-byte write
 */
void uart_write(const char *src)
{
    while (*src)
        uart_write_byte(*src++);
    uart_write_byte('\n');
}
