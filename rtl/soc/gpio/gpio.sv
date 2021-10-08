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

import gpio_pkg::*;

module gpio (
    input logic         clk,
    input logic         rst_n,
    ibex_data_bus.slave data_bus,
    soc_gpio_bus.master gpio_bus
);


/**
 * Local variables and signals
 */

gpio_regs_t  gpio_regs, gpio_regs_nxt;
logic [31:0] interrupt_detected;


/**
 * Signals assignments
 */

assign data_bus.rdata_intg = 7'b0;
assign data_bus.err = 1'b0;

/* 0x008: output data reg */
assign gpio_bus.dout = gpio_regs.odr;

/* 0x014: interrupt status reg */
assign gpio_bus.irq =| gpio_regs.isr;

/* 0x020: output enable reg */
assign gpio_bus.oe_n = gpio_regs.oenr;


/**
 * Submodules placement
 */

gpio_interrupt_detector u_gpio_interrupt_detector (
    .interrupt_detected,
    .clk,
    .rst_n,
    .io_in(gpio_bus.din),
    .ier(gpio_regs.ier),
    .rier(gpio_regs.rier),
    .fier(gpio_regs.fier)
);


/**
 * Tasks and functions definitions
 */

function automatic logic is_offset_valid(logic [11:0] offset);
    return offset inside {
        `GPIO_CR_OFFSET, `GPIO_SR_OFFSET, `GPIO_ODR_OFFSET, `GPIO_IDR_OFFSET, `GPIO_IER_OFFSET,
        `GPIO_ISR_OFFSET, `GPIO_RIER_OFFSET, `GPIO_FIER_OFFSET, `GPIO_OENR_OFFSET
    };
endfunction

function automatic logic is_reg_written(logic [11:0] offset);
    return data_bus.req && data_bus.we && data_bus.addr[11:0] == offset;
endfunction


/**
 * Module internal logic
 */

/* Bus gnt and rvalid signals setting  */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        data_bus.rvalid <= 1'b0;
    else
        data_bus.rvalid <= data_bus.gnt;
end

always_comb begin
    data_bus.gnt = is_offset_valid(data_bus.addr[11:0]);
end

/* Registers update */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        gpio_regs.cr <= 32'b0;
        gpio_regs.sr <= 32'b0;
        gpio_regs.odr <= 32'b0;
        gpio_regs.idr <= 32'b0;
        gpio_regs.ier <= 32'b0;
        gpio_regs.isr <= 32'b0;
        gpio_regs.rier <= 32'b0;
        gpio_regs.fier <= 32'b0;
        gpio_regs.oenr <= 32'hffffffff;
    end
    else begin
        gpio_regs <= gpio_regs_nxt;
    end
end

always_comb begin
    gpio_regs_nxt = gpio_regs;

    if (data_bus.req && data_bus.we) begin
        case (data_bus.addr[11:0])
        `GPIO_CR_OFFSET:    gpio_regs_nxt.cr = data_bus.wdata;
        `GPIO_SR_OFFSET:    gpio_regs_nxt.sr = data_bus.wdata;
        `GPIO_ODR_OFFSET:   gpio_regs_nxt.odr = data_bus.wdata;
        `GPIO_IDR_OFFSET:   gpio_regs_nxt.idr = data_bus.wdata;
        `GPIO_IER_OFFSET:   gpio_regs_nxt.ier = data_bus.wdata;
        `GPIO_ISR_OFFSET:   gpio_regs_nxt.isr = data_bus.wdata;
        `GPIO_RIER_OFFSET:  gpio_regs_nxt.rier = data_bus.wdata;
        `GPIO_FIER_OFFSET:  gpio_regs_nxt.fier = data_bus.wdata;
        `GPIO_OENR_OFFSET:  gpio_regs_nxt.oenr = data_bus.wdata;
        endcase
    end

    /* 0x00c: input data reg */
    gpio_regs_nxt.idr = gpio_bus.din;

    /* 0x014: interrupt status reg */
    if (interrupt_detected) begin
        gpio_regs_nxt.isr = gpio_regs.isr | interrupt_detected;

        if (is_reg_written(`GPIO_ISR_OFFSET))
            gpio_regs_nxt.isr = data_bus.wdata | interrupt_detected;
    end
end

/* Registers readout */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_bus.rdata <= 32'b0;
    end
    else begin
        if (data_bus.req) begin
            case (data_bus.addr[11:0])
            `GPIO_CR_OFFSET:    data_bus.rdata <= gpio_regs.cr;
            `GPIO_SR_OFFSET:    data_bus.rdata <= gpio_regs.sr;
            `GPIO_ODR_OFFSET:   data_bus.rdata <= gpio_regs.odr;
            `GPIO_IDR_OFFSET:   data_bus.rdata <= gpio_regs.idr;
            `GPIO_IER_OFFSET:   data_bus.rdata <= gpio_regs.ier;
            `GPIO_ISR_OFFSET:   data_bus.rdata <= gpio_regs.isr;
            `GPIO_RIER_OFFSET:  data_bus.rdata <= gpio_regs.rier;
            `GPIO_FIER_OFFSET:  data_bus.rdata <= gpio_regs.fier;
            `GPIO_OENR_OFFSET:  data_bus.rdata <= gpio_regs.oenr;
            endcase
        end
    end
end

endmodule
