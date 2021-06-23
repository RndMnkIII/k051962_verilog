`default_nettype none
`timescale 1ns/1ps

//Propagation delay 8ns
//OE to logic 25ns
//Output Disable to logic 15ns

module ttl_74245( inout A,
                  inout B,
                  input DIR,
                  input OEn);

    wire ena_AtoB;
    wire ena_BtoA;

    assign ena_AtoB = DIR & !OEn;
    assign ena_BtoA = !DIR & !OEn;

    assign #8 A =(ena_AtoB) ? B : 8'bz;
    assign #8 B =(ena_BtoA) ? A : 8'bz;
endmodule