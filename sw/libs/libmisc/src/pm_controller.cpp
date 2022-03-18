#include <pm_controller.hpp>
#include <cstring>
#include <pmcc_programmer.hpp>
#include <libdrivers/pmc.hpp>
#include <libdrivers/uart.hpp>

#define is_bit_set(word, bit) \
({ \
    word & 1<<bit; \
})

#define set_bit(word, bit) \
({ \
    word |= 1<<bit; \
})

#define clear_bit(word, bit) \
({ \
    word &= ~(1<<bit); \
})

Pm_controller pm_controller;

void Pm_controller::init(Pm::Controller_mode mode)
{
    this->mode = mode;

    switch (mode) {
    case Pm::Controller_mode::accelerated:
        pmc.set_ctrl_mode(Pmc::Ctrl_mode::coprocessed);
        pmc.set_data_mode(Pmc::Data_mode::accelerated);
        break;
    case Pm::Controller_mode::coprocessed:
        pmc.set_ctrl_mode(Pmc::Ctrl_mode::coprocessed);
        pmc.set_data_mode(Pmc::Data_mode::direct);
        break;
    case Pm::Controller_mode::direct:
        pmc.set_ctrl_mode(Pmc::Ctrl_mode::direct);
        pmc.set_data_mode(Pmc::Data_mode::direct);
        pmc.set_ctrl(0x0000);
        break;
    }
}

void Pm_controller::calibrate() const
{
    struct Config {
        uint16_t a;
        uint16_t b;
        uint16_t counts;
    };

    std::array<std::array<Config, Pm::cols>, Pm::cols> configs;
    std::memset((void *)configs[0].data(), 0, sizeof(configs));

    for (int config_a = 0; config_a < 8; ++config_a) {
        for (int config_b = 0; config_b < 8; ++config_b) {
            write_counters(Pm::Counter::a, config_a);
            write_counters(Pm::Counter::b, config_b);
            latch_configs();

            open_gate();
            const auto readout = read(Pm::Counter::a);
            for (int row = 0; row < Pm::rows; ++row) {
                for (int col = 0; col < Pm::cols; ++col) {
                    if (readout[row][col] > configs[row][col].counts) {
                        configs[row][col].a = config_a;
                        configs[row][col].b = config_b;
                        configs[row][col].counts = readout[row][col];
                    }
                }
            }
        }
    }

    Pm::Counters configs_a, configs_b;
    for (int row = 0; row < Pm::rows; ++row) {
        for (int col = 0; col < Pm::cols; ++col) {
            configs_a[row][col] = configs[row][col].a;
            configs_b[row][col] = configs[row][col].b;
        }
    }
    write_counters(Pm::Counter::a, configs_a);
    write_counters(Pm::Counter::b, configs_b);
    latch_configs();
}

Pm::Counters Pm_controller::read(Pm::Counter counter) const
{
    return read_counters(counter);
}

void Pm_controller::write(Pm::Counter counter, uint16_t val) const
{
    write_counters(counter, val);
}

void Pm_controller::write(Pm::Counter counter, const Pm::Counters &data) const
{
    write_counters(counter, data);
}

void Pm_controller::open_gate() const
{
    if (mode == Pm::Controller_mode::accelerated || mode == Pm::Controller_mode::coprocessed) {
        pmcc_programmer.load_hits_generator();
        pmc.trigger_pmcc();
    } else {
        pmc.set_ctrl(0x0008);
        pmc.set_ctrl(0x0000);
    }
}
void Pm_controller::latch_configs() const
{
    if (mode == Pm::Controller_mode::accelerated || mode == Pm::Controller_mode::coprocessed) {
        pmcc_programmer.load_config_latcher();
        pmc.trigger_pmcc();
    } else {
        pmc.set_ctrl(0x0020);
        pmc.set_ctrl(0x0000);
    }
}

Pm::Counters Pm_controller::read_counters(Pm::Counter counter) const
{
    Pm::Counters data;

    if (mode == Pm::Controller_mode::accelerated) {
        pmcc_programmer.load_data_shifter(mode, counter);
        pmc.trigger_pmcc();
        while (!pmc.is_pmcc_waiting_for_trigger()) { }

        for (int row = Pm::rows - 1; row >= 0; --row) {
            pmc.trigger_pmcc();
            while (!pmc.is_pmcc_waiting_for_trigger()) { }
            pmc.get_din(data[row]);
        }
    } else if (mode == Pm::Controller_mode::coprocessed) {
        pmcc_programmer.load_data_shifter(mode, counter);

        for (int row = Pm::rows - 1; row >= 0; --row) {
            for (int bit = Pm::bits - 1; bit >= 0; --bit) {
                const uint32_t dout{pmc.get_din()};
                for (int col = 0; col < Pm::cols; ++col) {
                    if (is_bit_set(dout, col))
                        set_bit(data[row][col], bit);
                    else
                        clear_bit(data[row][col], bit);
                }
                while (!pmc.is_pmcc_waiting_for_trigger()) { }
                pmc.trigger_pmcc();
            }
        }
    } else {
        pmc.set_ctrl(counter == Pm::Counter::a ? 0x02 : 0x04);

        for (int row = Pm::rows - 1; row >= 0; --row) {
            for (int bit = Pm::bits - 1; bit >= 0; --bit) {
                const uint32_t dout{pmc.get_din()};
                for (int col = 0; col < Pm::cols; ++col) {
                    if (is_bit_set(dout, col))
                        set_bit(data[row][col], bit);
                    else
                        clear_bit(data[row][col], bit);
                }

                if (counter == Pm::Counter::a) {
                    pmc.set_ctrl(0x0003);
                    pmc.set_ctrl(0x0002);
                } else {
                    pmc.set_ctrl(0x0005);
                    pmc.set_ctrl(0x0004);
                }
            }
        }
    }
    return data;
}

