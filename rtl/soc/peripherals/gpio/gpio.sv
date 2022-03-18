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
    output logic        irq,
    soc_gpio_bus.master gpio_bus
);


/**
 * Local variables and signals
 */

gpio_regs_t  regs, regs_nxt;
logic [31:0] rising_edge_interrupt_detected, falling_edge_interrupt_detected;


/**
 * Signals assignments
 */

assign data_bus.rdata_intg = 7'b0;

assign irq = (|regs.risr) | (|regs.fisr);

/* 0x000: output data reg */
assign gpio_bus.dout = regs.odr;


/**
 * Submodules placement
 */

gpio_interrupts_detector u_gpio_interrupts_detector (
    .clk,

    .rising_edge_interrupt_detected,
    .falling_edge_interrupt_detected,
    .regs(regs),
    .din(gpio_bus.din)
);


/**
 * Tasks and functions definitions
 */

function automatic logic is_offset_valid(logic [11:0] offset);
    return offset inside {
        GPIO_ODR_OFFSET, GPIO_IDR_OFFSET, GPIO_RIER_OFFSET, GPIO_RISR_OFFSET,
        GPIO_FIER_OFFSET, GPIO_FISR_OFFSET
    };
endfunction

function automatic logic is_reg_written(logic [11:0] offset);
    return data_bus.req && data_bus.we && data_bus.addr[11:0] == offset;
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
        regs <= {{6{32'b0}}};
    else
        regs <= regs_nxt;
end

always_comb begin
    regs_nxt = regs;

    if (data_bus.req && data_bus.we) begin
        case (data_bus.addr[11:0])
        GPIO_ODR_OFFSET:    regs_nxt.odr = data_bus.wdata;
        GPIO_IDR_OFFSET:    regs_nxt.idr = data_bus.wdata;
        GPIO_RIER_OFFSET:   regs_nxt.rier = data_bus.wdata;
        GPIO_RISR_OFFSET:   regs_nxt.risr = data_bus.wdata;
        GPIO_FIER_OFFSET:   regs_nxt.fier = data_bus.wdata;
        GPIO_FISR_OFFSET:   regs_nxt.fisr = data_bus.wdata;
        endcase
    end

    /* 0x004: input data reg */
    regs_nxt.idr = gpio_bus.din;

    /* 0x00c: rising-edge interrupt status reg */
    for (int i = 0; i < 32; ++i) begin
        if (rising_edge_interrupt_detected[i]) begin
            if (is_reg_written(GPIO_RISR_OFFSET))
                regs_nxt.risr[i] = data_bus.wdata[i] | 1'b1;
            else
                regs_nxt.risr[i] = 1'b1;
        end
    end

    /* 0x014: falling-edge interrupt status reg */
    for (int i = 0; i < 32; ++i) begin
        if (falling_edge_interrupt_detected[i]) begin
            if (is_reg_written(GPIO_FISR_OFFSET))
                regs_nxt.fisr[i] = data_bus.wdata[i] | 1'b1;
            else
                regs_nxt.fisr[i] = 1'b1;
        end
    end
end

/* Registers readout */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_bus.rdata <= 32'b0;
    end else begin
        if (data_bus.req) begin
            case (data_bus.addr[11:0])
            GPIO_ODR_OFFSET:    data_bus.rdata <= regs.odr;
            GPIO_IDR_OFFSET:    data_bus.rdata <= regs.idr;
            GPIO_RIER_OFFSET:   data_bus.rdata <= regs.rier;
            GPIO_RISR_OFFSET:   data_bus.rdata <= regs.risr;
            GPIO_FIER_OFFSET:   data_bus.rdata <= regs.fier;
            GPIO_FISR_OFFSET:   data_bus.rdata <= regs.fisr;
            endcase
        end
    end
end

endmodule
