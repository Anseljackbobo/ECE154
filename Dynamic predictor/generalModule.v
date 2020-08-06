//two imput adder
module adder(input [31:0] a, b,
             output [31:0] y);
  assign y = a+b;
endmodule

// 64bit adder
module adder64(input [63:0] a,b,
		output [63:0] y);
	assign y = a+b;
endmodule



//shift module
module sl2(input [31:0] a,
           output [31:0] y);
  assign y = {a[29:0], 2'b00};
endmodule

module s25l2(input [25:0] a,
	     output [27:0] y);
  assign y = {a[23:0], 2'b00};
endmodule

//shift 16bit
module sl16(input [31:0] a,
           output [31:0] y);
  assign y = {a[15:0],16'b0};// left shift 16
endmodule

module sl2jump(input [25:0] a,
           output [27:0] y);
  assign y = {a, 2'b00};
endmodule

//extention module can choose whether sign extend or zero extend
module extend(input [15:0] a,
		input se_ze,
		output [31:0] immext);
	assign immext = se_ze? {{16{a[15]}}, a}:{16'b0,a};
endmodule


 
//sign extention module
module signext(input [15:0] a,
               output [31:0] y);
  assign y = {{16{a[15]}}, a};
endmodule

//register
module flopr #(parameter WIDTH=8)
              (input clk, reset, enable,
               input [WIDTH-1:0] d,
               output reg [WIDTH-1:0] q);
  always @(posedge clk, posedge reset) begin
    if(enable) begin
      if(reset) q <= 0;
      else      q <= d;
    end
  end
endmodule
//multiplier register
module multreg #(parameter WIDTH=64)
		(input clk, 
		input [WIDTH-1:0] a,
		output reg [WIDTH-1:0] b);
	always @(posedge clk) begin
		b <= a;
		end
endmodule 
//fetch to decode stage register
module fetchtodec #(parameter WIDTH=32)
              (input clk, reset, enable,
               input [WIDTH-1:0] d0, 
	       input [WIDTH-1:0] d1,
	       input d2,
	       input [31:0] d3,
               output reg [WIDTH-1:0] q0,q1,
	       output reg q2,
	       output reg [31:0] q3);
  always @(posedge clk) begin
	
    if(enable) begin
	q0 <= reset ? 32'b0 : d0;
	q1 <= reset ? 32'b0 : d1;
	q2 <= reset ? 0 : d2;
	q3 <= reset ? 32'b0 : d3;
      /*if(reset) begin q0 <= 0; 
		      q1 <= 0; 
      end
      else begin     q0 <= d0; 
		     q1 <= d1;
      end*/
    end
  end
endmodule

//decode stage to excute stage register
module dectoexc #(parameter WIDTH=32)
              (input clk, clear,
               input [WIDTH-1:0] d0, d1, 
	       input c0, 
               input [1:0] c1, 
	       input c2, 
	       input [3:0] c3, 
	       input c4, c5, 
	       input c6, 
	       input c7, c8, c9,
	       input [4:0] rsd, rtd, rdd,
	       input [31:0] signimmd,
               output reg [WIDTH-1:0] q0,q1,
	       output reg  z0, 
	       output reg [1:0] z1,
	       output reg z2, 
	       output reg [3:0] z3, 
	       output reg z4, z5, 
	       output reg z6, 
	       output reg z7, z8,z9,
	       output reg [4:0] rse, rte,rde,
		output reg [31:0] signimme);
  always @(posedge clk) begin
	if(clear) begin 
		{q0, q1, z0, z1, z2, z3, z4, z5, z6, z7, z8, z9,
		rse, rte, signimme} <= 0;
	end
	else begin
    	q0 <= d0; 	
	q1 <= d1;
	z0 <= c0;
	z1 <= c1;
	z2 <= c2;
	z3 <= c3;
	z4 <= c4;
	z5 <= c5;
	z6 <= c6;
	z7 <= c7;
	z8 <= c8;
	z9 <= c9;
	rse <= rsd;
	rte <= rtd;
	rde <= rdd;
	signimme <= signimmd;
	end
      
  end
endmodule

// excute to memory register
module exctom #(parameter WIDTH=32)
              (input clk,
               input [WIDTH-1:0] multhi, multlo, aluoutE, writedataE, signimmE2,
		input [4:0] writeRegE,
	       input [1:0] outSelectE, 
	       input regWriteE,memtoRegE,memWriteE, 
               output reg [WIDTH-1:0] multhiM,multloM, aluoutM, writedataM, signimmM2,
	       	output reg [4:0] writeRegM,
		output reg  [1:0]outSelectM, 
	       output reg regWriteM,memtoRegM,memWriteM);
  always @(posedge clk) begin
    	multhiM <= multhi; 	
	multloM <= multlo;
	aluoutM <= aluoutE;
	writedataM <= writedataE;
	signimmM2 <= signimmE2;
	outSelectM <= outSelectE;
	regWriteM <= regWriteE;
	memtoRegM <= memtoRegE;
	memWriteM <= memWriteE;
	writeRegM <= writeRegE;
	
	end
      
 
endmodule
//mem to write register
module mtowrite #(parameter WIDTH=32)
              (input clk,
               input [WIDTH-1:0] readdataM, aluoutM2,
	       input [4:0] writeregM, 
	       input regWriteM,memtoRegM, 
               output reg [WIDTH-1:0] readdataW, aluoutW,
	       output reg  [4:0]writeregW, 
	       output reg regWriteW,memtoRegW);
  always @(posedge clk) begin
    	readdataW <= readdataM; 	
	aluoutW <= aluoutM2;
	writeregW <= writeregM;
	regWriteW <= regWriteM;
	memtoRegW <= memtoRegM;
	
	
	end
      
 
endmodule


module mux2 #(parameter WIDTH=8)
             (input [WIDTH-1:0] d0, d1,
              input s,
              output [WIDTH-1:0] y);
  assign y = s ? d1 : d0;
endmodule


module mux3 #(parameter WIDTH=8)
             (input [WIDTH-1:0] d0, d1, d2,
              input [1:0] s,
              output [WIDTH-1:0] y);
  assign y = s[1] ? d2 : (s[0] ? d1 : d0);
endmodule



module mux4 #(parameter WIDTH=8)
             (input [WIDTH-1:0] d0, d1, d2, d3,
              input [1:0] s,
              output [WIDTH-1:0] y);
  assign y = s[1] ? (s[0] ? d3: d2) : (s[0]? d1 : d0);

endmodule
//enable register
module enablereg #(parameter WIDTH=8)
                  (input clk, enable,
                   input [WIDTH-1:0] d,
                   output reg [WIDTH-1:0] q);
    always @(posedge clk) begin
      if(enable) q<=d;
    end
endmodule

//common register
module normalreg #(parameter WIDTH=8)
                  (input clk,
                   input [WIDTH-1:0] d,
                   output reg [WIDTH-1:0] q);
    always @(posedge clk) begin
      q <= d;
    end
endmodule

module resetclearenablereg #(parameter WIDTH = 8)
		(input clk, reset, clear,enable,
		 input [WIDTH-1:0] d,
		 output reg [WIDTH-1:0] q);

	always @(posedge clk) begin
		if(reset) q <= 0;
		else if(enable) q<= clear ? 0 : d;
	end
endmodule

module clearenablereg #(parameter WIDTH = 8)
		(input clk, clear,enable,
		 input [WIDTH-1:0] d,
		 output reg [WIDTH-1:0] q);

	always @(posedge clk) begin
		if(clear) q <= 0;
		else if(enable) q<= d;
	end
endmodule
module clearreg #(parameter WIDTH = 8)
		(input clk, clear,
		 input [WIDTH-1:0] d,
		 output reg [WIDTH-1:0] q);

	always @(posedge clk) begin
		if(clear) q <= 0;
		else q<= d;
	end
endmodule


module signaldelay(input data, input clk, input reset, output reg out);
	reg temp;
	always@(posedge clk) begin
		temp <= data;
		out <= reset ? 0 : temp;
		
	end
endmodule