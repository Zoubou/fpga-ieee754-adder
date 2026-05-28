module adder_spi_display (
    input clk,         
    input rst,            
    input push_button,   
    output CS,           
    output DIN,           
    output SPI_CLK        
);

    wire pulse;
    wire [63:0] outData;
    wire [31:0] sum_out;
    wire enable_1MHz;     

    debounce db (.fclk(clk), .reset(rst), .push_button(push_button), .pulse(pulse));

    ROM_controller rom_ctrl (.clk(clk), .rst(rst), .pulse(pulse), .outData(outData));

    SPFP_pipeline_adder adder (.clk(clk), .rst(rst), .A(outData[63:32]), .B(outData[31:0]), .out(sum_out));

    OneMHz slow_clock_gen (
        .clk(clk), 
        .reset(rst), 
        .en_nxt(enable_1MHz)
    );

    spi_7219 transmitter (
        .fclk(clk),
        .reset(rst),
        .en_nxt(enable_1MHz), 
        .sum(sum_out),       
        .CS(CS),
        .DIN(DIN),
        .CLK(SPI_CLK)
    );

endmodule