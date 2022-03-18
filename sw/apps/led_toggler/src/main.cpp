#include <libdrivers/core.hpp>
#include <libdrivers/gpio.hpp>
#include <libdrivers/timer.hpp>
#include <libmisc/ui.hpp>

int main()
{
    ui << "led_toggler started\n";

    gpio.set_pin_direction(0, Gpio::Direction::out);
    gpio.set_pin(0, false);

    core.enable_timer_interrupts([](){
        gpio.toggle_pin(0);
        timer.clear_matched();
        timer.clear_interrupt();
    });
    core.enable_interrupts();

    timer.set_cmpr(49'999'999);
    timer.enable_interrupts();
    timer.enable();
    while (1) { }
}
