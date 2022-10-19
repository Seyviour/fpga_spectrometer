module idx2RAM #(
    parameter
    ADDRESS_WIDTH = 11,
    NO_FFTS = 50,
    FFT_SIZE = 256,
    NO_BANKS = 2
) (
    input wire signed [6: 0] FFT_IDX,
    input wire [FFT_IDX_WIDTH-1:0] sample_idx,

    output reg [1: 0] bank_select, 
    output reg [ADDRESS_WIDTH-1: 0] wr_address
);

localparam FFT_IDX_WIDTH = $clog2(NO_FFTS);
reg [ADDRESS_WIDTH-1: 0] offset; 

//MSB OF FFT_IDX IS BANK SELECT
//OFFSET IS [MSB-1: LSB] * 128 -> memory is 4kx4bits => 32 FFTs per block RAM, each occupying 128 memory locations

always @(*) begin
    case(FFT_IDX[FFT_IDX_WIDTH-1])
        1'b0: bank_select = 2'b01; 
        1'b1: bank_select = 2'b10;
        default: bank_select = 2'b00;
    endcase

    offset = {FFT_IDX[FFT_IDX_WIDTH-2:0], 6'b0}; //128 LOCATIONS PER FFT
    wr_address = offset + sample_idx; 
end


    
endmodule