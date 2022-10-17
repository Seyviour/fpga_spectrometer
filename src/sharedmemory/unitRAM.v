module unitRAM #(
    parameter
    word_width = 4,
    address_width = 3
) (
    input wire clk,
    input wire wr_en, 
    input wire [address_width-1: 0] rd_address,
    input wire [address_width-1: 0] wr_address,
    input wire [word_width-1: 0] wr_data,
    output wire [word_width-1: 0] rd_data
);

localparam no_words = (2**address_width);

    Gowin_SDPB aUnitRAM(
        .dout(rd_data), //output [3:0] dout
        .clka(clk), //input clka
        .cea(wr_en), //input cea
        .reseta(1'b0), //input reseta
        .clkb(clk), //input clkb
        .ceb(wr_en), //input ceb
        .resetb(1'b0), //input resetb
        .oce(1'b1), //input oce
        .ada(wr_address), //input [11:0] ada
        .din(wr_data), //input [3:0] din
        .adb(rd_address) //input [11:0] adb
    );



//reg [no_words-1: 0] RAM [word_width-1: 0];

//always @(posedge clk) begin
//    if (wr_en) 
//        RAM[wr_address] <= wr_data;
//end

//assign rd_data = RAM[rd_address]; 

    
endmodule