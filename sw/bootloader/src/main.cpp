#include "code_loader.h"
#include "gpio.h"
#include "status_led.h"
#include "ui.h"

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
    ui << "INFO: bootloader started\n";
    Status_led::signalize_bootloader_start();

    if (gpio.get_codeload_skipping_pin()) {
        ui << "INFO: codeload skipped\n";
    } else {
        if (gpio.get_codeload_source_pin()) {
            ui << "INFO: codeload source: uart\n";
            if (Code_loader::load_code_through_uart()) {
                ui << "ERROR: codeload timeout occurred\n";
                Status_led::signalize_codeload_failure();
            }
        } else {
            ui << "INFO: codeload source: spi\n";
            Code_loader::load_code_through_spi();
        }

        ui << "INFO: codeload finished\n";
        Status_led::signalize_codeload_success();
    }

    update_trap_vector_base_address();
    ui << "INFO: bootloader finished\n";
    Status_led::signalize_bootloader_end();

    jump_to_loaded_software();
}
