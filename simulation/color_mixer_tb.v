`default_nettype none
`timescale 1ns/1ps
//Test Bench Usage:
//iverilog -o color_mixer_tb.vvp color_mixer_tb.v color_mixer.v prio.v ttl_ic.v cram_e14.v cram_e15.v
//vvp color_mixer_tb.vvp -lxt2
//gtkwave color_mixer_tb.lxt&

module color_mixer_tb;
    //Parameters for master clock
    localparam mc_freq = 6000000;
    localparam mc_p =  (1.0 / mc_freq) * 1000000000;
    localparam mc_hp = mc_p / 2;
    localparam mc_qp = mc_p / 4;
    localparam SIMULATION_TIME = 140000000; //ns

    localparam IMG_SIZE = 288 * 224; //18 * 14 16X16 BLOCKS

    //output file 
    integer fd;
    integer res;
    integer i, j, k; //loop counters
    integer colval;
    integer rowval;
    reg [17:0] cnt;

    //Test input signals
    reg [5:0] FI;
    reg [9:0] ADDR; //512Kx32bit ROM address space 0X0-0X7FFFF
    reg CRAMCS;
    reg NRD;
    reg [7:0] write_data;

    //Test output signals
    wire [7:0] DATA;
    wire [15:0] RAW_1BGR;
    wire [23:0] RAW_RGB;
    wire [4:0] B;
    wire [4:0] G;
    wire [4:0] R;


    assign DATA = (NRD) ? write_data : {8{1'bz}}; // NRD = ~RWn, when NRD=1 there is a write operation on data bus from CPU 
    
    color_mixer UUT(.CLK6(clk6), .CBLK(1'b1), 
                    //051962 interface: tile layer color indexes
                    .NFIX(1'b1),
                    .FI(FI),
                    .NVA(1'b0),
                    .SA({6{1'b0}}),
                    .NVB(1'b0),
                    .SB({6{1'b0}}),
                    //051960-051937 interface: sprite priority and color index
                    .WRP(1'b0), //don't inhibit write to CRAM
                    .NOBJ(1'b0),
                    .OBJ({8{1'b0}}),
                    .OBP({3{1'b0}}),
                    //CPU bus interface
                    .ADDR(ADDR),
                    .DATA(DATA),
                    .NRD(NRD),
                    .CRAMCS(CRAMCS),
                    //Color output
                    .COLOR_WD(RAW_1BGR),
                    //.BLK_OUT(),
                    .B(B),
                    .G(G),
                    .R(R));

    //24bit RGB output color conversion
    assign RAW_RGB = {RAW_1BGR[4:0], {3{1'b0}}, //R
                     RAW_1BGR[9:5],  {3{1'b0}}, //G
                     RAW_1BGR[14:10],{3{1'b0}}  //B
                     };
        
    //6MHz master clock
    reg clk6 = 0;
    always #mc_hp clk6 = !clk6;

    //Write out pixel color pixel data 
    // initial begin
    //     $fmonitor(fd, RAW_RGB);
    // end 

    initial 
        begin
            $dumpfile("color_mixer_tb.lxt");
            $dumpvars(0,color_mixer_tb);
            fd = $fopen("color_mixer.raw", "wb");
            //initial state    
            FI=6'h00; CRAMCS=1'b1; NRD=1'b0; ADDR=10'h000; write_data=8'hAA;
            #mc_qp; #mc_qp; #mc_qp;// advance 3/4 clock period
            
            for(i=0; i < 224; i=i+1) begin
                for(j=0; j < 290; j=j+1) begin
                    //$display ("pix color: %06X", RAW_RGB);
                    if (j>=2) begin
                        res = $fputc ({RAW_1BGR[4:0], {3{1'b0}}}, fd);
                        res = $fputc ({RAW_1BGR[9:5], {3{1'b0}}}, fd);
                        res = $fputc ({RAW_1BGR[14:10], {3{1'b0}}}, fd);
                        FI = (((j-2)>>4) + (i>>4));
                    end
                    #mc_p;
                end
            end
            $fclose(fd);
            $finish;
        end

    // always begin
    //     #mc_p; #mc_p; //two pixel clock periods delay
    //     res = $fputc ({RAW_1BGR[4:0], {3{1'b0}}}, fd);
    //     res = $fputc ({RAW_1BGR[9:5], {3{1'b0}}}, fd);
    //     res = $fputc ({RAW_1BGR[14:10], {3{1'b0}}}, fd);
    // end
endmodule