// `include "/home/saviour/study/fpga_spectrogram/src/sharedmemory/unitRAM.v"

module bankRAM #(
    parameter
    NO_BANKS = 2,
    DATA_WIDTH = 4,
    DEPTH = 4096,
    MEM_FILE = ""
) (
    input wire clk_rd,
    input wire clk_wr, 
    input wire [NO_BANKS-1: 0] wr_bank_select,
    input wire [NO_BANKS-1: 0] rd_bank_select, 
    input wire [NO_BANKS-1: 0] wr_en,
    input wire [ADDR_WIDTH-1: 0] addr_wr,
    input wire [ADDR_WIDTH-1: 0] addr_rd,
    input wire [DATA_WIDTH-1: 0] data_wr,
    output reg [DATA_WIDTH-1: 0] data_rd
);

localparam ADDR_WIDTH = $clog2(DEPTH); 

localparam MEM_FILE2 = "/home/saviour/study/fpga_spectrogram/src/videogen/helpers/samplehex2.mi"; 
wire [DATA_WIDTH-1: 0] read1, read2;

sdpRAM #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH ), .MEM_FILE (MEM_FILE)) RAM0
    (
        .clk_wr (clk_wr),
        .clk_rd (clk_rd),
        .we ((wr_en[0] && wr_bank_select[0])),
        .addr_wr (addr_wr),
        .addr_rd (addr_rd),
        .data_wr (data_wr),
        .data_rd  (read1)
    );

sdpRAM #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH ), .MEM_FILE (MEM_FILE2)) RAM1 
    (
        .clk_wr (clk_wr),
        .clk_rd (clk_rd),
        .we ((wr_en[1] && wr_bank_select[1])),
        .addr_wr (addr_wr),
        .addr_rd (addr_rd),
        .data_wr (data_wr),
        .data_rd  (read2)    );


//TODO: FIGURE OUT DYNAMIC ALTERNATIVE TO CASE, FOR NOW, ONWARDS!!!

always @(posedge clk_rd) begin
    case(rd_bank_select)
    
      2'b01: data_rd = read1;
      2'b10: data_rd = read2; 
      default: data_rd = read1; 
    endcase
end




    
endmodule