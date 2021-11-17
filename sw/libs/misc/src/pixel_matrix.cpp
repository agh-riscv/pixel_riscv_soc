#include "pixel_matrix.h"
#include <cstring>
#include "pmc.h"

Pixel_matrix pixel_matrix;

void Pixel_matrix::calibrate() const
{
    struct Config {
        uint16_t a;
        uint16_t b;
        uint16_t counts;
    };

    std::array<std::array<Config, Pixel_matrix::cols>, Pixel_matrix::rows> configs;
    std::memset((void *)configs[0].data(), 0, sizeof(configs));

    for (int config_a = 0; config_a < rows; ++config_a) {
        for (int config_b = 0; config_b < cols; ++config_b) {
            write_counters(Counter::a, config_a);
            write_counters(Counter::b, config_b);
            latch_configs();

            const auto readout = read(Counter::a);
            for (int row = 0; row < rows; ++row) {
                for (int col = 0; col < cols; ++col) {
                    if (readout[row][col] > configs[row][col].counts) {
                        configs[row][col].a = config_a;
                        configs[row][col].b = config_b;
                        configs[row][col].counts = readout[row][col];
                    }
                }
            }
        }
    }

    std::array<std::array<uint16_t, Pixel_matrix::cols>, Pixel_matrix::rows> configs_a, configs_b;
    for (int row = 0; row < rows; ++row) {
        for (int col = 0; col < cols; ++col) {
            configs_a[row][col] = configs[row][col].a;
            configs_b[row][col] = configs[row][col].b;
        }
    }
    load_configs(Counter::a, configs_a);
    load_configs(Counter::b, configs_b);
}

std::array<std::array<uint16_t, Pixel_matrix::cols>, Pixel_matrix::rows>
Pixel_matrix::read(const Counter counter) const
{
    pmc.get_pmcc().load_hits_generator();
    pmc.get_pmcc().trigger();
    return read_counters(counter);
}

std::array<std::array<uint16_t, Pixel_matrix::cols>, Pixel_matrix::rows>
Pixel_matrix::read_counters(const Counter counter) const
{
    if (counter == Counter::a)
        pmc.get_pmcc().load_data_shifter(Pmcc::Counter::a);
    else
        pmc.get_pmcc().load_data_shifter(Pmcc::Counter::b);
    pmc.get_pmcc().trigger();
    while (!pmc.get_pmcc().is_waiting_for_trigger()) { }

    std::array<std::array<uint16_t, cols>, rows> data;
    for (int row = rows - 1; row >= 0; --row) {
        pmc.get_pmcc().trigger();
        while (!pmc.get_pmcc().is_waiting_for_trigger()) { }
        pmc.get_din(data[row]);
    }
    return data;
}

void Pixel_matrix::load_configs(const Counter counter, const uint16_t config) const
{
    write_counters(counter, config);
    latch_configs();
}

void Pixel_matrix::load_configs(const Counter counter,
    const std::array<std::array<uint16_t, cols>, rows> &configs) const
{
    write_counters(counter, configs);
    latch_configs();
}

void Pixel_matrix::write_counters(const Counter counter, const uint16_t value) const
{
    std::array<uint16_t, 32> wdata;
    std::fill(begin(wdata), end(wdata), value);
    pmc.set_dout(wdata);

    if (counter == Counter::a)
        pmc.get_pmcc().load_data_shifter(Pmcc::Counter::a);
    else
        pmc.get_pmcc().load_data_shifter(Pmcc::Counter::b);
    pmc.get_pmcc().trigger();
    while (!pmc.get_pmcc().is_waiting_for_trigger()) { }

    for (int row = rows - 1; row >= 0; --row) {
        pmc.get_pmcc().trigger();
        while (!pmc.get_pmcc().is_waiting_for_trigger()) { }
    }
}

void Pixel_matrix::write_counters(const Counter counter,
    const std::array<std::array<uint16_t, cols>, rows> &data) const
{
    if (counter == Counter::a)
        pmc.get_pmcc().load_data_shifter(Pmcc::Counter::a);
    else
        pmc.get_pmcc().load_data_shifter(Pmcc::Counter::b);
    pmc.get_pmcc().trigger();
    while (!pmc.get_pmcc().is_waiting_for_trigger()) { }

    for (int row = rows - 1; row >= 0; --row) {
        pmc.set_dout(data[row]);
        pmc.get_pmcc().trigger();
        while (!pmc.get_pmcc().is_waiting_for_trigger()) { }
    }
}

void Pixel_matrix::latch_configs() const
{
    pmc.get_pmcc().load_config_latcher();
    pmc.get_pmcc().trigger();
}
