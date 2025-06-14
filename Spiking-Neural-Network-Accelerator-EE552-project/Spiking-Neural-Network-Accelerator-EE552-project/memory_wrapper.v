`timescale 1ns / 1ps

module memory_wrapper #(
    parameter WIDTH = 8,
    parameter WIDTH_NOC = 34,
    parameter WIDTH_IFMAP = 5,
    parameter WIDTH_FILTER = 24,
    parameter TIMESTEPS = 10,
    parameter MEM_DELAY = 15
)(
    input clk,
    input rst,

    // Simplified memory and NoC interfaces
    output reg [3:0] mem_read_x,
    output reg [3:0] mem_read_y,
    output reg mem_read_en,
    input [WIDTH-1:0] mem_read_data,

    output reg noc_send_en,
    output reg [WIDTH_NOC-1:0] noc_data_out
);

    // FSM states
    typedef enum reg [2:0] {
        IDLE,
        READ_FILTER_ROW,
        WAIT_MEM,
        COMBINE_FILTER,
        SEND_TO_NOC,
        DONE
    } state_t;

    state_t state;

    integer i, j;
    reg [7:0] filter_buf[2:0]; // for by1, by2, by3
    reg [23:0] filter_combined;
    reg [33:0] noc_packet;

    // FSM
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            i <= 0;
            j <= 0;
            mem_read_en <= 0;
            noc_send_en <= 0;
        end else begin
            case (state)
                IDLE: begin
                    i <= 0;
                    j <= 0;
                    state <= READ_FILTER_ROW;
                end

                READ_FILTER_ROW: begin
                    mem_read_en <= 1;
                    mem_read_x <= i;
                    mem_read_y <= j;
                    state <= WAIT_MEM;
                end

                WAIT_MEM: begin
                    mem_read_en <= 0;
                    filter_buf[j] <= mem_read_data;
                    j <= j + 1;
                    if (j == 2)
                        state <= COMBINE_FILTER;
                    else
                        state <= READ_FILTER_ROW;
                end

                COMBINE_FILTER: begin
                    filter_combined <= {filter_buf[2], filter_buf[1], filter_buf[0]};
                    state <= SEND_TO_NOC;
                end

                SEND_TO_NOC: begin
                    case (i)
                        0: noc_packet <= {4'b0000, 4'b0010, 2'b01, filter_combined}; // wrapper_addr, PE1_addr
                        1: noc_packet <= {4'b0000, 4'b0110, 2'b01, filter_combined}; // PE2
                        2: noc_packet <= {4'b0000, 4'b1010, 2'b01, filter_combined}; // PE3
                    endcase
                    noc_data_out <= noc_packet;
                    noc_send_en <= 1;
                    j <= 0;
                    i <= i + 1;
                    if (i == 2)
                        state <= DONE;
                    else
                        state <= READ_FILTER_ROW;
                end

                DONE: begin
                    noc_send_en <= 0;
                    // Other operations go here (ifmaps, output spikes)
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
