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

package pixel_riscv_soc_pkg;


/**
 * Patterns used for address decoding (memory map)
 */

`define BOOT_ROM_ADDRESS_SPACE 32'h0000_0???                /* 0x0000_0000 - 0x0000_0FFF (4 kB) */
`define CODE_RAM_ADDRESS_SPACE {16'h0001, 4'b00??, 12'h???} /* 0x0001_0000 - 0x0001_3FFF (16 kB) */
`define DATA_RAM_ADDRESS_SPACE {16'h0010, 4'b00??, 12'h???} /* 0x0010_0000 - 0x0010_3FFF (16 kB) */
`define GPIO_ADDRESS_SPACE     32'h0100_0???                /* 0x0100_0000 - 0x0100_0FFF (4 kB) */
`define SPI_ADDRESS_SPACE      32'h0100_1???                /* 0x0100_1000 - 0x0100_1FFF (4 kB) */
`define UART_ADDRESS_SPACE     32'h0100_2???                /* 0x0100_2000 - 0x0100_2FFF (4 kb) */
`define TIMER_ADDRESS_SPACE    32'h0100_3???                /* 0x0100_3000 - 0x0100_3FFF (4 kb) */
`define PMC_ADDRESS_SPACE      32'h0101_????                /* 0x0101_0000 - 0x0101_FFFF (64 kb) */


/**
 * Interfaces-related macros
 */

/* Data bus */

`define data_bus_assign_inputs(bus) \
    assign bus.addr = data_bus.addr; \
    assign bus.we = data_bus.we; \
    assign bus.be = data_bus.be; \
    assign bus.wdata = data_bus.wdata;

`define data_bus_set_outputs(bus) \
    begin \
        data_bus.rvalid = bus.rvalid; \
        data_bus.err = bus.err; \
        data_bus.rdata = bus.rdata; \
    end

`define data_bus_set_gnt_and_req(bus) \
    begin \
        data_bus.gnt = bus.gnt; \
        bus.req = 1'b1; \
    end

/* Instruction bus */

`define instr_bus_assign_inputs(bus) \
    assign bus.addr = instr_bus.addr;

`define instr_bus_set_outputs(bus) \
    begin \
        instr_bus.rvalid = bus.rvalid; \
        instr_bus.err = bus.err; \
        instr_bus.rdata = bus.rdata; \
    end

`define instr_bus_set_gnt_and_req(bus) \
    begin \
        instr_bus.gnt = bus.gnt; \
        bus.req = 1'b1; \
    end


/**
 * User defined types
 */

typedef enum logic [1:0] {
    INSTR_BUS_BOOT_ROM,
    INSTR_BUS_CODE_RAM,
    INSTR_BUS_NONE
} instr_bus_slave_t;

typedef enum logic [3:0] {
    DATA_BUS_BOOT_ROM,
    DATA_BUS_CODE_RAM,
    DATA_BUS_DATA_RAM,
    DATA_BUS_GPIO,
    DATA_BUS_SPI,
    DATA_BUS_UART,
    DATA_BUS_TIMER,
    DATA_BUS_PMC,
    DATA_BUS_NONE
} data_bus_slave_t;

typedef struct packed {
    instr_bus_slave_t requested_slave;
    instr_bus_slave_t responding_slave;
} instr_bus_state_t;

typedef struct packed {
    data_bus_slave_t requested_slave;
    data_bus_slave_t responding_slave;
} data_bus_state_t;

endpackage
