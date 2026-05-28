module spi_7219 (
    input fclk,          
    input reset,
    input en_nxt,        
    input [31:0] sum,    
    output reg CS,       
    output reg DIN,      
    output reg CLK       
);

    localparam IDLE     = 2'b00;
    localparam ADDRESS  = 2'b01;
    localparam TXDATA   = 2'b10;
    localparam FINISHED = 2'b11;

    reg [1:0] state;             
    reg [3:0] bit_counter;       
    reg [3:0] reg_addr;          
    reg [1:0] clk_phase;         
    reg [15:0] spi_packet;      

    wire [6:0] seg0, seg1, seg2, seg3, seg4, seg5, seg6, seg7;

    bin_2_7 d0 (.x(sum[3:0]),   .s(seg0));
    bin_2_7 d1 (.x(sum[7:4]),   .s(seg1));
    bin_2_7 d2 (.x(sum[11:8]),  .s(seg2));
    bin_2_7 d3 (.x(sum[15:12]), .s(seg3));
    bin_2_7 d4 (.x(sum[19:16]), .s(seg4));
    bin_2_7 d5 (.x(sum[23:20]), .s(seg5));
    bin_2_7 d6 (.x(sum[27:24]), .s(seg6));
    bin_2_7 d7 (.x(sum[31:28]), .s(seg7)); 

    always @(*) begin
        case (reg_addr)
            4'h9: spi_packet = 16'h0900; 
            4'hA: spi_packet = 16'h0A07; 
            4'hB: spi_packet = 16'h0B07; 
            4'hC: spi_packet = 16'h0C01; 
            4'hF: spi_packet = 16'h0F00; 
            
            4'h1: spi_packet = {4'h0, 4'h1, 1'b0, seg0}; 
            4'h2: spi_packet = {4'h0, 4'h2, 1'b0, seg1}; 
            4'h3: spi_packet = {4'h0, 4'h3, 1'b0, seg2}; 
            4'h4: spi_packet = {4'h0, 4'h4, 1'b0, seg3}; 
            4'h5: spi_packet = {4'h0, 4'h5, 1'b0, seg4}; 
            4'h6: spi_packet = {4'h0, 4'h6, 1'b0, seg5}; 
            4'h7: spi_packet = {4'h0, 4'h7, 1'b0, seg6}; 
            4'h8: spi_packet = {4'h0, 4'h8, 1'b0, seg7}; 
            
            default: spi_packet = 16'h0000;
        endcase
    end

    always @(posedge fclk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            reg_addr <= 4'hF;   
            CS <= 1'b1;          
            CLK <= 1'b0;
            DIN <= 1'b0;
            bit_counter <= 4'd7;
            clk_phase <= 2'd0;
        end 
        else if (en_nxt) begin   
            case (state)
                IDLE: begin
                    CS <= 1'b0;                
                    bit_counter <= 4'd7;         
                    clk_phase <= 2'd0;           
                    reg_addr <= reg_addr + 1;    
                    state <= ADDRESS;            
                end
                
                ADDRESS: begin
                    if (clk_phase == 2'd0) begin
                        DIN <= spi_packet[8 + bit_counter]; 
                        CLK <= 1'b0;
                        clk_phase <= 2'd1;
                    end
                    else if (clk_phase == 2'd1) begin
                        CLK <= 1'b1; 
                        clk_phase <= 2'd2;
                    end
                    else if (clk_phase == 2'd2) begin
                        CLK <= 1'b0; 
                        clk_phase <= 2'd0;
                        
                        if (bit_counter == 4'd0) begin
                            state <= TXDATA;
                            bit_counter <= 4'd7; 
                        end else begin
                            bit_counter <= bit_counter - 1; 
                        end
                    end
                end
                
                TXDATA: begin
                    if (clk_phase == 2'd0) begin
                        DIN <= spi_packet[bit_counter]; 
                        CLK <= 1'b0;
                        clk_phase <= 2'd1;
                    end
                    else if (clk_phase == 2'd1) begin
                        CLK <= 1'b1; 
                        clk_phase <= 2'd2;
                    end
                    else if (clk_phase == 2'd2) begin
                        CLK <= 1'b0; 
                        clk_phase <= 2'd0;
                        
                        if (bit_counter == 4'd0) begin
                            state <= FINISHED;
                        end else begin
                            bit_counter <= bit_counter - 1; 
                        end
                    end
                end
                
                FINISHED: begin
                    CS <= 1'b1;      
                    state <= IDLE;   
                end
            endcase
        end
    end

endmodule

module bin_2_7 (x, s);
 input [3:0] x;
 output [6:0] s;

 assign s = (x == 4'h0 ) ? 7'b1111110 : (x == 4'h1 ) ? 7'b0110000 :
 (x == 4'h2 ) ? 7'b1101101 : (x == 4'h3 ) ? 7'b1111001 :
 (x == 4'h4 ) ? 7'b0110011 : (x == 4'h5 ) ? 7'b1011011 :
 (x == 4'h6 ) ? 7'b1011111 : (x == 4'h7 ) ? 7'b1110010 :
 (x == 4'h8 ) ? 7'b1111111 : (x == 4'h9 ) ? 7'b1111011 : 
 (x == 4'ha ) ? 7'b1110111 : (x == 4'hb ) ? 7'b0011111 :
 (x == 4'hc ) ? 7'b1001110 : (x == 4'hd ) ? 7'b0111101 :
 (x == 4'he ) ? 7'b1001111 : (x == 4'hf ) ? 7'b1000111 :7'b0000001;

endmodule