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

module top_pixel_riscv_soc_arty_a7_100 (
    output logic [3:0] led,
    output logic       sout,
    output logic       led3_g,
    output logic       led2_g,
    output logic       led1_g,
    output logic       led0_g,
    input logic        io_clk,
    input logic        io_rst_n,
    input logic        sw,
    input logic [3:0]  btn,
    input logic        sin
);


/**
 * Local variables and signals
 */

logic                 clk, rst_n;

soc_gpio_bus          gpio_bus ();
soc_spi_bus           spi_bus ();
soc_uart_bus          uart_bus ();

soc_pm_ctrl           pm_ctrl ();
soc_pm_data           pm_data ();
soc_pm_analog_config  pm_analog_config ();
soc_pm_digital_config pm_digital_config ();


/**
 * Signals assignments
 */

assign led[3] = gpio_bus.dout[15];       /* bootloader finished */
assign led3_g = gpio_bus.dout[3];
assign led2_g = gpio_bus.dout[2];
assign led1_g = gpio_bus.dout[1];
assign led0_g = gpio_bus.dout[0];

assign gpio_bus.din[17] = 1'b0;          /* codeload skipping */
assign gpio_bus.din[16] = sw;            /* codeload source */
assign gpio_bus.din[3:0] = btn[3:0];

assign led[2:0] = 3'b0;

assign sout = uart_bus.sout;
assign uart_bus.sin = sin;


/**
 * Submodules placement
 */

pixel_riscv_soc u_pixel_riscv_soc (
    .clk,
    .rst_n,
    .gpio_bus,
    .spi_bus,
    .uart_bus,
    .pm_ctrl,
    .pm_data,
    .pm_analog_config,
    .pm_digital_config
);

spi_flash_memory u_spi_flash_memory (
    .miso(spi_bus.miso),
    .clk,
    .rst_n,
    .ss(spi_bus.ss),
    .sck(spi_bus.sck),
    .mosi(spi_bus.mosi)
);

clkgen_xil7series u_clkgen_xil7series (
    .IO_CLK(io_clk),
    .IO_RST_N(io_rst_n),
    .clk_sys(clk),
    .rst_sys_n(rst_n)
);

endmodule
