/**
 * Copyright (C) 2022  AGH University of Science and Technology
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

import iomux_pkg::*;

module iomux (
    input logic         clk,
    input logic         rst_n,

    ibex_data_bus.slave data_bus,

    soc_gpio_bus.slave  gpio_bus,
    soc_pmc_bus.slave   pmc_bus,
    soc_spi_bus.slave   spi_bus,
    soc_uart_bus.slave  uart_bus,

    output logic        gpio31_out,
    output logic        gpio30_uart_sout_out,
    output logic        gpio29_out,
    output logic        gpio28_spi_mosi_out,
    output logic        gpio27_spi_sck_out,
    output logic        gpio26_spi_ss1_out,
    output logic        gpio25_spi_ss0_out,
    output logic        gpio24_out,
    output logic        gpio23_out,
    output logic        gpio22_out,
    output logic        gpio21_out,
    output logic        gpio20_out,
    output logic        gpio19_out,
    output logic        gpio18_out,
    output logic        gpio17_out,
    output logic        gpio16_out,
    output logic        gpio15_out,
    output logic        gpio14_out,
    output logic        gpio13_out,
    output logic        gpio12_out,
    output logic        gpio11_out,
    output logic        gpio10_out,
    output logic        gpio9_out,
    output logic        gpio8_out,
    output logic        gpio7_out,
    output logic        gpio6_out,
    output logic        gpio5_out,
    output logic        gpio4_out,
    output logic        gpio3_out,
    output logic        gpio2_out,
    output logic        gpio1_out,
    output logic        gpio0_out,

    input logic         gpio31_uart_sin_in,
    input logic         gpio30_in,
    input logic         gpio29_spi_miso_in,
    input logic         gpio28_in,
    input logic         gpio27_in,
    input logic         gpio26_in,
    input logic         gpio25_in,
    input logic         gpio24_pmc_strobe_in,
    input logic         gpio23_pmc_gate_in,
    input logic         gpio22_in,
    input logic         gpio21_in,
    input logic         gpio20_in,
    input logic         gpio19_in,
    input logic         gpio18_in,
    input logic         gpio17_in,
    input logic         gpio16_in,
    input logic         gpio15_in,
    input logic         gpio14_in,
    input logic         gpio13_in,
    input logic         gpio12_in,
    input logic         gpio11_in,
    input logic         gpio10_in,
    input logic         gpio9_in,
    input logic         gpio8_in,
    input logic         gpio7_in,
    input logic         gpio6_in,
    input logic         gpio5_in,
    input logic         gpio4_in,
    input logic         gpio3_in,
    input logic         gpio2_in,
    input logic         gpio1_in,
    input logic         gpio0_in
);


/**
 * Local variables and signals
 */

iomux_regs_t  regs, regs_nxt;


/**
 * Signals assignments
 */

assign data_bus.rdata_intg = 7'b0;

/* gpio31_uart_sin */
assign gpio31_out = (regs.mr1.pin31 == IO_OUT) ? gpio_bus.dout[31] : 1'b0;
assign gpio_bus.din[31] = (regs.mr1.pin31 == IO_IN) ? gpio31_uart_sin_in : 1'b0;
assign uart_bus.sin = (regs.mr1.pin31 == IO_ALT) ? gpio31_uart_sin_in : 1'b1;    /* uart idle state: 1'b1 */

/* gpio30_uart_sout */
assign gpio30_uart_sout_out =
    (regs.mr1.pin30 == IO_OUT) ? gpio_bus.dout[30] :
    (regs.mr1.pin30 == IO_ALT) ? uart_bus.sout : 1'b0;
assign gpio_bus.din[30] = (regs.mr1.pin30 == IO_IN) ? gpio30_in : 1'b0;

/* gpio29_spi_miso */
assign gpio29_out = (regs.mr1.pin29 == IO_OUT) ? gpio_bus.dout[29] : 1'b0;
assign gpio_bus.din[29] = (regs.mr1.pin29 == IO_IN) ? gpio29_spi_miso_in : 1'b0;
assign spi_bus.miso = (regs.mr1.pin29 == IO_ALT) ? gpio29_spi_miso_in : 1'b0;

/* gpio28_spi_mosi */
assign gpio28_spi_mosi_out =
    (regs.mr1.pin28 == IO_OUT) ? gpio_bus.dout[28] :
    (regs.mr1.pin28 == IO_ALT) ? spi_bus.mosi : 1'b0;
assign gpio_bus.din[28] = (regs.mr1.pin28 == IO_IN) ? gpio28_in : 1'b0;

/* gpio27_spi_sck */
assign gpio27_spi_sck_out =
    (regs.mr1.pin27 == IO_OUT) ? gpio_bus.dout[27] :
    (regs.mr1.pin27 == IO_ALT) ? spi_bus.sck : 1'b0;
assign gpio_bus.din[27] = (regs.mr1.pin27 == IO_IN) ? gpio27_in : 1'b0;

