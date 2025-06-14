module packet_analyser_5 #(
    parameter FL = 2,
    parameter BL = 1,
    parameter WIDTH = 34,
    parameter [1:0] Xaddr = 2'b00,
    parameter [1:0] Yaddr = 2'b00
)(
    input wire clk,
    input wire rst,

    input wire [WIDTH-1:0] N_data_in,
    input wire N_valid_in,
    output reg [1:0] N_ctrl,
    output reg [WIDTH-1:0] N_data_out,
    output reg N_valid_out,

    input wire [WIDTH-1:0] S_data_in,
    input wire S_valid_in,
    output reg [1:0] S_ctrl,
    output reg [WIDTH-1:0] S_data_out,
    output reg S_valid_out,

    input wire [WIDTH-1:0] E_data_in,
    input wire E_valid_in,
    output reg [1:0] E_ctrl,
    output reg [WIDTH-1:0] E_data_out,
    output reg E_valid_out,

    input wire [WIDTH-1:0] W_data_in,
    input wire W_valid_in,
    output reg [1:0] W_ctrl,
    output reg [WIDTH-1:0] W_data_out,
    output reg W_valid_out,

    input wire [WIDTH-1:0] P_data_in,
    input wire P_valid_in,
    output reg [1:0] P_ctrl,
    output reg [WIDTH-1:0] P_data_out,
    output reg P_valid_out
);

// Direction codes
localparam WEST  = 2'b00;
localparam NORTH = 2'b01;
localparam SOUTH = 2'b10;
localparam EAST  = 2'b11;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        N_ctrl <= 0; N_data_out <= 0; N_valid_out <= 0;
        S_ctrl <= 0; S_data_out <= 0; S_valid_out <= 0;
        E_ctrl <= 0; E_data_out <= 0; E_valid_out <= 0;
        W_ctrl <= 0; W_data_out <= 0; W_valid_out <= 0;
        P_ctrl <= 0; P_data_out <= 0; P_valid_out <= 0;
    end else begin
        // NORTH
        if (N_valid_in) begin
            N_data_out <= N_data_in;
            N_valid_out <= 1;
            casez ({N_data_in[29:28], N_data_in[27:26]})
                {Xaddr, Yaddr} : N_ctrl <= SOUTH;
                default: begin
                    if (N_data_in[29:28] > Xaddr) N_ctrl <= EAST;
                    else if (N_data_in[29:28] < Xaddr) N_ctrl <= WEST;
                    else if (N_data_in[27:26] > Yaddr) N_ctrl <= SOUTH;
                    else if (N_data_in[27:26] < Yaddr) N_ctrl <= NORTH;
                end
            endcase
        end else N_valid_out <= 0;

        // SOUTH
        if (S_valid_in) begin
            S_data_out <= S_data_in;
            S_valid_out <= 1;
            casez ({S_data_in[29:28], S_data_in[27:26]})
                {Xaddr, Yaddr} : S_ctrl <= SOUTH;
                default: begin
                    if (S_data_in[29:28] > Xaddr) S_ctrl <= EAST;
                    else if (S_data_in[29:28] < Xaddr) S_ctrl <= WEST;
                    else if (S_data_in[27:26] > Yaddr) S_ctrl <= SOUTH;
                    else if (S_data_in[27:26] < Yaddr) S_ctrl <= NORTH;
                end
            endcase
        end else S_valid_out <= 0;

        // EAST
        if (E_valid_in) begin
            E_data_out <= E_data_in;
            E_valid_out <= 1;
            casez ({E_data_in[29:28], E_data_in[27:26]})
                {Xaddr, Yaddr} : E_ctrl <= SOUTH;
                default: begin
                    if (E_data_in[29:28] > Xaddr) E_ctrl <= EAST;
                    else if (E_data_in[29:28] < Xaddr) E_ctrl <= WEST;
                    else if (E_data_in[27:26] > Yaddr) E_ctrl <= SOUTH;
                    else if (E_data_in[27:26] < Yaddr) E_ctrl <= NORTH;
                end
            endcase
        end else E_valid_out <= 0;

        // WEST
        if (W_valid_in) begin
            W_data_out <= W_data_in;
            W_valid_out <= 1;
            casez ({W_data_in[29:28], W_data_in[27:26]})
                {Xaddr, Yaddr} : W_ctrl <= SOUTH;
                default: begin
                    if (W_data_in[29:28] > Xaddr) W_ctrl <= EAST;
                    else if (W_data_in[29:28] < Xaddr) W_ctrl <= WEST;
                    else if (W_data_in[27:26] > Yaddr) W_ctrl <= SOUTH;
                    else if (W_data_in[27:26] < Yaddr) W_ctrl <= NORTH;
                end
            endcase
        end else W_valid_out <= 0;

        // PE
        if (P_valid_in) begin
            P_data_out <= P_data_in;
            P_valid_out <= 1;
            if (P_data_in[29:28] > Xaddr) P_ctrl <= EAST;
            else if (P_data_in[29:28] < Xaddr) P_ctrl <= WEST;
            else if (P_data_in[27:26] > Yaddr) P_ctrl <= SOUTH;
            else if (P_data_in[27:26] < Yaddr) P_ctrl <= NORTH;
        end else P_valid_out <= 0;
    end
end

endmodule








//-------------------------------------------------------------------------------------------------------------------------------------------------------
module split_5(interface L, interface Ctrl, interface A, B, C, D);
parameter FL=4;
parameter BL=6;
parameter WIDTH=34;
logic [WIDTH-1:0]packet;
logic [1:0]controlPort;
always begin
	fork
	begin
	L.Receive(packet);
	//$display("router_split:%m---6. Split already receive packet(%b)",packet);
	#FL;
	end
	begin
	Ctrl.Receive(controlPort);
	//$display("router_split:%m---6. Split already receive contrl(%b)",controlPort);
	#FL;
	end
	join

	if(controlPort==2'b00) begin
	A.Send(packet);
	//$display("router_split:%m---6. Split already send packet(%b) to A port",packet);
	#BL; end
	else if(controlPort==2'b01) begin
	B.Send(packet);
	//$display("router_split:%m---6. Split already send packet(%b) to B port",packet);
	#BL; end
	else if(controlPort==2'b10) begin
	C.Send(packet);
	//$display("router_split:%m---6. Split already send packet(%b) to C port",packet);
	#BL; end
	else if(controlPort==2'b11) begin
	D.Send(packet);
//	$display("router_split:%m---6. Split already send packet(%b) to D port",packet);
	#BL; end
end
endmodule






module split_5(
    input wire clk,
    input wire rst,
    input wire [33:0] packet,
    input wire [1:0] controlPort,
    output reg [33:0] A,
    output reg [33:0] B,
    output reg [33:0] C,
    output reg [33:0] D
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            A <= 34'd0;
            B <= 34'd0;
            C <= 34'd0;
            D <= 34'd0;
        end else begin
            case (controlPort)
                2'b00: A <= packet;
                2'b01: B <= packet;
                2'b10: C <= packet;
                2'b11: D <= packet;
            endcase
        end
    end
endmodule
