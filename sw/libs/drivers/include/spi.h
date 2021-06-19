#pragma once

#include "spi_cdr.h"
#include "spi_cr.h"
#include "spi_rdr.h"
#include "spi_sr.h"
#include "spi_tdr.h"

class Spi final {
public:
    enum class Phase : bool { leading_captures, trailing_captures };
    enum class Polarity : bool { idle_low, idle_high };

    Spi(const uint32_t base_address);
    Spi(const Spi &) = delete;
    Spi(Spi &&) = delete;
    Spi &operator=(const Spi &) = delete;
    Spi &operator=(Spi &&) = delete;

    void set_phase(const Phase phase) const volatile;
    void set_polarity(const Polarity polarity) const volatile;
    void set_clock_divider(const uint8_t divider) const volatile;
    uint8_t read(void) const volatile;
    void write(const uint8_t byte) const volatile;

private:
    volatile Spi_cr * const cr;
    volatile Spi_sr * const sr;
    volatile Spi_tdr * const tdr;
    volatile Spi_rdr * const rdr;
    volatile Spi_cdr * const cdr;

    bool is_receiver_ready() const volatile;
    bool is_transmitter_active() const volatile;
};

extern Spi spi;
