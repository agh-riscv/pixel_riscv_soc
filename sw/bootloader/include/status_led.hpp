#pragma once

#include <cstdint>

class Status_led final {
public:
    Status_led(uint8_t pin);
    Status_led(const Status_led &) = delete;
    Status_led(Status_led &&) = delete;
    Status_led &operator=(const Status_led &) = delete;
    Status_led &operator=(Status_led &&) = delete;

    void signalize_bootloader_start() const;
    void signalize_codeload_success() const;
    void signalize_codeload_failure() const;
    void signalize_bootloader_end() const;

private:
    uint8_t pin;
};
