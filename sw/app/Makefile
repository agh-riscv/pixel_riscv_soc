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
    src/main.c

CRT = \
    src/crt0.S

LD = \
    link.ld

INCS = \
    -Iinclude \
    -I../drivers/include \
    -I../misc/include

LIBS = \
    ../drivers/libdrivers.a \
    ../misc/libmisc.a

OBJS = \
    ${SRCS:.c=.o} \
    ${CRT:.S=.o}

CFLAGS ?= -march=rv32imcb -mabi=ilp32 -mcmodel=medany -nostdlib -fvisibility=hidden -Os \
    -Wall -Wextra -Werror
export CFLAGS

asic: CFLAGS += -DASIC=1
asic: clean app

fpga: CFLAGS += -DFPGA=1
fpga: clean app

sim: CFLAGS += -DSIM=1
sim: clean app

app: app.vmem app.dis

app.vmem: app.bin
	srec_cat $^ -binary -fill 0x00 --within $^ -binary --range-padding 4 -offset 0x0000 -byte-swap 4 -o $@ -vmem

app.bin: app.elf
	riscv32-unknown-elf-objcopy -O binary $^ $@

app.dis: app.elf
	riscv32-unknown-elf-objdump -SD app.elf > $@

app.elf: libdrivers.a libmisc.a $(OBJS)
	riscv32-unknown-elf-gcc $(CFLAGS) -T $(LD) $(OBJS) $(LIBS) -o $@

%.o: %.c
	riscv32-unknown-elf-gcc -c $(CFLAGS) $(INCS) -o $@ $<

%.o: %.S
	riscv32-unknown-elf-gcc -c $(CFLAGS) -o $@ $<

libdrivers.a:
	$(MAKE) -C ../drivers

libmisc.a:
	$(MAKE) -C ../misc

clean:
	$(RM) *.{bin,dis,elf,vmem} src/*.{d,o}
	$(MAKE) -C ../drivers clean
	$(MAKE) -C ../misc clean
