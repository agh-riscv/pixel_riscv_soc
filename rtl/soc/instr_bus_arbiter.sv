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

import memory_map::*;

module instr_bus_arbiter (
    input logic           clk,
    input logic           rst_n,

    ibex_instr_bus.slave  core_instr_bus,

    ibex_instr_bus.master boot_rom_instr_bus,
    ibex_instr_bus.master code_ram_instr_bus
);


/**
 * User defined types
 */

typedef enum logic [1:0] {
    IDLE,
    WAITING_FOR_GRANT,
    WAITING_FOR_RESPONSE
} state_t;

typedef enum logic [1:0] {
    BOOT_ROM,
    CODE_RAM,
    INCORRECT
} slave_t;


/**
 * Local variables and signals
 */

state_t state, state_nxt;
slave_t responding_slave, responding_slave_nxt;


/**
 * Tasks and functions definitions
 */

`define set_instr_bus_slave_active(bus) \
    bus.req = core_instr_bus.req; \
    bus.addr = core_instr_bus.addr

`define set_instr_bus_slave_inactive(bus) \
    bus.req = 1'b0; \
    bus.addr = 32'b0

`define attach_instr_bus_slave(bus) \
    core_instr_bus.gnt = bus.gnt; \
    core_instr_bus.rvalid = bus.rvalid; \
    core_instr_bus.rdata = bus.rdata; \
    core_instr_bus.rdata_intg = bus.rdata_intg; \
    core_instr_bus.err = bus.err


/**
 * Module internal logic
 */

/* state control */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        state <= IDLE;
    else
        state <= state_nxt;
end

always_comb begin
    state_nxt = state;

    case (state)
    IDLE: begin
        if (core_instr_bus.req)
            state_nxt = core_instr_bus.gnt ? WAITING_FOR_RESPONSE : WAITING_FOR_GRANT;
    end
    WAITING_FOR_GRANT: begin
        if (core_instr_bus.gnt)
            state_nxt = WAITING_FOR_RESPONSE;
    end
    WAITING_FOR_RESPONSE: begin
        if (core_instr_bus.rvalid)
            state_nxt = IDLE;
    end
    endcase
end

/* input signals demultiplexing */

always_comb begin
    `set_instr_bus_slave_inactive(boot_rom_instr_bus);
    `set_instr_bus_slave_inactive(code_ram_instr_bus);

    case (state)
    IDLE,
    WAITING_FOR_GRANT: begin
        if (core_instr_bus.req) begin
            case (core_instr_bus.addr) inside
            `BOOT_ROM_ADDRESS_SPACE: begin
                `set_instr_bus_slave_active(boot_rom_instr_bus);
            end
            `CODE_RAM_ADDRESS_SPACE: begin
                `set_instr_bus_slave_active(code_ram_instr_bus);
            end
            endcase
        end
    end
    WAITING_FOR_RESPONSE: ;
    endcase
end

/* output signals multiplexing */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        responding_slave <= INCORRECT;
    else
        responding_slave <= responding_slave_nxt;
end

always_comb begin
    responding_slave_nxt = responding_slave;
    core_instr_bus.gnt = 1'b0;
    core_instr_bus.rvalid = 1'b0;
    core_instr_bus.rdata = 32'b0;
    core_instr_bus.rdata_intg = 7'b0;
    core_instr_bus.err = 1'b0;

    case (state)
    IDLE: begin
        if (core_instr_bus.req) begin
            case (core_instr_bus.addr) inside
            `BOOT_ROM_ADDRESS_SPACE: begin
                responding_slave_nxt = BOOT_ROM;
                `attach_instr_bus_slave(boot_rom_instr_bus);
            end
            `CODE_RAM_ADDRESS_SPACE: begin
                responding_slave_nxt = CODE_RAM;
                `attach_instr_bus_slave(code_ram_instr_bus);
            end
            default: begin
                responding_slave_nxt = INCORRECT;
                core_instr_bus.gnt = 1'b1;
            end
            endcase
        end
    end
    WAITING_FOR_GRANT: begin
        case (responding_slave)
        BOOT_ROM: begin
            `attach_instr_bus_slave(boot_rom_instr_bus);
        end
        CODE_RAM: begin
            `attach_instr_bus_slave(code_ram_instr_bus);
        end
        INCORRECT: begin
            core_instr_bus.gnt = 1'b1;
        end
        endcase
    end
    WAITING_FOR_RESPONSE: begin
        case (responding_slave)
        BOOT_ROM: begin
            `attach_instr_bus_slave(boot_rom_instr_bus);
        end
        CODE_RAM: begin
            `attach_instr_bus_slave(code_ram_instr_bus);
        end
        INCORRECT: begin
            core_instr_bus.rvalid = 1'b1;
            core_instr_bus.err = 1'b1;
        end
        endcase
    end
    endcase
end

endmodule
