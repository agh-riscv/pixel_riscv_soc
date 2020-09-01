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

#include "debug_lib.h"
#include "string_lib.h"
#include "uart.h"

/**
 * debug_print_dec_word - print decimal string representing unsigned word
 * @word: the unsigned word to print
 */
void debug_print_dec_word(uint32_t word)
{
    char dec_string[11];

    word_to_dec_string(dec_string, word);
    uart_write(dec_string);
}

/**
 * debug_print_hex_word - print hexadecimal string representing unsigned word
 * @word: the unsigned word to print
 */
void debug_print_hex_word(uint32_t word)
{
    char hex_string[11];

    word_to_hex_string(hex_string, word);
    uart_write(hex_string);
}

/**
 * debug_print_parameter_strings - print the parameter name and value
 * @name: the parameter name
 * @value: the parameter value
 *
 * The parameter and its value are printed in the following form: "<name>: <value>".
 */
static void debug_print_parameter_strings(const char *name, const char * value)
{
    char buffer[100];

    strcpy(buffer, name);
    strcat(buffer, ": ");
    strcat(buffer, value);

    uart_write(buffer);
}

/**
 * debug_print_parameter_name_and_dec_value - print the parameter name and decimal value
 * @name: the parameter name
 * @value: the parameter value
 *
 * The parameter and its value are printed in the following form: "<name>: <value>".
 */
void debug_print_parameter_name_and_dec_value(const char *name, uint32_t value)
{
    char value_string[11];

    word_to_dec_string(value_string, value);
    debug_print_parameter_strings(name, value_string);
}

/**
 * debug_print_parameter_name_and_hex_value - print the parameter name and hexadecimal value
 * @name: the parameter name
 * @value: the parameter value
 *
 * The parameter and its value are printed in the following form: "<name>: <value>".
 */
void debug_print_parameter_name_and_hex_value(const char *name, uint32_t value)
{
    char value_string[11];

    word_to_hex_string(value_string, value);
    debug_print_parameter_strings(name, value_string);
}

/**
 * debug_print_variable_strings - print the variable name, address and value
 * @name: the variable name
 * @address: the variable address
 * @value: the variable value
 *
 * The variable name, address and value are printed in the following form: "<name> (<address>): <value>".
 */
static void debug_print_variable_strings(const char *name, const char *address, const char *value)
{
    char buffer[100];

    strcpy(buffer, name);
    strcat(buffer, " (");
    strcat(buffer, address);
    strcat(buffer, "): ");
    strcat(buffer, value);

    uart_write(buffer);
}

/**
 * debug_print_variable_name_address_dec_value - print the variable name, address and decimal value
 * @name: the variable name
 * @address: the variable address
 * @value: the variable value
 *
 * The variable name, address and value are printed in the following form: "<name> (<address>): <value>".
 */
void debug_print_variable_name_address_dec_value(const char *name, uint32_t address, uint32_t value)
{
    char address_string[11], value_string[11];

    word_to_hex_string(address_string, address);
    word_to_dec_string(value_string, value);

    debug_print_variable_strings(name, address_string, value_string);
}

/**
 * debug_print_variable_name_address_hex_value - print the variable name, address and hexadecimal value
 * @name: the variable name
 * @address: the variable address
 * @value: the variable value
 *
 * The variable name, address and value are printed in the following form: "<name> (<address>): <value>".
 */
void debug_print_variable_name_address_hex_value(const char *name, uint32_t address, uint32_t value)
{
    char address_string[11], value_string[11];

    word_to_hex_string(address_string, address);
    word_to_hex_string(value_string, value);

    debug_print_variable_strings(name, address_string, value_string);
}
