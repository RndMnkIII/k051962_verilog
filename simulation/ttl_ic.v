//ttl_ic.v
//Author: @RndMnkIII
//Date: 24/06/2021.
//Support library for simulation of various 7400 series ICs
//Partly based on 7400 Library verilog code of Tim Rudy:
//https://github.com/TimRudy/ice-chips-verilog

`default_nettype none
`timescale 1ns/1ps

`define ASSIGN_UNPACK_ARRAY(PK_LEN, PK_WIDTH, UNPK_DEST, PK_SRC) wire [PK_LEN*PK_WIDTH-1:0] PK_IN_BUS; assign PK_IN_BUS=PK_SRC; generate genvar unpk_idx; for (unpk_idx=0; unpk_idx<PK_LEN; unpk_idx=unpk_idx+1) begin: gen_unpack assign UNPK_DEST[unpk_idx][PK_WIDTH-1:0]=PK_IN_BUS[PK_WIDTH*unpk_idx+:PK_WIDTH]; end endgenerate

`define PACK_ARRAY(PK_LEN, PK_WIDTH, UNPK_SRC) PK_OUT_BUS; wire [PK_LEN*PK_WIDTH-1:0] PK_OUT_BUS; generate genvar pk_idx; for (pk_idx=0; pk_idx<PK_LEN; pk_idx=pk_idx+1) begin: gen_pack assign PK_OUT_BUS[PK_WIDTH*pk_idx+:PK_WIDTH]=UNPK_SRC[pk_idx][PK_WIDTH-1:0]; end endgenerate



// Dual 4-input multiplexer, tPLH, TPHL 12-15ns
module ttl_74153 #(parameter BLOCKS = 2, WIDTH_IN = 4, WIDTH_SELECT = $clog2(WIDTH_IN))
(
  input [BLOCKS-1:0] ENn, //1:0
  input [WIDTH_SELECT-1:0] SEL, //1:0
  input [BLOCKS*WIDTH_IN-1:0] A_2D, //7:0
  output [BLOCKS-1:0] Y //1:0
);

    //------------------------------------------------//
    wire [WIDTH_IN-1:0] A [0:BLOCKS-1];
    reg [BLOCKS-1:0] computed;
    integer i;

    always @(*)
    begin
    for (i = 0; i < BLOCKS; i++)
    begin
        if (!ENn[i])
        computed[i] = A[i][SEL];
        else
        computed[i] = 1'b0;
    end
    end
    //------------------------------------------------//

    `ASSIGN_UNPACK_ARRAY(BLOCKS, WIDTH_IN, A, A_2D)
    assign #15 Y = computed;
endmodule

//Tri-state Octal Bus Transceiver
//Propagation delay 8ns
//OE to logic 25ns
//Output Disable to logic 15ns
module ttl_74245( inout [7:0] A,
                  inout [7:0] B,
                  input DIR,
                  input OEn);

    wire ena_AtoB;
    wire ena_BtoA;

    assign ena_AtoB = DIR & !OEn;
    assign ena_BtoA = !DIR & !OEn;

    assign #8 A =(ena_AtoB) ? B : 8'bz;
    assign #8 B =(ena_BtoA) ? A : 8'bz;
endmodule

// Quad 2-input multiplexer

module ttl_74157 #(parameter BLOCKS = 4, WIDTH_IN = 2, WIDTH_SELECT = $clog2(WIDTH_IN))
(
  input ENn,
  input [WIDTH_SELECT-1:0] SEL,
  input [BLOCKS*WIDTH_IN-1:0] A_2D,
  output [BLOCKS-1:0] Y
);
    //------------------------------------------------//
    wire [WIDTH_IN-1:0] A [0:BLOCKS-1];
    reg [BLOCKS-1:0] computed;
    integer i;

    always @(*)
    begin
    for (i = 0; i < BLOCKS; i++)
    begin
        if (!ENn)
        computed[i] = A[i][SEL];
        else
        computed[i] = 1'b0;
    end
    end
    //------------------------------------------------//

    `ASSIGN_UNPACK_ARRAY(BLOCKS, WIDTH_IN, A, A_2D)
    assign #17.5 Y = computed;
endmodule