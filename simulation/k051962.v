/*****************************************************************
 * Verilog simulation module of the k051962 Tile Layer Generator *
 * Based on @Furrtek schematics on 051962 die tracing:           *
 * https://github.com/furrtek/VGChips/tree/master/Konami/051962  *
 * Author: @RndMnkIII                                            *
 * Repository: https://github.com/RndMnkIII/k051962_verilog      *
 * Version: 1.0 16/06/2021                                       *
 ****************************************************************/

`define MODEL_DLY 1
`include "fujitsu_AV_delay_defs.v"
`default_nettype none
`timescale 1ns/10ps

module k051962_DLY (
    input wire M24,
    input wire RES,
    output wire RST, //Delayed RES signal
    input wire [1:0] AB,
    input wire NRD,
    inout wire [7:0] DB,
    inout wire [31:0] VC,
    input wire [7:0] COL,
    input wire ZB4H, ZB2H, ZB1H,
    input wire ZA4H, ZA2H, ZA1H,
    input wire BEN,
    input wire CRCS,
    input wire RMRD,
    output wire NSBC,
    output wire [11:0] DSB, //0,1,2,3,4,5,6,7,A,B,C,D
    output wire NSAC,
    output wire [11:0] DSA, //0,1,2,3,4,5,6,7,A,B,C,D
    output wire NFIC,
    output wire [7:0] DFI,
    output wire NVBK, NHBK, OHBK, NVSY, NHSY, NCSY,
    output wire P1H, M6, M12,
    input wire TEST,
    output [63:0] DBG);

