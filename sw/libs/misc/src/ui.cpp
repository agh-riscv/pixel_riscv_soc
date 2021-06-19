#include "ui.h"
#include "string_ops.h"
#include "uart.h"

int Ui::get_integer(const char *parameter_name)
{
    while (true) {
        uart.write(parameter_name);
        uart.write(": ");

        char buf[100];
        uart.read(buf, sizeof(buf));
        if (is_number(buf))
            return to_int(buf);
        else
            uart.write("incorrect value. try again\n");
    }
    return 0;
}
