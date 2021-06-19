#include "command_interpreter.h"
#include "uart.h"

int main()
{
    uart.write("application started\n");
    Command_interpreter command_interpreter;
    command_interpreter.run();
}
