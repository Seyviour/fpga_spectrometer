module sdpRAM #(
    parameter
    DATA_WIDTH = 4,
    DEPTH = 256,
    MEM_FILE = ""
) (
    input wire clk_wr,
    input wire clk_rd,
    input wire we,
    input wire [ADDRW-1:0] addr_wr,
    input wire [ADDRW-1:0] addr_rd,
    input wire [DATA_WIDTH-1:0] data_wr,
    output reg [DATA_WIDTH-1:0] data_rd
);

localparam ADDRW = $clog2(DEPTH);

reg [DATA_WIDTH-1:0] RAM [DEPTH-1:0];

initial begin
    if (MEM_FILE != "") begin
        $readmemh(MEM_FILE, RAM);
    end
end

always @(posedge clk_wr) begin
    if (we)
        RAM[addr_wr] <= data_wr;  
end

always @(*) begin
    data_rd <= RAM[addr_rd]; 
end
    
endmodule