`timescale 1ns/1ps

module arbiter_pipeline_2 (
    input clk,
    input rst,
    input [1:0] A_status,
    input [1:0] B_status,
    input [1:0] A_data,
    input [1:0] B_data,
    output reg W_out,
    output reg O_out
);
    parameter FL = 2;
    parameter BL = 2;
    parameter WIDTH = 2;

    reg [1:0] a, b;
    reg [31:0] counter = 0;
    integer winner;

    localparam IDLE = 2'b00;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            W_out <= 0;
            O_out <= 0;
            counter <= 0;
        end else begin
            if (A_status != IDLE || B_status != IDLE) begin
                // Decide the winner
                if (A_status != IDLE && B_status != IDLE)
                    winner = ($random % 2 == 0) ? 0 : 1;
                else if (A_status != IDLE)
                    winner = 0;
                else
                    winner = 1;

                // Receive data and send output
                if (winner == 0) begin
                    a <= A_data;
                    #(FL);
                    W_out <= 0;
                    O_out <= 0;
                    #(BL);
                end else begin
                    b <= B_data;
                    #(FL);
                    W_out <= 1;
                    O_out <= 1;
                    #(BL);
                end
            end
        end
    end
endmodule
