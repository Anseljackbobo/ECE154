

module laji_mult(input [31:0] a, input [31:0] b, input clk, input reset, input start, input is_signed, output [63:0] s, output reg isready);

	reg [63:0] Asign;
	reg [31:0] Bsign;
	reg [63:0] outsigned;
	
	reg [31:0] laji_counter;
	assign s = outsigned;
	always @(posedge clk) begin
		if(reset) begin
			laji_counter <= 0;
			isready <= 1;
			outsigned <= 0;
		end
		if(start) begin
			laji_counter <= 32;
			Asign <= is_signed ? {{32{a[31]}}, a} : {32'b0,a};
			Bsign <= b;
			outsigned <= 0;
			isready <= 0;
		end
		else if(laji_counter > 1) begin
			if(Bsign[32-laji_counter]) outsigned <= outsigned + Asign;
			else outsigned <= outsigned;
			Asign <= {Asign[62:0],1'b0};
			laji_counter <= laji_counter - 1;
			if(laji_counter == 3) isready <= 1;
		end
		else if(laji_counter == 1) begin
			if(Bsign[32-laji_counter]) outsigned <= outsigned - Asign;
			else outsigned <= outsigned;
			Asign <= {Asign[62:0],1'b0};
			laji_counter <= laji_counter - 1;
			//isready <= 1;
		end
	end

endmodule


/*

tiancai_mult(input [31:0] a, input [31:0] b, input clk, input reset, input start, 
		input is_signed, output [63:0] s, output reg isready)

wire [30:0] preA, preB;


assign preA = a[30:0];
assign preB = b[30:0];

reg [63:0] temp;
reg [31:0] counter;
reg [63:0] out;

assign s = out;

always @(posedge clk) begin
		if(reset) begin
			counter <= 0;
			isready <= 1;
			outsigned <= 0;
		end
		if(start) begin
			counter <= 0;
			temp <= preA & 31{preB[0]};
			
		end
		if(counter <31) begin
			counter <= counter + 1;
			temp2 <= preA & 31{}
			
		end
	end
*/








