// logic to go from display coordinates to ram bank + ram address to read
// display data from 

module coord_to_ram #(
    parameter
    NO_BANKS = 8,
    COORDW = 10,
    RAM_ADDR_WIDTH = 12
) (
    input wire [COORDW-1: 0] x,
    input wire [COORDW-1: 0] y,

    output reg [NO_BANKS-1: 0] rd_bank_select, 
    output reg [RAM_ADDR_WIDTH-1: 0] rd_address
);

reg [RAM_ADDR_WIDTH-1: 0] offset; 

always @(*) begin
    case(y[COORDW-1: COORDW-4]) //bank select is upper 4 bits
        4'b0000: rd_bank_select = 8'b00000001;
        4'b0001: rd_bank_select = 8'b00000010;
        4'b0010: rd_bank_select = 8'b00000100;
        4'b0011: rd_bank_select = 8'b00001000;
        4'b0100: rd_bank_select = 8'b00010000;
        4'b0101: rd_bank_select = 8'b00100000;
        4'b0110: rd_bank_select = 8'b01000000;
        4'b0111: rd_bank_select = 8'b10000000;
        default: rd_bank_select = x; 
    endcase
end

always @(*) begin
    offset = {y[5:3], {9{1'b0}}};
    rd_address = offset + x; 
end

    
endmodule
