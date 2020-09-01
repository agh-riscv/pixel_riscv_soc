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

.section .vectors, "ax"
.option norvc;

.org  0x00
.rept 32
    jal     x0,     default_exc_handler
.endr

/* reset vector */
.org  0x80
    jal     x0,     reset_handler

/* illegal instruction exception */
.org  0x84
    jal     x0,     default_exc_handler

/* ecall handler */
.org  0x88
    jal     x0,     default_exc_handler


.section .text

default_exc_handler:
    jal     x0,     default_exc_handler

reset_handler:
/* set all registers to zero (x0 is hardwired to zero) */
    mv      x1,     x0
    mv      x2,     x0
    mv      x3,     x0
    mv      x4,     x0
    mv      x5,     x0
    mv      x6,     x0
    mv      x7,     x0
    mv      x8,     x0
    mv      x9,     x0
    mv      x10,    x0
    mv      x11,    x0
    mv      x12,    x0
    mv      x13,    x0
    mv      x14,    x0
    mv      x15,    x0
    mv      x16,    x0
    mv      x17,    x0
    mv      x18,    x0
    mv      x19,    x0
    mv      x20,    x0
    mv      x21,    x0
    mv      x22,    x0
    mv      x23,    x0
    mv      x24,    x0
    mv      x25,    x0
    mv      x26,    x0
    mv      x27,    x0
    mv      x28,    x0
    mv      x29,    x0
    mv      x30,    x0
    mv      x31,    x0

/* stack initilization */
    la      sp,     _stack_start

/* BSS clearing */
    la      t0,     _bss_start
    la      t1,     _bss_end

    bge     t0,     t1,     bss_clear_loop_end
bss_clear_loop:
    sw      x0,     0(t0)
    addi    t0,     t0,     4
    ble     t0,     t1,     bss_clear_loop
bss_clear_loop_end:

/* data initilization */
    la      t0,     _sidata
    la      t1,     _sdata
    la      t2,     _edata

    bge     t1,     t2,     data_init_loop_end
data_init_loop:
    lw      t3,     0(t0)
    sw      t3,     0(t1)
    addi    t0,     t0,     4
    addi    t1,     t1,     4
    ble     t1,     t2,     data_init_loop
data_init_loop_end:

/* jump to main program entry point (argc = argv = 0) */
main_entry:
    addi    a0,     x0,     0
    addi    a1,     x0,     0
    jal     x1,     main
