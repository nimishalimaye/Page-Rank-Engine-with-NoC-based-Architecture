module regfile #(parameter WIDTH, ADDWIDTH)
(input clk, input reset, input writeEnable, input readEnable,
 input [ADDWIDTH-1:0] dest, input [ADDWIDTH-1:0] source, 
 input [WIDTH-1:0] dataIn, output reg [WIDTH-1:0] dataOut, output [WIDTH-1:0] dataOutl);

parameter DEPTH= 2**ADDWIDTH;

reg [WIDTH-1 : 0] rf [DEPTH-1 : 0];

integer i;

always @ (posedge clk, posedge reset) begin

	if (reset) begin
		dataOut <=0;
		for (i=0;i<DEPTH;i=i+1) begin
			rf[i] <= 0;
		end
	end
	else begin
		if (readEnable)
			dataOut <= rf[source];
		else
			dataOut <= 0;
		if(writeEnable && dataIn[0] == 1)
			rf[dest] <= dataIn; 
	end
end

assign dataOutl = rf[source];
endmodule
