#include <command_interpreter.hpp>
#include <libmisc/ui.hpp>

int main()
{
    ui << "command_interpreter started\n";
    Command_interpreter command_interpreter;
    command_interpreter.run();
}
