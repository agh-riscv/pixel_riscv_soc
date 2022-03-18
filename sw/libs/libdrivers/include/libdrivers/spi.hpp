#pragma once

#include <cstdint>

class Spi final {
public:
    enum class Phase : bool { leading_captures, trailing_captures };
    enum class Polarity : bool { idle_low, idle_high };

    Spi(uint32_t base_address);
    Spi(const Spi &) = delete;
    Spi(Spi &&) = delete;
    Spi &operator=(const Spi &) = delete;
    Spi &operator=(Spi &&) = delete;

    void init() const;

    void set_active_slave(uint8_t active_slave) const;
    void set_phase(Phase phase) const;
    void set_polarity(Polarity polarity) const;
    void set_clock_divider(uint8_t val) const;

    uint8_t read() const;
    void write(uint8_t val) const;
    void write(const uint8_t *buf, int len) const;
    void write_sync(const uint8_t *buf, int len) const;

    void enable_transmitter_interrupts() const;
    void disable_transmitter_interrupts() const;
    bool is_transmitter_interrupt_pending() const;
    void clear_transmitter_interrupt() const;

private:
    volatile uint32_t * const regs;

    void set_wdata(uint8_t val) const;
    uint8_t get_rdata() const;
    bool is_receiver_fifo_empty() const;
    bool is_transmitter_fifo_full() const;
    bool is_transmitter_fifo_empty() const;
    void flush() const;
};

extern Spi spi;
