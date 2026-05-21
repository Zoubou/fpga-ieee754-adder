module SPFP_adder (A, B, clk, reset, sum)
    input [31:0] A, B;
    input clk, reset;
    output [31:0] sum;
    reg [31:0] reg_A, reg_B;
    reg [31:0] reg_sum;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_A <= 0;
            reg_B <= 0;
        end else begin
            reg_A <= A;
            reg_B <= B;
        end
    end

    // Extract sign, exponent, and mantissa
    wire sign_A = reg_A[31];
    wire [7:0] exponent_A = reg_A[30:23];
    wire [22:0] mantissa_A = reg_A[22:0];
    wire sign_B = reg_B[31];
    wire [7:0] exponent_B = reg_B[30:23];
    wire [22:0] mantissa_B = reg_B[22:0];



endmodule