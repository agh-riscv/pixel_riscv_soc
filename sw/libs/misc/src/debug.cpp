#include "debug.h"
#include "string_ops.h"
#include "uart.h"

void Debugger::print_dec_word(const uint32_t word)
{
    char dec_string[11];
    to_dec_string(dec_string, word);
    print(dec_string);
}

void Debugger::print_dec_word(const char *name, const uint32_t value)
{
    char value_string[11];
    to_dec_string(value_string, value);
    print(name, value_string);
}

void Debugger::print_dec_word(const char *name, const uint32_t address, const uint32_t value)
{
    char address_string[11], value_string[11];
    to_hex_string(address_string, address);
    to_dec_string(value_string, value);
    print(name, address_string, value_string);
}

void Debugger::print_hex_word(uint32_t word)
{
    char hex_string[11];
    to_hex_string(hex_string, word);
    print(hex_string);
}

void Debugger::print_hex_word(const char *name, const uint32_t value)
{
    char value_string[11];
    to_hex_string(value_string, value);
    print(name, value_string);
}

void Debugger::print_hex_word(const char *name, const uint32_t address, const uint32_t value)
{
    char address_string[11], value_string[11];
    to_hex_string(address_string, address);
    to_hex_string(value_string, value);
    print(name, address_string, value_string);
}

void Debugger::print(const char *value)
{
    char buffer[100];
    strcpy(buffer, value);
    strcat(buffer, "\n");
    uart.write(buffer);
}

void Debugger::print(const char *name, const char *value)
{
    char buffer[100];
    strcpy(buffer, name);
    strcat(buffer, ": ");
    strcat(buffer, value);
    strcat(buffer, "\n");
    uart.write(buffer);
}

void Debugger::print(const char *name, const char *address, const char *value)
{
    char buffer[100];
    strcpy(buffer, name);
    strcat(buffer, " (");
    strcat(buffer, address);
    strcat(buffer, "): ");
    strcat(buffer, value);
    strcat(buffer, "\n");
    uart.write(buffer);
}
