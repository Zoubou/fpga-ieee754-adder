`define CYCLE 20

module testbench;
parameter vectors = 10;  
reg clk,rst;
reg [31:0] A, B;
wire [31:0] out;
integer i, errors;
real fA, fB, fout;
reg [3*32-1:0] fp_InOut[0:vectors-1];  
reg [3*32-1:0] FPVal;
reg [31:0] correctOut;
reg [31:0] correctOut_delayed; // <--- ΝΕΑ ΜΕΤΑΒΛΗΤΗ: Εδώ θα "θυμάται" την έξοδο

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

              // 1. Περιμένουμε 2 κύκλους (όσο έκανε το παλιό Γ1 κύκλωμα)
#(`CYCLE<<1); 
              
              // 2. Το νέο κύκλωμα Pipeline θέλει 1 ακόμα κύκλο.
              // "Θυμόμαστε" τη σωστή απόκριση πριν προχωρήσει ο χρόνος.
              correctOut_delayed = correctOut;

              // 3. Περιμένουμε "έναν κύκλο αργότερα" για να ολοκληρωθεί το Pipeline
#(`CYCLE); 
              
              $display ("A=%h,B=%h,out=%h, correctOut=%h\n",A, B, out, correctOut_delayed);
              
              // Συγκρίνουμε με την αποθηκευμένη (delayed) τιμή
              if (out != correctOut_delayed) 
                begin
                  $display ("Error at input %d. Out was %h instead of %h\n", i, out, correctOut_delayed);
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