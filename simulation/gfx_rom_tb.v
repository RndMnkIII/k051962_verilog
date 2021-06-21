`default_nettype none
`timescale 1ns/1ps
//Test Bench Usage:
//iverilog -o gfx_rom_tb.vvp gfx_rom_tb.v gfx_rom.v
//vvp gfx_rom_tb.vvp -lxt2
//gtkwave gfx_rom_tb.lxt&

module gfx_rom_tb;

    //Test input signals
    //reg a, b, c
    reg [18:0] ADDR; //512Kx32bit ROM address space 0X0-0X7FFFF
    reg CEn;

    //Test output signals
    wire [31:0] DATA;
    wire H18, H18n;

    //Switch between lower and upper GFX bank ROMs.
    assign H18= ADDR[18]; //Lower half
    assign H18n= ~ADDR[18]; //Upper half

    //*** Lower Half GFX ***
    GFX_ROM_K19 GFX_LW_1(.ADDR(ADDR[17:0]), .CEn(CEn), .OEn(H18), .DATA(DATA[31:16]));
    GFX_ROM_K13 GFX_LW_0(.ADDR(ADDR[17:0]), .CEn(CEn), .OEn(H18), .DATA(DATA[15:0]));

    //*** Upper Half GFX ***
    GFX_ROM_J19 GFX_UP_1(.ADDR(ADDR[16:0]), .CEn(CEn), .OEn(H18n), .DATA(DATA[31:16]));
    GFX_ROM_J13 GFX_UP_0(.ADDR(ADDR[16:0]), .CEn(CEn), .OEn(H18n), .DATA(DATA[15:0]));

    initial
    begin
        $dumpfile("gfx_rom_tb.lxt");
        $dumpvars(0,gfx_rom_tb);
    end
        initial 
        begin
            ADDR = 19'h00000; CEn=0; //19'b0_00_0000_0000_0000_0000
            #100;
            ADDR = 19'h00001; CEn=0;
            #333.34; 
            ADDR = 19'h00002; CEn=0;
            #333.34; 
            ADDR = 19'h00003; CEn=0;
            #333.34; 
            ADDR = 19'h00004; CEn=0;
            #333.34; 
            ADDR = 19'h4001C; CEn=0;
            #333.34; 
            ADDR = 19'h4001D; CEn=0;
            #333.34;
            ADDR = 19'h4001E; CEn=0;
            #333.34;
            ADDR = 19'h4001F; CEn=0;
            #333.34;
            $finish;
        end
endmodule