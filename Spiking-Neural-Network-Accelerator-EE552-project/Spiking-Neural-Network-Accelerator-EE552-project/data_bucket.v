`timescale 1ns/1ps

module data_bucket (
    input wire clk,
    input wire rst,
    input wire [11:0] r_data,      // Data input
    input wire r_valid,            // Valid signal from sender
    output reg r_ready             // Ready signal to sender
);
    parameter WIDTH = 12;
    parameter BL = 2;

    reg [11:0] ReceiveValue = 0;
    integer cycleCounter = 0;
    real timeOfReceive = 0;
    real cycleTime = 0;
    real averageThroughput = 0;
    real averageCycleTime = 0;
    real sumOfCycleTimes = 0;

    initial begin
        r_ready = 1'b0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cycleCounter <= 0;
            timeOfReceive <= 0;
            cycleTime <= 0;
            sumOfCycleTimes <= 0;
            averageThroughput <= 0;
            averageCycleTime <= 0;
            r_ready <= 0;
        end else begin
            r_ready <= 1;
            if (r_valid) begin
                timeOfReceive = $time;
                ReceiveValue <= r_data;

                #BL;

                cycleCounter = cycleCounter + 1;

                cycleTime = $time - timeOfReceive;
                averageThroughput = cycleCounter / $time;
                sumOfCycleTimes = sumOfCycleTimes + cycleTime;
                averageCycleTime = sumOfCycleTimes / cycleCounter;

                $display("Execution cycle = %d, Cycle Time = %0t, Avg Cycle Time = %0f, Avg Throughput = %0f",
                    cycleCounter, cycleTime, averageCycleTime, averageThroughput);
            end
        end
    end
endmodule
