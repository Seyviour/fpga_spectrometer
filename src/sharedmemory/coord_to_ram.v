// logic to go from display coordinates to ram bank + ram address to read
// display data from 

module coord_to_ram #(
    parameter
    NO_BANKS = 2,
    COORDW = 16,
    RAM_ADDR_WIDTH = 12,
    NO_FFTS = 50,
    FFT_SIZE = 256
) (
    input wire clk, 
    input wire [COORDW-1: 0] x, // 0 - 512
    input wire [COORDW-1: 0] y, // 0 - 
    input wire signed [$clog2(NO_FFTS)-1:0] OLDEST_FFT_IDX, 

    output reg [NO_BANKS-1: 0] rd_bank_select, 
    output reg [RAM_ADDR_WIDTH-1: 0] rd_address
);


// There are two banks of RAM, each 4Kx4bits
// For each FFT_ID (0-50), the bank will be selected as the MSB

// Scanning horizontally, each pixel should be repeated 4 times
// Every FFT has 128 elements (mirror eliminated from 256)
// The last two bits of the x-component of the address are disregarded
// Each "pixel" is also repeated along the vertical 4 times

reg [COORDW-1: 0] i_x;
reg [COORDW-1: 0] i_y;

always @(posedge clk) begin 
    i_x <= COORDW'(x + 1);
    i_y <=  y; 
end

localparam FFT_IDX_WIDTH = $clog2(NO_FFTS);
localparam FFT_IDX_MSB = FFT_IDX_WIDTH-1; 

reg [FFT_IDX_WIDTH:0] IDX_SUM;
reg [FFT_IDX_WIDTH-1:0] CURR_FFT_IDX;

reg [RAM_ADDR_WIDTH-1: 0] offset; 


always @(*) begin
    IDX_SUM = OLDEST_FFT_IDX + i_y[4+:FFT_IDX_WIDTH];
end

always @(posedge clk) begin
    if (IDX_SUM <= (NO_FFTS-1))
        CURR_FFT_IDX <= IDX_SUM;
    else
        CURR_FFT_IDX <= IDX_SUM - NO_FFTS; 
end

always @(posedge clk) begin
//    case(CURR_FFT_IDX[$clog2(NO_FFTS)-1])    
    case(CURR_FFT_IDX[FFT_IDX_WIDTH-1])
        1'b0: rd_bank_select <= 2'b01;
        1'b1: rd_bank_select <= 2'b10;
        default: rd_bank_select = 2'b00;
    endcase

    offset <= {CURR_FFT_IDX[(FFT_IDX_WIDTH-2) : 0], ($clog2(FFT_SIZE/2))'(0)}; //TODO: parameterize this 7!
    rd_address <= offset + i_x[COORDW-1:2];

end
    
endmodule
