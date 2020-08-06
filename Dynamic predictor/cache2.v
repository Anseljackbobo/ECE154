module cachesystem(input clk, reset, input [31:0] aluoutm, writedatam, input memwritem, input enable,
			output [31:0] mout, output stallm);

	wire mem_ready;
	wire [1:0] offset1;
	wire [6:0] index;
	wire which_cache, enable_cache, cache_wr;
	wire [1:0] cache_sel;
	wire mem_en, mem_rw;
	wire [31:0] address;
	wire cachedatainselect;
	wire [31:0] memout;
	wire [31:0] cacheout;

	cache_control ccl (aluoutm, enable, clk, reset, mem_ready, memwritem, offset1, index, 
	which_cache, enable_cache, cache_wr, 
	cache_sel, mem_en, mem_rw,address, cachedatainselect, stallm,ruozhiout);

	wire [31:0] muxout;
	assign muxout = cachedatainselect ? memout : writedatam;

	cache c (clk, offset1, index, which_cache, cache_sel, enable_cache, cache_wr, muxout, cacheout);

	wire mem_en2;
	assign mem_en2 = ruozhiout & mem_en;
	
	
	memory mem (clk, reset, mem_en2, mem_rw, address, cacheout, memout, mem_ready);

	assign mout = cacheout;


endmodule





module cache (input clk, input [1:0] offset, input [6:0] index, input whichcache, 
		input [1:0]cachesel, input enable, input wr, 
		input [31:0] writedata, output [31:0] outputdata);

	//change start
	
	//reg [127:0] cachereg1 [127:0];
	//reg [127:0] cachereg2 [127:0];
	//change end


	reg [31:0] cachereg10 [127:0];
	reg [31:0] cachereg11 [127:0];
	reg [31:0] cachereg12 [127:0];
	reg [31:0] cachereg13 [127:0];

	reg [31:0] cachereg20 [127:0];
	reg [31:0] cachereg21 [127:0];
	reg [31:0] cachereg22 [127:0];
	reg [31:0] cachereg23 [127:0];




	// |data0|data1|data2|data3|
	// data0 = cachereg#[index][offset]
	//wire [127:0] offsetstart, offsetend;
	//assign offsetstart = offset << 5+31;
	//assign offsetend = offset << 5;
	//assign outputdata = whichcache ? cachereg1[index][offsetstart:offsetend] : cachereg2[index][offsetstart:offsetend];
	
	wire [31:0] temprawoutput0;
	wire [31:0] temprawoutput1;
	wire [31:0] temprawoutput2;
	wire [31:0] temprawoutput3;

	assign temprawoutput0 = whichcache ? cachereg20[index] : cachereg10[index];
	assign temprawoutput1 = whichcache ? cachereg21[index] : cachereg11[index];
	assign temprawoutput2 = whichcache ? cachereg22[index] : cachereg12[index];
	assign temprawoutput3 = whichcache ? cachereg23[index] : cachereg13[index];

	//assign {temprawoutput0,temprawoutput1,temprawoutput2,temprawoutput3} = whichcache ? {cachereg10[index], cachereg11[index], cachereg12[index], cachereg13[index]} : 
			//{cachereg20[index], cachereg21[index], cachereg22[index], cachereg23[index]};

	//mux4 #(32) ruozhi(temprawoutput[31:0], temprawoutput[63:32], temprawoutput[95:64], temprawoutput[127:96],offset,outputdata);
	mux4 #(32) ruozhi(temprawoutput0, temprawoutput1, temprawoutput2, temprawoutput3,offset,outputdata);

	always @(posedge clk) begin
		if(enable) begin
			if(wr) begin
				if(whichcache) begin// reg2 is using
					case(cachesel)
						2'b00: cachereg20[index] = writedata;
						2'b01: cachereg21[index] = writedata;
						2'b10: cachereg22[index] = writedata;
						2'b11: cachereg23[index] = writedata;
					endcase
				end
				else begin
					case(cachesel)
						
						2'b00: cachereg10[index] = writedata;
						2'b01: cachereg11[index] = writedata;
						2'b10: cachereg12[index] = writedata;
						2'b11: cachereg13[index] = writedata;
					endcase
				end
			end 
		end
	end

endmodule


