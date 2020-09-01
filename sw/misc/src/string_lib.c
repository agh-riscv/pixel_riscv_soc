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

#include "string_lib.h"

/**
 * strcpy - copy the NUL-terminated string
 * @dest: the buffer to copy the string to
 * @src: the buffer to copy the string from
 *
 * Return: address of the copying destination
 */
char *strcpy(char *dest, const char *src)
{
    char *tmp = dest;

    while ((*dest++ = *src++) != '\0') { }

    return tmp;
}

/**
 * strcat - append one NUL-terminated string to another
 * @dest: the string to be appended to
 * @src: the string to append to it
 *
 * Return: address of the concatenated string
 */
char *strcat(char *dest, const char *src)
{
    char *tmp = dest;

    while (*dest)
        ++dest;

    while ((*dest++ = *src++) != '\0') { }

    return tmp;
}

/**
 * uint_to_hex_string - convert the unsigned integer to the hexadecimal string
 * @dest: the buffer to write the string to
 * @number: the number to convert
 * @bytes_number: the length of converted number in bytes
 */
static void uint_to_hex_string(char *dest, uint32_t number, uint8_t bytes_number)
{
    const uint8_t nibbles_number = 2 * bytes_number;

    dest[0] = '0';
    dest[1] = 'x';

    for (int i = nibbles_number; i > 0; --i) {
        uint8_t nibble = number & 0x0f;

        if (nibble < 10)
            dest[1 + i] = '0' + nibble;
        else
            dest[1 + i] = 'a' + nibble - 10;

        number >>= 4;
    }

    dest[nibbles_number + 2] = '\0';
}

/**
 * byte_to_hex_string - convert the unsigned byte to the hexadecimal string
 * @dest: the buffer to write the string to
 * @byte: the byte to convert
 */
void byte_to_hex_string(char *dest, uint8_t byte)
{
    uint_to_hex_string(dest, byte, 1);
}

/**
 * word_to_hex_string - convert the unsigned word to the hexadecimal string
 * @dest: the buffer to write the string to
 * @word: the word to convert
 */
void word_to_hex_string(char *dest, uint32_t word)
{
    uint_to_hex_string(dest, word, 4);
}

/**
 * uint_to_dec_string - convert the unsigned integer to the decimal string
 * @dest: the buffer to write the string to
 * @number: the number to convert
 * @bytes_number: the length of converted number in bytes
 */
static void uint_to_dec_string(char *dest, uint32_t number, uint8_t bytes_number)
{
    uint32_t divider;

    switch (bytes_number) {
    case 1:
        divider = 100;
        break;
    case 2:
        divider = 10000;
        break;
    case 4:
        divider = 1000000000;
        break;
    default:
        divider = 0;
        break;
    }

    for( ; divider >= 1; divider /= 10) {
        *dest = number / divider;
        number -= *dest * divider;
        *dest++ += '0';
    }
    *dest = '\0';
}

/**
 * find_first_non_zero_digit - find the address of the first nonzero digit in the decimal string
 * @str: the unsigned decimal string
 *
 * Return: the address of the first nonzero digit
 */
static char *find_first_non_zero_digit(char *str)
{
    while (*str == '0')
        ++str;

    /* If the string contains only zeros, return the last one */
    return *str ? str : str - 1;
}

/**
 * byte_to_dec_string - convert the unsigned byte to the decimal string
 * @dest: the buffer to write the string to
 * @byte: the byte to convert
 */
void byte_to_dec_string(char *dest, uint8_t byte)
{
    uint_to_dec_string(dest, byte, 1);
}

/**
 * word_to_dec_string - convert the unsigned word to the decimal string
 * @dest: the buffer to write the string to
 * @word: the word to convert
 */
void word_to_dec_string(char *dest, uint32_t word)
{
    char dec_string_buffer[11];
    char *first_non_zero_digit;

    uint_to_dec_string(dec_string_buffer, word, 4);
    first_non_zero_digit = find_first_non_zero_digit(dec_string_buffer);

    strcpy(dest, first_non_zero_digit);
}
