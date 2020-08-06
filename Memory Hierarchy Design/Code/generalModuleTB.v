module clearreg_tb;


reg clk, clear;
reg [36:0] d;
wire [36:0] q;
clearreg #(37) dut(clk, clear, d, q);

initial begin
clear <= 0;
#10;
d <= 36'd273;
#10;
d <= 36'd738;
#10;
d <= 36'd15;
clear <= 1;
#10;
d<= 36'd25;
clear <= 0;
#10;

end
always begin
	clk <= 1; #5; clk <= 0; #5;
end

endmodule
