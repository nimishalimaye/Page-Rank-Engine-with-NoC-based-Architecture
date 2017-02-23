module noc_router #(parameter WIDTH,ADDWIDTH)
(input clk, input reset, 
 input writeE, 
 input writeW, 
 input writeN,
 input writeS, //write ports
 input [WIDTH-1:0] dataInE, 
 input [WIDTH-1:0] dataInW, 
 input [WIDTH-1:0] dataInN,
 input [WIDTH-1:0] dataInS, //write data ports
 input   ip_fullE, 
 input   ip_almost_fullE, 
 input   ip_fullW, 
 input   ip_almost_fullW, 
 input   ip_fullN, 
 input   ip_almost_fullN,
 input   ip_fullS, 
 input   ip_almost_fullS, //full inputs from FIFOs from other router
 output  [WIDTH-1:0] dataOutE,
 output  [WIDTH-1:0] dataOutW,
 output  [WIDTH-1:0] dataOutN,
 output  [WIDTH-1:0] dataOutS, //output ports
 output   fullE, 
 output   almost_fullE, 
 output   fullW, 
 output   almost_fullW, 
 output   fullN, 
 output   almost_fullN,
 output   fullS, 
 output   almost_fullS, //full outputs from FIFOs
 output   op_WriteE,
 output   op_WriteW,
 output   op_writeN,
 output   op_writeS
 );


wire readE, readW, readN, readS; //output from arbiter, input to FIFO
wire [WIDTH-1:0] dataOutFifoE, dataOutFifoW, dataOutFifoN,dataOutFifoS; //output from FIFO, input to arbiter
wire emptyE, almost_emptyE, emptyW, almost_emptyW, emptyN, almost_emptyN, emptyS, almost_emptyS; //output from FIFO, input to arbiter
wire [WIDTH-1:0] dataOutE_temp, dataOutW_temp, dataOutN_temp, dataOutS_temp, dataOutE_templ, dataOutW_templ, dataOutN_templ, dataOutS_templ; //output from arbiter, input to outport 
wire stallE,stallW,stallN,stallS;

fifo_improved #(WIDTH,ADDWIDTH) fifoE (clk,  reset,  writeE,  readE, dataInE, dataOutFifoE, fullE, almost_fullE, emptyE, almost_emptyE, dataOutE_templ);

fifo_improved #(WIDTH,ADDWIDTH) fifoW (clk,  reset,  writeW,  readW, dataInW, dataOutFifoW, fullW, almost_fullW, emptyW, almost_emptyW, dataOutW_templ);

fifo_improved #(WIDTH,ADDWIDTH) fifoN (clk,  reset,  writeN,  readN, dataInN, dataOutFifoN, fullN, almost_fullN, emptyN, almost_emptyN, dataOutN_templ);

fifo_improved #(WIDTH,ADDWIDTH) fifoS (clk,  reset,  writeS,  readS, dataInS, dataOutFifoS, fullS, almost_fullS, emptyS, almost_emptyS, dataOutS_templ);

arbiter #(WIDTH)a(clk, reset, emptyE, almost_emptyE, dataOutFifoE, dataOutE_templ,
                      emptyW, almost_emptyW, dataOutFifoW, dataOutW_templ,
                      emptyN, almost_emptyN, dataOutFifoN, dataOutN_templ,
		      emptyS, almost_emptyS, dataOutFifoS, dataOutS_templ,
		      stallE,stallW,stallN,stallS,
                      readE,   readW, readN , readS,
		      dataOutE_temp, dataOutW_temp, dataOutN_temp, dataOutS_temp); 

 
outport #(WIDTH) o(clk, reset, dataOutE_temp, dataOutW_temp, dataOutN_temp, dataOutS_temp,
	 ip_fullE, ip_almost_fullE, ip_fullW, ip_almost_fullW, ip_fullN, ip_almost_fullN, ip_fullS, ip_almost_fullS,
	 dataOutE, dataOutW, dataOutN, dataOutS,
	 stallE,stallW,stallN,stallS,
	 op_WriteE,op_WriteW,op_writeN,op_writeS
	);

endmodule

module  outport #(parameter WIDTH)(input clk, input reset, 
		input [WIDTH-1:0] dataOutE_temp, input [WIDTH-1:0] dataOutW_temp, input [WIDTH-1:0] dataOutN_temp, input [WIDTH-1:0] dataOutS_temp,
		input fullE, input almost_fullE,
		input fullW, input almost_fullW,
		input fullN, input almost_fullN,
		input fullS, input almost_fullS,
		output reg [WIDTH-1:0] dataOutE, output reg [WIDTH-1:0] dataOutW, output reg [WIDTH-1:0] dataOutN, output reg [WIDTH-1:0] dataOutS,
		output reg stallE, output reg stallW, output reg stallN, output reg stallS,
		output reg op_writeE, output reg op_writeW, output reg op_writeN, output reg op_writeS
	       );


