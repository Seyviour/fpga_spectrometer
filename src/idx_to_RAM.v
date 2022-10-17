module idx2RAM #(
    parameter
    ADDRESS_WIDTH = 12,
    NO_FFTS = 50,
    FFT_SIZE = 256,
    NO_BANKS = 2
) (
    input wire signed [$clog2(NO_FFTS)-1: 0] FFT_IDX,
    input wire [$clog2(FFT_SIZE/2)-1:0] sample_idx,

    output reg [NO_BANKS-1: 0] bank_select, 
    output reg [ADDRESS_WIDTH-1: 0] wr_address
);

localparam FFT_id_width = $clog2(NO_FFTS);
reg [ADDRESS_WIDTH-1: 0] offset; 

always @(*) begin
    case(FFT_IDX[FFT_id_width-1])
        1'b0: bank_select = 2'b01; 
        1'b1: bank_select = 2'b10;
        default: bank_select = 2'b00;
    endcase

    offset = FFT_IDX[FFT_id_width-2: 0] << 7; //128 LOCATIONS PER FFT
    wr_address = offset + sample_idx; 
end


    
endmodule