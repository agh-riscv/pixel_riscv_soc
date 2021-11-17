#pragma once

class Status_led final {
public:
    Status_led() = delete;
    Status_led(const Status_led &) = delete;
    Status_led(Status_led &&) = delete;
    Status_led &operator=(const Status_led &) = delete;
    Status_led &operator=(Status_led &&) = delete;

    static void signalize_bootloader_start();
    static void signalize_codeload_success();
    static void signalize_codeload_failure();
    static void signalize_bootloader_end();
};
