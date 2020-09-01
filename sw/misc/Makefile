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

.PHONY: asic fpga sim clean

SRCS = \
    src/debug_lib.c \
    src/delay.c \
    src/pm.c \
    src/pmcc.c \
    src/string_lib.c

CFLAGS ?= -march=rv32imcb -mabi=ilp32 -mcmodel=medany -nostdlib -fvisibility=hidden -Os \
    -Wall -Wextra -Werror

default: clean libmisc.a

asic: CFLAGS += -DASIC=1
asic: clean libmisc.a

fpga: CFLAGS += -DFPGA=1
fpga: clean libmisc.a

sim: CFLAGS += -DSIM=1
sim: clean libmisc.a

libmisc.a: ${SRCS:.c=.o}
	riscv32-unknown-elf-ar rcs libmisc.a ${SRCS:.c=.o}

%.o: %.c
	riscv32-unknown-elf-gcc -c $(CFLAGS) -Iinclude -I../drivers/include -o $@ $<

clean:
	$(RM) *.a src/*.{d,o}
