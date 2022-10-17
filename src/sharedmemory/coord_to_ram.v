// logic to go from display coordinates to ram bank + ram address to read
// display data from 

module coord_to_ram #(
    parameter
    NO_BANKS = 2,
    COORDW = 10,
    RAM_ADDR_WIDTH = 12,
    NO_FFTS = 50
) (
    input wire [COORDW-1: 0] x,
    input wire [COORDW-1: 0] y,
    input wire signed [$clog2(NO_FFTS)-1:0] OLDEST_FFT_IDX,

    output reg [NO_BANKS-1: 0] rd_bank_select, 
    output reg [RAM_ADDR_WIDTH-1: 0] rd_address
);

localparam N_IDX_BITS = $clog2(NO_FFTS);

wire [$clog2(NO_FFTS):0] NEWEST_FFT_IDX;
reg [$clog2(NO_FFTS)-1:0]  CURR_FFT_IDX;

assign NEWEST_FFT_IDX = OLDEST_FFT_IDX + (N_IDX_BITS-1)'(NO_FFTS-1); 

reg [RAM_ADDR_WIDTH-1: 0] offset; 


// always @(*) begin
//     case(y[COORDW-1: COORDW-4]) //bank select is upper 4 bits
//         4'b0000: rd_bank_select = 8'b00000001;
//         4'b0001: rd_bank_select = 8'b00000010;
//         4'b0010: rd_bank_select = 8'b00000100;
//         4'b0011: rd_bank_select = 8'b00001000;
//         4'b0100: rd_bank_select = 8'b00010000;
//         4'b0101: rd_bank_select = 8'b00100000;
//         4'b0110: rd_bank_select = 8'b01000000;
//         4'b0111: rd_bank_select = 8'b10000000;
//         default: rd_bank_select = x; 
//     endcase
// end

always @(*) begin
    CURR_FFT_IDX = ((NEWEST_FFT_IDX+y[COORDW-1:3]) > (N_IDX_BITS-1)'(NO_FFTS-1))
                    ? (NEWEST_FFT_IDX+y[COORDW-1:3]) - (N_IDX_BITS-1)'(NO_FFTS-1)
                    :  (NEWEST_FFT_IDX+y[COORDW-1:3]);            
end

always @(*) begin
//    case(CURR_FFT_IDX[$clog2(NO_FFTS)-1])    
    case(CURR_FFT_IDX[2])


        1'b0: rd_bank_select = 2'b01;
        1'b1: rd_bank_select = 2'b10;
        default: rd_bank_select = 2'b00;
    endcase

    offset = {CURR_FFT_IDX [(N_IDX_BITS-2) : 0], 7'b0};
    rd_address = offset + x[COORDW-1:3];

end

// always @(*) begin
//     offset = {y[5:3], {9{1'b0}}};
//     rd_address = offset + x; 
// end

    
endmodule
