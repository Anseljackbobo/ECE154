module detector_tb();

reg data;
reg clk;
wire out;


posedgedetector ruozhi(data, clk, out);

initial begin
data <= 0;
#100
data <= 1;
#10
data <= 0;
#70
data <= 1;
#320
data<= 0;
#50
$stop;



end

always begin
	clk <= 1;#5;clk<=0;#5;
end

endmodule