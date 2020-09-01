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

module spi_flash_memory (
    output logic miso,

    input logic  clk,
    input logic  rst_n,
    input logic  ss,
    input logic  sck,
    input logic  mosi
);


/**
 * User defined types
 */

typedef enum logic {
    IDLE,
    TRANSMISSION
} state_t;


/**
 * Local variables and signals
 */

logic [31:0] rdata, addr, addr_nxt;
logic [3:0]  bytes_counter, bytes_counter_nxt;
logic [7:0]  tx_data, tx_data_nxt;

state_t state, state_nxt;


/**
 * Submodules placement
 */

spi_mem u_spi_mem (
    .rdata,
    .addr
);

spi_slave u_spi_slave(
    .busy(),
    .rx_data(),
    .clk,
    .rst_n,
    .tx_data,
    .miso,
    .ss,
    .sck,
    .mosi
);


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        state <= IDLE;
    else
        state <= state_nxt;
end

always_comb begin
    case (state)
        IDLE:           state_nxt = !ss ? TRANSMISSION : IDLE;
        TRANSMISSION:   state_nxt = ss ? IDLE : TRANSMISSION;
        default:        state_nxt = IDLE;
    endcase
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        addr <= 'b0;
        bytes_counter <= 'b0;
        tx_data <= 'b0;
    end
    else begin
        addr <= addr_nxt;
        bytes_counter <= bytes_counter_nxt;
        tx_data <= tx_data_nxt;
    end
end

always_comb begin
    addr_nxt = addr;
    bytes_counter_nxt = bytes_counter;
    tx_data_nxt = tx_data;

    case (state)
        IDLE: begin
            case (bytes_counter)
                3:          tx_data_nxt = rdata[31:24];
                2:          tx_data_nxt = rdata[23:16];
                1:          tx_data_nxt = rdata[15:8];
                0:          tx_data_nxt = rdata[7:0];
                default:    tx_data_nxt = rdata[7:0];
            endcase
        end
        TRANSMISSION: begin
            if (ss) begin
                if (bytes_counter == 3) begin
                    addr_nxt = (addr == 4095) ? 0 : addr + 4;
                    bytes_counter_nxt = 0;
                end
                else begin
                    bytes_counter_nxt = bytes_counter + 1;
                end
            end
        end
    endcase
end

endmodule
