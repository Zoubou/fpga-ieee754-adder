`define CYCLE 20

module testbench;
parameter vectors = 10;  
reg	clk,rst;
reg	[31:0] A, B;
wire [31:0] out;
integer i, errors;
real fA, fB, fout;
reg [3*32-1:0] fp_InOut[0:vectors-1];  
reg [3*32-1:0] FPVal;
reg [31:0] correctOut;

      initial begin
        $readmemh("vectors.hex", fp_InOut);  
      end

      initial
        begin
          clk=0;
          rst=0;
#(`CYCLE) rst = 1;
#(`CYCLE) rst = 0;
          errors = 0;
          for (i=0; i < vectors; i=i+1)
            begin	
              FPVal = fp_InOut[i];       
              A = FPVal[95:64]; 
              B = FPVal[63:32]; 
              correctOut = FPVal[31:0]; 
 #(`CYCLE<<1) $display ("A=%h,B=%h,out=%h, correctOut=%h\n",A, B, out, correctOut);
              if (out != correctOut) 
			    begin
                  $display ("Error at input %d. Out was %h instead of %h\n", i, out, correctOut);
                  errors = errors + 1;
                end
            end
			$display ("Num of Errors = %4d\n", errors);
			$stop;
		end
	        
	  always #(`CYCLE/2) clk=~clk;
		
      SPFP_adder CUT (
          .clk(clk),
          .rst(rst),
          .A(A),
          .B(B),
          .out(out)
      );
endmodule
