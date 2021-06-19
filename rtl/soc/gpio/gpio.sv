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

gpio_t       gpio;
gpio_reg_t   requested_reg;
logic [31:0] interrupt_detected;


/**
 * Signals assignments
 */

assign data_bus.err = 1'b0;
assign gpio_bus.irq =| gpio.isr;
assign gpio_bus.dout = gpio.odr;


/**
 * Submodules placement
 */

gpio_offset_decoder u_gpio_offset_decoder (
    .gnt(data_bus.gnt),
    .rvalid(data_bus.rvalid),
    .requested_reg,
    .clk,
    .rst_n,
    .req(data_bus.req),
    .addr(data_bus.addr)
);

gpio_interrupt_detector u_gpio_interrupt_detector (
    .interrupt_detected,
    .clk,
    .rst_n,
    .io_in(gpio_bus.din),
    .ier(gpio.ier),
    .rier(gpio.rier),
    .fier(gpio.fier)
);


/**
 * Module internal logic
 */

/* Registers update */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        gpio.cr <= 32'b0;
        gpio.sr <= 32'b0;
        gpio.odr <= 32'b0;
        gpio.idr <= 32'b0;
        gpio.ier <= 32'b0;
        gpio.isr <= 32'b0;
        gpio.rier <= 32'b0;
        gpio.fier <= 32'b0;
    end
    else begin
        gpio.idr <= gpio_bus.din;

        if (data_bus.we) begin
            case (requested_reg)
            GPIO_CR:    gpio.cr <= data_bus.wdata;
            GPIO_SR:    gpio.sr <= data_bus.wdata;
            GPIO_ODR:   gpio.odr <= data_bus.wdata;
            GPIO_IER:   gpio.ier <= data_bus.wdata;
            GPIO_ISR:   gpio.isr <= data_bus.wdata;
            GPIO_RIER:  gpio.rier <= data_bus.wdata;
            GPIO_FIER:  gpio.fier <= data_bus.wdata;
            endcase
        end

        if (interrupt_detected) begin
            if (requested_reg == GPIO_ISR && data_bus.we)
                gpio.isr <= data_bus.wdata | interrupt_detected;
            else
                gpio.isr <= gpio.isr | interrupt_detected;
        end
    end
end


/* Registers readout */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_bus.rdata <= 32'b0;
    end
    else begin
        case (requested_reg)
        GPIO_CR:    data_bus.rdata <= gpio.cr;
        GPIO_SR:    data_bus.rdata <= gpio.sr;
        GPIO_ODR:   data_bus.rdata <= gpio.odr;
        GPIO_IDR:   data_bus.rdata <= gpio.idr;
        GPIO_IER:   data_bus.rdata <= gpio.ier;
        GPIO_ISR:   data_bus.rdata <= gpio.isr;
        GPIO_RIER:  data_bus.rdata <= gpio.rier;
        GPIO_FIER:  data_bus.rdata <= gpio.fier;
        endcase
    end
end

endmodule
