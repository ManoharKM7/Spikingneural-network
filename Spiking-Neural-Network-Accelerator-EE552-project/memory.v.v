`timescale 1ns / 1ps

module memory(
    input wire clk,
    input wire rst,

    // Simulating interface behavior with procedural inputs
    input wire        read_en,
    input wire [1:0]  read_type,   // 0 = V_mem, 1 = spike, 2 = filter
    input wire [3:0]  read_row,
    input wire [3:0]  read_col,
    output reg [7:0]  read_data,

    input wire        write_en,
    input wire [1:0]  write_type,  // 0 = V_mem, 1 = output spike
    input wire [3:0]  write_row,
    input wire [3:0]  write_col,
    input wire [7:0]  write_data,

    input wire        timestep_advance,
    output reg        done
);

parameter TIMESTEPS = 10;
parameter F_ROWS = 3;
parameter F_COLS = 3;
parameter F_WIDTH = 8;
parameter IF_ROWS = 5;
parameter IF_COLS = 5;
parameter OF_ROWS = 3;
parameter OF_COLS = 3;
parameter V_POT_WIDTH = 8;

reg [F_WIDTH-1:0] filter_mem [0:F_ROWS-1][0:F_COLS-1];
reg if_mem [0:TIMESTEPS-1][0:IF_ROWS-1][0:IF_COLS-1];
reg of_mem [0:TIMESTEPS-1][0:OF_ROWS-1][0:OF_COLS-1];
reg golden_of_mem [0:OF_ROWS-1][0:OF_COLS-1];
reg [V_POT_WIDTH-1:0] V_pot_mem [0:OF_ROWS-1][0:OF_COLS-1];

integer t;
integer i, j, k;

// Flattened pre-load arrays
reg [F_WIDTH-1:0] pre_golden_memory [0:OF_ROWS*OF_COLS-1];
reg [F_WIDTH-1:0] pre_filt_memory [0:F_ROWS*F_COLS-1];
reg pre_ifmaps_mem [0:IF_COLS*IF_ROWS*TIMESTEPS-1];

initial begin
    $readmemb("sparse_output_bin.mem", pre_golden_memory);
    $readmemh("sparse_kernel_hex.mem", pre_filt_memory);
    $readmemb("sparse_ifmaps_bin.mem", pre_ifmaps_mem);

    for (i = 0; i < OF_ROWS; i = i + 1)
        for (j = 0; j < OF_COLS; j = j + 1)
            golden_of_mem[i][j] = pre_golden_memory[i * OF_COLS + j];

    for (i = 0; i < F_ROWS; i = i + 1)
        for (j = 0; j < F_COLS; j = j + 1)
            filter_mem[i][j] = pre_filt_memory[i * F_COLS + j];

    for (t = 0; t < TIMESTEPS; t = t + 1)
        for (i = 0; i < IF_ROWS; i = i + 1)
            for (j = 0; j < IF_COLS; j = j + 1)
                if_mem[t][i][j] = pre_ifmaps_mem[(IF_ROWS * IF_COLS) * t + (IF_COLS * i + j)];

    for (t = 0; t < TIMESTEPS; t = t + 1)
        for (i = 0; i < OF_ROWS; i = i + 1)
            for (j = 0; j < OF_COLS; j = j + 1)
                of_mem[t][i][j] = 1'b0;

    $display("Memory initialized.");
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        t <= 0;
        done <= 0;
    end else begin
        if (read_en) begin
            case (read_type)
                2'd0: read_data <= V_pot_mem[read_row][read_col]; // V_mem
                2'd1: read_data <= if_mem[t][read_row][read_col]; // input spike
                2'd2: read_data <= filter_mem[read_row][read_col]; // filter
                default: read_data <= 8'hFF;
            endcase
        end

        if (write_en) begin
            case (write_type)
                2'd0: V_pot_mem[write_row][write_col] <= write_data;
                2'd1: of_mem[t][write_row][write_col] <= 1'b1;
            endcase
        end

        if (timestep_advance) begin
            if (t < TIMESTEPS-1)
                t <= t + 1;
            else
                done <= 1'b1;
        end
    end
end

endmodule
