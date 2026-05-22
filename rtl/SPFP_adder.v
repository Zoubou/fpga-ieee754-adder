module SPFP_adder (clk, rst, A, B, out);
    input clk, rst;
    input [31:0] A, B;
    output reg [31:0] out;
    reg [31:0] reg_A, reg_B;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            reg_A <= 0;
            reg_B <= 0;
        end else begin
            reg_A <= A;
            reg_B <= B;
        end
    end

    wire sign_A = reg_A[31];
    wire [7:0] exp_A = reg_A[30:23];
    wire sign_B = reg_B[31];
    wire [7:0] exp_B = reg_B[30:23];

    wire [48:0] ext_M_A = {2'b00, 1'b1, reg_A[22:0], 23'b0};
    wire [48:0] ext_M_B = {2'b00, 1'b1, reg_B[22:0], 23'b0};

    reg [7:0] sum_exp;
    reg [7:0] exp_diff;
    reg [48:0] shifted_M_A, shifted_M_B;
    reg [48:0] comp2_M_A, comp2_M_B;
    reg [49:0] mantissa_sum;
    reg [49:0] abs_mantissa;
    reg final_sign;
    reg [7:0] final_exponent;
    reg [22:0] final_mantissa;
    reg [31:0] final_sum;
    reg [5:0] shift_count;
    reg [49:0] norm_mantissa;
    
    integer i;

    always @(*) begin
        shifted_M_A = ext_M_A;
        shifted_M_B = ext_M_B;
        sum_exp = 8'd0;
        exp_diff = 8'd0;
        comp2_M_A = 49'd0;
        comp2_M_B = 49'd0;
        mantissa_sum = 50'd0;
        abs_mantissa = 50'd0;
        final_sign = 1'b0;
        final_exponent = 8'd0;
        final_mantissa = 23'd0;
        shift_count = 6'd0;
        norm_mantissa = 50'd0;
        final_sum = 32'd0;

        if ((reg_A == 32'd0 && reg_B == 32'd0) || (reg_A[30:0] == reg_B[30:0] && sign_A != sign_B)) begin
            final_sum = 32'd0;
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
                                
                mantissa_sum = {comp2_M_A[48], comp2_M_A} + {comp2_M_B[48], comp2_M_B};
                if (mantissa_sum[49] == 1'b1) begin
                    final_sign   = 1'b1;                 
                    abs_mantissa = ~mantissa_sum + 1'b1; 
                end else begin
                    final_sign   = 1'b0;                  
                    abs_mantissa = mantissa_sum;          
                end

            end else begin
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

                mantissa_sum = {comp2_M_A[48], comp2_M_A} + {comp2_M_B[48], comp2_M_B};
                if (mantissa_sum[49] == 1'b1) begin
                    final_sign   = 1'b1;                 
                    abs_mantissa = ~mantissa_sum + 1'b1; 
                end else begin
                    final_sign   = 1'b0;                  
                    abs_mantissa = mantissa_sum;          
                end
            end

            if (abs_mantissa[47] == 1'b1) begin
                final_exponent = sum_exp + 1'b1;
                final_mantissa = abs_mantissa[46:24];
            end else if (abs_mantissa[46] == 1'b1) begin
                final_exponent = sum_exp;
                final_mantissa = abs_mantissa[45:23];
            end else begin
                shift_count = 0;
                for (i = 45; i >= 0; i = i - 1) begin
                    if (abs_mantissa[i] == 1'b1 && shift_count == 0) begin
                        shift_count = 46 - i;
                    end
                end

                if (shift_count == 0 && abs_mantissa[46] == 1'b0) begin
                    final_exponent = 8'd0;
                    final_mantissa = 23'd0;
                    final_sign = 1'b0;
                end else begin
                    final_exponent = sum_exp - shift_count;
                    norm_mantissa = abs_mantissa << shift_count;
                    final_mantissa = norm_mantissa[45:23];
                end
            end

            final_sum = {final_sign, final_exponent, final_mantissa};
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out <= 32'd0;
        end else begin
            out <= final_sum;
        end
    end

endmodule