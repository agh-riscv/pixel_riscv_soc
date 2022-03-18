#include <debug.hpp>
#include <string_ops.hpp>
#include <ui.hpp>

void Debugger::print_dec_word(uint32_t word)
{
    char dec_string[11];
    to_dec_string(dec_string, word);
    print(dec_string);
}

void Debugger::print_dec_word(const char *name, uint32_t value)
{
    char value_string[11];
    to_dec_string(value_string, value);
    print(name, value_string);
}

void Debugger::print_dec_word(const char *name, uint32_t address, uint32_t value)
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

void Debugger::print_hex_word(const char *name, uint32_t value)
{
    char value_string[11];
    to_hex_string(value_string, value);
    print(name, value_string);
}

void Debugger::print_hex_word(const char *name, uint32_t address, uint32_t value)
{
    char address_string[11], value_string[11];
    to_hex_string(address_string, address);
    to_hex_string(value_string, value);
    print(name, address_string, value_string);
}

void Debugger::print(const char *value)
{
    char buf[100];
    strcpy(buf, value);
    strcat(buf, "\n");
    ui << buf;
}

void Debugger::print(const char *name, const char *value)
{
    char buf[100];
    strcpy(buf, name);
    strcat(buf, ": ");
    strcat(buf, value);
    strcat(buf, "\n");
    ui << buf;
}

void Debugger::print(const char *name, const char *address, const char *value)
{
    char buf[100];
    strcpy(buf, name);
    strcat(buf, " (");
    strcat(buf, address);
    strcat(buf, "): ");
    strcat(buf, value);
    strcat(buf, "\n");
    ui << buf;
}
