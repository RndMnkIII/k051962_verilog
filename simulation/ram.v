module CRAM_E15(
    input [8:0] ADDR, //512Bx8bit
    input CEn,
    input OEn,
    input WEn,
    inout [7:0] DATA);

    localparam ADDR_WIDTH = 9; //512Bx8bit

    reg [7:0] mem[0:(2**ADDR_WIDTH)]; //512Bx8bit
    reg [7:0] data_out;
    
    initial begin
        $readmemh("CRAM_E15.hex", mem);
    end

    always @*
    begin: mem_write
        if (!CSn && !WEn) begin
          mem[ADDR] = DATA;
        end
    end

    always @*
    begin
        if (!CSn && WEn && !OEn) begin
          data_out = mem[ADDR];
        end
    end

    //typical value for 45ns SRAM address to output valid 25ns (max. 45ns)
    assign DATA = ((!CSn) && WEn && (!OEn)) ? data_out :{8{1'bz}};
endmodule

module CRAM_E14(
    input [8:0] ADDR, //512Bx8bit
    input CEn,
    input OEn,
    input WEn,
    inout wire [7:0] DATA);

    localparam ADDR_WIDTH = 9; //512Bx8bit

    reg [7:0] mem[0:(2**ADDR_WIDTH)]; //512Bx8bit
    reg [7:0] data_out;
    
    initial begin
        $readmemh("CRAM_E14.hex", mem);
    end

    always @*
    begin: mem_write
        if (!CSn && !WEn) begin
          mem[ADDR] = DATA;
        end
    end

    always @*
    begin
        if (!CSn && WEn && !OEn) begin
          data_out = mem[ADDR];
        end
    end

    //typical value for 45ns SRAM address to output valid 25ns (max. 45ns)
    assign DATA = (!CSn && WEn && !OEn) ? data_out : {8{1'bz}};
endmodule