always @ (posedge clk, posedge reset)begin

	if (reset) begin
		dataOutE <= 0;
		dataOutW <= 0;
		dataOutN <= 0;
		dataOutS <= 0;
		stallE   <= 0;
		stallW	 <= 0;
		stallN	 <= 0;
		stallS	 <= 0;
	end
	else begin
		//if (stallE == 0)
		dataOutE <= dataOutE_temp;
		//if (stallW == 0)
	        dataOutW <= dataOutW_temp;
		//if (stallN == 0)
                dataOutN <= dataOutN_temp;
		dataOutS <= dataOutS_temp;
	end	
	
end

always @ (posedge clk, posedge reset) begin

if (reset) begin
		op_writeE <= 0;
		op_writeW <= 0;
		op_writeN <= 0;
		op_writeS <= 0;
		stallE <= 0;
		stallW <= 0;
		stallN <= 0;
		stallS <= 0;
	end
	else begin
	if ((op_writeE & almost_fullE)|(~op_writeE & fullE)) begin
		op_writeE <= 0;stallE <= 1;
	end
	else begin
		op_writeE <= 1;stallE <= 0;
	end

	if ((op_writeW & almost_fullW)|(~op_writeW & fullW)) begin
		op_writeW <= 0;stallW <= 1;
	end
	else begin
		op_writeW <= 1;stallW <= 0;
	end

	if ((op_writeN & almost_fullN)|(~op_writeN & fullN)) begin
		op_writeN <= 0;stallN <= 1;
	end
	else begin
		op_writeN <= 1;stallN <= 0;
	end

	if ((op_writeS & almost_fullS)|(~op_writeS & fullS)) begin
		op_writeS <= 0;stallS <= 1;
	end
	else begin
		op_writeS <= 1;stallS <= 0;
	end
	end
end
endmodule 	  



//Arbiter+crossbar
module arbiter #(parameter WIDTH) (input clk, input reset, 
	        input emptyE, input almost_emptyE, input [WIDTH-1:0] dataInFifoE, input [WIDTH-1:0] dataInFifoEl,
		input emptyW, input almost_emptyW, input [WIDTH-1:0] dataInFifoW, input [WIDTH-1:0] dataInFifoWl,
		input emptyN, input almost_emptyN, input [WIDTH-1:0] dataInFifoN, input [WIDTH-1:0] dataInFifoNl,
		input emptyS, input almost_emptyS, input [WIDTH-1:0] dataInFifoS, input [WIDTH-1:0] dataInFifoSl,
		input stallE, input stallW, input stallN, input stallS,
		output reg readE, output reg readW, output reg readN, output reg readS,
		output reg [WIDTH-1:0] dataOutE_temp, output reg [WIDTH-1:0] dataOutW_temp, output reg [WIDTH-1:0] dataOutN_temp, output reg [WIDTH-1:0] dataOutS_temp);

localparam East = 2'b00, West = 2'b01, North = 2'b10, South = 2'b11;

reg [1:0] token;
reg reqReadE, reqReadW, reqReadN, reqReadS;
reg portEfull, portWfull, portNfull, portSfull;

always @ (posedge clk, posedge reset) begin

	if (reset)
		token<= 2'b00;
	else begin
		/*if (token == 2'b10)
			token <= 2'b00;
		else*/
			token <= token + 1;
	end
end

//generates data at the dataInFifo* ports
always @ (posedge clk, posedge reset) begin

	if (reset) begin
		readE <=1'b0;
		readW <=1'b0;
		readN <=1'b0;
		readS <=1'b0;
	end
	else begin
		if ((almost_emptyE & readE) | (emptyE) | (~reqReadE))
			readE <= 1'b0;
		else 
			readE <= 1'b1;

		if ((almost_emptyW & readW) | (emptyW) | (~reqReadW))
			readW <= 1'b0;
		else 
			readW <= 1'b1;

		if ((almost_emptyN & readN) | (emptyN) | (~reqReadN))
			readN <= 1'b0;
		else 
			readN <= 1'b1;

		if ((almost_emptyS & readS) | (emptyS) | (~reqReadS))
			readS <= 1'b0;
		else 
			readS <= 1'b1;

	end

end

