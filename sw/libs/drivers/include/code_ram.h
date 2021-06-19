#pragma once

#include <cstdint>

class Code_ram final {
public:
    Code_ram(const uint32_t base_address, const uint32_t size);
    Code_ram(const Code_ram &) = delete;
    Code_ram(Code_ram &&) = delete;
    Code_ram &operator=(const Code_ram &) = delete;
    Code_ram &operator=(Code_ram &&) = delete;

    uint32_t &operator[](const uint32_t address) const volatile;
    uint32_t get_size() const volatile;

private:
    uint32_t * const mem;
    const uint32_t size;
};

extern Code_ram code_ram;
