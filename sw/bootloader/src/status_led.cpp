#include <status_led.hpp>
#include <libdrivers/gpio.hpp>
#include <libmisc/delay.hpp>

Status_led::Status_led(uint8_t pin)
    :   pin{pin}
{
    gpio.set_pin_direction(pin, Gpio::Direction::out);
}

void Status_led::signalize_bootloader_start() const
{
    mdelay(250);
    gpio.set_pin(pin, true);
    mdelay(250);
    gpio.set_pin(pin, false);
    mdelay(250);
}

void Status_led::signalize_codeload_success() const
{
    mdelay(250);
    for (int i = 0; i < 2; ++i) {
        gpio.set_pin(pin, true);
        mdelay(250);
        gpio.set_pin(pin, false);
        mdelay(250);
    }
    mdelay(250);
}

void Status_led::signalize_codeload_failure() const
{
    mdelay(250);
    while (true) {
        gpio.set_pin(pin, true);
        mdelay(250);
        gpio.set_pin(pin, false);
        mdelay(250);
    }
}

void Status_led::signalize_bootloader_end() const
{
    mdelay(250);
    gpio.set_pin(pin, true);
}
