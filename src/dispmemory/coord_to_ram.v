// logic to go from display coordinates to ram locations

module coord_to_ram #(
    parameter
    XSTART = 0,
    BARWIDTH = 12, 
    COORDW = 12,
    RAM_ADDR_WIDTH = 11
) (
    input wire [COORDW-1: 0] x,
    input wire [COORDW-1: 0] y,

    output wire [3:0] bank_select,
    output reg [RAM_ADDR_WIDTH-1: 0] address
);


localparam B0LIMIT = 143 + XSTART;
localparam B1LIMIT = 287 + XSTART;
localparam B2LIMIT = 431 + XSTART;
localparam B3LIMIT = 575 + XSTART; 

reg sel0, sel1, sel2, sel3;

always @(*) begin
    sel0 = (x >= XSTART && x <=B0LIMIT);
    sel1 = (x >B0LIMIT && x <= B1LIMIT);
    sel2 = (x > B1LIMIT && x <= B2LIMIT);
    sel3 = (x > B2LIMIT && x <= B3LIMIT); 
end


assign bank_select =  {sel0, sel1, sel2, sel3};
    
endmodule
