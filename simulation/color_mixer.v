//color_mixer.v
//Author: @RndMnkIII
//Date: 24/06/2021.
//Dependecies:
//prio.v ttl_ic.v cram_e14.v cram_e15.v

//Verilog simulation (NOT for synthesis) module that implements Konami Aliens priority and color mixer circuitry.
//This game uses a more primitive priority system based on a 256Bx4bit PROM, only uses the 
//two LSB from the PROM output to choose the color index value between FIX, OBJ, LAYER-A and LAYER-B layers.
//Outputs color data in 16-bit 1BGR format at video clock rate of 6MHz.
//See Konami Aliens Schematics Page 3.
`default_nettype none
`timescale 1ns/1ps

module color_mixer(
    //clock and video signals
    input CLK6,
    //input CSYNC, //NCSY = NVSY & NHSY
    //input VSYNC, //NVSY
    input CBLK, //NCBK = NVBK & NHBK

    //051962 interface: tile layer color indexes
    input NFIX,
    input [5:0] FI,
    input NVA,
    input [5:0] SA,
    input NVB,
    input [5:0] SB,

    //051960-051937 interface: sprite priority and color index
    input WRP,
    input NOBJ,
    input [7:0] OBJ,
    input [2:0] OBP,

    //CPU bus interface
    input [9:0] ADDR,
    inout [7:0] DATA,
    input NRD,
    input CRAMCS,

    //Color output
    output [15:0] COLOR_WD,
    output BLK_OUT,
    output [4:0] B,
    output [4:0] G,
    output [4:0] R
);

    wire H14_Q0, H14_Q1; //Priority selection signals for the 4:1 MUXes
    PRIO h14(.ADDR({1'b0, OBP[0], OBP[1], OBP[2], NFIX, NOBJ, NVB, NVA}),
             .EN1n(1'b0),.EN2n(1'b0), .Q0(H14_Q0), .Q1(H14_Q1));

    //Priority 4:1 MUXes
    wire [7:0] PRIO_OUT;
    //ICs: LS153 G13,G12,H13,I13
    ttl_74153 #(.BLOCKS(8)) PRIO_MUXES(.ENn({8{1'b0}}), 
                                       .SEL({H14_Q1, H14_Q0}), //1:0
                                       .A_2D({ 1'b0, OBJ[7], 1'b1,  1'b0,
                                               1'b0, OBJ[6], 1'b0,  1'b1,
                                              FI[5], OBJ[5], SB[5], SA[5],
                                              FI[4], OBJ[4], SB[4], SA[4],
                                              FI[3], OBJ[3], SB[3], SA[3],
                                              FI[2], OBJ[2], SB[2], SA[2],
                                              FI[1], OBJ[1], SB[1], SA[1],
                                              FI[0], OBJ[0], SB[0], SA[0]}), //31:0
                                       .Y(PRIO_OUT));
    wire OBJ_PAL_SEL; //LS08: seleccionamos cuando utilizamos los 256 colores de paleta mas altos para los sprites
    assign #5 OBJ_PAL_SEL = ~H14_Q0 & H14_Q1;

    //Register the selected color index (LS174 DFFs and blanking signal
    reg [8:0] CC_R;
    reg CBLK_R;
    reg OBJ_PAL_SEL_R;

    //ICs: LS174 G17,G16
    always @ (posedge CLK6) begin
        CC_R[7] <= #25 PRIO_OUT[7];
        CC_R[6] <= #25 PRIO_OUT[6];
        CC_R[5] <= #25 PRIO_OUT[5];
        CC_R[4] <= #25 PRIO_OUT[4];
        CC_R[3] <= #25 PRIO_OUT[3];
        CC_R[2] <= #25 PRIO_OUT[2];
        CC_R[1] <= #25 PRIO_OUT[1];
        CC_R[0] <= #25 PRIO_OUT[0];
        CBLK_R  <= #25 CBLK;
        OBJ_PAL_SEL_R <= #25 OBJ_PAL_SEL;
    end

    //ICs: LS157 D16,D17,E17
    wire [11:0] IDX_Q;
    wire CRMOE; //Output enable for CRAM
    
    ttl_74157 #(.BLOCKS(12)) CPU_PRIO_SEL(.ENn(1'b0),
                                          .SEL({CRAMCS}),
                                          .A_2D({1'b0,    NRD,     1'b1,   ~ADDR[0], 1'b1,    ADDR[0], OBJ_PAL_SEL_R, ADDR[9],
                                                 CC_R[7], ADDR[8], CC_R[6], ADDR[7], CC_R[5], ADDR[6], CC_R[4],       ADDR[5],
                                                 CC_R[3], ADDR[4], CC_R[2], ADDR[3], CC_R[1], ADDR[2], CC_R[0],       ADDR[1]}),
                                          .Y(IDX_Q));
    
    assign CRMOE = IDX_Q[11];

    wire CLWR1; //LS32
    wire CLWR2; //LS32
    assign #13 CLWR1 = IDX_Q[9] | WRP;
    assign #13 CLWR2 = IDX_Q[10] | WRP;

    wire [7:0] W15_8;
    wire [7:0] W7_0;
    ttl_74245 G15(.A(DATA), .B(W15_8), .DIR(NRD), .OEn(IDX_Q[9]));
    ttl_74245 G14(.A(DATA), .B(W7_0), .DIR(NRD), .OEn(IDX_Q[10]));

    //CRAM IC E15 even bytes of a color (16bits).
    CRAM_E15 E15(.ADDR({IDX_Q[5], IDX_Q[0], IDX_Q[6], IDX_Q[7], IDX_Q[8], IDX_Q[3], IDX_Q[2], IDX_Q[4], IDX_Q[1]}),
                 .CEn(1'b0), .OEn(CRMOE), .WEn(CLWR1), .DATA(W15_8));
    
    //CRAM IC E14 odd bytes of a color (16bits).
    CRAM_E14 E14(.ADDR({IDX_Q[5], IDX_Q[0], IDX_Q[6], IDX_Q[8], IDX_Q[7], IDX_Q[3], IDX_Q[2], IDX_Q[4], IDX_Q[1]}),
                 .CEn(1'b0), .OEn(CRMOE), .WEn(CLWR2), .DATA(W7_0));

        //ICs: LS174 D15,D14
    reg [15:0] COUT_R;
    always @ (posedge CLK6) begin
        COUT_R[15] <= #25 CBLK_R; //W15_8[7] is unused to color output data
        COUT_R[14] <= #25 W15_8[6];
        COUT_R[13] <= #25 W15_8[5];
        COUT_R[12] <= #25 W15_8[4];
        COUT_R[11] <= #25 W15_8[3];
        COUT_R[10] <= #25 W15_8[2];
        COUT_R[9]  <= #25 W15_8[1];
        COUT_R[8]  <= #25 W15_8[0];
        COUT_R[7]  <= #25 W7_0[7];
        COUT_R[6]  <= #25 W7_0[6];
        COUT_R[5]  <= #25 W7_0[5];
        COUT_R[4]  <= #25 W7_0[4];
        COUT_R[3]  <= #25 W7_0[3];
        COUT_R[2]  <= #25 W7_0[2];;
        COUT_R[1]  <= #25 W7_0[1];;
        COUT_R[0]  <= #25 W7_0[0];;
    end

    assign COLOR_WD = COUT_R;
    assign BLK_OUT = COUT_R[15];
    assign B = COUT_R[14:10];
    assign G = COUT_R[9:5];
    assign R = COUT_R[4:0];
endmodule

