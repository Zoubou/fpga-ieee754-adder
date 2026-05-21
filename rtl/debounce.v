 module debounce (fclk, reset, push_button, pulse);
   input fclk, reset, push_button;
   output pulse;
   reg pulse;
   reg [3:0] pb_samples;

   // Synchronize input
   always @(posedge fclk or posedge reset)
     if (reset) pb_samples <= 4'h0;
       else pb_samples <= {pb_samples[2:0], push_button};
   wire rswitch;
   assign rswitch = pb_samples[3];

   // Debounce
   reg [15:0] counter;
   reg       debounced;
   always @(posedge fclk or posedge reset)
     if (reset) 
       begin
         counter   <= 0;
         debounced <= 0;
       end
      else 
       begin
         counter <= 0;
         pulse   <= 0;
         if (counter == 65535)
           begin
             debounced <= rswitch;
             pulse <= rswitch & ~debounced;
           end
          else if (debounced != rswitch) counter <= counter + 1;  
       end
 endmodule
