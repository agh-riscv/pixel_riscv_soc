#pragma once

#include <cstdint>

class Gpio final {
public:
    enum class Direction {out, in};

    Gpio(uint32_t base_address);
    Gpio(const Gpio &) = delete;
    Gpio(Gpio &&) = delete;
    Gpio &operator=(const Gpio &) = delete;
    Gpio &operator=(Gpio &&) = delete;

    void set_pin_direction(uint8_t pin, Direction direction) const;
    Direction get_pin_direction(uint8_t pin) const;

    void set_pin(uint8_t pin, bool val) const;
    bool get_pin(uint8_t pin) const;
    void toggle_pin(uint8_t pin) const;

    void enable_rising_edge_interrupts(uint8_t pin) const;
    void disable_rising_edge_interrupts(uint8_t pin) const;
    bool is_rising_edge_interrupt_pending(uint8_t pin) const;
    void clear_rising_edge_interrupt(uint8_t pin) const;

    void enable_falling_edge_interrupts(uint8_t pin) const;
    void disable_falling_edge_interrupts(uint8_t pin) const;
    bool is_falling_edge_interrupt_pending(uint8_t pin) const;
    void clear_falling_edge_interrupt(uint8_t pin) const;

private:
    volatile uint32_t * const regs;
};

extern Gpio gpio;
