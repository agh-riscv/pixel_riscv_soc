#include "status_led.h"
#include "delay.h"
#include "gpio.h"

void Status_led::signalize_bootloader_start()
{
    mdelay(250);
    gpio.set_bootloader_status_pin(true);
    mdelay(250);
    gpio.set_bootloader_status_pin(false);
    mdelay(250);
}

void Status_led::signalize_codeload_success()
{
    mdelay(250);
    for (int i = 0; i < 2; ++i) {
        gpio.set_bootloader_status_pin(true);
        mdelay(250);
        gpio.set_bootloader_status_pin(false);
        mdelay(250);
    }
    mdelay(250);
}

void Status_led::signalize_codeload_failure()
{
    mdelay(250);
    while (true) {
        gpio.set_bootloader_status_pin(true);
        mdelay(250);
        gpio.set_bootloader_status_pin(false);
        mdelay(250);
    }
}

void Status_led::signalize_bootloader_end()
{
    mdelay(250);
    gpio.set_bootloader_status_pin(true);
}
