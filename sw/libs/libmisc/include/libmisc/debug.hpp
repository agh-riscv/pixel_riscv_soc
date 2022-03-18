#pragma once

#include <cstdint>

#define debug_dec_word(parameter) \
    Debugger::print_dec_word(#parameter, parameter)

#define debug_hex_word(parameter) \
    Debugger::print_hex_word(#parameter, parameter)

class Debugger final {
public:
    Debugger() = delete;
    Debugger(const Debugger &) = delete;
    Debugger(Debugger &&) = delete;
    Debugger &operator=(const Debugger &) = delete;
    Debugger &operator=(Debugger &&) = delete;

    static void print_dec_word(uint32_t word);
    static void print_dec_word(const char *name, uint32_t value);
    static void print_dec_word(const char *name, uint32_t address, uint32_t value);

    static void print_hex_word(uint32_t word);
    static void print_hex_word(const char *name, uint32_t value);
    static void print_hex_word(const char *name, uint32_t address, uint32_t value);

private:
    static void print(const char *value);
    static void print(const char *name, const char *value);
    static void print(const char *name, const char *address, const char *value);
};
