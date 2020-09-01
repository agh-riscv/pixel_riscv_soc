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

class Vmem_reader:
    def read_file(self, file_path):
        self.data = []
        with open(file_path, 'r') as vmem_file:
            mem_hexdump = [line for line in vmem_file.read().split('\n') if '@' in line]
        for line in mem_hexdump:
            self.data += [int(word, base=16) for word in line.split(' ') if '@' not in word]

    def get_file_content(self):
        return self.data

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print('usage: {} <vmem_file_path>'.format(sys.argv[0]))
        sys.exit()

    vmem_reader = Vmem_reader()
    vmem_reader.read_file(sys.argv[1])
    vmem_file_content = vmem_reader.get_file_content()
    for i in range(1, len(vmem_file_content)):
        print('0x{:03x}: 0x{:08x}'.format(i, vmem_file_content[i]))
    print('Memory size: {}'.format(len(vmem_file_content)))
