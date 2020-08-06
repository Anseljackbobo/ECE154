module dpb_tb();
	reg enable;
	reg [31:0] pc;
	reg istakenE;
	reg [31:0] branchaddr;
	wire [31:0] pcpredctF;
	wire foundF;
	

DynamicPredicBuffer(input enable, input [31:0] pc, input istakenE, input [31:0] branchaddr, 
	output [31:0] pcpredictF, output foundF);
	