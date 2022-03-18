#include <code_loader.hpp>
#include <status_led.hpp>
#include <libdrivers/common.hpp>
#include <libdrivers/gpio.hpp>
#include <libdrivers/spi.hpp>
#include <libdrivers/uart.hpp>
#include <libmisc/ui.hpp>

static inline void update_trap_vector_base_address()
{
    asm volatile (
        "li    t0, 0x10000    \n"
        "csrrw t0, mtvec,  t0 \n"
    );
}

static inline void jump_to_loaded_software()
{
    asm ("j 0x10080");
}

int main()
{
    spi.init();
    uart.init();

    ui << "INFO: bootloader started\n";

    Status_led status_led{gpio26_spi_ss1_pin};
    status_led.signalize_bootloader_start();

    if (gpio.get_pin(gpio23_pmc_gate_pin)) {
        ui << "INFO: codeload skipped\n";
    } else {
        Code_loader code_loader;

        if (gpio.get_pin(gpio24_pmc_strobe_pin)) {
            ui << "INFO: codeload source: uart\n";

            if (const auto err = code_loader.load_code_through_uart(); err) {
                ui << "ERROR: codeload timeout occurred. received bytes: " << err << "\n";
                status_led.signalize_codeload_failure();
            }
        } else {
            ui << "INFO: codeload source: spi\n";
            code_loader.load_code_through_spi();
        }

        ui << "INFO: codeload finished\n";
        status_led.signalize_codeload_success();
    }

    update_trap_vector_base_address();
    ui << "INFO: bootloader finished\n";
    ui.flush();
    status_led.signalize_bootloader_end();

    jump_to_loaded_software();
}
