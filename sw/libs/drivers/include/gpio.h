#pragma once

#include <cstdint>

class Gpio final {
public:
    Gpio(const uint32_t base_address);
    Gpio(const Gpio &) = delete;
    Gpio(Gpio &&) = delete;
    Gpio &operator=(const Gpio &) = delete;
    Gpio &operator=(Gpio &&) = delete;

    void set_ier(const uint32_t ier) const volatile { *this->ier = ier; };
    void set_isr(const uint32_t isr) const volatile { *this->isr = isr; };
    uint32_t get_isr() const volatile { return *isr; };
    void set_rier(const uint32_t rier) const volatile { *this->rier = rier; };
    void set_fier(const uint32_t fier) const volatile { *this->fier = fier; };

    void set_pin(const uint8_t pin, const bool value) const volatile;
    bool get_pin(const uint8_t pin) const volatile;
    void toggle_pin(const uint8_t pin) const volatile;
    void set_mask_bits(const uint32_t mask, const uint32_t bits) const volatile;

    bool get_codeload_skipping_pin() const volatile;
    bool get_codeload_source_pin() const volatile;
    void set_bootloader_finished_pin(const bool value) const volatile;

private:
    volatile uint32_t * const cr;
    volatile uint32_t * const sr;
    volatile uint32_t * const odr;
    volatile uint32_t * const idr;
    volatile uint32_t * const ier;
    volatile uint32_t * const isr;
    volatile uint32_t * const rier;
    volatile uint32_t * const fier;
};

extern Gpio gpio;
