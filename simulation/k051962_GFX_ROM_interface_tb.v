/****************************************************************
 * Test bench for the051962 Tilemap generator module based on   *
 * @Furrtek schematics on 051962 die:                           *
 * https://github.com/furrtek/VGChips/tree/master/Konami/051962 *
 * Author: @RndMnkIII                                           *
 * Repository: https://github.com/RndMnkIII/k051962_verilog     *
 * Version: 1.0 16/06/2021 Preliminar                           *
 ***************************************************************/
//Test Bench Usage:
//iverilog -o k051962_GFX_ROM_interface_tb.vvp k051962_GFX_ROM_interface_tb.v gfx_rom.v k051962.v vc_in.v fujitsu_AV_UnitCellLibrary_DLY.v
//vvp k051962_GFX_ROM_interface_tb.vvp -lxt2
//gtkwave k051962_GFX_ROM_interface_tb.lxt&

`default_nettype none
`timescale 1ns/1ps

module k051962_GFX_ROM_interface_tb;
    //Parameters for master clock
    localparam mc_freq = 24000000;
    localparam mc_p =  (1.0 / mc_freq) * 1000000000;
    localparam mc_hp = mc_p / 2;
    localparam mc_qp = mc_p / 4;
    //localparam SIMULATION_TIME = 140000000; //ns

    //TEST INPUT SIGNALS

    //*** GFX TiLe ROMs signals ***
    reg [18:0] ADDR; //512Kx32bit ROM address space 0X0-0X7FFFF
    reg CEn;

    //*** System signals ***
    reg RES;
    reg [1:0] AB;
    reg NRD;
    
    //*** k051962 interface signals ***
    reg [7:0] COL;
    reg ZB4H, ZB2H, ZB1H;
    reg ZA4H, ZA2H, ZA1H;
    reg BEN;
    reg CRCS;
    reg RMRD;
    reg TEST;

    //TEST OUTPUT SIGNALS
    //*** GFX TiLe ROMs signals ***
    wire [31:0] DATA;
    wire H18, H18n;

    //*** k051962 interface signals ***
    wire [7:0] DB; //bidirectional signal
    wire [31:0] VC; //bidirectional signal
    wire [7:0] input_byte;
    reg [7:0] output_byte;
    
    wire [31:0] input_dword;
    reg [31:0] output_dword;

    assign input_byte = DB;
    assign DB = (~CRCS & RMRD) ? output_byte : 8'hZZ;

    //assign input_dword = VC;
    //assign VC = (NRD & RMRD) ? output_dword : 32'hZZZZZZZZ; //when Z VC acts as INPUT, in the other case as OUPUT

    wire RST; //Delayed RES signal
    wire NSBC;
    wire [11:0] DSB;
    wire NSAC;
    wire [11:0] DSA;
    wire NFIC;
    wire [7:0] DFI;
    wire NVBK, NHBK, OHBK, NVSY, NHSY, NCSY;
    wire P1H, M6, M12;

    //*** GFX ROM to K051962 data interface ***//
    //Switch between lower and upper GFX bank ROMs.
    assign H18= ADDR[18]; //Lower half
    assign H18n= ~ADDR[18]; //Upper half
    assign VC = DATA; //ROM data to k051962

    wire [3:0] pix_data0, pix_data1, pix_data2, pix_data3, pix_data4, pix_data5, pix_data6, pix_data7;
    assign pix_data0 = { DATA[24], DATA[16], DATA[8], DATA[0]};
    assign pix_data1 = { DATA[25], DATA[17], DATA[9], DATA[1]};
    assign pix_data2 = { DATA[26], DATA[18], DATA[10], DATA[2]};
    assign pix_data3 = { DATA[27], DATA[19], DATA[11], DATA[3]};
    assign pix_data4 = { DATA[28], DATA[20], DATA[12], DATA[4]};
    assign pix_data5 = { DATA[29], DATA[21], DATA[13], DATA[5]};
    assign pix_data6 = { DATA[30], DATA[22], DATA[14], DATA[6]};
    assign pix_data7 = { DATA[31], DATA[23], DATA[15], DATA[7]};

    //*** Lower Half GFX ***
    GFX_ROM_K19 GFX_LW_1(.ADDR(ADDR[17:0]), .CEn(CEn), .OEn(H18), .DATA(DATA[31:16]));
    GFX_ROM_K13 GFX_LW_0(.ADDR(ADDR[17:0]), .CEn(CEn), .OEn(H18), .DATA(DATA[15:0]));

    //*** Upper Half GFX ***
    GFX_ROM_J19 GFX_UP_1(.ADDR(ADDR[16:0]), .CEn(CEn), .OEn(H18n), .DATA(DATA[31:16]));
    GFX_ROM_J13 GFX_UP_0(.ADDR(ADDR[16:0]), .CEn(CEn), .OEn(H18n), .DATA(DATA[15:0]));

    //*** K051962 Core ***
    k051962_DLY UUT(
    .M24(clk24),
    .RES(RES),
    .RST(RST), //Delayed RES signal
    .AB(AB),
    .NRD(NRD),
    .DB(DB),
    .VC(VC),
    .COL(COL),
    .ZB4H(ZB4H), .ZB2H(ZB2H), .ZB1H(ZB1H),
    .ZA4H(ZA4H), .ZA2H(ZA2H), .ZA1H(ZA1H),
    .BEN(BEN),
    .CRCS(CRCS),
    .RMRD(RMRD),
    .NSBC(NSBC),
    .DSB(DSB),
    .NSAC(NSAC),
    .DSA(DSA),
    .NFIC(NFIC),
    .DFI(DFI),
    .NVBK(NVBK), .NHBK(NHBK), .OHBK(OHBK), .NVSY(NVSY), .NHSY(NHSY), .NCSY(NCSY),
    .P1H(P1H), .M6(M6), .M12(M12),
    .TEST(TEST),
    .DBG(DBG));

    //Debugging section
    //DBG output signals for K051962_SCROLLING module
    wire [63:0] DBG;
    wire DBG_BB7, DBG_T70, DBG_BB105_QD, DBG_CC58;
    assign DBG_BB7 = DBG[0];
    assign DBG_T70 = DBG[1];
    assign DBG_BB105_QD = DBG[2];
    assign DBG_CC58 = DBG[3];
    //End of debugging section

    initial
    begin
        $display("---------------------------------");
        $display("Master Clock Settings:");
        $display("Freq: %f Hz Period: %f ns", mc_freq, mc_p);
        $display("---------------------------------");
        $dumpfile("k051962_GFX_ROM_interface_tb.lxt");
        $dumpvars(0,k051962_GFX_ROM_interface_tb);
    end

    //24MHz master clock
    reg clk24 = 0;
    always #mc_hp clk24 = !clk24;

    //Testing timing signals
     initial 
        begin
            RES=1'b0; AB=2'h0;
            NRD=1'b0; CRCS=1'b1; RMRD=1'b0;
            COL=8'h00; ZB4H=1'b0; ZB2H=1'b0; ZB1H=1'b0; ZA4H=1'b0; ZA2H=1'b0; ZA1H=1'b0;
            BEN=1'b0; TEST=1'b0;
            
            #mc_p; #mc_p; #mc_p; #mc_qp;
            RES=1'b1;

            #mc_qp;
            #mc_p; #mc_p; #mc_p; #mc_p; //#mc_p; #mc_p; #mc_p; #mc_p;

            #10.416; //sync address change with 10.416ns after rising edge of clk24. 
            ADDR = 19'h00000; CEn=0; //19'b0_00_0000_0000_0000_0000
            #333.334; 
            ADDR = 19'h00001; CEn=0;
            #333.334; 
            ADDR = 19'h00002; CEn=0;
            #333.334; 
            ADDR = 19'h00003; CEn=0;
            #333.334; 
            ADDR = 19'h00004; CEn=0;
            #333.334; 
            ADDR = 19'h4001C; CEn=0;
            #333.334; 
            ADDR = 19'h4001D; CEn=0;
            #333.334;
            ADDR = 19'h4001E; CEn=0;
            #333.334;
            ADDR = 19'h4001F; CEn=0;
            #333.334;
            ADDR = 19'h00020; CEn=0;

            repeat (1000) begin
                #333.334;
                ADDR = ADDR + 19'h00001;
            end

            $finish;
        end
endmodule
