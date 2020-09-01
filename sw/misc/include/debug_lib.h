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

#pragma once

#include <stdint.h>

#define debug_parameter_dec(parameter) \
    debug_print_parameter_name_and_dec_value(#parameter, parameter)

#define debug_parameter_hex(parameter) \
    debug_print_parameter_name_and_hex_value(#parameter, parameter)

#define debug_variable_dec(variable) \
    debug_print_variable_name_address_dec_value(#variable, (uint32_t)&variable, variable)

#define debug_variable_hex(variable) \
    debug_print_variable_name_address_hex_value(#variable, (uint32_t)&variable, variable)

void debug_print_dec_word(uint32_t word);
void debug_print_hex_word(uint32_t word);

void debug_print_parameter_name_and_dec_value(const char *name, uint32_t value);
void debug_print_parameter_name_and_hex_value(const char *name, uint32_t value);

void debug_print_variable_name_address_dec_value(const char *name, uint32_t address, uint32_t value);
void debug_print_variable_name_address_hex_value(const char *name, uint32_t address, uint32_t value);
