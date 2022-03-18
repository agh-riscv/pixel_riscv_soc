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


/**
 * Local variables and signals
 */

state_t      state, state_nxt;
logic [31:0] requested_addr, requested_addr_nxt;


/**
 * Tasks and functions definitions
 */

`define attach_core_instr_bus_to_slave(bus) \
    bus.req = core_instr_bus.req; \
    bus.addr = core_instr_bus.addr

`define attach_zeros_to_slave_instr_bus(bus) \
    bus.req = 1'b0; \
    bus.addr = 32'b0

`define attach_slave_instr_bus_to_core(bus) \
    core_instr_bus.gnt = bus.gnt; \
    core_instr_bus.rvalid = bus.rvalid; \
    core_instr_bus.rdata = bus.rdata; \
    core_instr_bus.rdata_intg = bus.rdata_intg; \
    core_instr_bus.err = bus.err

function automatic logic is_address_valid(logic [31:0] address);
    return address inside {
        [BOOT_ROM_BASE_ADDRESS:BOOT_ROM_END_ADDRESS],
        [CODE_RAM_BASE_ADDRESS:CODE_RAM_END_ADDRESS]
    };
endfunction


/**
 * Properties and assertions
 */

assert property (@(negedge clk) core_instr_bus.req |-> is_address_valid(core_instr_bus.addr)) else
    $warning("incorrect address requested: 0x%x", core_instr_bus.addr);


/**
 * Module internal logic
 */

/* core state control */

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

/* core input signals demultiplexing */

always_comb begin
    `attach_zeros_to_slave_instr_bus(boot_rom_instr_bus);
    `attach_zeros_to_slave_instr_bus(code_ram_instr_bus);

    case (state)
    IDLE,
    WAITING_FOR_GRANT: begin
        if (core_instr_bus.req) begin
            case (core_instr_bus.addr) inside
            [BOOT_ROM_BASE_ADDRESS:BOOT_ROM_END_ADDRESS]: begin
                `attach_core_instr_bus_to_slave(boot_rom_instr_bus);
            end
            [CODE_RAM_BASE_ADDRESS:CODE_RAM_END_ADDRESS]: begin
                `attach_core_instr_bus_to_slave(code_ram_instr_bus);
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
        requested_addr <= 32'b0;
    else
        requested_addr <= requested_addr_nxt;
end

always_comb begin
    requested_addr_nxt = requested_addr;
    core_instr_bus.gnt = 1'b0;
    core_instr_bus.rvalid = 1'b0;
    core_instr_bus.rdata = 32'b0;
    core_instr_bus.rdata_intg = 7'b0;
    core_instr_bus.err = 1'b0;

    case (state)
    IDLE: begin
        if (core_instr_bus.req) begin
            core_instr_bus.gnt = 1'b1;
            requested_addr_nxt = core_instr_bus.addr;

            case (core_instr_bus.addr) inside
            [BOOT_ROM_BASE_ADDRESS:BOOT_ROM_END_ADDRESS]: begin
                `attach_slave_instr_bus_to_core(boot_rom_instr_bus);
            end
            [CODE_RAM_BASE_ADDRESS:CODE_RAM_END_ADDRESS]: begin
                `attach_slave_instr_bus_to_core(code_ram_instr_bus);
            end
            endcase
        end
    end
    WAITING_FOR_GRANT: begin
        case (requested_addr) inside
        [BOOT_ROM_BASE_ADDRESS:BOOT_ROM_END_ADDRESS]: begin
            `attach_slave_instr_bus_to_core(boot_rom_instr_bus);
        end
        [CODE_RAM_BASE_ADDRESS:CODE_RAM_END_ADDRESS]: begin
            `attach_slave_instr_bus_to_core(code_ram_instr_bus);
        end
        endcase
    end
    WAITING_FOR_RESPONSE: begin
        case (requested_addr) inside
        [BOOT_ROM_BASE_ADDRESS:BOOT_ROM_END_ADDRESS]: begin
            `attach_slave_instr_bus_to_core(boot_rom_instr_bus);
        end
        [CODE_RAM_BASE_ADDRESS:CODE_RAM_END_ADDRESS]: begin
            `attach_slave_instr_bus_to_core(code_ram_instr_bus);
        end
        default: begin
            core_instr_bus.rvalid = 1'b1;
            core_instr_bus.err = 1'b1;
        end
        endcase
    end
    endcase
end

endmodule