/* gpio26_spi_ss1 */
assign gpio26_spi_ss1_out =
    (regs.mr1.pin26 == IO_OUT) ? gpio_bus.dout[26] :
    (regs.mr1.pin26 == IO_ALT) ? spi_bus.ss1 : 1'b0;
assign gpio_bus.din[26] = (regs.mr1.pin26 == IO_IN) ? gpio26_in : 1'b0;

/* gpio25_spi_ss0 */
assign gpio25_spi_ss0_out =
    (regs.mr1.pin25 == IO_OUT) ? gpio_bus.dout[25] :
    (regs.mr1.pin25 == IO_ALT) ? spi_bus.ss0 : 1'b0;
assign gpio_bus.din[25] = (regs.mr1.pin25 == IO_IN) ? gpio25_in : 1'b0;

/* gpio24_pmc_strobe */
assign gpio24_out = (regs.mr1.pin24 == IO_OUT) ? gpio_bus.dout[24] : 1'b0;
assign gpio_bus.din[24] = (regs.mr1.pin24 == IO_IN) ? gpio24_pmc_strobe_in : 1'b0;
assign pmc_bus.strobe = (regs.mr1.pin24 == IO_ALT) ? gpio24_pmc_strobe_in : 1'b0;

/* gpio23_pmc_gate */
assign gpio23_out = (regs.mr1.pin23 == IO_OUT) ? gpio_bus.dout[23] : 1'b0;
assign gpio_bus.din[23] = (regs.mr1.pin23 == IO_IN) ? gpio23_pmc_gate_in : 1'b0;
assign pmc_bus.gate = (regs.mr1.pin23 == IO_ALT) ? gpio23_pmc_gate_in : 1'b0;

/* gpio22 */
assign gpio22_out = (regs.mr1.pin22 == IO_OUT) ? gpio_bus.dout[22] : 1'b0;
assign gpio_bus.din[22] = (regs.mr1.pin22 == IO_IN) ? gpio22_in : 1'b0;

/* gpio21 */
assign gpio21_out = (regs.mr1.pin21 == IO_OUT) ? gpio_bus.dout[21] : 1'b0;
assign gpio_bus.din[21] = (regs.mr1.pin21 == IO_IN) ? gpio21_in : 1'b0;

/* gpio20 */
assign gpio20_out = (regs.mr1.pin20 == IO_OUT) ? gpio_bus.dout[20] : 1'b0;
assign gpio_bus.din[20] = (regs.mr1.pin20 == IO_IN) ? gpio20_in : 1'b0;

/* gpio19 */
assign gpio19_out = (regs.mr1.pin19 == IO_OUT) ? gpio_bus.dout[19] : 1'b0;
assign gpio_bus.din[19] = (regs.mr1.pin19 == IO_IN) ? gpio19_in : 1'b0;

/* gpio18 */
assign gpio18_out = (regs.mr1.pin18 == IO_OUT) ? gpio_bus.dout[18] : 1'b0;
assign gpio_bus.din[18] = (regs.mr1.pin18 == IO_IN) ? gpio18_in : 1'b0;

/* gpio17 */
assign gpio17_out = (regs.mr1.pin17 == IO_OUT) ? gpio_bus.dout[17] : 1'b0;
assign gpio_bus.din[17] = (regs.mr1.pin17 == IO_IN) ? gpio17_in : 1'b0;

/* gpio16 */
assign gpio16_out = (regs.mr1.pin16 == IO_OUT) ? gpio_bus.dout[16] : 1'b0;
assign gpio_bus.din[16] = (regs.mr1.pin16 == IO_IN) ? gpio16_in : 1'b0;

/* gpio15 */
assign gpio15_out = (regs.mr0.pin15 == IO_OUT) ? gpio_bus.dout[15] : 1'b0;
assign gpio_bus.din[15] = (regs.mr0.pin15 == IO_IN) ? gpio15_in : 1'b0;

/* gpio14 */
assign gpio14_out = (regs.mr0.pin14 == IO_OUT) ? gpio_bus.dout[14] : 1'b0;
assign gpio_bus.din[14] = (regs.mr0.pin14 == IO_IN) ? gpio14_in : 1'b0;

/* gpio13 */
assign gpio13_out = (regs.mr0.pin13 == IO_OUT) ? gpio_bus.dout[13] : 1'b0;
assign gpio_bus.din[13] = (regs.mr0.pin13 == IO_IN) ? gpio13_in : 1'b0;

/* gpio12 */
assign gpio12_out = (regs.mr0.pin12 == IO_OUT) ? gpio_bus.dout[12] : 1'b0;
assign gpio_bus.din[12] = (regs.mr0.pin12 == IO_IN) ? gpio12_in : 1'b0;

