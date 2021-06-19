#include "code_loader.h"
#include "gpio.h"
#include "uart.h"

static inline void update_trap_vector_base_address(void)
{
    asm volatile (
        "li    t0, 0x10000    \n"
        "csrrw t0, mtvec,  t0 \n"
    );
}

static inline void jump_to_loaded_software(void)
{
    asm ("j 0x10080");
}

int main()
{
    uart.write("bootloader started\n");

    if (gpio.get_codeload_skipping_pin()) {
        uart.write("codeload skipped\n");
    }
    else {
        Code_loader::Source codeload_source;
        if (gpio.get_codeload_source_pin()) {
            codeload_source = Code_loader::Source::uart;
            uart.write("codeload source: uart\n");
        }
        else {
            codeload_source = Code_loader::Source::spi;
            uart.write("codeload source: spi\n");
        }
        Code_loader::load_code(codeload_source);
        uart.write("codeload finished\n");
    }
    update_trap_vector_base_address();

    uart.write("bootloader finished\n");
    gpio.set_bootloader_finished_pin(true);
    jump_to_loaded_software();
}