//*** DBG ASSIGNMENTS Section ***
    assign DBG[0] = BB7;
    assign DBG[1] = T70;
    assign DBG[2] = BB105_QD;
    assign DBG[3] = CC58;

    //Calculate remaining unassigned bits:
    // 64 - last_dbg_bit_position - 1
    //64 - 2 -1 = 61
    assign DBG[63:4] = {60{1'b0}};

//*** DUMMY OUTPUT PORTS Section ***
    //assign RST = 1'b1;
    //assign NSBC = 1'b1;
    //assign DSB = {12{1'b1}};
    //assign NSAC = 1'b1;
    //assign DSA = {12{1'b1}};
    //assign NFIC = 1'b1;
    //assign DFI = {12{1'b1}};
    //assign NVBK = 1'b1;
    //assign NHBK = 1'b1;
    //assign OHBK = 1'b1;
    //assign NVSY = 1'b1;
    //assign NHSY = 1'b1;
    //assign NCSY = 1'b1;

    //assign P1H = 1'b1;

//*** TIMING GENERATION: PAGE 1 Section ***
    wire BB8_BOT;
    
    wire BB8_Qn;
    FDE_DLY bb8( .D(1'b1), .CLn(RES), .CK(M24), .Q(BB8_BOT), .Qn(BB8_Qn));
    
    wire BB7; //Logic Cell V2B
    assign #0.64 BB7 = ~BB8_Qn; //BB7 is a signal used to async clear multiple DFF.

    wire CC56; //Logic Cell V1N
    assign #0.55 CC56 = ~BB7;

    wire CC58; //Logic Cell V1N
    assign #0.55 CC58 = ~CC56; //To Pg. 3 RST delay chain

    wire Z4_Q, Z4_Qn;
    FDN_DLY z4( .D(Z4_Qn), .Sn(BB8_BOT), .CK(M24), .Q(Z4_Q), .Qn(Z4_Qn)); //outputs to M12 bypass Z11 buffer
    wire Z11; //Logic Cell K1B
    assign #1.26 Z11 = Z4_Q;
    assign M12 = Z11; //*** M12 Output Signal ***

    wire Z19;
    wire Z26; //Logic Cell X1B

    FDN_DLY z19( .D(Z26), .Sn(BB8_BOT), .CK(M24), .Q(Z19));
    assign #3.24 Z26 = ~(Z19 ^ Z35);

    wire Z47_Q, Z47_Qn;
    FDN_DLY z47( .D(Z30), .Sn(BB8_BOT), .CK(M24), .Q(Z47_Q), .Qn(Z47_Qn));

    wire Z30, Z35;
    assign #3.24 Z30 = ~(Z47_Qn ^ Z4_Qn);
    assign #0.71 Z35 = ~(Z47_Qn & Z4_Qn);

    wire BB75; //Logic Cell K1B
    assign #1.26 BB75 = Z47_Q;
    assign M6 = BB75; //*** M6 Output Signal ***

    wire T70; //Logic Cell K2B
    assign `DLY_K2B T70 = Z47_Q; //T70 is a signal used to clock multiple DFF and 4-bit counters

    wire Z68_Q;
    FDG_DLY z68( .D(Z47_Q), .CLn(BB7), .CK(M24), .Q(Z68_Q)); //check BB7 origin 
    wire T61; //Logic Cell K2B
    assign #1.83 T61 = Z68_Q; //triggers tile layers MSBs LATCHES (Gn input)

    /**************************************************************/

    wire AA103; //Logic Cell N2P
    assign #1.41 AA103 = Z99_CO & AA102;

    wire AA97; //Logic Cell R2P
    assign #1.97 AA97 = AA103 | AA86_Qn;
    
    wire AA99; //Logic Cell N2P
    assign #1.41 AA99 = AA97 & AA102;

    wire AA86_Q, AA86_Qn;
    FDG_DLY aa86(.D(AA99), .CLn(BB7), .CK(T70), .Q(AA86_Q), .Qn(AA86_Qn));
    assign OHBK = AA86_Q; //*** OHBK Output Signal ***

    //Y151 comes from SCROLLING section
    wire Y100_Qn;
    FDG_DLY y100(.D(Y151), .CLn(BB7), .CK(T70), .Qn(Y100_Qn));

    wire Z78; //Logic Cell N2N
    assign #0.71 Z78 = ~(AA86_Q & Z80); //Z80 inverted output of QB AA108 4-bit binary cnt.

    wire AA77_Qn;
    FDG_DLY aa77( .D(AA86_Qn), .CLn(BB7), .CK(Y100_Qn), .Qn(AA77_Qn));
    assign NHBK = AA77_Qn; //*** NHBK Output Signal ***

    wire Z81_Qn;
    FDN_DLY z81( .D(Z78), .Sn(BB7), .CK(Z99_QD), .Qn(Z81_Qn));

    wire BB83; //Logic Cell X1B
    assign #3.24 BB83 = ~(BB87_Q ^ AA105);

    wire Z88_Qn;
    FDN_DLY z88( .D(Z81_Qn), .Sn(BB7), .CK(Z99_QC), .Qn(Z88_Qn));

    wire CC87_Q, CC87_Qn;
    FDG_DLY cc87( .D(CC86), .CLn(BB7), .CK(BB105_QD), .Q(CC87_Q), .Qn(CC87_Qn));
    assign NVBK = CC87_Qn;

    wire BB87_Q, BB87_Qn;
    FDG_DLY bb87( .D(BB83), .CLn(BB7), .CK(T70), .Q(BB87_Q), .Qn(BB87_Qn));

    wire BB81; //Logic Cell N2P
    assign BB81 = TEST & AB[0];

    wire Y86_Qn;
    FDN_DLY y86( .D(Z88_Qn), .Sn(BB7), .CK(Z99_QA_BUF), .Qn(Y86_Qn));
    assign NHSY = Y86_Qn; //*** NHSY Output Signal ***

//  CL(BB7),CK(T70)->BB105->QD->CK(QD)->CC87->Q->BB80->BB78

    wire AA105; //Logic Cell N3P
    assign #1.82 AA105 = Z99_CO & AA108_QC & AA108_QD;

    wire BB99; //Logic Cell N2P
    assign #1.41 BB99 = AA105 & BB87_Qn;

    wire BB101; //Logic Cell R2P
    assign #1.97 BB101 = BB81 | BB87_Qn;

    wire BB103; //Logic Cell R2P
    assign #1.97 BB103 = BB81 | BB99;

    wire BB80; //Logic Cell V1N
    assign #0.55 BB80 = ~CC87_Q;

    wire AA102; //Logic Cell V1N
    assign #0.55 AA102 = ~AA105;

    wire BB78; //Logic Cell V1N
    assign #0.55 BB78 = ~BB80;

    wire Z99_CO, Z99_QA, Z99_QB, Z99_QC, Z99_QD;
    //Y147 comes from SCROLLING section
    C43_DLY z99(.CK(T70), .CLn(BB7), .Ln(AA102), .CI(Y147), .EN(Y147), .CO(Z99_CO), .Q({Z99_QD, Z99_QC, Z99_QB, Z99_QA}), .D(4'b0000));
    wire X148; //Logic Cell K2B
    wire Z99_QA_BUF;
    assign #1.83 X148 = Z99_QA;
    assign Z99_QA_BUF = X148;
    

    wire AA108_QA; //this output is left unconnected but must be specified in the output vector port (a bit vector port cannot partial o full left unconected)
    wire AA108_QB, AA108_QC, AA108_QD;
    C43_DLY aa108(.CK(T70), .CLn(BB7), .Ln(AA102), .CI(Z99_CO), .EN(Z99_CO), .Q({AA108_QD, AA108_QC, AA108_QB, AA108_QA}), .D({4'b0001}));
    wire Z80; //Logic Cell V1N
    assign #0.55 Z80 = ~ AA108_QB;

    wire BB105_QA, BB105_QB, BB105_QC; //these outputs are left unconnected but must be specified in the output vector port (a bit vector port cannot partial o full left unconected)
    wire BB105_QD;
    wire BB105_CO;
    C43_DLY bb105(.CK(T70), .CLn(BB7), .Ln(CC104), .CI(BB103), .EN(BB101), .CO(BB105_CO), .Q({BB105_QD, BB105_QC, BB105_QB, BB105_QA}), .D(4'b1100));

    wire CC104; //Logic Cell V1N
    assign #0.55 CC104 = ~CC107_CO;

    wire CC107_QA, CC107_QB, CC107_QC; //these outputs are left unconnected but must be specified in the output vector port (a bit vector port cannot partial o full left unconected)
    wire CC107_QD;
    wire CC107_CO;
    C43_DLY cc107(.CK(T70), .CLn(BB7), .Ln(CC104), .CI(BB105_CO), .EN(BB101), .CO(CC107_CO), .Q({CC107_QD, CC107_QC, CC107_QB, CC107_QA}), .D(4'b0111));

    wire CC105; //Logic Cell N3N
    assign #0.83 CC105 = ~(CC107_QA & CC107_QB & CC107_QC);

    wire CC86; //Logic Cell N2N
    assign #0.71 CC86 = ~(CC105 & CC80);

    wire CC80; //Logic Cell N2N
    assign #0.71 CC80 = ~(AB[1] & TEST);

    wire CC82; //Logic Cell V1N
    assign #0.55 CC82 = ~TEST;

    wire CC83; //Logic Cell N2P
    assign #1.41 CC83 = CC82 & NHSY;

    wire CC98_Q;
    LTL_DLY cc98(.D(CC107_QD), .Gn(CC83), .CLn(BB7), .Q(CC98_Q));
    assign NVSY = CC98_Q; //*** NVSY Output Signal ***

    wire CC77; //Logic Cell N2P
    assign  #1.41 CC77 = NVSY & NHSY;
    assign NCSY = CC77; //*** NCSY Output Signal ***


    /**************************************************************/

    wire X90; //Logic Cell V1N
    assign #0.55 X90 = Z99_QA_BUF;

    wire X88; //Logic Cell V1N
    assign #0.55 X88 = Z99_QB;
    
    //Y93 comes from SCROLLING section
    wire X145; //Logic Cell N3P
    assign #1.82 X145 = Y93 & Z99_QA_BUF & Z99_QB;

    //Y93 comes from SCROLLING section
    wire X81; //Logic Cell N3P
    assign #1.82 X81 = Y93 & X90 & X88;

    //Y93 comes from SCROLLING section
    wire X84; //Logic Cell N3P
    assign #1.82 X84 = Y93 & X90 & Z99_QB;

    wire V154; //Logic Cell V2B
    assign #0.64 V154 = ~X145; //To pg 4,5,6,7,8,9,10,11,12,13 LAYER A D0-D3-MSBs STAGE 2 selection signal, LAYER B D0-D3-MSBs STAGE 1 selection signal

    wire X80; //Logic Cell V2B
    assign #0.64 X80 = ~X81; //To pg. 14,15,16,17,18 //LAYER FIX D0-D3, MSBs

    wire X78; //Logic Cell V2B
    assign #0.64 X78 = ~X84; //To pg. 4,5,6,7,8 LAYER A D0-D3, MSBs Stage 1 selection signal
  
    
// *** ROM READBACK MUX: PAGE 2 Section ***
    wire BB68; //Logic Cell V1N;
    assign #0.55 BB68 = ~AB[1];

    wire BB54; //Logic Cell V1N;
    assign #0.55 BB54 = ~AB[0];

    wire ADDR0; //BB47 Logic Cell N2P
    assign #1.41 ADDR0 = BB68 & BB54;

    wire ADDR1; //BB69 Logic Cell N2P
    assign #1.41 ADDR1 = BB68 & AB[0];

    wire ADDR2; //BB51 Logic Cell N2P
    assign #1.41 ADDR2 = AB[1] & BB54;

    wire ADDR3; //BB49 Logic Cell N2P
    assign #1.41 ADDR3 = AB[1] & AB[0];

    wire [31:0] VC_IN;
    wire [7:0] DB_OUT;

    generate
        genvar i;
        for(i=0; i < 8; i=i+1) begin: N2N_N4B 
            //N2N + N4B = 0.71 + 2.38 = 3.09
            assign #3.09 DB_OUT[i] = ~&{~(VC_IN[24+i] & ADDR3), ~(VC_IN[16+i] & ADDR2), ~(VC_IN[8+i] & ADDR1), ~(VC_IN[0+i] & ADDR0)};
        end
    endgenerate


// *** SCROLLING: PAGE 3 Section ***
   
    //-- Reset Subsection --
    wire CC59_Q;
    FDG_DLY cc59(.D(CC58), .CLn(CC58), .CK(BB78), .Q(CC59_Q));

    wire CC68_Q;
    FDG_DLY cc68(.D(CC59_Q), .CLn(CC58), .CK(BB78), .Q(CC68_Q));

    wire CC35_Q;
    FDG_DLY cc35(.D(CC68_Q), .CLn(CC58), .CK(BB78), .Q(CC35_Q));

    wire CC44_Q;
    FDG_DLY cc44(.D(CC35_Q), .CLn(CC58), .CK(BB78), .Q(CC44_Q));

    wire CC23_Q;
    FDG_DLY cc23(.D(CC44_Q), .CLn(CC58), .CK(BB78), .Q(CC23_Q));

    wire CC3_Q;
    FDG_DLY cc3(.D(CC23_Q), .CLn(CC58), .CK(BB78), .Q(CC3_Q));

    wire CC14_Q;
    FDG_DLY cc14( .D(CC3_Q), .CLn(CC58), .CK(BB78), .Q(CC14_Q));

    wire BB33_Q;
    FDG_DLY bb33( .D(CC14_Q), .CLn(CC58), .CK(BB78), .Q(BB33_Q));

    assign RST = BB33_Q; //*** RST Output Signal ***
    //-- End of Reset Subsection --

    //-- Subsection
    //D24_DLY xxx (.A1(), .A2(), .B1(), .B2(), .X());
    wire J73_X;
    //H13, H15 come from pg 13 Section LAYER B MSBs
    D24_DLY j73 (.A1(J61_Qn), .A2(H13), .B1(COL[0]), .B2(H15), .X(J73_X));

    wire J61_Qn;
    //L67 comes from pg 13 Section LAYER B MSBs
    FDM_DLY j61 (.D(J73_X), .CK(T70), .Qn(J61_Qn)); //T70 -> l67

    wire K81_X;
    //L120, K153 from pg. 13
    D24_DLY k81 (.A1(K83_Qn), .A2(K153), .B1(J61_Qn), .B2(L120), .X(K81_X));

    wire K83_Qn;
    //L106 from pg. 13
    FDM_DLY k83 (.D(K81_X), .CK(T70), .Qn(K83_Qn)); //T70 -> l67

    wire M67_X;
    //M60, M52 from pg. 18
    D24_DLY m67 (.A1(M61_Qn), .A2(M52), .B1(COL[0]), .B2(M60), .X(M67_X));

    //M69 from pg. 18
    wire M61_Qn;
    FDM_DLY m61 (.D(M67_X), .CK(T70), .Qn(M61_Qn)); //T70 -> M69

    wire S77_Qn;
    FDG_DLY s77(.D(DB0_IN_BUF), .CLn(BB7), .CK(BEN), .Q(S77_Qn));

    wire S86_Qn;
    FDG_DLY s86(.D(DB1_IN_BUF), .CLn(BB7), .CK(BEN), .Q(S86_Qn));

    wire P92; //Logic Cell N2N
    assign #0.71 P92 = ~(S86_Qn & K83_Qn);

    wire S96; //Logic Cell N2N
    assign #0.71 S96 = ~(S86_Qn & M61_Qn);

    wire S111; //Logic Cell N2N
    assign #0.71 S111 = ~(S86_Qn & DSA[8]); //DSAA

    wire P87; //Logic Cell X2B
    assign #3.50 P87 = P92 ^ S77_Qn;

    wire S102; //Logic Cell X2B
    assign #3.50 S102 = S96 ^ S77_Qn;

    wire S106; //Logic Cell X2B
    assign #3.50 S106 = S111 ^ S77_Qn;
    //-- End of Subsection --

    //-- Subsection
    //---LAYER B----
    wire L79; //Logic Cell X2B
    assign #3.50 L79 = P87 ^ ZB4H; //To pg. 9,10,11,12 LAYER B D0-3

    wire L87; //Logic Cell X2B
    assign #3.50 L87 = P87 ^ ZB1H; //To pg. 9,10,11,12 LAYER B D0-3

    wire L83; //Logic Cell X2B
    assign #3.50 L83 = P87 ^ ZB2H; //To pg. 9,10,11,12 LAYER B D0-3

    wire L77; //Logic Cell N3N
    assign #0.83 L77 = ~(ZB4H & ZB1H & ZB2H); //TO PG. 9,10,11,12, 13(LAYER B MSBs) Stage 2 selection signal
    
    //---LAYER A, LAYER FIX----
    wire T11; //Logic Cell X2B
    assign #3.50 T11 = S106 ^ ZA2H; //TO PG. 4,5,6,7 LAYER A D0-D3, 15 LAYER FIX D1

    wire T15; //Logic Cell X2B
    assign #3.50 T15 = S106 ^ ZA4H; //TO PG. 4,5,6,7 LAYER A D0-D3, 15 LAYER FIX D1

    wire T7; //Logic Cell X2B
    assign #3.50 T7 = S106 ^ ZA1H; //TO PG. 4,5,6,7 LAYER A D0-D3, 15 LAYER FIX D1

    wire T19; //Logic Cell N3N
    assign #0.83 T19 = ~(ZA4H & ZA1H & ZA2H); //TO PG. 4,5,6,7 LAYER A D0-D3, 8 LAYER A MSBs Stage 3 selection signal
    //-- End of Subsection --


    //-- End of Reset Subsection --

    //-- Subsection
    wire Z59_Q;
    FDG_DLY z59( .D(Z19), .CLn(BB8_BOT), .CK(M24), .Q(Z59_Q));

    wire Y77_Qn;
    FDG_DLY y77( .D(Z59_Q), .CLn(BB7), .CK(T70), .Q(Y77_Qn));

    wire Y93; //Logic Cell K2B
    assign #1.83 Y93 = ~Y77_Qn;
    assign P1H = Y93;

    wire Y147; //Logic Cell R2P
    assign #1.97 Y147 = Y77_Qn | TEST;

    wire Y149; //Logic Cell N2P
    assign #1.41 Y149 = Y147 & Z99_QC;

    wire Y154; //Logic Cell R2N
    assign #0.87 Y154 = ~(Z99_QB | Z99_QA_BUF);

    wire Y151; //Logic Cell N2P
    assign #1.41 Y151 = Y149 & Y154;

    wire X116_Qn;
    FDG_DLY x116( .D(Z99_QB), .CLn(BB7), .CK(Z99_QA_BUF), .Qn(X116_Qn));

    wire X126; //Logic Cell V1N
    assign #0.55 X126 = ~Z99_QA;

    wire X102; //Logic Cell X2B
    assign #3.50 X102 = Y93 ^ S102; //To pg. 14,15,16,17 LAYER FIX D0-D3

    wire X108; //Logic Cell X2B
    assign #3.50 X108 = X116_Qn ^ S102; //To pg. 14,15,16,17 LAYER FIX D0-D3

    wire X112; //Logic Cell X2B
    assign #3.50 X112 = X126 ^ S102; //To pg. 14,15,16,17 LAYER FIX D0-D3
    //-- End of Subsection --

    //-- Subsection
    //-- End of Subsection --



    // *** LAYER A D0: PAGE 4 Section ***
    wire R104; //Logic Cell V1N
    assign #0.55 R104 = ~ T7;
    wire R110; //Logic Cell V1N
    assign #0.55 R110 = ~ T15;
    wire R108; //Logic Cell V1N
    assign #0.55 R108 = ~ T11;

//-- VC7-VC0_IN
    wire [7:0] LAYER_A_D0_OUT;
    generate
        for(i = 7; i >= 0; i = i - 1) begin: LAYER_A_D0_VCIN
            VC_IN_DLY  inst(.DIN(VC_IN[i]), .SEL1(X78), .SEL2(V154), .SEL3(T19), .CK(T70), .DOUT(LAYER_A_D0_OUT[i]));
        end
    endgenerate
    
    wire R101; //Logic Cell N4N
    assign #0.96 R101 = ~(LAYER_A_D0_OUT[7] & T15 & T11 & T7);

    wire R99; //Logic Cell N4N
    assign #0.96 R99 = ~(LAYER_A_D0_OUT[6] & T15 & T11 & R104);

    wire R81; //Logic Cell N4N
    assign #0.96 R81 = ~(LAYER_A_D0_OUT[5] & T15 & R108 & T7);

    wire R85; //Logic Cell N4N
    assign #0.96 R85 = ~(LAYER_A_D0_OUT[4] & T15 & R108 & R104);

    wire R77; //Logic Cell N4N
    assign #0.96 R77 = ~(LAYER_A_D0_OUT[3] & R110 & T11 & T7);

    wire R83; //Logic Cell N4N
    assign #0.96 R83 = ~(LAYER_A_D0_OUT[2] & R110 & T11 & R104);

    wire R79; //Logic Cell N4N
    assign #0.96 R79 = ~(LAYER_A_D0_OUT[1] & R110 & R108 & T7);

    wire R93; //Logic Cell N4N
    assign #0.96 R93 = ~(LAYER_A_D0_OUT[0] & R110 & R108 & R104);

    wire R87; //Logic Cell N8B
    assign #3.09 R87 = ~(R101 & R99 & R81 & R85 & R77 & R83 & R79 & R93); //DSA0



    // *** LAYER A D1: PAGE 5 Section ***
    wire P112; //Logic Cell V1N
    assign #0.55 P112 = ~ T7;
    wire P78; //Logic Cell V1N
    assign #0.55 P78 = ~ T15;
    wire P114; //Logic Cell V1N
    assign #0.55 P114 = ~ T11;

    //-- VC15-VC8_IN
    wire [7:0] LAYER_A_D1_OUT;
    generate
        for(i = 15; i >= 8; i = i - 1) begin: LAYER_A_D1_VCIN
            VC_IN_DLY  inst(.DIN(VC_IN[i]), .SEL1(X78), .SEL2(V154), .SEL3(T19), .CK(T70), .DOUT(LAYER_A_D1_OUT[i-8]));
        end
    endgenerate
    
    wire P109; //Logic Cell N4N
    assign #0.96 P109 = ~(LAYER_A_D1_OUT[7] & T15 & T11 & T7);

    wire P107; //Logic Cell N4N
    assign #0.96 P107 = ~(LAYER_A_D1_OUT[6] & T15 & T11 & P112);

    wire P105; //Logic Cell N4N
    assign #0.96 P105 = ~(LAYER_A_D1_OUT[5] & T15 & P114 & T7);

    wire P103; //Logic Cell N4N
    assign #0.96 P103 = ~(LAYER_A_D1_OUT[4] & T15 & P114 & P112);

    wire P79; //Logic Cell N4N
    assign #0.96 P79 = ~(LAYER_A_D1_OUT[3] & P78 & T11 & T7);

    wire P83; //Logic Cell N4N
    assign #0.96 P83 = ~(LAYER_A_D1_OUT[2] & P78 & T11 & P112);

    wire P81; //Logic Cell N4N
    assign #0.96 P81 = ~(LAYER_A_D1_OUT[1] & P78 & P114 & T7);

    wire P85; //Logic Cell N4N
    assign #0.96 P85 = ~(LAYER_A_D1_OUT[0] & P78 & P114 & P112);

    wire P97; //Logic Cell N8B
    assign #3.09 P97 = ~(P109 & P107 & P105 & P103 & P79 & P83 & P81 & P85); //DSA1



    // *** LAYER A D2: PAGE 6 Section ***
    wire P146; //Logic Cell V1N
    assign #0.55 P146 = ~ T7;
    wire P154; //Logic Cell V1N
    assign #0.55 P154 = ~ T15;
    wire P152; //Logic Cell V1N
    assign #0.55 P152 = ~ T11;

    //-- VC23-VC16_IN
    wire [7:0] LAYER_A_D2_OUT;
    generate
        for(i = 23; i >= 16; i = i - 1) begin: LAYER_A_D2_VCIN
            VC_IN_DLY  inst(.DIN(VC_IN[i]), .SEL1(X78), .SEL2(V154), .SEL3(T19), .CK(T70), .DOUT(LAYER_A_D2_OUT[i-16]));
        end
    endgenerate
    
    wire P119; //Logic Cell N4N
    assign #0.96 P119 = ~(LAYER_A_D2_OUT[7] & T15 & T11 & T7);

    wire P125; //Logic Cell N4N
    assign #0.96 P125 = ~(LAYER_A_D2_OUT[6] & T15 & T11 & P146);

    wire P123; //Logic Cell N4N
    assign #0.96 P123 = ~(LAYER_A_D2_OUT[5] & T15 & P152 & T7);

    wire P135; //Logic Cell N4N
    assign #0.96 P135 = ~(LAYER_A_D2_OUT[4] & T15 & P152 & P146);

    wire P121; //Logic Cell N4N
    assign #0.96 P121 = ~(LAYER_A_D2_OUT[3] & P154 & T11 & T7);

    wire P127; //Logic Cell N4N
    assign #0.96 P127 = ~(LAYER_A_D2_OUT[2] & P154 & T11 & P146);

    wire P143; //Logic Cell N4N
    assign #0.96 P143 = ~(LAYER_A_D2_OUT[1] & P154 & P152 & T7);

    wire P141; //Logic Cell N4N
    assign #0.96 P141 = ~(LAYER_A_D2_OUT[0] & P154 & P152 & P146);

    wire P129; //Logic Cell N8B
    assign #3.09 P129 = ~(P119 & P125 & P123 & P135 & P121 & P127 & P143 & P141); //DSA2



// *** LAYER A D3: PAGE 7 Section ***
    wire R152; //Logic Cell V1N
    assign #0.55 R152 = ~ T7;
    wire R114; //Logic Cell V1N
    assign #0.55 R114 = ~ T15;
    wire R154; //Logic Cell V1N
    assign #0.55 R154 = ~ T11;

    //-- VC23-VC16_IN
    wire [7:0] LAYER_A_D3_OUT;
    generate
        for(i = 31; i >= 24; i = i - 1) begin: LAYER_A_D3_VCIN
            VC_IN_DLY  inst(.DIN(VC_IN[i]), .SEL1(X78), .SEL2(V154), .SEL3(T19), .CK(T70), .DOUT(LAYER_A_D3_OUT[i-24]));
        end
    endgenerate
    
    wire R105; //Logic Cell N4N
    assign #0.96 R105 = ~(LAYER_A_D3_OUT[7] & T15 & T11 & T7);

    wire R132; //Logic Cell N4N
    assign #0.96 R132 = ~(LAYER_A_D3_OUT[6] & T15 & T11 & R152);

    wire R130; //Logic Cell N4N
    assign #0.96 R130 = ~(LAYER_A_D3_OUT[5] & T15 & R154 & T7);

    wire R134; //Logic Cell N4N
    assign #0.96 R134 = ~(LAYER_A_D3_OUT[4] & T15 & R154 & R152);

    wire R111; //Logic Cell N4N
    assign #0.96 R111 = ~(LAYER_A_D3_OUT[3] & R114 & T11 & T7);

    wire R128; //Logic Cell N4N
    assign #0.96 R128 = ~(LAYER_A_D3_OUT[2] & R114 & T11 & R152);

    wire R124; //Logic Cell N4N
    assign #0.96 R124 = ~(LAYER_A_D3_OUT[1] & R114 & R154 & T7);

    wire R126; //Logic Cell N4N
    assign #0.96 R126 = ~(LAYER_A_D3_OUT[0] & R114 & R154 & R152);

    wire R118; //Logic Cell N8B
    assign #3.09 R118 = ~(R105 & R132 & R130 & R134 & R111 & R128 & R124 & R126); //DSA3


// *** LAYER A MSBs: PAGE 8 Section ***
    //--COL
    wire [7:0] LAYER_A_MSBS_OUT;
    generate
        for(i = 7; i >= 0; i = i - 1) begin: LAYER_A_COL
            VC_IN_DLY  inst(.DIN(COL[i]), .SEL1(X78), .SEL2(V154), .SEL3(T19), .CK(T70), .DOUT(LAYER_A_MSBS_OUT[i]));
        end
    endgenerate

    //--DSA7-DSA4 output from latches, enabled by T61
    generate
        for(i = 7; i >= 4; i = i - 1) begin: LAYER_A_MSBS_LATCHES
            LT2_DLY inst(.D(LAYER_A_MSBS_OUT[i]), .Gn(T61), .Q(DSA[i])); //*** outputs DSA7-4 Layer A bits color index ***
        end
    endgenerate

    //DSAD-DSAA direct output from DFF clocked by T70
    assign DSA[11] = LAYER_A_MSBS_OUT[3]; //*** outputs DSAD Layer A bit color index ***
    assign DSA[10] = LAYER_A_MSBS_OUT[2]; //*** outputs DSAC Layer A bit color index ***
    assign DSA[9] = LAYER_A_MSBS_OUT[1]; //*** outputs DSAB Layer A bit color index ***
    assign DSA[8] = LAYER_A_MSBS_OUT[0]; //*** outputs DSAA Layer A bit color index ***
    


// *** LAYER B D0: PAGE 9 Section ***
    wire G88; //Logic Cell V1N
    assign #0.55 G88 = ~ L87;
    wire J107; //Logic Cell V1N
    assign #0.55 J107 = ~ L83;
    wire J117; //Logic Cell V1N
    assign #0.55 J117 = ~ L79;

//-- VC7-VC0_IN
    wire [7:0] LAYER_B_D0_OUT;
    generate
        for(i = 7; i >= 0; i = i - 1) begin: LAYER_B_D0_VCIN
            VC_IN2_DLY  inst(.DIN(VC_IN[i]), .SEL1(V154), .SEL2(L77), .CK(T70), .DOUT(LAYER_B_D0_OUT[i]));
        end
    endgenerate

    wire G91; //Logic Cell N4N
    assign #0.96 G91 = ~(LAYER_B_D0_OUT[7] & L79 & L83 & L87);

    wire G97; //Logic Cell N4N
    assign #0.96 G97 = ~(LAYER_B_D0_OUT[6] & L79 & L83 & G88);

    wire G103; //Logic Cell N4N
    assign #0.96 G103 = ~(LAYER_B_D0_OUT[5] & L79 & J107 & L87);

    wire G101; //Logic Cell N4N
    assign #0.96 G101 = ~(LAYER_B_D0_OUT[4] & L79 & J107 & G88);

    wire J102; //Logic Cell N4N
    assign #0.96 J102 = ~(LAYER_B_D0_OUT[3] & J117 & L83 & L87);

    wire J98; //Logic Cell N4N
    assign #0.96 J98 = ~(LAYER_B_D0_OUT[2] & J117 & L83 & G88);

    wire J104; //Logic Cell N4N
    assign #0.96 J104 = ~(LAYER_B_D0_OUT[1] & J117 & J107 & L87);

    wire J100; //Logic Cell N4N
    assign #0.96 J100 = ~(LAYER_B_D0_OUT[0] & J117 & J107 & G88);

    wire G107; //Logic Cell N8B
    assign #3.09 G107 = ~(G91 & G97 & G103 & G101 & J102 & J98 & J104 & J100); //DSB0


// *** LAYER B D1: PAGE 10 Section ***
    wire G90; //Logic Cell V1N
    assign #0.55 G90 = ~ L87;
    wire G151; //Logic Cell V1N
    assign #0.55 G151 = ~ L83;
    wire G153; //Logic Cell V1N
    assign #0.55 G153 = ~ L79;

//-- VC15-VC8_IN
    wire [7:0] LAYER_B_D1_OUT;
    generate
        for(i = 15; i >= 8; i = i - 1) begin: LAYER_B_D1_VCIN
            VC_IN2_DLY  inst(.DIN(VC_IN[i]), .SEL1(V154), .SEL2(L77), .CK(T70), .DOUT(LAYER_B_D1_OUT[i-8]));
        end
    endgenerate

    wire G129; //Logic Cell N4N
    assign #0.96 G129 = ~(LAYER_B_D1_OUT[7] & L79 & L83 & L87);

    wire G99; //Logic Cell N4N
    assign #0.96 G99 = ~(LAYER_B_D1_OUT[6] & L79 & L83 & G90);

    wire G133; //Logic Cell N4N
    assign #0.96 G133 = ~(LAYER_B_D1_OUT[5] & L79 & G151 & L87);

    wire G131; //Logic Cell N4N
    assign #0.96 G131 = ~(LAYER_B_D1_OUT[4] & L79 & G151 & G90);

    wire G105; //Logic Cell N4N
    assign #0.96 G105 = ~(LAYER_B_D1_OUT[3] & G153 & L83 & L87);

    wire G117; //Logic Cell N4N
    assign #0.96 G117 = ~(LAYER_B_D1_OUT[2] & G153 & L83 & G90);

    wire G127; //Logic Cell N4N
    assign #0.96 G127 = ~(LAYER_B_D1_OUT[1] & G153 & G151 & L87);

    wire G119; //Logic Cell N4N
    assign #0.96 G119 = ~(LAYER_B_D1_OUT[0] & G153 & G151 & G90);

    wire G121; //Logic Cell N8B
    assign #3.09 G121 = ~(G129 & G99 & G133 & G131 & G105 & G117 & G127 & G119); //DSB1


// *** LAYER B D2: PAGE 11 Section ***
    wire F151; //Logic Cell V1N
    assign #0.55 F151 = ~ L87;
    wire F153; //Logic Cell V1N
    assign #0.55 F153 = ~ L83;
    wire F109; //Logic Cell V1N
    assign #0.55 F109 = ~ L79;

//-- VC23-VC16_IN
    wire [7:0] LAYER_B_D2_OUT;
    generate
        for(i = 23; i >= 16; i = i - 1) begin: LAYER_B_D2_VCIN
            VC_IN2_DLY  inst(.DIN(VC_IN[i]), .SEL1(V154), .SEL2(L77), .CK(T70), .DOUT(LAYER_B_D2_OUT[i-16]));
        end
    endgenerate

    wire F129; //Logic Cell N4N
    assign #0.96 F129 = ~(LAYER_B_D2_OUT[7] & L79 & L83 & L87);

    wire F133; //Logic Cell N4N
    assign #0.96 F133 = ~(LAYER_B_D2_OUT[6] & L79 & L83 & F151);

    wire F131; //Logic Cell N4N
    assign #0.96 F131 = ~(LAYER_B_D2_OUT[5] & L79 & F153 & L87);

    wire F140; //Logic Cell N4N
    assign #0.96 F140 = ~(LAYER_B_D2_OUT[4] & L79 & F153 & F151);

    wire F110; //Logic Cell N4N
    assign #0.96 F110 = ~(LAYER_B_D2_OUT[3] & F109 & L83 & L87);

    wire F127; //Logic Cell N4N
    assign #0.96 F127 = ~(LAYER_B_D2_OUT[2] & F109 & L83 & F151);

    wire F123; //Logic Cell N4N
    assign #0.96 F123 = ~(LAYER_B_D2_OUT[1] & F109 & F153 & L87);

    wire F125; //Logic Cell N4N
    assign #0.96 F125 = ~(LAYER_B_D2_OUT[0] & F109 & F153 & F151);

    wire F117; //Logic Cell N8B
    assign #3.09 F117 = ~(F129 & F133 & F131 & F140 & F110 & F127 & F123 & F125); //DSB2


// *** LAYER B D3: PAGE 12 Section ***
    wire F80; //Logic Cell V1N
    assign #0.55 F80 = ~ L87;
    wire F105; //Logic Cell V1N
    assign #0.55 F105 = ~ L83;
    wire F78; //Logic Cell V1N
    assign #0.55 F78 = ~ L79;

//-- VC23-VC16_IN
    wire [7:0] LAYER_B_D3_OUT;
    generate
        for(i = 31; i >= 24; i = i - 1) begin: LAYER_B_D3_VCIN
            VC_IN2_DLY  inst(.DIN(VC_IN[i]), .SEL1(V154), .SEL2(L77), .CK(T70), .DOUT(LAYER_B_D3_OUT[i-24]));
        end
    endgenerate

    wire F106; //Logic Cell N4N
    assign #0.96 F106 = ~(LAYER_B_D3_OUT[7] & L79 & L83 & L87);

    wire F102; //Logic Cell N4N
    assign #0.96 F102 = ~(LAYER_B_D3_OUT[6] & L79 & L83 & F80);

    wire F100; //Logic Cell N4N
    assign #0.96 F100 = ~(LAYER_B_D3_OUT[5] & L79 & F105 & L87);

    wire F98; //Logic Cell N4N
    assign #0.96 F98 = ~(LAYER_B_D3_OUT[4] & L79 & F105 & F80);

    wire F81; //Logic Cell N4N
    assign #0.96 F81 = ~(LAYER_B_D3_OUT[3] & F78 & L83 & L87);

    wire F87; //Logic Cell N4N
    assign #0.96 F87 = ~(LAYER_B_D3_OUT[2] & F78 & L83 & F80);

    wire F85; //Logic Cell N4N
    assign #0.96 F85 = ~(LAYER_B_D3_OUT[1] & F78 & F105 & L87);

    wire F83; //Logic Cell N4N
    assign #0.96 F83 = ~(LAYER_B_D3_OUT[0] & F78 & F105 & F80);

    wire F92; //Logic Cell N8B
    assign #3.09 F92 = ~(F106 & F102 & F100 & F98 & F81 & F87 & F85 & F83); //DSB3


// *** LAYER B MSBs: PAGE 13 Section ***
    wire H15; //LOGIC CELL V1N
    assign #0.55 H15 = ~V154;

    wire H13; //LOGIC CELL V1N
    assign #0.55 H13 = ~H15;

    wire L120; //LOGIC CELL V1N
    assign #0.55 L120 = ~L77;

    wire K153; //LOGIC CELL V1N
    assign #0.55 K153 = ~L120;

    //--COL
    wire [7:0] LAYER_B_MSBS_OUT;
    generate
        for(i = 7; i >= 0; i = i - 1) begin: LAYER_B_COL
            VC_IN2_DLY  inst(.DIN(COL[i]), .SEL1(V154), .SEL2(L77), .CK(T70), .DOUT(LAYER_B_MSBS_OUT[i]));
        end
    endgenerate

    //--DSA7-DSA4 output from latches, enabled by T61
    generate
        for(i = 7; i >= 4; i = i - 1) begin: LAYER_B_MSBS_LATCHES
            LT2_DLY inst(.D(LAYER_B_MSBS_OUT[i]), .Gn(T61), .Q(DSB[i])); //*** outputs DSB7-4 Layer B bits color index ***
        end
    endgenerate

    //DSAD-DSAA direct output from DFF clocked by T70
    assign DSB[11] = LAYER_B_MSBS_OUT[3]; //*** outputs DSBD Layer B bit color index ***
    assign DSB[10] = LAYER_B_MSBS_OUT[2]; //*** outputs DSBC Layer B bit color index ***
    assign DSA[9] = LAYER_B_MSBS_OUT[1]; //*** outputs DSBB Layer B bit color index ***
    
    //DOES NOT APPEAR ON THE SCHEMATICS!!!
    assign DSA[8] = LAYER_B_MSBS_OUT[0]; //*** outputs DSBA Layer B bit color index *** 


// *** LAYER FIX D0: PAGE 14 Section ***
    wire W152; //Logic Cell V1N
    assign #0.55 W152 = ~ X102;
    wire W114; //Logic Cell V1N
    assign #0.55 W114 = ~ X112;
    wire W154; //Logic Cell V1N
    assign #0.55 W154 = ~ X108;

//-- VC7-VC0_IN
    wire [7:0] LAYER_FIX_D0_OUT;
    generate
        for(i = 7; i >= 0; i = i - 1) begin: LAYER_FIX_D0_VCIN
            VC_IN3_DLY  inst(.DIN(VC_IN[i]), .SEL1(X80), .CK(T70), .DOUT(LAYER_FIX_D0_OUT[i]));
        end
    endgenerate

    wire W105; //Logic Cell N4N
    assign #0.96 W105 = ~(LAYER_FIX_D0_OUT[7] & X108 & X112 & X102);

    wire W134; //Logic Cell N4N
    assign #0.96 W134 = ~(LAYER_FIX_D0_OUT[6] & X108 & X112 & W152);

    wire W111; //Logic Cell N4N
    assign #0.96 W111 = ~(LAYER_FIX_D0_OUT[5] & X108 & W114 & X102);

    wire W124; //Logic Cell N4N
    assign #0.96 W124 = ~(LAYER_FIX_D0_OUT[4] & X108 & W114 & W152);

    wire W128; //Logic Cell N4N
    assign #0.96 W128 = ~(LAYER_FIX_D0_OUT[3] & W154 & X112 & X102);

    wire W126; //Logic Cell N4N
    assign #0.96 W126 = ~(LAYER_FIX_D0_OUT[2] & W154 & X112 & W152);

    wire W130; //Logic Cell N4N
    assign #0.96 W130 = ~(LAYER_FIX_D0_OUT[1] & W154 & W114 & X102);

    wire W132; //Logic Cell N4N
    assign #0.96 W132 = ~(LAYER_FIX_D0_OUT[0] & W154 & W114 & W152);

    wire W118; //Logic Cell N8B
    assign #3.09 W118 = ~(W105 & W134 & W111 & W124 & W128 & W126 & W130 & W132); //DFI0


// *** LAYER FIX D1: PAGE 15 Section***
    wire V144; //Logic Cell V1N
    assign #0.55 V144 = ~ X102;
    wire V146; //Logic Cell V1N
    assign #0.55 V146 = ~ X112;
    wire V148; //Logic Cell V1N
    assign #0.55 V148 = ~ X108;

//-- VC15-VC8_IN
    wire [7:0] LAYER_FIX_D1_OUT;
    generate
        for(i = 15; i >= 8; i = i - 1) begin: LAYER_FIX_D1_VCIN
            VC_IN3_DLY  inst(.DIN(VC_IN[i]), .SEL1(X80), .CK(T70), .DOUT(LAYER_FIX_D1_OUT[i-8]));
        end
    endgenerate

    wire V116; //Logic Cell N4N
    assign #0.96 V116 = ~(LAYER_FIX_D1_OUT[7] & X108 & X112 & X102);

    wire V130; //Logic Cell N4N
    assign #0.96 V130 = ~(LAYER_FIX_D1_OUT[6] & X108 & X112 & V144);

    wire V120; //Logic Cell N4N
    assign #0.96 V120 = ~(LAYER_FIX_D1_OUT[5] & X108 & V146 & X102);

    wire V134; //Logic Cell N4N
    assign #0.96 V134 = ~(LAYER_FIX_D1_OUT[4] & X108 & V146 & V144);

    wire V118; //Logic Cell N4N
    assign #0.96 V118 = ~(LAYER_FIX_D1_OUT[3] & V148 & X112 & X102);

    wire V132; //Logic Cell N4N
    assign #0.96 V132 = ~(LAYER_FIX_D1_OUT[2] & V148 & X112 & V144);

    wire V122; //Logic Cell N4N
    assign #0.96 V122 = ~(LAYER_FIX_D1_OUT[1] & V148 & V146 & X102);

    wire V141; //Logic Cell N4N
    assign #0.96 V141 = ~(LAYER_FIX_D1_OUT[0] & V148 & V146 & V144);

    wire V124; //Logic Cell N8B
    assign #3.09 V124 = ~(V116 & V130 & V120 & V134 & V118 & V132 & V122 & V141); //DFI1


// *** LAYER FIX D2: PAGE 16 Section ***
    wire W108; //Logic Cell V1N
    assign #0.55 W108 = ~ X102;
    wire W104; //Logic Cell V1N
    assign #0.55 W104 = ~ X112;
    wire W110; //Logic Cell V1N
    assign #0.55 W110 = ~ X108;

//-- VC23-VC16_IN
    wire [7:0] LAYER_FIX_D2_OUT;
    generate
        for(i = 23; i >= 16; i = i - 1) begin: LAYER_FIX_D2_VCIN
            VC_IN3_DLY  inst(.DIN(VC_IN[i]), .SEL1(X80), .CK(T70), .DOUT(LAYER_FIX_D2_OUT[i-16]));
        end
    endgenerate

    wire W101; //Logic Cell N4N
    assign #0.96 W101 = ~(LAYER_FIX_D2_OUT[7] & X108 & X112 & X102);

    wire W93; //Logic Cell N4N
    assign #0.96 W93 = ~(LAYER_FIX_D2_OUT[6] & X108 & X112 & W108);

    wire W99; //Logic Cell N4N
    assign #0.96 W99 = ~(LAYER_FIX_D2_OUT[5] & X108 & W104 & X102);

    wire W91; //Logic Cell N4N
    assign #0.96 W91 = ~(LAYER_FIX_D2_OUT[4] & X108 & W104 & W108);

    wire W77; //Logic Cell N4N
    assign #0.96 W77 = ~(LAYER_FIX_D2_OUT[3] & W110 & X112 & X102);

    wire W83; //Logic Cell N4N
    assign #0.96 W83 = ~(LAYER_FIX_D2_OUT[2] & W110 & X112 & W108);

    wire W79; //Logic Cell N4N
    assign #0.96 W79 = ~(LAYER_FIX_D2_OUT[1] & W110 & W104 & X102);

    wire W81; //Logic Cell N4N
    assign #0.96 W81 = ~(LAYER_FIX_D2_OUT[0] & W110 & W104 & W108);

    wire W85; //Logic Cell N8B
    assign #3.09 W85 = ~(W101 & W93 & W99 & W91 & W77 & W83 & W79 & W81); //DFI2


// *** LAYER FIX D3: PAGE 17 Section ***
    wire T125; //Logic Cell V1N
    assign #0.55 T125 = ~ X102;
    wire T135; //Logic Cell V1N
    assign #0.55 T135 = ~ X112;
    wire T154; //Logic Cell V1N
    assign #0.55 T154 = ~ X108;

//-- VC31-VC24_IN
    wire [7:0] LAYER_FIX_D3_OUT;
    generate
        for(i = 31; i >= 24; i = i - 1) begin: LAYER_FIX_D3_VCIN
            VC_IN3_DLY  inst(.DIN(VC_IN[i]), .SEL1(X80), .CK(T70), .DOUT(LAYER_FIX_D3_OUT[i-24]));
        end
    endgenerate

    wire T128; //Logic Cell N4N
    assign #0.96 T128 = ~(LAYER_FIX_D3_OUT[7] & X108 & X112 & X102);

    wire T126; //Logic Cell N4N
    assign #0.96 T126 = ~(LAYER_FIX_D3_OUT[6] & X108 & X112 & T125);

    wire T132; //Logic Cell N4N
    assign #0.96 T132 = ~(LAYER_FIX_D3_OUT[5] & X108 & T135 & X102);

    wire T151; //Logic Cell N4N
    assign #0.96 T151 = ~(LAYER_FIX_D3_OUT[4] & X108 & T135 & T125);

    wire T130; //Logic Cell N4N
    assign #0.96 T130 = ~(LAYER_FIX_D3_OUT[3] & T154 & X112 & X102);

    wire T149; //Logic Cell N4N
    assign #0.96 T149 = ~(LAYER_FIX_D3_OUT[2] & T154 & X112 & T125);

    wire T147; //Logic Cell N4N
    assign #0.96 T147 = ~(LAYER_FIX_D3_OUT[1] & T154 & T135 & X102);

    wire T145; //Logic Cell N4N
    assign #0.96 T145 = ~(LAYER_FIX_D3_OUT[0] & T154 & T135 & T125);

    wire T139; //Logic Cell N8B
    assign #3.09 T139 = ~(T128 & T126 & T132 & T151 & T130 & T149 & T147 & T145); //DFI3

// *** LAYER FIX MSBs: PAGE 18 Section ***
    wire M60; //LOGIC CELL V1N
    assign #0.55 M60 = ~X80;

    wire M52; //LOGIC CELL V1N
    assign #0.55 M52 = ~M60;

   //--COL
    wire [3:0] LAYER_FIX_MSBS_OUT;
    generate
        for(i = 7; i >= 4; i = i - 1) begin: LAYER_FIX_COL
            VC_IN3_DLY  inst(.DIN(COL[i]), .SEL1(X80), .CK(T70), .DOUT(LAYER_FIX_MSBS_OUT[i-4]));
        end
    endgenerate

    //--DFI7-DFI4 output from latches, enabled by T61
    generate
        for(i = 7; i >= 4; i = i - 1) begin: LAYER_FIX_MSBS_LATCHES
            LT2_DLY inst(.D(LAYER_FIX_MSBS_OUT[i-4]), .Gn(T61), .Q(DFI[i])); //*** outputs DFI7-4 Layer FIX bits color index ***
        end
    endgenerate


// *** BIDIRECTIONAL I/O AND LSB OUTPUT LATCHES: PAGE 19 Section ***
    wire DB_DIR; //Logic Cell N2B
    wire VC7TO0_DIR, VC15TO8_DIR, VC23TO16_DIR, VC31TO24_DIR;//Logic Cell N4B
    wire Y10, Y15; //Logic Cell V1N

    assign  #0.55 Y10 = ~CRCS;
    assign  #0.55 Y15 = ~CRCS;

    wire DB0_IN_BUF; //, VC24_16_8_0_OUT;
    wire DB1_IN_BUF; //, VC25_17_9_1_OUT;
    // wire VC26_18_10_2_OUT;
    // wire VC27_19_11_3_OUT;
    // wire VC28_20_12_4_OUT;
    // wire VC29_21_13_5_OUT;
    // wire VC30_22_14_6_OUT;
    // wire VC31_23_15_7_OUT;
    wire [7:0] VC_BYTE_OUT;
    wire [7:0] DB_IN;

    assign #2.03 DB_DIR = ~(Y15 & RMRD);
    assign #2.03 VC7TO0_DIR = ~(ADDR0 & Y10 & NRD & RMRD);
    assign #2.03 VC15TO8_DIR = ~(ADDR1 & Y10 & NRD & RMRD);
    assign #2.03 VC23TO16_DIR = ~(ADDR2 & Y10 & NRD & RMRD);
    assign #2.03 VC31TO24_DIR = ~(ADDR3 & Y10 & NRD & RMRD);

    // V1N + V1N propagation delay: 1.10ns
    assign #1.10 DB0_IN_BUF = DB_IN[0];
    assign #1.10 DB1_IN_BUF = DB_IN[1];
    assign #1.10 VC_BYTE_OUT[0] = DB_IN[0];
    assign #1.10 VC_BYTE_OUT[1] = DB_IN[1];
    assign #1.10 VC_BYTE_OUT[2] = DB_IN[2];
    assign #1.10 VC_BYTE_OUT[3]= DB_IN[3];
    assign #1.10 VC_BYTE_OUT[4] = DB_IN[4];
    assign #1.10 VC_BYTE_OUT[5]= DB_IN[5];
    assign #1.10 VC_BYTE_OUT[6] = DB_IN[6];
    assign #1.10 VC_BYTE_OUT[7] = DB_IN[7];

    // IO tristate buffers
    //H6T Cell? -> DB_DIR active low: 
    //0 -> READ FROM 051962 (output data from DB_OUT)
    //1 -> WRITE TO 051962 (read data to DB_IN)

    //Port DB
    generate
        for(i=0; i < 8; i=i+1) begin: DB_IO_PORT
            //H6T_DLY inst(.IN(DB_IN[i]), .Cn(DB_DIR), .OT(DB_OUT[i]), .X(DB[i]));
            assign DB[i] = DB_DIR ? 1'bZ : DB_OUT[i];
            assign DB_IN[i] = DB[i];
        end
    endgenerate

    //End of port DB

    //Port VC
    generate
        for(i=31; i >= 24; i = i - 1) begin: VC_IO_PORT_BYTE3
            //H6T_DLY inst(.IN(VC_IN[i]), .Cn(VC31TO24_DIR), .OT(VC_BYTE_OUT[i-24]), .X(VC[i]));
            assign VC[i] = VC31TO24_DIR ? 1'bZ : VC_BYTE_OUT[i-24];
            assign VC_IN[i] = VC[i];
        end
    endgenerate

    generate
        for(i=23; i >= 16; i = i - 1) begin: VC_IO_PORT_BYTE2
            //H6T_DLY inst(.IN(VC_IN[i]), .Cn(VC23TO16_DIR), .OT(VC_BYTE_OUT[i-16]), .X(VC[i]));
            assign VC[i] = VC23TO16_DIR ? 1'bZ : VC_BYTE_OUT[i-16];
            assign VC_IN[i] = VC[i];
        end
    endgenerate

    generate
        for(i=15; i >= 8; i = i - 1) begin: VC_IO_PORT_BYTE1
            //H6T_DLY inst(.IN(VC_IN[i]), .Cn(VC15TO8_DIR), .OT(VC_BYTE_OUT[i-8]), .X(VC[i]));
            assign VC[i] = VC15TO8_DIR ? 1'bZ : VC_BYTE_OUT[i-8];
            assign VC_IN[i] = VC[i];
        end
    endgenerate

    generate
        for(i=7; i >= 0; i = i - 1) begin: VC_IO_PORT_BYTE0
            //H6T_DLY inst(.IN(VC_IN[i]), .Cn(VC7TO0_DIR), .OT(VC_BYTE_OUT[i]), .X(VC[i]));
            assign VC[i] = VC7TO0_DIR ? 1'bZ : VC_BYTE_OUT[i];
            assign VC_IN[i] = VC[i];
        end
    endgenerate
    //End of port VC

    //TILE LAYERS COLOR INDEX LSB OUTPUT LATCHES

    LT2_DLY s138(.D(R118), .Gn(T61), .Q(DSA[3])); //*** outputs DSA3 Layer A bit color index ***
    LT2_DLY r147(.D(P129), .Gn(T61), .Q(DSA[2])); //*** outputs DSA2 Layer A bit color index ***
    LT2_DLY r143(.D(P97), .Gn(T61), .Q(DSA[1])); //*** outputs DSA1 Layer A bit color index ***
    LT2_DLY p147(.D(R87), .Gn(T61), .Q(DSA[0])); //*** outputs DSA0 Layer A bit color index ***
    wire R140; //Logic Cell R4P
    assign #4.52 R140 = R118 | P129 | P97 | R87;
    assign NSAC = R140; //*** outputs NFAC ***

    LT2_DLY f146(.D(F92), .Gn(T61), .Q(DSB[3])); //*** outputs DSB3 Layer B bit color index ***
    LT2_DLY f142(.D(F117), .Gn(T61), .Q(DSB[2])); //*** outputs DSB2 Layer B bit color index ***
    LT2_DLY g146(.D(G121), .Gn(T61), .Q(DSB[1])); //*** outputs DSB1 Layer B bit color index ***
    LT2_DLY g142(.D(G107), .Gn(T61), .Q(DSB[0])); //*** outputs DSB0 Layer B bit color index ***
    wire G139; //Logic Cell R4P
    assign #4.52 G139 = F92 | F117 | G121 | G107;
    assign NSBC = G139; //*** outputs NFBC ***

    LT2_DLY v149(.D(T139), .Gn(T61), .Q(DFI[3])); //*** outputs DFI3 Layer FIX bit color index ***
    LT2_DLY w147(.D(W85), .Gn(T61), .Q(DFI[2])); //*** outputs DFI2 Layer FIX bit color index ***
    LT2_DLY w143(.D(V124), .Gn(T61), .Q(DFI[1])); //*** outputs DFI1 Layer FIX bit color index ***
    LT2_DLY x141(.D(W118), .Gn(T61), .Q(DFI[0])); //*** outputs DFI0 Layer FIX bit color index ***
    wire W140; //Logic Cell R4P
    assign #4.52 W140 = T139 | W85 | V124 | W118;
    assign NFIC = W140; //*** outputs NFIC ***
endmodule