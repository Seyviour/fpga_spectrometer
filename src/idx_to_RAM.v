module idx2RAM #(
    parameter
    ADDRESS_WIDTH = 12,
    NO_FFTS = 50,
    FFT_SIZE = 256,
    NO_BANKS = 2
) (
    input wire signed [6: 0] FFT_IDX,
    input wire [6:0] sample_idx,

    output reg [1: 0] bank_select, 
    output reg [11: 0] wr_address
);

localparam FFT_id_width = 6;

reg [ADDRESS_WIDTH-1: 0] offset; 



always @(*) begin
    case(FFT_IDX[FFT_id_width-1])
        1'b0: bank_select = 2'b01; 
        1'b1: bank_select = 2'b10;
        default: bank_select = 2'b00;
    endcase

    offset = {5'(FFT_IDX[FFT_id_width-2: 0]), 7'b0}; //128 LOCATIONS PER FFT
    wr_address = offset + sample_idx; 
end


    
endmodule