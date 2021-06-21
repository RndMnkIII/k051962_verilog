`default_nettype none
`timescale 1ns/1ps
//Test Bench Usage:
//iverilog -o gfx_rom_tb.vvp gfx_rom_tb.v gfx_rom.v
//vvp gfx_rom_tb.vvp -lxt2
//gtkwave gfx_rom_tb.lxt&

module gfx_rom_tb;

    //Test input signals
    //reg a, b, c
    reg [17:0] ADDR;
    reg OEn, CEn;


    //Test output signals
    wire [31:0] DATA;


    GFX_ROM_K19 UUT(.ADDR(ADDR), .CEn(CEn), .OEn(OEn), .DATA(DATA[31:16]));
    GFX_ROM_K13 UUT2(.ADDR(ADDR), .CEn(CEn), .OEn(OEn), .DATA(DATA[15:0]));
    

    initial
    begin
        $dumpfile("gfx_rom_tb.lxt");
        $dumpvars(0,gfx_rom_tb);
    end
        initial 
        begin
            ADDR = 18'h00000; CEn=0; OEn=1;
            #100;
            ADDR = 18'h00001; CEn=0; OEn=0;
            #333.34; 
            ADDR = 18'h00002; CEn=0; OEn=0;
            #333.34; 
            ADDR = 18'h00003; CEn=0; OEn=0;
            #333.34; 
            ADDR = 18'h00004; CEn=0; OEn=0;
            #333.34; 
            ADDR = 18'h00005; CEn=0; OEn=0;
            #333.34; 
            ADDR = 18'h00006; CEn=0; OEn=0;
            #333.34;
            ADDR = 18'h00007; CEn=0; OEn=0;
            #333.34;
            ADDR = 18'h00008; CEn=0; OEn=0;
            #333.34;
            $finish;
        end
endmodule