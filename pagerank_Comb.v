module pageRank #(parameter N=64, WIDTH=16)
(
input clk,
input reset,
input [N*N-1:0] adjacency,
input [N*WIDTH-1:0] weights,
output  [10*WIDTH-1:0] top10Vals,
output  [10*6-1:0] top10IDs,
output  done);

localparam start1=0;
localparam start2=N/4;
localparam start3=N/2;
localparam start4=3*N/4;
localparam finish1=N/4;
localparam finish2=N/2;
localparam finish3=3*N/4;
localparam finish4=N;


wire [8:0] requestE,requestW,requestN,requestS;
wire [16*WIDTH+95:0] nodevalueE,nodevalueW,nodevalueN,nodevalueS;
reg [WIDTH+4:0] received_packetE,received_packetW,received_packetN,received_packetS;
wire[WIDTH+4:0] my_dataE,my_dataW,my_dataN,my_dataS;
wire[WIDTH-1:0] noofcyclesE,noofcyclesW,noofcyclesN,noofcyclesS;

wire writeE_R, writeW_R, writeN_R, writeS_R,writeE, writeW, writeN, writeS;
wire [WIDTH+4:0] dataInE_R, dataInW_R, dataInN_R, dataInS_R;
wire [WIDTH+4:0] dataOutE_R, dataOutW_R, dataOutN_R, dataOutS_R;
wire fullE_R, almost_fullE_R, fullW_R, almost_fullW_R, fullN_R, almost_fullN_R, fullS_R, almost_fullS_R,fullE, almost_fullE, fullW, almost_fullW, fullN, almost_fullN, fullS, almost_fullS;
wire op_WriteE_R, op_WriteW_R, op_writeN_R, op_writeS_R,op_WriteE, op_WriteW, op_writeN, op_writeS;

wire[8:0] dataInE, dataInW, dataInN, dataInS;
wire[8:0] dataOutE, dataOutW, dataOutN, dataOutS;
reg [1407:0] nodevalue_all;
noc_router #(21,4) nocresp
(clk, reset,
writeE_R, writeW_R, writeN_R, writeS_R,
dataInE_R, dataInW_R, dataInN_R, dataInS_R,
1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0,
dataOutE_R, dataOutW_R, dataOutN_R, dataOutS_R,
fullE_R, almost_fullE_R, fullW_R, almost_fullW_R, fullN_R, almost_fullN_R, fullS_R, almost_fullS_R,
op_WriteE_R, op_WriteW_R, op_writeN_R, op_writeS_R
);

noc_router  #(9,4) noc_req ( clk,reset,
writeE, writeW, writeN, writeS,
dataInE, dataInW, dataInN, dataInS,
fullE_R, almost_fullE_R, fullW_R, almost_fullW_R, fullN_R, almost_fullN_R, fullS_R, almost_fullS_R,
dataOutE, dataOutW, dataOutN, dataOutS,
fullE, almost_fullE, fullW, almost_fullW, fullN, almost_fullN, fullS, almost_fullS,
op_WriteE, op_WriteW, op_writeN, op_writeS
);

requester #(2'b00,9) reqE( clk,reset,fullE,almost_fullE,requestE,dataInE,writeE);
requester #(2'b01,9) reqW( clk,reset,fullW,almost_fullW,requestW,dataInW,writeW);
requester #(2'b10,9) reqN( clk,reset,fullN,almost_fullN,requestN,dataInN,writeN);
requester #(2'b11,9) reqS( clk,reset,fullS,almost_fullS,requestS,dataInS,writeS);

responder  #(16,4) respE (clk, reset, fullE_R, almost_fullE_R, my_dataE, dataOutE, dataInE_R, writeE_R );
responder  #(16,4) respW (clk, reset, fullW_R, almost_fullW_R, my_dataW, dataOutW, dataInW_R, writeW_R );
responder  #(16,4) respN (clk, reset, fullN_R, almost_fullN_R, my_dataN, dataOutN, dataInN_R, writeN_R );
responder  #(16,4) respS (clk, reset, fullS_R, almost_fullS_R, my_dataS, dataOutS, dataInS_R, writeS_R );

pagerank  #(2'b00,start1,finish1,WIDTH) prE(clk,reset,adjacency,weights,dataOutE_R,requestE,my_dataE,nodevalueE,noofcyclesE);
pagerank  #(2'b01,start2,finish2,WIDTH) prW(clk,reset,adjacency,weights,dataOutW_R,requestW,my_dataW,nodevalueW,noofcyclesW);
pagerank  #(2'b10,start3,finish3,WIDTH) prN(clk,reset,adjacency,weights,dataOutN_R,requestN,my_dataN,nodevalueN,noofcyclesN);
pagerank  #(2'b11,start4,finish4,WIDTH) prS(clk,reset,adjacency,weights,dataOutS_R,requestS,my_dataS,nodevalueS,noofcyclesS);

sorter #(64,16) sort( clk,  reset, nodevalue_all, top10Vals,top10IDs,done);

always@(posedge clk)begin

if(noofcyclesE>624 && noofcyclesW>624 && noofcyclesN>624 && noofcyclesS>624)begin
	nodevalue_all <= {nodevalueS,nodevalueN,nodevalueW,nodevalueE};
end
end
endmodule 