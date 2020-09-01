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

logic        clk, rst_n;
logic [31:0] gpio_out, gpio_in;
logic        ss, sck, mosi, miso;
logic [63:0] pm_din, pm_dout;

pmc_ctrl         ctrl();
pmc_analog_conf  analog_conf();
pmc_digital_conf digital_conf();


/**
 * Signals assignments
 */

assign led[3] = gpio_out[15];       /* bootloader finished */
assign led3_g = gpio_out[3];
assign led2_g = gpio_out[2];
assign led1_g = gpio_out[1];
assign led0_g = gpio_out[0];

assign gpio_in[17] = 1'b0;          /* codeload skipping */
assign gpio_in[16] = sw;            /* codeload source */
assign gpio_in[3:0] = btn[3:0];

assign led[2:0] = 3'b0;


/**
 * Submodules placement
 */

pixel_riscv_soc u_pixel_riscv_soc (
    .gpio_out,
    .ss,
    .sck,
    .mosi,
    .sout,
    .pm_dout,
    .clk,
    .rst_n,
    .gpio_in,
    .miso,
    .sin,
    .pm_din,
    .ctrl,
    .analog_conf,
    .digital_conf
);

spi_flash_memory u_spi_flash_memory (
    .miso,
    .clk,
    .rst_n,
    .ss,
    .sck,
    .mosi
);

clkgen_xil7series u_clkgen_xil7series (
    .IO_CLK(io_clk),
    .IO_RST_N(io_rst_n),
    .clk_sys(clk),
    .rst_sys_n(rst_n)
);

endmodule
