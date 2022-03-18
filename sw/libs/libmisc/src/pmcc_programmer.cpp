#include <pmcc_programmer.hpp>
#include <cstdint>
#include <libdrivers/pmc.hpp>

Pmcc_programmer pmcc_programmer;

static constexpr uint8_t data_shifter_a_accelerated[] {
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

static constexpr uint8_t data_shifter_a_coprocessed[] {
    0x00,               /* 0x000: waitt */
    0xc0, 0x03, 0x00,   /* 0x001: store 0x0003: set shA and clkSh */
    0xc0, 0x02, 0x00,   /* 0x004: store 0x0002: set shA, clear clkSh */
    0x20, 0x00          /* 0x007: jump 0x000 */
};

static constexpr uint8_t data_shifter_b_accelerated[] {
    0x00,               /* 0x000: waitt */
    0xc0, 0x02, 0x00,   /* 0x001: store 0x0004: set sh_b at the beginning */
    0x00,               /* 0x004: waitt */
                        /* 16 repetitions of store 0x0003 and store 0x0002 */
    0xc0, 0x05, 0x00,   /* 0x005: store 0x0005: set sh_b and clkSh */
    0xc0, 0x04, 0x00,   /* 0x008: store 0x0004: set sh_b, clear clkSh */
    0xc0, 0x05, 0x00,
    0xc0, 0x04, 0x00,
    0xc0, 0x05, 0x00,
    0xc0, 0x04, 0x00,
    0xc0, 0x05, 0x00,
    0xc0, 0x04, 0x00,
    0xc0, 0x05, 0x00,
    0xc0, 0x04, 0x00,
    0xc0, 0x05, 0x00,
    0xc0, 0x04, 0x00,
    0xc0, 0x05, 0x00,
    0xc0, 0x04, 0x00,
    0xc0, 0x05, 0x00,
    0xc0, 0x04, 0x00,
    0xc0, 0x05, 0x00,
    0xc0, 0x04, 0x00,
    0xc0, 0x05, 0x00,
    0xc0, 0x04, 0x00,
    0xc0, 0x05, 0x00,
    0xc0, 0x04, 0x00,
    0xc0, 0x05, 0x00,
    0xc0, 0x04, 0x00,
    0xc0, 0x05, 0x00,
    0xc0, 0x04, 0x00,
    0xc0, 0x05, 0x00,
    0xc0, 0x04, 0x00,
    0xc0, 0x05, 0x00,
    0xc0, 0x04, 0x00,
    0xc0, 0x05, 0x00,
    0xc0, 0x04, 0x00,
    0x20, 0x04          /* 0x065: jump 0x004 */
};

static constexpr uint8_t data_shifter_b_coprocessed[] {
    0x00,               /* 0x000: waitt */
    0xc0, 0x05, 0x00,   /* 0x001: store 0x0005: set shB and clkSh */
    0xc0, 0x04, 0x00,   /* 0x004: store 0x0004: set shB, clear clkSh */
    0x20, 0x00          /* 0x007: jump 0x000 */
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

void Pmcc_programmer::load_data_shifter(Pm::Controller_mode mode, Pm::Counter counter) const
{
    if (mode == Pm::Controller_mode::accelerated) {
        if (counter == Pm::Counter::a) {
            pmc.load_pmcc_application(data_shifter_a_accelerated,
                (int)(sizeof(data_shifter_a_accelerated)));
        } else {
            pmc.load_pmcc_application(data_shifter_b_accelerated,
                (int)(sizeof(data_shifter_b_accelerated)));
        }
    } else if (mode == Pm::Controller_mode::coprocessed) {
        if (counter == Pm::Counter::a) {
            pmc.load_pmcc_application(data_shifter_a_coprocessed,
                (int)(sizeof(data_shifter_a_coprocessed)));
        } else {
            pmc.load_pmcc_application(data_shifter_b_coprocessed,
                (int)(sizeof(data_shifter_b_coprocessed)));
        }
    }
}

void Pmcc_programmer::load_config_latcher() const
{
    pmc.load_pmcc_application(pixels_configs_latcher, (int)(sizeof(pixels_configs_latcher)));
}

void Pmcc_programmer::load_hits_generator() const
{
    pmc.load_pmcc_application(hits_generator, (int)(sizeof(hits_generator)));
}