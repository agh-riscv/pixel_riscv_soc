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

module timer (
    output logic        active,
    output logic        match_occurred,
    output logic [31:0] counter,
    input logic         clk,
    input logic         rst_n,
    input logic         trigger,
    input logic         halt,
    input logic         single_shot,
    input logic [31:0]  compare_value
);


/**
 * User defined types
 */

typedef enum logic {
    IDLE,
    COUNT
} state_t;

typedef enum logic {
    SINGLE_SHOT,
    CONTINUOUS
} run_mode_t;


/**
 * Local variables and signals
 */

run_mode_t   run_mode, run_mode_nxt;
logic [31:0] counter_nxt;

state_t state, state_nxt;


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        run_mode <= SINGLE_SHOT;
        counter <= 32'b0;
    end
    else begin
        state <= state_nxt;
        run_mode <= run_mode_nxt;
        counter <= counter_nxt;
    end
end

always_comb begin
    state_nxt = state;
    run_mode_nxt = run_mode;
    counter_nxt = counter;

    case (state)
        IDLE: begin
            if (trigger) begin
                state_nxt = COUNT;
                run_mode_nxt = single_shot ? SINGLE_SHOT : CONTINUOUS;
            end
        end
        COUNT: begin
            if (halt) begin
                state_nxt = IDLE;
                counter_nxt = 32'b0;
            end
            else begin
                if (counter == compare_value) begin
                    state_nxt = (run_mode == SINGLE_SHOT) ? IDLE : COUNT;
                    counter_nxt = 32'b0;
                end
                else begin
                    counter_nxt = counter + 1;
                end
            end
        end
    endcase
end

always_comb begin
    match_occurred = 1'b0;
    active = 1'b0;

    case (state)
        IDLE: ;
        COUNT: begin
            active = 1'b1;

            if (counter == compare_value)
                match_occurred = 1'b1;
        end
    endcase
end

endmodule
