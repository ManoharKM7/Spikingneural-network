`timescale 1ns/1ps

module data_generator (
    input  wire        clk,
    input  wire        rst,
    output reg  [33:0] r_data,
    output reg         r_valid,
    input  wire        r_ready
);
    parameter WIDTH = 34;
    parameter FL = 2;
    parameter MAX = 50;

    reg [3:0] state = 0;
    reg [33:0] SendValue;
    reg [15:0] zeros = 16'b0000_0000_0000_0000;

    initial begin
        r_data = 0;
        r_valid = 0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= 0;
            r_valid <= 0;
        end else begin
            case (state)
                0: begin
                    SendValue = {8'b1000_0100, 2'b10, {16{1'b0}}, 8'b0001_0011}; // 19 PE1
                    r_valid <= 1;
                    r_data <= SendValue;
                    state <= 1;
                end
                1: if (r_ready) begin
                    SendValue = {8'b1001_0100, 2'b10, {16{1'b0}}, 8'b0000_1100}; // 12 PE2
                    r_data <= SendValue;
                    state <= 2;
                end
                2: if (r_ready) begin
                    SendValue = {8'b1010_0100, 2'b10, {16{1'b0}}, 8'b0010_0111}; // 39 PE3
                    r_data <= SendValue;
                    state <= 3;
                end
                3: if (r_ready) begin
                    SendValue = {8'b1000_0100, 2'b10, {16{1'b0}}, 8'b0001_0011}; // 19 PE1
                    r_data <= SendValue;
                    state <= 4;
                end
                4: if (r_ready) begin
                    SendValue = {8'b1001_0100, 2'b10, {16{1'b0}}, 8'b0001_0011}; // 19 PE2
                    r_data <= SendValue;
                    state <= 5;
                end
                5: if (r_ready) begin
                    SendValue = {8'b1010_0100, 2'b10, {16{1'b0}}, 8'b0000_1001}; // 9 PE3
                    r_data <= SendValue;
                    state <= 6;
                end
                6: if (r_ready) begin
                    SendValue = {8'b1000_0100, 2'b10, {16{1'b0}}, 8'b0001_1011}; // 27 PE1
                    r_data <= SendValue;
                    state <= 7;
                end
                7: if (r_ready) begin
                    SendValue = {8'b1001_0100, 2'b10, {16{1'b0}}, 8'b0000_1000}; // 8 PE2
                    r_data <= SendValue;
                    state <= 8;
                end
                8: if (r_ready) begin
                    SendValue = {8'b1010_0100, 2'b10, {16{1'b0}}, 8'b0000_0000}; // 0 PE3
                    r_data <= SendValue;
                    state <= 9;
                end
                9: if (r_ready) begin
                    r_valid <= 0; // done sending all
                    state <= 10;
                end
                default: begin
                    // Idle
                    r_valid <= 0;
                end
            endcase
        end
    end
endmodule
