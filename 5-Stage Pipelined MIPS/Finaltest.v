module datapath_tb;
  reg clk;
  reg reset;
  
  top dut(clk, reset);
  
  initial begin
    reset <= 1; #22; reset <= 0;
    #10000;
    $stop;
  end
  
  always begin
    clk <= 1; #5; clk <= 0; #5;
  end
  
  
  
  
endmodule
