module pe_combined(
    input clk,
    input rst,
    input [33:0] packet_in,
    output reg [33:0] packet_out
);

// === PARAMETERS ===
parameter WIDTH = 34;
parameter WIDTH_filter = 24;
parameter WIDTH_ifmap = 5;
parameter WIDTH_addr = 4;
parameter WIDTH_unit = 8;
parameter range = 2;
parameter input_type = 2'b00;
parameter kernel_type = 2'b01;
parameter mem_type = 2'b10;
parameter FL = 2;
parameter BL = 1;
parameter PE1_addr = 4'b0010;
parameter PE2_addr = 4'b0110;
parameter PE3_addr = 4'b1010;
parameter adder1_addr = 4'b0001;
parameter adder2_addr = 4'b0101;
parameter adder3_addr = 4'b1001;

// === REGISTERS ===
reg [WIDTH-1:0] value;
reg [WIDTH_filter-1:0] filter_value;
reg [WIDTH_ifmap-1:0] ifmap_value, ifmap_value_old;
reg [WIDTH_unit-1:0] filter_unit;
reg ifmap_bit;
reg [WIDTH_addr-1:0] addr_value;

reg [7:0] mul_out, adder_sum, acc_value, split_input, final_result;
reg [1:0] flag; // for ifmap receive count
reg [1:0] count; // for loop control

reg [33:0] packet_value;

reg [3:0] i = 0;
reg [3:0] j = 0;

// === FSM States ===
reg [3:0] state;
localparam IDLE=0, RECEIVE=1, PROCESS_IFMAP=2, PROCESS_FILTER=3,
           MULTIPLY=4, ADD=5, SPLIT=6, ACCUMULATE=7, PACKETIZE=8;

// === MAIN FSM ===
always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        packet_out <= 0;
        flag <= 0;
        acc_value <= 0;
    end else begin
        case(state)
            IDLE: begin
                state <= RECEIVE;
            end

            RECEIVE: begin
                value <= packet_in;
                addr_value <= packet_in[WIDTH-5:WIDTH-8];
                if (packet_in[WIDTH-9:WIDTH-10] == input_type) begin
                    ifmap_value <= packet_in[WIDTH-30:0];
                    state <= PROCESS_IFMAP;
                end else if (packet_in[WIDTH-9:WIDTH-10] == kernel_type) begin
                    filter_value <= packet_in[WIDTH-11:0];
                    state <= PROCESS_FILTER;
                end
            end

            PROCESS_IFMAP: begin
                flag <= flag + 1;
                if (flag >= 2) begin
                    ifmap_value_old <= ifmap_value;
                end
                i <= 0;
                j <= 0;
                state <= MULTIPLY;
            end

            PROCESS_FILTER: begin
                // decode filter unit
                case(i)
                    0: filter_unit <= filter_value[7:0];
                    1: filter_unit <= filter_value[15:8];
                    2: filter_unit <= filter_value[23:16];
                endcase
                state <= MULTIPLY;
            end

            MULTIPLY: begin
                ifmap_bit <= ifmap_value[i];
                mul_out <= filter_unit * ifmap_bit;
                state <= ADD;
            end

            ADD: begin
                adder_sum <= mul_out + acc_value;
                state <= SPLIT;
            end

            SPLIT: begin
                if (j == range) begin
                    final_result <= adder_sum;
                    acc_value <= 0;
                    state <= PACKETIZE;
                end else begin
                    acc_value <= adder_sum;
                    i <= i + 1;
                    if (i == range) begin
                        i <= 0;
                        j <= j + 1;
                    end
                    state <= MULTIPLY;
                end
            end

            PACKETIZE: begin
                // result packetization
                case(j)
                    0: packet_value = {addr_value, adder1_addr, mem_type, 16'b0, final_result};
                    1: packet_value = {addr_value, adder2_addr, mem_type, 16'b0, final_result};
                    2: packet_value = {addr_value, adder3_addr, mem_type, 16'b0, final_result};
                endcase
                packet_out <= packet_value;
                if (addr_value == PE2_addr)
                    packet_out <= {addr_value, PE1_addr, input_type, 18'b0, ifmap_value_old};
                else if (addr_value == PE3_addr)
                    packet_out <= {addr_value, PE2_addr, input_type, 18'b0, ifmap_value_old};
                state <= IDLE;
            end

            default: state <= IDLE;
        endcase
    end
end

endmodule