void Pm_controller::write_counters(Pm::Counter counter, uint16_t val) const
{
    if (mode == Pm::Controller_mode::accelerated) {
        std::array<uint16_t, 32> wdata;
        std::fill(begin(wdata), end(wdata), val);
        pmc.set_dout(wdata);

        pmcc_programmer.load_data_shifter(mode, counter);
        pmc.trigger_pmcc();
        while (!pmc.is_pmcc_waiting_for_trigger()) { }

        for (int row = Pm::rows - 1; row >= 0; --row) {
            pmc.trigger_pmcc();
            while (!pmc.is_pmcc_waiting_for_trigger()) { }
        }
    } else if (mode == Pm::Controller_mode::coprocessed) {
        pmcc_programmer.load_data_shifter(mode, counter);

        for (int row = Pm::rows - 1; row >= 0; --row) {
            for (int bit = Pm::bits - 1; bit >= 0; --bit) {
                uint32_t din{0};
                for (int col = 0; col < Pm::cols; ++col) {
                    if (is_bit_set(val, bit))
                        set_bit(din, col);
                    else
                        clear_bit(din, col);
                }
                pmc.set_dout(din);
                while (!pmc.is_pmcc_waiting_for_trigger()) { }
                pmc.trigger_pmcc();
            }
        }
    } else {
        for (int row = Pm::rows - 1; row >= 0; --row) {
            for (int bit = Pm::bits - 1; bit >= 0; --bit) {
                uint32_t din{0};
                for (int col = 0; col < Pm::cols; ++col) {
                    if (is_bit_set(val, bit))
                        set_bit(din, col);
                    else
                        clear_bit(din, col);
                }
                pmc.set_dout(din);

                if (counter == Pm::Counter::a) {
                    pmc.set_ctrl(0x0003);
                    pmc.set_ctrl(0x0002);
                } else {
                    pmc.set_ctrl(0x0005);
                    pmc.set_ctrl(0x0004);
                }
            }
        }
    }
}

void Pm_controller::write_counters(Pm::Counter counter, const Pm::Counters &data) const
{
    if (mode == Pm::Controller_mode::accelerated) {
        pmcc_programmer.load_data_shifter(mode, counter);
        pmc.trigger_pmcc();
        while (!pmc.is_pmcc_waiting_for_trigger()) { }

        for (int row = Pm::rows - 1; row >= 0; --row) {
            pmc.set_dout(data[row]);
            pmc.trigger_pmcc();
            while (!pmc.is_pmcc_waiting_for_trigger()) { }
        }
    } else if (mode == Pm::Controller_mode::coprocessed) {
        pmcc_programmer.load_data_shifter(mode, counter);

        for (int row = Pm::rows - 1; row >= 0; --row) {
            for (int bit = Pm::bits - 1; bit >= 0; --bit) {
                uint32_t din{0};
                for (int col = 0; col < Pm::cols; ++col) {
                    if (is_bit_set(data[row][col], bit))
                        set_bit(din, col);
                    else
                        clear_bit(din, col);
                }
                pmc.set_dout(din);
                while (!pmc.is_pmcc_waiting_for_trigger()) { }
                pmc.trigger_pmcc();
            }
        }
    } else {
        for (int row = Pm::rows - 1; row >= 0; --row) {
            for (int bit = Pm::bits - 1; bit >= 0; --bit) {
                uint32_t din{0};
                for (int col = 0; col < Pm::cols; ++col) {
                    if (is_bit_set(data[row][col], bit))
                        set_bit(din, col);
                    else
                        clear_bit(din, col);
                }
                pmc.set_dout(din);

                if (counter == Pm::Counter::a) {
                    pmc.set_ctrl(0x0002);
                    pmc.set_ctrl(0x0003);
                    pmc.set_ctrl(0x0002);
                } else {
                    pmc.set_ctrl(0x0004);
                    pmc.set_ctrl(0x0005);
                    pmc.set_ctrl(0x0004);
                }
            }
        }
    }
}
