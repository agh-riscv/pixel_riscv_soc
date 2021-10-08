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

import pixel_riscv_soc_pkg::*;

module peripherals (
    input logic                  clk,
    input logic                  rst_n,

    ibex_instr_bus.slave         instr_bus,
    ibex_data_bus.slave          data_bus,

    soc_gpio_bus.master          gpio_bus,
    soc_spi_bus.master           spi_bus,
    soc_timer_bus.master         timer_bus,
    soc_uart_bus.master          uart_bus,

    soc_pm_ctrl.master           pm_ctrl,
    soc_pm_data.master           pm_data,
    soc_pm_analog_config.master  pm_analog_config,
    soc_pm_digital_config.master pm_digital_config
);


/**
 * Local variables and signals
 */

instr_bus_state_t instr_bus_state;
data_bus_state_t  data_bus_state;

ibex_instr_bus boot_rom_instr_bus ();
ibex_instr_bus code_ram_instr_bus ();

ibex_data_bus boot_rom_data_bus ();
ibex_data_bus code_ram_data_bus ();
ibex_data_bus data_ram_data_bus ();
ibex_data_bus gpio_data_bus ();
ibex_data_bus spi_data_bus ();
ibex_data_bus uart_data_bus ();
ibex_data_bus timer_data_bus ();
ibex_data_bus pmc_data_bus ();


/**
 * Signals assignments
 */

`data_bus_assign_inputs(boot_rom_data_bus)
`data_bus_assign_inputs(code_ram_data_bus)
`data_bus_assign_inputs(data_ram_data_bus)
`data_bus_assign_inputs(gpio_data_bus)
`data_bus_assign_inputs(spi_data_bus)
`data_bus_assign_inputs(uart_data_bus)
`data_bus_assign_inputs(timer_data_bus)
`data_bus_assign_inputs(pmc_data_bus)

`instr_bus_assign_inputs(boot_rom_instr_bus)
`instr_bus_assign_inputs(code_ram_instr_bus)


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
    .clk,
    .rst_n,
    .data_bus(gpio_data_bus),
    .gpio_bus
);

spi u_spi (
    .clk,
    .rst_n,
    .data_bus(spi_data_bus),
    .spi_bus
);

uart u_uart (
    .clk,
    .rst_n,
    .data_bus(uart_data_bus),
    .uart_bus
);

timer u_timer (
    .clk,
    .rst_n,
    .data_bus(timer_data_bus),
    .timer_bus
);

pmc u_pmc (
    .clk,
    .rst_n,
    .data_bus(pmc_data_bus),
    .pm_ctrl,
    .pm_data,
    .pm_analog_config,
    .pm_digital_config
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
    INSTR_BUS_BOOT_ROM: `instr_bus_set_gnt_and_req(boot_rom_instr_bus)
    INSTR_BUS_CODE_RAM: `instr_bus_set_gnt_and_req(code_ram_instr_bus)
    endcase
end

always_comb begin
    instr_bus.rvalid = 1'b0;
    instr_bus.rdata = 32'b0;
    instr_bus.rdata_intg = 7'b0;
    instr_bus.err = 1'b0;

    case (instr_bus_state.responding_slave)
    INSTR_BUS_BOOT_ROM: `instr_bus_set_outputs(boot_rom_instr_bus)
    INSTR_BUS_CODE_RAM: `instr_bus_set_outputs(code_ram_instr_bus)
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
    timer_data_bus.req = 1'b0;
    pmc_data_bus.req = 1'b0;

    case (data_bus_state.requested_slave)
    DATA_BUS_BOOT_ROM:  `data_bus_set_gnt_and_req(boot_rom_data_bus)
    DATA_BUS_CODE_RAM:  `data_bus_set_gnt_and_req(code_ram_data_bus)
    DATA_BUS_DATA_RAM:  `data_bus_set_gnt_and_req(data_ram_data_bus)
    DATA_BUS_GPIO:      `data_bus_set_gnt_and_req(gpio_data_bus)
    DATA_BUS_SPI:       `data_bus_set_gnt_and_req(spi_data_bus)
    DATA_BUS_UART:      `data_bus_set_gnt_and_req(uart_data_bus)
    DATA_BUS_TIMER:     `data_bus_set_gnt_and_req(timer_data_bus)
    DATA_BUS_PMC:       `data_bus_set_gnt_and_req(pmc_data_bus)
    endcase
end

always_comb begin
    data_bus.rvalid = 1'b0;
    data_bus.rdata = 32'b0;
    data_bus.rdata_intg = 7'b0;
    data_bus.err = 1'b0;

    case (data_bus_state.responding_slave)
    DATA_BUS_BOOT_ROM:  `data_bus_set_outputs(boot_rom_data_bus)
    DATA_BUS_CODE_RAM:  `data_bus_set_outputs(code_ram_data_bus)
    DATA_BUS_DATA_RAM:  `data_bus_set_outputs(data_ram_data_bus)
    DATA_BUS_GPIO:      `data_bus_set_outputs(gpio_data_bus)
    DATA_BUS_SPI:       `data_bus_set_outputs(spi_data_bus)
    DATA_BUS_UART:      `data_bus_set_outputs(uart_data_bus)
    DATA_BUS_TIMER:     `data_bus_set_outputs(timer_data_bus)
    DATA_BUS_PMC:       `data_bus_set_outputs(pmc_data_bus)
    endcase
end

endmodule
