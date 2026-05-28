module ROM_controller (clk, rst, pulse, outData);
    input clk, rst, pulse;
    output reg [63:0] outData;

    reg [3:0] address;
    reg [63:0] mem [0:9]; 

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mem[0] <= 64'h3f800000_40000000;
            mem[1] <= 64'hbf800000_3f800000; 
            mem[2] <= 64'hc2de8000_45155e00; 
            mem[3] <= 64'h6b64b235_6ac49214;
            mem[4] <= 64'h2ac49214_6ac49214;
            mem[5] <= 64'hbfc66666_3fc7ae14;
            mem[6] <= 64'hc565ee8b_4565ee8a;
            mem[7] <= 64'h447a4efa_c47a1ccd;
            mem[8] <= 64'h00000000_00000000;
            mem[9] <= 64'h38108900_bb908900;
            address <= 0;
				outData <= 64'd0;
        end 
        else if (pulse) begin
            outData <= mem[address];
            address <= (address == 9) ? 0 : (address + 1);
        end
    end

endmodule