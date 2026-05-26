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

 assign s = (x == 4'h0 ) ? 7'b1111110 : (x == 4'h1 ) ? 7'b0110000 :
 (x == 4'h2 ) ? 7'h1101101 : (x == 4'h3 ) ? 7'b1111001 :
 (x == 4'h4 ) ? 7'h0110011 : (x == 4'h5 ) ? 7'b1011011 :
 (x == 4'h6 ) ? 7'b1011111 : (x == 4'h7 ) ? 7'b1110010 :
 (x == 4'h8 ) ? 7'b1111111 : (x == 4'h9 ) ? 7'b1111011 : 
 (x == 4'ha ) ? 7'b1110111 : (x == 4'hb ) ? 7'b0011111 :
 (x == 4'hc ) ? 7'b1001110 : (x == 4'hd ) ? 7'b0111101 :
 (x == 4'he ) ? 7'b1001111 : (x == 4'hf ) ? 7'b1000111 :7'b0000001;

endmodule