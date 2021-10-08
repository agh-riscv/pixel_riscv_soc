#include "command_interpreter.h"
#include "ui.h"

int main()
{
    ui << "command_interpreter started\n";
    Command_interpreter command_interpreter;
    command_interpreter.run();
}
