`timescale 1ns/100ps

module Partial_sum_adder (
    input clk,
    input rst_n,
    input [33:0] in_data,
    input in_valid,
    output reg in_ready,

    output reg [33:0] out_data,
    output reg out_valid
);

parameter adder_number     = 2'b00;
parameter adder3_num       = 2'b10;
parameter WIDTH            = 34;
parameter memb_p_WIDTH     = 8;
parameter threshold        = 16;
parameter PE1_addr         = 4'b0010;
parameter PE2_addr         = 4'b0110;
parameter PE3_addr         = 4'b1010;
parameter Adder_addr       = 4'b0110;
parameter Mem_addr         = 4'b0000;
parameter WR_addr          = 4'b0000;
parameter Out_to_Mem_zeros = 20'b0;
parameter MP_to_Mem_zeros  = 16'b0;
parameter count_number     = 2'b10;
parameter done_signal      = 4'b1111;
parameter mem_p_type       = 2'b10;
parameter output_spike_type= 2'b11;

reg [7:0] partial_PE1, partial_PE2, partial_PE3, membrane_potential;
reg output_spike;
reg [1:0] count;
reg first_time;

reg [1:0] receive_count;

reg [33:0] input_buffer [0:3]; // Buffer to store 4 packets
reg process_start;

integer i;

// State Machine
typedef enum reg [1:0] {
    IDLE,
    RECEIVE,
    PROCESS,
    SEND
} state_t;

state_t current_state, next_state;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end

// Next State Logic
always @(*) begin
    case (current_state)
        IDLE:     next_state = in_valid ? RECEIVE : IDLE;
        RECEIVE:  next_state = (receive_count == 2'd3) ? PROCESS : RECEIVE;
        PROCESS:  next_state = SEND;
        SEND:     next_state = IDLE;
        default:  next_state = IDLE;
    endcase
end

// Main FSM
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        receive_count     <= 0;
        process_start     <= 0;
        count             <= 0;
        first_time        <= 0;
        in_ready          <= 1;
        out_valid         <= 0;
        output_spike      <= 0;
        membrane_potential<= 0;
    end else begin
        case (current_state)
            IDLE: begin
                receive_count <= 0;
                in_ready <= 1;
                out_valid <= 0;
            end

            RECEIVE: begin
                if (in_valid && in_ready) begin
                    input_buffer[receive_count] <= in_data;
                    receive_count <= receive_count + 1;
                end
            end

            PROCESS: begin
                // Decode packets
                for (i = 0; i < 4; i = i + 1) begin
                    case (input_buffer[i][33:30])
                        PE1_addr: partial_PE1 = input_buffer[i][7:0];
                        PE2_addr: partial_PE2 = input_buffer[i][7:0];
                        PE3_addr: partial_PE3 = input_buffer[i][7:0];
                        WR_addr: begin
                            if (input_buffer[i][25:24] == mem_p_type)
                                membrane_potential = input_buffer[i][7:0];
                        end
                    endcase
                end

                // Compute
                if (first_time)
                    membrane_potential = membrane_potential + partial_PE1 + partial_PE2 + partial_PE3;
                else
                    membrane_potential = partial_PE1 + partial_PE2 + partial_PE3;

                // Threshold
                if (membrane_potential >= threshold) begin
                    output_spike = 1;
                    membrane_potential = membrane_potential - threshold;
                end else begin
                    output_spike = 0;
                end
            end

            SEND: begin
                // Send Membrane Potential
                out_data = {Adder_addr, Mem_addr, mem_p_type, MP_to_Mem_zeros, membrane_potential};
                out_valid = 1;

                // Send spike
                if (output_spike) begin
                    out_data = {Adder_addr, Mem_addr, output_spike_type, Out_to_Mem_zeros, {count, adder_number}};
                    out_valid = 1;
                end

                // Done signal from adder3
                if (adder_number == adder3_num) begin
                    out_data = {Adder_addr, Mem_addr, output_spike_type, Out_to_Mem_zeros, done_signal};
                    out_valid = 1;
                end

                count <= count + 1;
                if (count > count_number) begin
                    count <= 0;
                    first_time <= 1;
                end
            end
        endcase
    end
end

endmodule
