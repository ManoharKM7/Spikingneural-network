module PE_Adder_System (
    input  [4:0]  pe00_in,
    input  [7:0]  pe01a_in1, pe01a_in2, pe01a_in3,
    input  [7:0]  pe01b_in1, pe01b_in2, pe01b_in3,
    output [10:0] final_sum
);

    // Internal signals for partial sums (all 9 bits)
    wire [8:0] pe00_out;
    wire [8:0] pe01a_out;
    wire [8:0] pe01b_out;

    // PE00: Extend 5-bit to 9-bit
    assign pe00_out = {4'b0000, pe00_in};

    // PE01a: Add 3x8-bit inputs
    assign pe01a_out = pe01a_in1 + pe01a_in2 + pe01a_in3;

    // PE01b: Add 3x8-bit inputs
    assign pe01b_out = pe01b_in1 + pe01b_in2 + pe01b_in3;

    // Final sum of 3x9-bit values → 11-bit result
    assign final_sum = pe00_out + pe01a_out + pe01b_out;

endmodule