//Looks at data at the dataInFifo* ports and pushes them to the output
//crossbar + outputreg
always @ (token) begin

	portEfull=stallE; portWfull=stallW; portNfull=stallN; portSfull=stallS;
	reqReadE=0; reqReadW=0; reqReadN=0; reqReadS=0;

	
if (token == 0) begin

	if (dataInFifoEl[0]==1) begin
		if (dataInFifoEl[2:1]==East && portEfull == 1'b0)begin
			reqReadE = 1'b1; portEfull = 1'b1;
		end
		if (dataInFifoEl[2:1]==West && portWfull == 1'b0)begin
			reqReadE = 1'b1; portWfull = 1'b1;
		end
		if (dataInFifoEl[2:1]==North && portNfull == 1'b0)begin
			reqReadE = 1'b1; portNfull = 1'b1;
		end
		if (dataInFifoEl[2:1]==South && portSfull == 1'b0)begin
			reqReadE = 1'b1; portSfull = 1'b1;
		end
	end
	else
		reqReadE = 1'b0;

	if (dataInFifoWl[0]==1) begin
		if (dataInFifoWl[2:1]==East && portEfull == 1'b0) begin
			reqReadW = 1'b1; portEfull = 1'b1;
		end
		if (dataInFifoWl[2:1]==West && portWfull == 1'b0) begin
			reqReadW = 1'b1; portWfull = 1'b1;
		end
		if (dataInFifoWl[2:1]==North && portNfull == 1'b0) begin
			reqReadW = 1'b1; portNfull = 1'b1;
		end
		if (dataInFifoWl[2:1]==South && portSfull == 1'b0) begin
			reqReadW = 1'b1; portSfull = 1'b1;
		end
	end
	else
		reqReadW = 1'b0;

	if (dataInFifoNl[0]==1) begin
		if (dataInFifoNl[2:1]==East && portEfull == 1'b0) begin
			reqReadN = 1'b1; portEfull = 1'b1;
		end
		if (dataInFifoNl[2:1]==West && portWfull == 1'b0) begin
			reqReadN = 1'b1; portWfull = 1'b1;
		end
		if (dataInFifoNl[2:1]==North && portNfull == 1'b0) begin
			reqReadN = 1'b1; portNfull = 1'b1;
		end
		if (dataInFifoNl[2:1]==South && portSfull == 1'b0) begin
			reqReadN = 1'b1; portSfull = 1'b1;
		end
	end
	else
		reqReadN = 1'b0;

	if (dataInFifoSl[0]==1) begin
		if (dataInFifoSl[2:1]==East && portEfull == 1'b0) begin
			reqReadS = 1'b1; portEfull = 1'b1;
		end
		if (dataInFifoSl[2:1]==West && portWfull == 1'b0) begin
			reqReadS = 1'b1; portWfull = 1'b1;
		end
		if (dataInFifoSl[2:1]==North && portNfull == 1'b0) begin
			reqReadS = 1'b1; portNfull = 1'b1;
		end
		if (dataInFifoSl[2:1]==South && portSfull == 1'b0) begin
			reqReadS = 1'b1; portSfull = 1'b1;
		end
	end
	else
		reqReadS = 1'b0;
end

if (token == 1) begin


	if (dataInFifoWl[0]==1) begin
		if (dataInFifoWl[2:1]==East && portEfull == 1'b0) begin
			reqReadW = 1'b1; portEfull = 1'b1;
		end
		if (dataInFifoWl[2:1]==West && portWfull == 1'b0) begin
			reqReadW = 1'b1; portWfull = 1'b1;
		end
		if (dataInFifoWl[2:1]==North && portNfull == 1'b0) begin
			reqReadW = 1'b1; portNfull = 1'b1;
		end
		if (dataInFifoWl[2:1]==South && portSfull == 1'b0) begin
			reqReadW = 1'b1; portSfull = 1'b1;
		end
	end
	else
		reqReadW = 1'b0;

	if (dataInFifoNl[0]==1) begin
		if (dataInFifoNl[2:1]==East && portEfull == 1'b0) begin
			reqReadN = 1'b1; portEfull = 1'b1;
		end
		if (dataInFifoNl[2:1]==West && portWfull == 1'b0) begin
			reqReadN = 1'b1; portWfull = 1'b1;
		end
		if (dataInFifoNl[2:1]==North && portNfull == 1'b0) begin
			reqReadN = 1'b1; portNfull = 1'b1;
		end
		if (dataInFifoNl[2:1]==South && portSfull == 1'b0) begin
			reqReadN = 1'b1; portSfull = 1'b1;
		end
	end
	else
		reqReadN = 1'b0;

	if (dataInFifoSl[0]==1) begin
		if (dataInFifoSl[2:1]==East && portEfull == 1'b0) begin
			reqReadS = 1'b1; portEfull = 1'b1;
		end
		if (dataInFifoSl[2:1]==West && portWfull == 1'b0) begin
			reqReadS = 1'b1; portWfull = 1'b1;
		end
		if (dataInFifoSl[2:1]==North && portNfull == 1'b0) begin
			reqReadS = 1'b1; portNfull = 1'b1;
		end
		if (dataInFifoSl[2:1]==South && portSfull == 1'b0) begin
			reqReadS = 1'b1; portSfull = 1'b1;
		end
	end
	else
		reqReadS = 1'b0;

	if (dataInFifoEl[0]==1) begin
		if (dataInFifoEl[2:1]==East && portEfull == 1'b0)begin
			reqReadE = 1'b1; portEfull = 1'b1;
		end
		if (dataInFifoEl[2:1]==West && portWfull == 1'b0)begin
			reqReadE = 1'b1; portWfull = 1'b1;
		end
		if (dataInFifoEl[2:1]==North && portNfull == 1'b0)begin
			reqReadE = 1'b1; portNfull = 1'b1;
		end
		if (dataInFifoEl[2:1]==South && portSfull == 1'b0)begin
			reqReadE = 1'b1; portSfull = 1'b1;
		end
	end
	else
		reqReadE = 1'b0;
end

if (token == 2) begin



	if (dataInFifoNl[0]==1) begin
		if (dataInFifoNl[2:1]==East && portEfull == 1'b0) begin
			reqReadN = 1'b1; portEfull = 1'b1;
		end
		if (dataInFifoNl[2:1]==West && portWfull == 1'b0) begin
			reqReadN = 1'b1; portWfull = 1'b1;
		end
		if (dataInFifoNl[2:1]==North && portNfull == 1'b0) begin
			reqReadN = 1'b1; portNfull = 1'b1;
		end
		if (dataInFifoNl[2:1]==South && portSfull == 1'b0) begin
			reqReadN = 1'b1; portSfull = 1'b1;
		end
	end
	else
		reqReadN = 1'b0;

	if (dataInFifoSl[0]==1) begin
		if (dataInFifoSl[2:1]==East && portEfull == 1'b0) begin
			reqReadS = 1'b1; portEfull = 1'b1;
		end
		if (dataInFifoSl[2:1]==West && portWfull == 1'b0) begin
			reqReadS = 1'b1; portWfull = 1'b1;
		end
		if (dataInFifoSl[2:1]==North && portNfull == 1'b0) begin
			reqReadS = 1'b1; portNfull = 1'b1;
		end
		if (dataInFifoSl[2:1]==South && portSfull == 1'b0) begin
			reqReadS = 1'b1; portSfull = 1'b1;
		end
	end
	else
		reqReadS = 1'b0;

	if (dataInFifoEl[0]==1) begin
		if (dataInFifoEl[2:1]==East && portEfull == 1'b0)begin
			reqReadE = 1'b1; portEfull = 1'b1;
		end
		if (dataInFifoEl[2:1]==West && portWfull == 1'b0)begin
			reqReadE = 1'b1; portWfull = 1'b1;
		end
		if (dataInFifoEl[2:1]==North && portNfull == 1'b0)begin
			reqReadE = 1'b1; portNfull = 1'b1;
		end
		if (dataInFifoEl[2:1]==South && portSfull == 1'b0)begin
			reqReadE = 1'b1; portSfull = 1'b1;
		end
	end
	else
		reqReadE = 1'b0;

	if (dataInFifoWl[0]==1) begin
		if (dataInFifoWl[2:1]==East && portEfull == 1'b0) begin
			reqReadW = 1'b1; portEfull = 1'b1;
		end
		if (dataInFifoWl[2:1]==West && portWfull == 1'b0) begin
			reqReadW = 1'b1; portWfull = 1'b1;
		end
		if (dataInFifoWl[2:1]==North && portNfull == 1'b0) begin
			reqReadW = 1'b1; portNfull = 1'b1;
		end
		if (dataInFifoWl[2:1]==South && portSfull == 1'b0) begin
			reqReadW = 1'b1; portSfull = 1'b1;
		end
	end
	else
		reqReadW = 1'b0;
end

if (token == 3) begin



	if (dataInFifoSl[0]==1) begin
		if (dataInFifoSl[2:1]==East && portEfull == 1'b0) begin
			reqReadS = 1'b1; portEfull = 1'b1;
		end
		if (dataInFifoSl[2:1]==West && portWfull == 1'b0) begin
			reqReadS = 1'b1; portWfull = 1'b1;
		end
		if (dataInFifoSl[2:1]==North && portNfull == 1'b0) begin
			reqReadS = 1'b1; portNfull = 1'b1;
		end
		if (dataInFifoSl[2:1]==South && portSfull == 1'b0) begin
			reqReadS = 1'b1; portSfull = 1'b1;
		end
	end
	else
		reqReadS = 1'b0;

	if (dataInFifoEl[0]==1) begin
		if (dataInFifoEl[2:1]==East && portEfull == 1'b0)begin
			reqReadE = 1'b1; portEfull = 1'b1;
		end
		if (dataInFifoEl[2:1]==West && portWfull == 1'b0)begin
			reqReadE = 1'b1; portWfull = 1'b1;
		end
		if (dataInFifoEl[2:1]==North && portNfull == 1'b0)begin
			reqReadE = 1'b1; portNfull = 1'b1;
		end
		if (dataInFifoEl[2:1]==South && portSfull == 1'b0)begin
			reqReadE = 1'b1; portSfull = 1'b1;
		end
	end
	else
		reqReadE = 1'b0;

	if (dataInFifoWl[0]==1) begin
		if (dataInFifoWl[2:1]==East && portEfull == 1'b0) begin
			reqReadW = 1'b1; portEfull = 1'b1;
		end
		if (dataInFifoWl[2:1]==West && portWfull == 1'b0) begin
			reqReadW = 1'b1; portWfull = 1'b1;
		end
		if (dataInFifoWl[2:1]==North && portNfull == 1'b0) begin
			reqReadW = 1'b1; portNfull = 1'b1;
		end
		if (dataInFifoWl[2:1]==South && portSfull == 1'b0) begin
			reqReadW = 1'b1; portSfull = 1'b1;
		end
	end
	else
		reqReadW = 1'b0;

	if (dataInFifoNl[0]==1) begin
		if (dataInFifoNl[2:1]==East && portEfull == 1'b0) begin
			reqReadN = 1'b1; portEfull = 1'b1;
		end
		if (dataInFifoNl[2:1]==West && portWfull == 1'b0) begin
			reqReadN = 1'b1; portWfull = 1'b1;
		end
		if (dataInFifoNl[2:1]==North && portNfull == 1'b0) begin
			reqReadN = 1'b1; portNfull = 1'b1;
		end
		if (dataInFifoNl[2:1]==South && portSfull == 1'b0) begin
			reqReadN = 1'b1; portSfull = 1'b1;
		end
	end
	else
		reqReadN = 1'b0;
end

end

always @ (*) begin
	
	dataOutE_temp=0;dataOutW_temp=0;dataOutN_temp=0;dataOutS_temp=0;
	if (dataInFifoS[0]==1) begin
		if (dataInFifoS[2:1]==East)
			dataOutE_temp = dataInFifoS;
		if (dataInFifoS[2:1]==West)
			dataOutW_temp = dataInFifoS;
		if (dataInFifoS[2:1]==North)
			dataOutN_temp = dataInFifoS;
		if (dataInFifoS[2:1]==South)
			dataOutS_temp = dataInFifoS;
	end

	if (dataInFifoN[0]==1) begin
		if (dataInFifoN[2:1]==East)
			dataOutE_temp = dataInFifoN;
		if (dataInFifoN[2:1]==West)
			dataOutW_temp = dataInFifoN;
		if (dataInFifoN[2:1]==North)
			dataOutN_temp = dataInFifoN;
		if (dataInFifoN[2:1]==South)
			dataOutS_temp = dataInFifoN;
	end

	if (dataInFifoW[0]==1) begin
		if (dataInFifoW[2:1]==East)
			dataOutE_temp = dataInFifoW;
		if (dataInFifoW[2:1]==West)
			dataOutW_temp = dataInFifoW;
		if (dataInFifoW[2:1]==North)
			dataOutN_temp = dataInFifoW;
		if (dataInFifoW[2:1]==South)
			dataOutS_temp = dataInFifoW;
	end

	if (dataInFifoE[0]==1) begin
		if (dataInFifoE[2:1]==East)
			dataOutE_temp = dataInFifoE;
		if (dataInFifoE[2:1]==West)
			dataOutW_temp = dataInFifoE;
		if (dataInFifoE[2:1]==North)
			dataOutN_temp = dataInFifoE;
		if (dataInFifoE[2:1]==South)
			dataOutS_temp = dataInFifoE;
	end

end


			
endmodule




