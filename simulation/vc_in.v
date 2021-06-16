/****************************************************************
 * Support modules for use with generate blocks repetitive      *
 * hardware patterns.                                           *
 * @Furrtek schematics on 051962 die:                           *
 * https://github.com/furrtek/VGChips/tree/master/Konami/051962 *
 * Author: @RndMnkIII                                           *
 * Repository: https://github.com/RndMnkIII/k051962_verilog     *
 * Version: 1.0 16/06/2021                                      *
 ***************************************************************/

 module VC_IN_DLY ( input DIN,
                 input SEL1,
                 input SEL2,
                 input SEL3,
                 input CK,
                 output DOUT);

    //Stage 1
    wire V1N_ST1A; //Logic Cell V1N
    assign #0.55 V1N_ST1A = ~ SEL1;
    wire V1N_ST1B; //Logic Cell V1N
    assign #0.55 V1N_ST1B = ~ V1N_ST1A;

    wire D24ST1_X;
    D24_DLY d24st1(.A1(FDMST1_Qn), .A2(V1N_ST1B), .B1(DIN), .B2(V1N_ST1A), .X(D24ST1_X));
    wire FDMST1_Qn;
    FDM_DLY fdmst1 (.D(D24ST1_X), .CK(CK), .Qn(FDMST1_Qn));

    //Stage 2
    wire V1N_ST2A; //Logic Cell V1N
    assign #0.55 V1N_ST2A = ~ SEL2;
    wire V1N_ST2B; //Logic Cell V1N
    assign #0.55 V1N_ST2B = ~ V1N_ST2A;

    wire D24ST2_X;
    D24_DLY d24st2(.A1(FDMST2_Qn), .A2(V1N_ST2B), .B1(FDMST1_Qn), .B2(V1N_ST2A), .X(D24ST2_X));
    wire FDMST2_Qn;
    FDM_DLY fdmst2(.D(D24ST2_X), .CK(CK), .Qn(FDMST2_Qn));

    //Stage 3
    wire V1N_ST3A; //Logic Cell V1N
    assign #0.55 V1N_ST3A = ~ SEL3;
    wire V1N_ST3B; //Logic Cell V1N
    assign #0.55 V1N_ST3B = ~ V1N_ST3A;

    wire D24ST3_X;
    D24_DLY d24st3(.A1(FDMST3_Qn), .A2(V1N_ST3B), .B1(FDMST2_Qn), .B2(V1N_ST3A), .X(D24ST3_X));
    wire FDMST3_Qn;
    FDM_DLY fdmst3(.D(D24ST3_X), .CK(CK), .Qn(FDMST3_Qn));

    assign DOUT = FDMST3_Qn;
endmodule

module VC_IN2_DLY ( input DIN,
                 input SEL1,
                 input SEL2,
                 input CK,
                 output DOUT);

    //Stage 1
    wire V1N_ST1A; //Logic Cell V1N
    assign #0.55 V1N_ST1A = ~ SEL1;
    wire V1N_ST1B; //Logic Cell V1N
    assign #0.55 V1N_ST1B = ~ V1N_ST1A;

    wire D24ST1_X;
    D24_DLY d24st1(.A1(FDMST1_Qn), .A2(V1N_ST1B), .B1(DIN), .B2(V1N_ST1A), .X(D24ST1_X));
    wire FDMST1_Qn;
    FDM_DLY fdmst1 (.D(D24ST1_X), .CK(CK), .Qn(FDMST1_Qn));

    //Stage 2
    wire V1N_ST2A; //Logic Cell V1N
    assign #0.55 V1N_ST2A = ~ SEL2;
    wire V1N_ST2B; //Logic Cell V1N
    assign #0.55 V1N_ST2B = ~ V1N_ST2A;

    wire D24ST2_X;
    D24_DLY d24st2(.A1(FDMST2_Qn), .A2(V1N_ST2B), .B1(FDMST1_Qn), .B2(V1N_ST2A), .X(D24ST2_X));
    wire FDMST2_Qn;
    FDM_DLY fdmst2(.D(D24ST2_X), .CK(CK), .Qn(FDMST2_Qn));
    assign DOUT = FDMST2_Qn;
endmodule

module VC_IN3_DLY ( input DIN,
                 input SEL1,
                 input CK,
                 output DOUT);

    //Stage 1
    wire V1N_ST1A; //Logic Cell V1N
    assign #0.55 V1N_ST1A = ~ SEL1;
    wire V1N_ST1B; //Logic Cell V1N
    assign #0.55 V1N_ST1B = ~ V1N_ST1A;

    wire D24ST1_X;
    D24_DLY d24st1(.A1(FDMST1_Qn), .A2(V1N_ST1B), .B1(DIN), .B2(V1N_ST1A), .X(D24ST1_X));
    wire FDMST1_Qn;
    FDM_DLY fdmst1 (.D(D24ST1_X), .CK(CK), .Qn(FDMST1_Qn));
    assign DOUT = FDMST1_Qn;
endmodule