/* gpio11 */
assign gpio11_out = (regs.mr0.pin11 == IO_OUT) ? gpio_bus.dout[11] : 1'b0;
assign gpio_bus.din[11] = (regs.mr0.pin11 == IO_IN) ? gpio11_in : 1'b0;

/* gpio10 */
assign gpio10_out = (regs.mr0.pin10 == IO_OUT) ? gpio_bus.dout[10] : 1'b0;
assign gpio_bus.din[10] = (regs.mr0.pin10 == IO_IN) ? gpio10_in : 1'b0;

/* gpio9 */
assign gpio9_out = (regs.mr0.pin9 == IO_OUT) ? gpio_bus.dout[9] : 1'b0;
assign gpio_bus.din[9] = (regs.mr0.pin9 == IO_IN) ? gpio9_in : 1'b0;

/* gpio8 */
assign gpio8_out = (regs.mr0.pin8 == IO_OUT) ? gpio_bus.dout[8] : 1'b0;
assign gpio_bus.din[8] = (regs.mr0.pin8 == IO_IN) ? gpio8_in : 1'b0;

/* gpio7 */
assign gpio7_out = (regs.mr0.pin7 == IO_OUT) ? gpio_bus.dout[7] : 1'b0;
assign gpio_bus.din[7] = (regs.mr0.pin7 == IO_IN) ? gpio7_in : 1'b0;

/* gpio6 */
assign gpio6_out = (regs.mr0.pin6 == IO_OUT) ? gpio_bus.dout[6] : 1'b0;
assign gpio_bus.din[6] = (regs.mr0.pin6 == IO_IN) ? gpio6_in : 1'b0;

/* gpio5 */
assign gpio5_out = (regs.mr0.pin5 == IO_OUT) ? gpio_bus.dout[5] : 1'b0;
assign gpio_bus.din[5] = (regs.mr0.pin5 == IO_IN) ? gpio5_in : 1'b0;

/* gpio4 */
assign gpio4_out = (regs.mr0.pin4 == IO_OUT) ? gpio_bus.dout[4] : 1'b0;
assign gpio_bus.din[4] = (regs.mr0.pin4 == IO_IN) ? gpio4_in : 1'b0;

/* gpio3 */
assign gpio3_out = (regs.mr0.pin3 == IO_OUT) ? gpio_bus.dout[3] : 1'b0;
assign gpio_bus.din[3] = (regs.mr0.pin3 == IO_IN) ? gpio3_in : 1'b0;

/* gpio2 */
assign gpio2_out = (regs.mr0.pin2 == IO_OUT) ? gpio_bus.dout[2] : 1'b0;
assign gpio_bus.din[2] = (regs.mr0.pin2 == IO_IN) ? gpio2_in : 1'b0;

/* gpio1 */
assign gpio1_out = (regs.mr0.pin1 == IO_OUT) ? gpio_bus.dout[1] : 1'b0;
assign gpio_bus.din[1] = (regs.mr0.pin1 == IO_IN) ? gpio1_in : 1'b0;

/* gpio0 */
assign gpio0_out = (regs.mr0.pin0 == IO_OUT) ? gpio_bus.dout[0] : 1'b0;
assign gpio_bus.din[0] = (regs.mr0.pin0 == IO_IN) ? gpio0_in : 1'b0;


/**
 * Tasks and functions definitions
 */

function automatic logic is_offset_valid(logic [11:0] offset);
    return offset inside {
        IOMUX_MR0_OFFSET, IOMUX_MR1_OFFSET
    };
endfunction


/**
 * Properties and assertions
 */

assert property (@(negedge clk) data_bus.req |-> is_offset_valid(data_bus.addr[11:0])) else
    $warning("incorrect offset requested: 0x%x", data_bus.addr[11:0]);


/**
 * Module internal logic
 */

/* Ibex data bus handling */

always_comb begin
    data_bus.gnt = data_bus.req;
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_bus.rvalid <= 1'b0;
        data_bus.err <= 1'b0;
    end else begin
        data_bus.rvalid <= data_bus.gnt;
        data_bus.err <= data_bus.gnt && !is_offset_valid(data_bus.addr[11:0]);
    end
end

/* Registers update */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        regs <= {{2{32'b0}}};
    else
        regs <= regs_nxt;
end

always_comb begin
    regs_nxt = regs;

    if (data_bus.req && data_bus.we) begin
        case (data_bus.addr[11:0])
        IOMUX_MR0_OFFSET:   regs_nxt.mr0 = data_bus.wdata;
        IOMUX_MR1_OFFSET:   regs_nxt.mr1 = data_bus.wdata;
        endcase
    end
end

/* Registers readout */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_bus.rdata <= 32'b0;
    end else begin
        if (data_bus.req) begin
            case (data_bus.addr[11:0])
            IOMUX_MR0_OFFSET:   data_bus.rdata <= regs.mr0;
            IOMUX_MR1_OFFSET:   data_bus.rdata <= regs.mr1;
            endcase
        end
    end
end

endmodule
