`default_nettype none
`timescale 1ns/10ps
//*********************************************************************
//***                     IMPORTANT!!!                              ***
//*** You need to byte swap the ROM GFX files because the hardware  ***
//*** uses Big Endian byte ordering.                                ***
//*** These files will not included in the project repository, the  ***
//*** user is responsible for creating said files by following the  ***
//*** instructions provided below:                                  ***
//*********************************************************************

//How to create the VMEM verilog hex data files:
//Install the srecord tools (i.e. brew install srecord)
//In this example I've used the Konami Aliens (Romset 3) GFX ROMS that 
//you can dump from your pcb board or search on the web a replacement 
//file copy if you own your original ROMs.
//Use the srec_cat util to convert from binary to verilog VMEM format
//srec_cat 875b11.k13 -binary -byte-swap -o 875b07_k13.hex -VMem 16
//srec_cat 875b12.k19 -binary -byte-swap -o 875b07_k19.hex -VMem 16
//srec_cat 875b07.j13 -binary -byte-swap -o 875b07_j13.hex -VMem 16
//srec_cat 875b08.j19 -binary -byte-swap -o 875b07_j19.hex -VMem 16

//K13, K19 Lower Region H18=0 256Kx16bit each
//J13, J19 Higher Region H18=1 128Kx16bit each

module GFX_ROM_K13(
    input wire [17:0] ADDR, //256Kx16bit
    input wire CEn,
    input wire OEn,
    output wire [15:0] DATA);

    localparam ADDR_WIDTH = 18;

    reg [15:0] romdata [0:(2**ADDR_WIDTH)]; //256Kx16bit
    wire [15:0] d0;
    
    initial begin
        $readmemh("875b11_k13.hex", romdata);
    end

    //MODEL Address Access Time of 70ns
    assign #70 DATA = (~CEn) ? ( (~OEn) ? romdata[ADDR] : 16'hZZZZ) : 16'hZZZZ;
    // specify
    //     if(d0 === 16'hZZZZ) (d0 => DATA) = 70;
    //     if(d0 !== 16'hZZZZ) (d0 => DATA) = 150;
    // endspecify
endmodule

module GFX_ROM_K19(
    input wire [17:0] ADDR, //256Kx16bit
    input wire CEn,
    input wire OEn,
    output wire [15:0] DATA);

    localparam ADDR_WIDTH = 18;

    reg [15:0] romdata [0:(2**ADDR_WIDTH)]; //256Kx16bit
    wire [15:0] d0;
    
    initial begin
        $readmemh("875b12_k19.hex", romdata);
    end

    //MODEL Address Access Time of 70ns
    assign #70 DATA = (~CEn) ? ( (~OEn) ? romdata[ADDR] : 16'hZZZZ) : 16'hZZZZ;
    // specify
    //     if(d0 === 16'hZZZZ) (d0 => DATA) = 70;
    //     if(d0 !== 16'hZZZZ) (d0 => DATA) = 150;
    // endspecify
endmodule

module GFX_ROM_J13(
    input wire [16:0] ADDR, //128Kx16bit
    input wire CEn,
    input wire OEn,
    output wire [15:0] DATA);

    localparam ADDR_WIDTH = 17;

    reg [15:0] romdata [0:(2**ADDR_WIDTH)]; //128Kx16bit
    wire [15:0] d0;
    
    initial begin
        $readmemh("875b07_j13.hex", romdata);
    end

    //MODEL Address Access Time of 70ns
    assign #70 DATA = (~CEn) ? ( (~OEn) ? romdata[ADDR] : 16'hZZZZ) : 16'hZZZZ;
    // specify
    //     if(d0 === 16'hZZZZ) (d0 => DATA) = 70;
    //     if(d0 !== 16'hZZZZ) (d0 => DATA) = 150;
    // endspecify
endmodule

module GFX_ROM_J19(
    input wire [16:0] ADDR, //128Kx16bit
    input wire CEn,
    input wire OEn,
    output wire [15:0] DATA);

    localparam ADDR_WIDTH = 17;

    reg [15:0] romdata [0:(2**ADDR_WIDTH)]; //128Kx16bit
    wire [15:0] d0;
    
    initial begin
        $readmemh("875b08_j19.hex", romdata);
    end

    //MODEL Address Access Time of 70ns
    assign #70 DATA = (~CEn) ? ( (~OEn) ? romdata[ADDR] : 16'hZZZZ) : 16'hZZZZ;
    // specify
    //     if(d0 === 16'hZZZZ) (d0 => DATA) = 70;
    //     if(d0 !== 16'hZZZZ) (d0 => DATA) = 150;
    // endspecify
endmodule