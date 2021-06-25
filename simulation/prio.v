`default_nettype none
`timescale 1ns/10ps
//Priority PROM AM27S21A:
//     ----\_/----
//  A6 | 1     16 | VCC
//     |          |
//  A5 | 2     15 | A7
//     |          |
//  A4 | 3     14 | EN2n
//     |          |
//  A3 | 4     13 | EN1n
//     |          |
//  A0 | 5     12 | Q0
//     |          |
//  A1 | 6     11 | Q1 
//     |          |
//  A2 | 7     10 | Q2
//     |          | 
// GND | 8      9 | Q3
//     -----------
//Sets the drawing order of sprites over the tile layers.
//INPUT ADDRESSES:
// A7: 1'b0
// A6: OBP0
// A5: OBP1
// A4: OBP2
// A3: NFIX
// A2: NOBJ
// A1: NVB
// A0: NVA

module PRIO(
    input wire [7:0] ADDR, //256Bx4bit
    input wire EN1n,
    input wire EN2n,
    output wire Q0, Q1, Q2, Q3);

    localparam ADDR_WIDTH = 8;

    reg [3:0] priodata [0:(2**ADDR_WIDTH)]; //256Bx4bit
    wire [3:0] d0;
    
    initial begin
        $readmemh("prio.hex", priodata);
    end

    //MODEL Address Access Time of 30ns
    assign #30 d0 = (!EN1n && !EN2n) ? priodata[ADDR] : 4'hZ;
    assign Q0 = d0[0];
    assign Q1 = d0[1];
    assign Q2 = d0[2];
    assign Q3 = d0[3];
endmodule