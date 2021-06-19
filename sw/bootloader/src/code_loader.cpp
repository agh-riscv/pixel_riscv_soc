#include "code_loader.h"
#include "code_ram.h"
#include "spi.h"
#include "uart.h"

union Code_ram_word {
    uint8_t bytes[4];
    uint32_t word;
};

void Code_loader::load_code(const Source source)
{
    if (source == Source::spi)
        load_code_through_spi();
    else
        load_code_through_uart();
}

void Code_loader::load_code_through_spi()
{
    spi.set_phase(Spi::Phase::trailing_captures);
    spi.set_clock_divider(3);
    for (uint32_t i = 0; i < code_ram.get_size(); i += 4) {
        Code_ram_word code_ram_word;
        for (int j = 0; j < 4; ++j)
            code_ram_word.bytes[j] = spi.read();
        code_ram[i] = code_ram_word.word;
    }
}

void Code_loader::load_code_through_uart()
{
    for (uint32_t i = 0; i < code_ram.get_size(); i += 4) {
        Code_ram_word code_ram_word;
        for (int j = 0; j < 4; ++j)
            code_ram_word.bytes[j] = uart.read();
        code_ram[i] = code_ram_word.word;
    }
}
