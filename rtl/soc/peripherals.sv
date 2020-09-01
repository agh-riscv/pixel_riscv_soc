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

import rxd_pkg::*;

module peripherals (
    output logic        tmr_irq,
    output logic        gpio_irq,
    output logic [31:0] gpio_out,
    output logic        ss,
    output logic        sck,
    output logic        mosi,
    output logic        sout,
    output logic [63:0] pm_din,
    input logic         clk,
    input logic         rst_n,
    input logic [31:0]  gpio_in,
    input logic         miso,
    input logic         sin,
    input logic [63:0]  pm_dout,

    ibex_instr_bus.slave    instr_bus,
    ibex_data_bus.slave     data_bus,
    pmc_ctrl.master         ctrl,
    pmc_analog_conf.master  analog_conf,
    pmc_digital_conf.master digital_conf
);


/**
 * Local variables and signals
 */

instr_bus_state_t instr_bus_state;
data_bus_state_t  data_bus_state;

ibex_instr_bus boot_rom_instr_bus();
ibex_instr_bus code_ram_instr_bus();

ibex_data_bus boot_rom_data_bus();
ibex_data_bus code_ram_data_bus();
ibex_data_bus data_ram_data_bus();
ibex_data_bus gpio_data_bus();
ibex_data_bus spi_data_bus();
ibex_data_bus uart_data_bus();
ibex_data_bus tmr_data_bus();
ibex_data_bus pmc_data_bus();


/**
 * Signals assignments
 */

`ibex_data_bus_assign_inputs(boot_rom_data_bus, data_bus)
`ibex_data_bus_assign_inputs(code_ram_data_bus, data_bus)
`ibex_data_bus_assign_inputs(data_ram_data_bus, data_bus)
`ibex_data_bus_assign_inputs(gpio_data_bus, data_bus)
`ibex_data_bus_assign_inputs(spi_data_bus, data_bus)
`ibex_data_bus_assign_inputs(uart_data_bus, data_bus)
`ibex_data_bus_assign_inputs(tmr_data_bus, data_bus)
`ibex_data_bus_assign_inputs(pmc_data_bus, data_bus)

`ibex_instr_bus_assign_inputs(boot_rom_instr_bus, instr_bus)
`ibex_instr_bus_assign_inputs(code_ram_instr_bus, instr_bus)


/**
 * Submodules placement
 */

/* Bus arbiters */

data_bus_arbiter u_data_bus_arbiter (
    .data_bus_state,
    .clk,
    .rst_n,
    .data_bus_req(data_bus.req),
    .data_bus_addr(data_bus.addr)
);

instr_bus_arbiter u_instr_bus_arbiter (
    .instr_bus_state,
    .clk,
    .rst_n,
    .instr_bus_req(instr_bus.req),
    .instr_bus_addr(instr_bus.addr)
);


/* Memories */

boot_rom u_boot_rom (
    .clk,
    .rst_n,
    .instr_bus(boot_rom_instr_bus),
    .data_bus(boot_rom_data_bus)
);

code_ram u_code_ram (
    .clk,
    .rst_n,
    .data_bus(code_ram_data_bus),
    .instr_bus(code_ram_instr_bus)
);

data_ram u_data_ram (
    .clk,
    .rst_n,
    .data_bus(data_ram_data_bus)
);


/* Miscellaneous */

gpio u_gpio (
    .irq(gpio_irq),
    .io_out(gpio_out),
    .clk,
    .rst_n,
    .io_in(gpio_in),
    .data_bus(gpio_data_bus)
);

spi u_spi (
    .ss,
    .sck,
    .mosi,
    .clk,
    .rst_n,
    .miso,
    .data_bus(spi_data_bus)
);

uart u_uart (
    .sout,
    .clk,
    .rst_n,
    .sin,
    .data_bus(uart_data_bus)
);

tmr u_tmr (
    .irq(tmr_irq),
    .clk,
    .rst_n,
    .data_bus(tmr_data_bus)
);

