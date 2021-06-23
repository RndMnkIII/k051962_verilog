`default_nettype none
`timescale 1ns/1ps
//Test Bench Usage:
//iverilog -o CRAM_tb.vvp CRAM_tb.v cram_e15.v cram_e14.v
//vvp CRAM_tb.vvp -lxt2
//gtkwave CRAM_tb.lxt&

module CRAM_tb;

    //Test input signals
    //reg a, b, c
    reg [8:0] ADDR; //512Kx32bit ROM address space 0X0-0X7FFFF
    reg CEn, OE1n, WE1n, OE2n, WE2n;
    reg [7:0] write_data;

    //Test output signals
    wire [7:0] data_e15;
    wire [7:0] data_e14;
    wire [7:0] read_data_e15;
    wire [7:0] read_data_e14;
    

    assign data_e15 = (!WE1n && OE1n && !CEn) ? write_data : {8{1'bz}};
    CRAM_E15 uut(.ADDR(ADDR), .CEn(CEn), .OEn(OE1n), .WEn(WE1n), .DATA(data_e15));

    assign data_e14 = (!WE2n && OE2n && !CEn) ? write_data : {8{1'bz}};
    CRAM_E14 uut2(.ADDR(ADDR), .CEn(CEn), .OEn(OE2n), .WEn(WE2n), .DATA(data_e14));

    initial
        begin
            $dumpfile("CRAM_tb.lxt");
            $dumpvars(0,CRAM_tb);
        end
    
    initial 
        begin
            //Read from E15
            ADDR = 9'h002; CEn=0; OE1n=0; WE1n=1; OE2n=1; WE2n=1;
            #45;

            //Read from E14
            ADDR = 9'h002; CEn=0; OE1n=1; WE1n=1; OE2n=0; WE2n=1;
            #45;

            //Read from E15,E14
            ADDR = 9'h002; CEn=0; OE1n=0; WE1n=1; OE2n=0; WE2n=1;
            #45;

            //Write to E15
            write_data = 8'hAA; 
            ADDR = 9'h002; CEn=0; OE1n=1; OE2n=1; WE2n=1;
            #5
            WE1n=0;
            #10;
            WE1n=1;
            #30;

            //Read from E15
            ADDR = 9'h002; CEn=0; OE1n=0; WE1n=1; OE2n=1; WE2n=1;
            #45;

            $finish;
        end
endmodule