`default_nettype none
`timescale 1ns/10ps
//How to create the VMEM verilog hex data files:
//Install the srecord tools (i.e. brew install srecord)
//Use the srec_cat util to convert from binary to verilog VMEM format
//srec_cat 875b07.j13 -binary -byte-swap -o 875b07_j13.hex -VMem 16
//srec_cat 875b08.j19 -binary -byte-swap -o 875b07_j19.hex -VMem 16
//srec_cat 875b11.k13 -binary -byte-swap -o 875b07_k13.hex -VMem 16
//srec_cat 875b12.k19 -binary -byte-swap -o 875b07_k19.hex -VMem 16

module GFX_ROM_K13(
    input wire [17:0] ADDR,
    input wire CEn,
    input wire OEn,
    output wire [15:0] DATA);

    reg [15:0] romdata [0:262143]; //256Kx16bit
    wire [15:0] d0;
    
    initial begin
        $readmemh("875b11_k13.hex", romdata);
    end

    //MODEL Address Access Time of 150ns
    assign #70 DATA = (~CEn) ? ( (~OEn) ? romdata[ADDR] : 16'hZZZZ) : 16'hZZZZ;
    // specify
    //     if(d0 === 16'hZZZZ) (d0 => DATA) = 70;
    //     if(d0 !== 16'hZZZZ) (d0 => DATA) = 150;
    // endspecify
endmodule

module GFX_ROM_K19(
    input wire [17:0] ADDR,
    input wire CEn,
    input wire OEn,
    output wire [15:0] DATA);

    reg [15:0] romdata [0:262143]; //256Kx16bit
    wire [15:0] d0;
    
    initial begin
        $readmemh("875b12_k19.hex", romdata);
    end

    //MODEL Address Access Time of 150ns
    assign #70 DATA = (~CEn) ? ( (~OEn) ? romdata[ADDR] : 16'hZZZZ) : 16'hZZZZ;
    // specify
    //     if(d0 === 16'hZZZZ) (d0 => DATA) = 70;
    //     if(d0 !== 16'hZZZZ) (d0 => DATA) = 150;
    // endspecify
endmodule