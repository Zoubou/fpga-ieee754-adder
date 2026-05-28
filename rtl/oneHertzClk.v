module cnt100 (input reset, input clk, input enable, output clkdiv100);
    reg [6:0] cnt; 

    assign clkdiv100 = (cnt == 7'd99);

    always @(posedge clk or posedge reset) begin
        if (reset) 
            cnt <= 7'd0;
        else if (enable) begin
            if (clkdiv100) 
                cnt <= 7'd0; 
            else 
                cnt <= cnt + 1;
        end
    end
endmodule

module OneMHz (input reset, input clk, output en_nxt);

    cnt100 i0 (reset, clk, 1'b1, clk1MHz);
    assign en_nxt = clk1MHz;

endmodule