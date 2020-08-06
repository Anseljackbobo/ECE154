module StaticBranchBuffer (input [15:0]rd, [31:0] pcf, output predictionF, output [31:0]pc_predictF);
	wire [31:0]rd1;
	wire [31:0]rd2;
	assign rd1 = {{16{rd[15]}}, rd};
	sl2 s (rd1, rd2);
	assign pc_predictF = rd2 + pcf;
	assign predictionF = 0;
endmodule
