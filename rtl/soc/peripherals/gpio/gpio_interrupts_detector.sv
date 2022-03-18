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

import gpio_pkg::*;

module gpio_interrupts_detector (
    input logic         clk,

    output logic [31:0] rising_edge_interrupt_detected,
    output logic [31:0] falling_edge_interrupt_detected,
    input gpio_regs_t   regs,
    input logic [31:0]  din
);


/**
 * Module internal logic
 */

always_comb begin
    for (int i = 0; i < 32; ++i) begin
        rising_edge_interrupt_detected[i] = regs.rier[i] & ~regs.idr[i] & din[i];
        falling_edge_interrupt_detected[i] = regs.fier[i] & regs.idr[i] & ~din[i];
    end
end

endmodule