pmc u_pmc (
    .pm_din,
    .clk,
    .rst_n,
    .pm_dout,
    .data_bus(pmc_data_bus),
    .ctrl,
    .analog_conf,
    .digital_conf
);


/**
 * Module internal logic
 */

/* Instruction bus */

always_comb begin
    instr_bus.gnt = 1'b0;
    boot_rom_instr_bus.req = 1'b0;
    code_ram_instr_bus.req = 1'b0;

    case (instr_bus_state.requested_slave)
        INSTR_BUS_BOOT_ROM: `ibex_bus_set_req_and_gnt(boot_rom_instr_bus, instr_bus)
        INSTR_BUS_CODE_RAM: `ibex_bus_set_req_and_gnt(code_ram_instr_bus, instr_bus)
    endcase
end

always_comb begin
    instr_bus.rvalid = 1'b0;
    instr_bus.err = 1'b0;
    instr_bus.rdata = 32'b0;

    case (instr_bus_state.responding_slave)
        INSTR_BUS_BOOT_ROM: `ibex_bus_set_outputs(instr_bus, boot_rom_instr_bus)
        INSTR_BUS_CODE_RAM: `ibex_bus_set_outputs(instr_bus, code_ram_instr_bus)
    endcase
end


/* Data bus */

always_comb begin
    data_bus.gnt = 1'b0;
    boot_rom_data_bus.req = 1'b0;
    code_ram_data_bus.req = 1'b0;
    data_ram_data_bus.req = 1'b0;
    gpio_data_bus.req = 1'b0;
    spi_data_bus.req = 1'b0;
    uart_data_bus.req = 1'b0;
    tmr_data_bus.req = 1'b0;
    pmc_data_bus.req = 1'b0;

    case (data_bus_state.requested_slave)
        DATA_BUS_BOOT_ROM:  `ibex_bus_set_req_and_gnt(boot_rom_data_bus, data_bus)
        DATA_BUS_CODE_RAM:  `ibex_bus_set_req_and_gnt(code_ram_data_bus, data_bus)
        DATA_BUS_DATA_RAM:  `ibex_bus_set_req_and_gnt(data_ram_data_bus, data_bus)
        DATA_BUS_GPIO:      `ibex_bus_set_req_and_gnt(gpio_data_bus, data_bus)
        DATA_BUS_SPI:       `ibex_bus_set_req_and_gnt(spi_data_bus, data_bus)
        DATA_BUS_UART:      `ibex_bus_set_req_and_gnt(uart_data_bus, data_bus)
        DATA_BUS_TMR:       `ibex_bus_set_req_and_gnt(tmr_data_bus, data_bus)
        DATA_BUS_PMC:       `ibex_bus_set_req_and_gnt(pmc_data_bus, data_bus)
    endcase
end

always_comb begin
    data_bus.rvalid = 1'b0;
    data_bus.err = 1'b0;
    data_bus.rdata = 32'b0;

    case (data_bus_state.responding_slave)
        DATA_BUS_BOOT_ROM:  `ibex_bus_set_outputs(data_bus, boot_rom_data_bus)
        DATA_BUS_CODE_RAM:  `ibex_bus_set_outputs(data_bus, code_ram_data_bus)
        DATA_BUS_DATA_RAM:  `ibex_bus_set_outputs(data_bus, data_ram_data_bus)
        DATA_BUS_GPIO:      `ibex_bus_set_outputs(data_bus, gpio_data_bus)
        DATA_BUS_SPI:       `ibex_bus_set_outputs(data_bus, spi_data_bus)
        DATA_BUS_UART:      `ibex_bus_set_outputs(data_bus, uart_data_bus)
        DATA_BUS_TMR:       `ibex_bus_set_outputs(data_bus, tmr_data_bus)
        DATA_BUS_PMC:       `ibex_bus_set_outputs(data_bus, pmc_data_bus)
    endcase
end

endmodule
