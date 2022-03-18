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

module data_bus_arbiter (
    input logic          clk,
    input logic          rst_n,

    ibex_data_bus.slave  core_data_bus,

    ibex_data_bus.master boot_rom_data_bus,
    ibex_data_bus.master code_ram_data_bus,
    ibex_data_bus.master data_ram_data_bus,

    ibex_data_bus.master gpio_data_bus,
    ibex_data_bus.master iomux_data_bus,
    ibex_data_bus.master pmc_data_bus,
    ibex_data_bus.master spi_data_bus,
    ibex_data_bus.master timer_data_bus,
    ibex_data_bus.master uart_data_bus
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

`define attach_core_data_bus_to_slave(bus) \
    bus.req = core_data_bus.req; \
    bus.we = core_data_bus.we; \
    bus.be = core_data_bus.be; \
    bus.addr = core_data_bus.addr; \
    bus.wdata = core_data_bus.wdata; \
    bus.wdata_intg = core_data_bus.wdata_intg

`define attach_zeros_to_slave_data_bus(bus) \
    bus.req = 1'b0; \
    bus.we = 1'b0; \
    bus.be = 4'b0; \
    bus.addr = 32'b0; \
    bus.wdata = 32'b0; \
    bus.wdata_intg = 7'b0

`define attach_slave_data_bus_to_core(bus) \
    core_data_bus.gnt = bus.gnt; \
    core_data_bus.rvalid = bus.rvalid; \
    core_data_bus.rdata = bus.rdata; \
    core_data_bus.rdata_intg = bus.rdata_intg; \
    core_data_bus.err = bus.err

function automatic logic is_address_valid(logic [31:0] address);
    return address inside {
        [BOOT_ROM_BASE_ADDRESS:BOOT_ROM_END_ADDRESS],
        [CODE_RAM_BASE_ADDRESS:CODE_RAM_END_ADDRESS],
        [DATA_RAM_BASE_ADDRESS:DATA_RAM_END_ADDRESS],
        [GPIO_BASE_ADDRESS:GPIO_END_ADDRESS],
        [IOMUX_BASE_ADDRESS:IOMUX_END_ADDRESS],
        [PMC_BASE_ADDRESS:PMC_END_ADDRESS],
        [SPI_BASE_ADDRESS:SPI_END_ADDRESS],
        [TIMER_BASE_ADDRESS:TIMER_END_ADDRESS],
        [UART_BASE_ADDRESS:UART_END_ADDRESS]
    };
endfunction


/**
 * Properties and assertions
 */

assert property (@(negedge clk) core_data_bus.req |-> is_address_valid(core_data_bus.addr)) else
    $warning("incorrect address requested: 0x%x", core_data_bus.addr);


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
        if (core_data_bus.req)
            state_nxt = core_data_bus.gnt ? WAITING_FOR_RESPONSE : WAITING_FOR_GRANT;
    end
    WAITING_FOR_GRANT: begin
        if (core_data_bus.gnt)
            state_nxt = WAITING_FOR_RESPONSE;
    end
    WAITING_FOR_RESPONSE: begin
        if (core_data_bus.rvalid)
            state_nxt = IDLE;
    end
    endcase
end

/* core input signals demultiplexing */

always_comb begin
    `attach_zeros_to_slave_data_bus(boot_rom_data_bus);
    `attach_zeros_to_slave_data_bus(code_ram_data_bus);
    `attach_zeros_to_slave_data_bus(data_ram_data_bus);
    `attach_zeros_to_slave_data_bus(gpio_data_bus);
    `attach_zeros_to_slave_data_bus(iomux_data_bus);
    `attach_zeros_to_slave_data_bus(pmc_data_bus);
    `attach_zeros_to_slave_data_bus(spi_data_bus);
    `attach_zeros_to_slave_data_bus(timer_data_bus);
    `attach_zeros_to_slave_data_bus(uart_data_bus);

    case (state)
    IDLE,
    WAITING_FOR_GRANT: begin
        if (core_data_bus.req) begin
            case (core_data_bus.addr) inside
            [BOOT_ROM_BASE_ADDRESS:BOOT_ROM_END_ADDRESS]: begin
                `attach_core_data_bus_to_slave(boot_rom_data_bus);
            end
            [CODE_RAM_BASE_ADDRESS:CODE_RAM_END_ADDRESS]: begin
                `attach_core_data_bus_to_slave(code_ram_data_bus);
            end
            [DATA_RAM_BASE_ADDRESS:DATA_RAM_END_ADDRESS]: begin
                `attach_core_data_bus_to_slave(data_ram_data_bus);
            end
            [GPIO_BASE_ADDRESS:GPIO_END_ADDRESS]: begin
                `attach_core_data_bus_to_slave(gpio_data_bus);
            end
            [IOMUX_BASE_ADDRESS:IOMUX_END_ADDRESS]: begin
                `attach_core_data_bus_to_slave(iomux_data_bus);
            end
            [PMC_BASE_ADDRESS:PMC_END_ADDRESS]: begin
                `attach_core_data_bus_to_slave(pmc_data_bus);
            end
            [SPI_BASE_ADDRESS:SPI_END_ADDRESS]: begin
                `attach_core_data_bus_to_slave(spi_data_bus);
            end
            [TIMER_BASE_ADDRESS:TIMER_END_ADDRESS]: begin
                `attach_core_data_bus_to_slave(timer_data_bus);
            end
            [UART_BASE_ADDRESS:UART_END_ADDRESS]: begin
                `attach_core_data_bus_to_slave(uart_data_bus);
            end
            endcase
        end
    end
    WAITING_FOR_RESPONSE: ;
    endcase
end

/* core output signals multiplexing */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        requested_addr <= 32'b0;
    else
        requested_addr <= requested_addr_nxt;
end

always_comb begin
    requested_addr_nxt = requested_addr;
    core_data_bus.gnt = 1'b0;
    core_data_bus.rvalid = 1'b0;
    core_data_bus.rdata = 32'b0;
    core_data_bus.rdata_intg = 7'b0;
    core_data_bus.err = 1'b0;

    case (state)
    IDLE: begin
        if (core_data_bus.req) begin
            core_data_bus.gnt = 1'b1;
            requested_addr_nxt = core_data_bus.addr;

            case (core_data_bus.addr) inside
            [BOOT_ROM_BASE_ADDRESS:BOOT_ROM_END_ADDRESS]: begin
                `attach_slave_data_bus_to_core(boot_rom_data_bus);
            end
            [CODE_RAM_BASE_ADDRESS:CODE_RAM_END_ADDRESS]: begin
                `attach_slave_data_bus_to_core(code_ram_data_bus);
            end
            [DATA_RAM_BASE_ADDRESS:DATA_RAM_END_ADDRESS]: begin
                `attach_slave_data_bus_to_core(data_ram_data_bus);
            end
            [GPIO_BASE_ADDRESS:GPIO_END_ADDRESS]: begin
                `attach_slave_data_bus_to_core(gpio_data_bus);
            end
            [IOMUX_BASE_ADDRESS:IOMUX_END_ADDRESS]: begin
                `attach_slave_data_bus_to_core(iomux_data_bus);
            end
            [PMC_BASE_ADDRESS:PMC_END_ADDRESS]: begin
                `attach_slave_data_bus_to_core(pmc_data_bus);
            end
            [SPI_BASE_ADDRESS:SPI_END_ADDRESS]: begin
                `attach_slave_data_bus_to_core(spi_data_bus);
            end
            [TIMER_BASE_ADDRESS:TIMER_END_ADDRESS]: begin
                `attach_slave_data_bus_to_core(timer_data_bus);
            end
            [UART_BASE_ADDRESS:UART_END_ADDRESS]: begin
                `attach_slave_data_bus_to_core(uart_data_bus);
            end
            endcase
        end
    end
    WAITING_FOR_GRANT: begin
        case (requested_addr) inside
        [BOOT_ROM_BASE_ADDRESS:BOOT_ROM_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(boot_rom_data_bus);
        end
        [CODE_RAM_BASE_ADDRESS:CODE_RAM_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(code_ram_data_bus);
        end
        [DATA_RAM_BASE_ADDRESS:DATA_RAM_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(data_ram_data_bus);
        end
        [GPIO_BASE_ADDRESS:GPIO_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(gpio_data_bus);
        end
        [IOMUX_BASE_ADDRESS:IOMUX_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(iomux_data_bus);
        end
        [PMC_BASE_ADDRESS:PMC_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(pmc_data_bus);
        end
        [SPI_BASE_ADDRESS:SPI_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(spi_data_bus);
        end
        [TIMER_BASE_ADDRESS:TIMER_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(timer_data_bus);
        end
        [UART_BASE_ADDRESS:UART_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(uart_data_bus);
        end
        endcase
    end
    WAITING_FOR_RESPONSE: begin
        case (requested_addr) inside
        [BOOT_ROM_BASE_ADDRESS:BOOT_ROM_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(boot_rom_data_bus);
        end
        [CODE_RAM_BASE_ADDRESS:CODE_RAM_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(code_ram_data_bus);
        end
        [DATA_RAM_BASE_ADDRESS:DATA_RAM_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(data_ram_data_bus);
        end
        [GPIO_BASE_ADDRESS:GPIO_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(gpio_data_bus);
        end
        [IOMUX_BASE_ADDRESS:IOMUX_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(iomux_data_bus);
        end
        [PMC_BASE_ADDRESS:PMC_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(pmc_data_bus);
        end
        [SPI_BASE_ADDRESS:SPI_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(spi_data_bus);
        end
        [TIMER_BASE_ADDRESS:TIMER_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(timer_data_bus);
        end
        [UART_BASE_ADDRESS:UART_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(uart_data_bus);
        end
        default: begin
            core_data_bus.rvalid = 1'b1;
            core_data_bus.err = 1'b1;
        end
        endcase
    end
    endcase
end

endmodule
