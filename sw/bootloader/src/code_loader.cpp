#include <code_loader.hpp>
#include <libdrivers/code_ram.hpp>
#include <libdrivers/core.hpp>
#include <libdrivers/spi.hpp>
#include <libdrivers/uart.hpp>

static constexpr uint32_t code_ram_base_address{0x0001'0000};
static constexpr uint32_t depth{4096};
static constexpr uint32_t word_length{4};
static constexpr uint32_t size{depth * word_length};

union Code_ram_word {
    uint8_t bytes[4];
    uint32_t word;
};

Code_loader::Code_loader()
    :   code_ram{code_ram_base_address, size}
{ }

void Code_loader::load_code_through_spi()
{
    spi.set_active_slave(0);
    spi.set_phase(Spi::Phase::trailing_captures);
    spi.set_clock_divider(3);

    for (uint32_t i = 0; i < code_ram.get_size(); i += 4) {
        Code_ram_word code_ram_word;
        for (int j = 0; j < 4; ++j)
            code_ram_word.bytes[j] = spi.read();
        code_ram.write(i, code_ram_word.word);
    }
}

int Code_loader::load_code_through_uart()
{
    const auto timeout = core.get_performance_counter() + 1'000'000'000;    /* 20 s if fclk = 50 MHz */
    int received_bytes{0};

    for (uint32_t i = 0; i < code_ram.get_size(); i += 4) {
        Code_ram_word code_ram_word;
        for (int j = 0; j < 4; ++j) {
            while (!uart.is_receiver_ready() && core.get_performance_counter() < timeout) { }
            if (uart.is_receiver_ready()) {
                code_ram_word.bytes[j] = uart.get_rdata();
                ++received_bytes;
            } else {
                return received_bytes;
            }
        }
        code_ram.write(i, code_ram_word.word);
    }
    return 0;
}
