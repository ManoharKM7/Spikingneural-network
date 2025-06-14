`timescale 1ns/1ps

module channel #(
    parameter WIDTH = 34
)(
    input clk,
    input rst,
    input [WIDTH-1:0] data_in,
    input send_req,
    output reg send_ack,

    output reg [WIDTH-1:0] data_out,
    output reg recv_req,
    input recv_ack
);

    reg [1:0] state;
    localparam IDLE = 2'b00, SEND = 2'b01, WAIT_ACK = 2'b10;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            send_ack <= 0;
            recv_req <= 0;
            data_out <= 0;
        end else begin
            case(state)
                IDLE: begin
                    if (send_req) begin
                        data_out <= data_in;
                        recv_req <= 1;
                        state <= SEND;
                    end
                end

                SEND: begin
                    if (recv_ack) begin
                        recv_req <= 0;
                        send_ack <= 1;
                        state <= WAIT_ACK;
                    end
                end

                WAIT_ACK: begin
                    if (!send_req) begin
                        send_ack <= 0;
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
