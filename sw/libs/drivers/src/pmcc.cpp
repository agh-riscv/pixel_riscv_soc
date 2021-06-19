#include "pmcc.h"

static constexpr uint32_t code_ram_base_address{0x0101'1000};
static constexpr uint32_t code_ram_depth{256};
static constexpr uint8_t code_ram_word_length{4};
static constexpr uint32_t code_ram_size{code_ram_depth * code_ram_word_length};

static constexpr uint8_t data_shifter[] {
    0x00,               /* 0x000: waitt */
    0xc0, 0x02, 0x00,   /* 0x001: store 0x0002: set shA at the beginning */
    0x00,               /* 0x004: waitt */
                        /* 16 repetitions of store 0x0003 and store 0x0002 */
    0xc0, 0x03, 0x00,   /* 0x005: store 0x0003: set shA and clkSh */
    0xc0, 0x02, 0x00,   /* 0x008: store 0x0002: set shA, clear clkSh */
    0xc0, 0x03, 0x00,
    0xc0, 0x02, 0x00,
    0xc0, 0x03, 0x00,
    0xc0, 0x02, 0x00,
    0xc0, 0x03, 0x00,
    0xc0, 0x02, 0x00,
    0xc0, 0x03, 0x00,
    0xc0, 0x02, 0x00,
    0xc0, 0x03, 0x00,
    0xc0, 0x02, 0x00,
    0xc0, 0x03, 0x00,
    0xc0, 0x02, 0x00,
    0xc0, 0x03, 0x00,
    0xc0, 0x02, 0x00,
    0xc0, 0x03, 0x00,
    0xc0, 0x02, 0x00,
    0xc0, 0x03, 0x00,
    0xc0, 0x02, 0x00,
    0xc0, 0x03, 0x00,
    0xc0, 0x02, 0x00,
    0xc0, 0x03, 0x00,
    0xc0, 0x02, 0x00,
    0xc0, 0x03, 0x00,
    0xc0, 0x02, 0x00,
    0xc0, 0x03, 0x00,
    0xc0, 0x02, 0x00,
    0xc0, 0x03, 0x00,
    0xc0, 0x02, 0x00,
    0xc0, 0x03, 0x00,
    0xc0, 0x02, 0x00,
    0x20, 0x04          /* 0x065: jump 0x004 */
};

static constexpr uint8_t pixels_configs_latcher[] {
    0x00,               /* 0x000: waitt */
    0xc0, 0x20, 0x00,   /* 0x001: store 0x0023: set write_cfg */
    0xc0, 0x00, 0x00,   /* 0x004: store 0x0000: clear write_cfg */
    0x20, 0x00          /* 0x007: jump 0x000 */
};

static constexpr uint8_t hits_generator[] {
    0x00,               /* 0x000: waitt */
    0xc0, 0x08, 0x00,   /* 0x001: store 0x0008: set gate */
    0xc0, 0x00, 0x00,   /* 0x004: store 0x0000: clear gate */
    0x20, 0x00          /* 0x007: jump 0x000 */
};

union Code_ram_word {
    uint8_t bytes[4];
    uint32_t word;
};

Pmcc::Pmcc(const uint32_t pmc_cr_address, const uint32_t pmc_sr_address)
    :   cr{reinterpret_cast<volatile Pmc_cr *>(pmc_cr_address)},
        sr{reinterpret_cast<volatile Pmc_sr *>(pmc_sr_address)},
        code_ram{code_ram_base_address, code_ram_size}
{ }

void Pmcc::set_reset(const bool reset) const volatile
{
    cr->pmcc_rst_n = !reset;
}

void Pmcc::trigger() const volatile
{
    cr->pmcc_trg = 1;
}

bool Pmcc::is_waiting_for_trigger() const volatile
{
    return sr->pmcc_wtt;
}

void Pmcc::load_application(const uint8_t *code, int size) const volatile
{
    set_reset(true);

    int words_written;
    for (words_written = 0; words_written < size / 4; ++words_written) {
        Code_ram_word code_ram_word;
        for (int i = 0; i < 4; ++i)
            code_ram_word.bytes[i] = code[words_written * 4 + i];
        code_ram[words_written * 4] = code_ram_word.word;
    }

    int bytes_left = size - 4 * words_written;
    if (bytes_left) {
        Code_ram_word code_ram_word;
        for (int i = 0; i < 3; ++i)
            code_ram_word.bytes[i] = (bytes_left > i) ? code[words_written * 4 + i] : 0;
        code_ram_word.bytes[3] = 0;
        code_ram[words_written * 4] = code_ram_word.word;
    }

    set_reset(false);
}

void Pmcc::load_data_shifter() const volatile
{
    load_application(data_shifter, (int)(sizeof(data_shifter)));
}

void Pmcc::load_config_latcher() const volatile
{
    load_application(pixels_configs_latcher, (int)(sizeof(pixels_configs_latcher)));
}

void Pmcc::load_hits_generator() const volatile
{
    load_application(hits_generator, (int)(sizeof(hits_generator)));
}
