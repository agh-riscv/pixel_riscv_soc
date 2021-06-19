#!/usr/bin/python3
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
    @staticmethod
    def read_file(file_path):
        file_content = []
        with open(file_path, 'r') as vmem_file:
            mem_hexdump = [line for line in vmem_file.read().split('\n') if '@' in line]
        for line in mem_hexdump:
            file_content += [int(word, base=16) for word in line.split(' ') if '@' not in word]
        return file_content

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print('usage: {} <vmem_file_path>'.format(sys.argv[0]))
        sys.exit()

    file_content = Vmem_reader.read_file(sys.argv[1])
    for i in range(1, len(file_content)):
        print('0x{:03x}: 0x{:08x}'.format(i, file_content[i]))
    print('vmem size: {} words'.format(len(file_content)))
