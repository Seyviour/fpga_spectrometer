`include "/home/saviour/study/fpga_spectrogram/src/sharedmemory/unitRAM.v"

module bankRAM #(
    parameter
    no_banks = 8,
    word_width = 4,
    address_width = 5
) (
    input wire clk,
    input wire [no_banks-1: 0] wr_bank_select,
    input wire [no_banks-1: 0] rd_bank_select, 
    input wire [no_banks-1: 0] wr_en,
    input wire [address_width-1: 0] wr_address,
    input wire [address_width-1: 0] rd_address,
    input wire [word_width-1: 0] wr_data,
    output reg [word_width-1: 0] rd_data
);

genvar i; 

wire [no_banks*word_width-1: 0] all_reads; 


generate
    for (i = 0; i < no_banks; i=i+1) begin
        unitRAM #(.word_width(word_width), .address_width(address_width)) thisRAM
            (
                .clk(clk),
                .wr_en(wr_en[i]),
                .wr_address(wr_address),
                .rd_address(rd_address),
                .wr_data(wr_data),
                .rd_data(all_reads[word_width*(i+1)-1: word_width*i])
            );
    end
endgenerate

//TODO: FIGURE OUT DYNAMIC ALTERNATIVE TO CASE, FOR NOW, ONWARDS!!!

always @(*) begin
    case(rd_bank_select)

    8'b00000001: rd_data = all_reads[word_width-1: 0];
    8'b00000010: rd_data = all_reads[word_width*2-1: word_width];
    8'b00000100: rd_data = all_reads[word_width*3-1: word_width*2];
    8'b00001000: rd_data = all_reads[word_width*4-1: word_width*3];
    8'b00010000: rd_data = all_reads[word_width*5-1: word_width*4];
    8'b00100000: rd_data = all_reads[word_width*6-1: word_width*5]; 
    8'b01000000: rd_data = all_reads[word_width*7-1: word_width*6];
    8'b10000000: rd_data = all_reads[word_width*8-1: word_width*7];
    default: rd_data = 0; 


    endcase

end




    
endmodule