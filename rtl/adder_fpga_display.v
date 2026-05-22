module adder_fpga_display (clk, rst, push_button, left, right);
    input clk, rst, push_button;
    output [6:0] left, right;
    wire [31:0] sum;
    wire pulse;
    wire [63:0] outData;

    debounce db (clk, rst, push_button, pulse);

    ROM_controller rom_ctrl (clk, rst, pulse, outData);

    SPFP_pipeline_adder adder (clk, rst, outData[63:32], outData[31:0], sum);

    bin_2_7 led_A (sum[31:28], left);
    bin_2_7 led_B (sum[27:24], right);
endmodule

module bin_2_7 (x, s);
 input [3:0] x;
 output [6:0] s;

 assign s = (x == 4'd0 ) ? 7'b1111110 : (x == 4'd1 ) ? 7'b0110000 :
 (x == 4'd2 ) ? 7'b1101101 : (x == 4'd3 ) ? 7'b1111001 :
 (x == 4'd4 ) ? 7'b0110011 : (x == 4'd5 ) ? 7'b1011011 :
 (x == 4'd6 ) ? 7'b1011111 : (x == 4'd7 ) ? 7'b1110010 :
 (x == 4'd8 ) ? 7'b1111111 : (x == 4'd9 ) ? 7'b1111011 : 7'b0000001;

endmodule