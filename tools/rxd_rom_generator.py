#!/usr/bin/python3
#
# Copyright (C) 2020  AGH University of Science and Technology
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

import sys
from rxd_modules.vmem_reader import Vmem_reader

def get_file_header():
    header = '''\
/**
 * Copyright (C) 2020  AGH University of Science and Technology
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

'''
    return header

def get_module_prologue(module_name):
    module_definition = '''\
module {} (
    output logic [31:0] rdata,
    input logic [31:0] addr
);

'''.format(module_name)
    return module_definition

def get_module_internal_logic(vmem_content, boot_rom):
    module_internal_logic = '''\
/**
 * Module internal logic
 */

always_comb begin
    case (addr[{}:2])
'''.format('11' if boot_rom else '13')

    for i in range(len(vmem_content)):
        module_internal_logic += '        {:4}:    rdata = 32\'h{:08x};\n'.format(i, vmem_content[i])

    module_internal_logic += '''\
        default: rdata = 32'h00000000;
    endcase
end
'''
    return module_internal_logic

def get_module_epilogue():
    module_epilogue = '''\
endmodule
'''
    return module_epilogue


if __name__ == '__main__':
    if len(sys.argv) < 4:
        print('usage: {} <module_name> <vmem_file_path> <rxd_rom_file_path>'.format(sys.argv[0]))
        sys.exit()

    module_name = sys.argv[1]
    vmem_file_path = sys.argv[2]
    rxd_rom_file_path = sys.argv[3]

    vmem_reader = Vmem_reader()

    vmem_reader.read_file(vmem_file_path)
    vmem_content = vmem_reader.get_file_content()

    rxd_rom_file_content = get_file_header()
    rxd_rom_file_content += get_module_prologue(module_name)
    rxd_rom_file_content += get_module_internal_logic(vmem_content, module_name == 'boot_rom')
    rxd_rom_file_content += get_module_epilogue()

    with open(rxd_rom_file_path, 'w') as rxd_rom_file:
        rxd_rom_file.write(rxd_rom_file_content)
