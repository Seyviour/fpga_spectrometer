module idx2RAM #(
    parameter
    ADDRESS_WIDTH = 12,
    NO_FFTS = 50,
    FFT_SIZE = 256,
    NO_BANKS = 2
) (
    input wire clk,
    input wire signed [FFT_IDX_WIDTH-1: 0] FFT_IDX,
    input wire [SAMPLE_IDX_WIDTH-1:0] sample_idx,

    output reg [1: 0] bank_select, 
    output reg [ADDRESS_WIDTH-1: 0] wr_address
);
localparam SAMPLE_IDX_WIDTH = $clog2(FFT_SIZE/2);
localparam FFT_IDX_WIDTH = $clog2(NO_FFTS);
localparam SHIFT = $clog2(FFT_SIZE/2);

reg [ADDRESS_WIDTH-1: 0] offset; 

//MSB OF FFT_IDX IS BANK SELECT
//OFFSET IS [MSB-1: LSB] * 128 -> memory is 4kx4bits => 32 FFTs per block RAM, each occupying 128 memory locations

always @(*) begin
       offset = {FFT_IDX[FFT_IDX_WIDTH-2:0], {SHIFT{1'B0}}}; //128 LOCATIONS PER FFT
end

always @(posedge clk) begin
    case(FFT_IDX[FFT_IDX_WIDTH-1])
        1'b0: bank_select = 2'b01; 
        1'b1: bank_select = 2'b10;
        default: bank_select = 2'b00;
    endcase

    wr_address <= (ADDRESS_WIDTH)'(offset + sample_idx); 
end

initial begin
    $dumpfile("idx2RAM.vcd");
    $dumpvars(0, idx2RAM);
end
    
endmodule