#pragma once

#include <cstdint>

class Code_ram final {
public:
    Code_ram(uint32_t base_address, uint32_t size);
    Code_ram(const Code_ram &) = delete;
    Code_ram(Code_ram &&) = delete;
    Code_ram &operator=(const Code_ram &) = delete;
    Code_ram &operator=(Code_ram &&) = delete;

    uint32_t read(uint32_t offset) const;
    void write(uint32_t offset, uint32_t val) const;
    uint32_t get_size() const;

private:
    volatile uint32_t * const mem;
    const uint32_t size;
};

extern Code_ram code_ram;
