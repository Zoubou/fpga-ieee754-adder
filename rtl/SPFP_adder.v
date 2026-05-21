module SPFP_adder (A, B, clk, reset, sum);
    input [31:0] A, B;
    input clk, reset;
    output reg [31:0] sum;
    reg [31:0] reg_A, reg_B, reg_sum;
    
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
    wire [7:0] exp_A = reg_A[30:23];
    wire sign_B = reg_B[31];
    wire [7:0] exp_B = reg_B[30:23];


    wire [48:0] ext_M_A = {2'b01, 1'b1, reg_A[22:0], 23'b0};
    wire [48:0] ext_M_B = {2'b01, 1'b1, reg_B[22:0], 23'b0};

    reg [7:0] sum_exp;
    reg [7:0] exp_diff;
    reg [48:0] shifted_M_A, shifted_M_B;
    reg [48:0] comp2_M_A, comp2_M_B;
    reg [49:0] mantissa_sum;

    always @(*) begin
        if ((reg_A == 32'd0 && reg_B == 32'd0) || (reg_A[30:0] == reg_B[30:0] && sign_A != sign_B)) begin
            sum = 32'd0;
        end else begin
            if (exp_A >= exp_B) begin
                sum_exp = exp_A;
                exp_diff = exp_A - exp_B;
                shifted_M_A = ext_M_A;
                shifted_M_B = ext_M_B >> exp_diff;

                case ({sign_A, sign_B})
                    2'b00: begin
                        comp2_M_A = shifted_M_A;
                        comp2_M_B = shifted_M_B;
                    end
                    2'b01: begin
                        comp2_M_A = shifted_M_A;
                        comp2_M_B = ~shifted_M_B + 1'b1; 
                    end
                    2'b10: begin
                        comp2_M_A = ~shifted_M_A + 1'b1;
                        comp2_M_B = shifted_M_B;
                    end
                    2'b11: begin
                        comp2_M_A = ~shifted_M_A + 1'b1; 
                        comp2_M_B = ~shifted_M_B + 1'b1; 
                    end
                endcase
                                
                mantissa_sum = comp2_M_A + comp2_M_B;
                if (mantissa_sum[49] == 1'b1) begin
                    final_sign   = 1'b1;                 
                    abs_mantissa = ~mantissa_sum + 1'b1; 
                end else begin
                    final_sign   = 1'b0;                  
                    abs_mantissa = mantissa_sum;          
                end

            end else if (exp_B > exp_A) begin
                sum_exp = exp_B;
                exp_diff = exp_B - exp_A;
                shifted_M_A = ext_M_A >> exp_diff;
                shifted_M_B = ext_M_B;

                case ({sign_A, sign_B})
                    2'b00: begin
                        comp2_M_A = shifted_M_A;
                        comp2_M_B = shifted_M_B;
                    end
                    2'b01: begin
                        comp2_M_A = shifted_M_A;
                        comp2_M_B = ~shifted_M_B + 1'b1; 
                    end
                    2'b10: begin
                        comp2_M_A = ~shifted_M_A + 1'b1;
                        comp2_M_B = shifted_M_B;
                    end
                    2'b11: begin
                        comp2_M_A = ~shifted_M_A + 1'b1; 
                        comp2_M_B = ~shifted_M_B + 1'b1; 
                    end
                endcase

                mantissa_sum = comp2_M_A + comp2_M_B;

            end
        end

    end


endmodule