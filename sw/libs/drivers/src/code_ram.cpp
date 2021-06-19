#include "code_ram.h"

static constexpr uint32_t code_ram_base_address{0x0001'0000};
static constexpr uint32_t depth{4096};
static constexpr uint8_t word_length{4};
static constexpr uint32_t size{depth * word_length};

Code_ram code_ram{code_ram_base_address, size};

Code_ram::Code_ram(const uint32_t base_address, const uint32_t size)
    :   mem{reinterpret_cast<uint32_t *>(base_address)}, size{size}
{ }

uint32_t &Code_ram::operator[](const uint32_t address) const volatile
{
    return mem[address >> 2];
}

uint32_t Code_ram::get_size() const volatile
{
    return size;
}
