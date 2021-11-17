#include "code_loader.h"
#include "code_ram.h"
#include "core.h"
#include "spi.h"
#include "uart.h"

union Code_ram_word {
    uint8_t bytes[4];
    uint32_t word;
};

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

int Code_loader::load_code_through_uart()
{
    const auto timeout = core.get_performance_counter() + 1'000'000'000;    /* 20 s if fclk = 50 MHz */

    for (uint32_t i = 0; i < code_ram.get_size(); i += 4) {
        Code_ram_word code_ram_word;
        for (int j = 0; j < 4; ++j) {
            while (!uart.is_receiver_ready() && core.get_performance_counter() < timeout) { }
            if (uart.is_receiver_ready())
                code_ram_word.bytes[j] = uart.get_rdata();
            else
                return -1;
        }
        code_ram[i] = code_ram_word.word;
    }
    return 0;
}
