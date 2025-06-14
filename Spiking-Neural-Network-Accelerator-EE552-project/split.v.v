module split_4 (
    input wire clk,
    input wire rst,
    input wire [33:0] L_data,
    input wire L_valid,
    input wire [1:0] Ctrl_data,
    input wire Ctrl_valid,
    output reg [33:0] A_data,
    output reg A_valid,
    output reg [33:0] B_data,
    output reg B_valid,
    output reg [33:0] C_data,
    output reg C_valid,
    output reg [33:0] D_data,
    output reg D_valid
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            A_valid <= 0;
            B_valid <= 0;
            C_valid <= 0;
            D_valid <= 0;
        end else if (L_valid && Ctrl_valid) begin
            A_valid <= 0; B_valid <= 0; C_valid <= 0; D_valid <= 0;
            case (Ctrl_data)
                2'b00: begin A_data <= L_data; A_valid <= 1; end
                2'b01: begin B_data <= L_data; B_valid <= 1; end
                2'b10: begin C_data <= L_data; C_valid <= 1; end
                2'b11: begin D_data <= L_data; D_valid <= 1; end
            endcase
        end
    end
endmodule


module data_generator_4 (
    input wire clk,
    input wire rst,
    output reg [33:0] data_out,
    output reg valid
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            valid <= 0;
        end else begin
            data_out <= $random % (2**15);  // 15-bit random
            valid <= 1;
        end
    end
endmodule

module data_generator_ctrl (
    input wire clk,
    input wire rst,
    output reg [1:0] ctrl_out,
    output reg valid
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            valid <= 0;
        end else begin
            ctrl_out <= $random % 4;  // Generates values 0 to 3
            valid <= 1;
        end
    end
endmodule


module data_bucket_4 (
    input wire clk,
    input wire rst,
    input wire [33:0] data_in,
    input wire valid
);
    always @(posedge clk) begin
        if (valid) begin
            $display("Received: %d @ %t", data_in, $time);
        end
    end
endmodule




module split_tb;
    reg clk = 0, rst = 1;
    always #5 clk = ~clk; // 10ns clock

    wire [33:0] L_data;
    wire L_valid;
    wire [1:0] Ctrl_data;
    wire Ctrl_valid;
    
    wire [33:0] A_data, B_data, C_data, D_data;
    wire A_valid, B_valid, C_valid, D_valid;

    data_generator_4 dg_l (.clk(clk), .rst(rst), .data_out(L_data), .valid(L_valid));
    data_generator_ctrl dg_ctrl (.clk(clk), .rst(rst), .ctrl_out(Ctrl_data), .valid(Ctrl_valid));

    split_4 split_inst (
        .clk(clk), .rst(rst),
        .L_data(L_data), .L_valid(L_valid),
        .Ctrl_data(Ctrl_data), .Ctrl_valid(Ctrl_valid),
        .A_data(A_data), .A_valid(A_valid),
        .B_data(B_data), .B_valid(B_valid),
        .C_data(C_data), .C_valid(C_valid),
        .D_data(D_data), .D_valid(D_valid)
    );

    data_bucket_4 dbA (.clk(clk), .rst(rst), .data_in(A_data), .valid(A_valid));
    data_bucket_4 dbB (.clk(clk), .rst(rst), .data_in(B_data), .valid(B_valid));
    data_bucket_4 dbC (.clk(clk), .rst(rst), .data_in(C_data), .valid(C_valid));
    data_bucket_4 dbD (.clk(clk), .rst(rst), .data_in(D_data), .valid(D_valid));

    initial begin
        #12 rst = 0;
        #800 $stop;
    end
endmodule

