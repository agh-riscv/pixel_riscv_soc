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

module peripherals (
    input logic                  clk,
    input logic                  rst_n,

    ibex_data_bus.slave          gpio_data_bus,
    ibex_data_bus.slave          pmc_data_bus,
    ibex_data_bus.slave          spi_data_bus,
    ibex_data_bus.slave          timer_data_bus,
    ibex_data_bus.slave          uart_data_bus,

    output logic                 gpio_irq,
    output logic                 spi_irq,
    output logic                 timer_irq,
    output logic                 uart_irq,

    soc_gpio_bus.master          gpio_bus,
    soc_pmc_bus.master           pmc_bus,
    soc_spi_bus.master           spi_bus,
    soc_uart_bus.master          uart_bus,

    soc_pm_ctrl.master           pm_ctrl,
    soc_pm_data.master           pm_data,
    soc_pm_analog_config.master  pm_analog_config,
    soc_pm_digital_config.master pm_digital_config
);


/**
 * Submodules placement
 */

gpio u_gpio (
    .clk,
    .rst_n,
    .data_bus(gpio_data_bus),
    .irq(gpio_irq),
    .gpio_bus
);

pmc u_pmc (
    .clk,
    .rst_n,
    .data_bus(pmc_data_bus),
    .pmc_bus,
    .pm_ctrl,
    .pm_data,
    .pm_analog_config,
    .pm_digital_config
);

spi u_spi (
    .clk,
    .rst_n,
    .data_bus(spi_data_bus),
    .irq(spi_irq),
    .spi_bus
);

timer u_timer (
    .clk,
    .rst_n,
    .data_bus(timer_data_bus),
    .irq(timer_irq)
);

uart u_uart (
    .clk,
    .rst_n,
    .data_bus(uart_data_bus),
    .irq(uart_irq),
    .uart_bus
);

endmodule
