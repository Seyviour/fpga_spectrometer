module iRAM #(
    parameter
    WORD_WIDTH=16,
    ADDRESS_WIDTH=5
) (
    input wire clk,
    input wire wr_en,
    input wire [ADDRESS_WIDTH-1: 0] wr_addr,
    input wire [ADDRESS_WIDTH-1: 0] rd_addr,
    input wire [WORD_WIDTH-1: 0] wr_data,
    output wire [WORD_WIDTH -1: 0] rd_data
);
    
// reg [WORD_WIDTH-1: 0] RAM [2**ADDRESS_WIDTH-1: 0];
reg [2**ADDRESS_WIDTH-1: 0] RAM [WORD_WIDTH-1: 0];

always @(posedge clk)
    if (wr_en)
        RAM[wr_addr] <= wr_data; 

assign rd_data = RAM[rd_addr];
endmodule