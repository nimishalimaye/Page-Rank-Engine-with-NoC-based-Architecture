module fifo_improved #(parameter WIDTH, ADDWIDTH)
(input clk, input reset, input write, input read,
 input [WIDTH-1:0] dataIn, output reg [WIDTH-1:0] dataOut, output reg full, 
 output reg almost_full, output reg empty, output reg almost_empty, output [WIDTH-1:0] dataOutl);

parameter DEPTH= 2**ADDWIDTH;
reg [ADDWIDTH-1:0] head; //where to write to
reg [ADDWIDTH-1:0] tail; //where to read from
wire [WIDTH-1:0] dataOut_l;

always @ (posedge clk, posedge reset) begin
	if (reset) 
		head <= 0;
	else begin
		if(write && dataIn[0] == 1)
			head <= head+1;
	end
end

always @ (posedge clk, posedge reset) begin
	if (reset) 
		tail <= 0;
	else begin
		if(read)
			tail <= tail+1;
	end
end

//always @(*)
//	almost_full = ((head+1)==tail);


always @ (*) begin
	almost_full = 0;
	if (head==DEPTH-1) begin
		if (tail==0)
			almost_full=1;
	end
	else begin
		if (head+1==tail)
			almost_full=1;
	end
end

always @ (*) begin
	almost_empty = 0;
		if (tail==DEPTH-1) begin
		if (head==0)
			almost_empty=1;
		end
		else begin
		if (tail+1==head)
			almost_empty=1;
	end
end


always @ (posedge clk, posedge reset) begin

	if (reset)
		full <= 0;
	else 
		if ((almost_full & (write && dataIn[0] == 1) & ~read) | (full  & ~read))
			full <= 1;
		else
			full <= 0;
end





always @ (posedge clk, posedge reset) begin

	if (reset)
		empty <= 1'b1;
	else 
		if ((almost_empty & read & ~(write && dataIn[0] == 1)) | (empty & ~(write && dataIn[0] == 1)))
			empty <= 1'b1;

		else
			empty <= 1'b0;
end



wire [WIDTH-1:0] dataOut_temp;

always @ (*) 
	dataOut = dataOut_temp;

regfile #(WIDTH,ADDWIDTH) rf1 (clk, reset, write, read, head, tail, dataIn, dataOut_temp,dataOut_l);

assign dataOutl = empty ? 16'h0000:dataOut_l;

endmodule
