module count_ones #(
    parameter
    WIDTH = 8,
    COUNTWIDTH = $clog2(WIDTH) + 1
) (
    input wire [WIDTH-1: 0] A,
    output reg [COUNTWIDTH-1: 0] one_count
);
    

integer i;

always @(A)
begin
    one_count = 0;  //initialize count variable.
    for(i=0;i<WIDTH;i=i+1)   //for all the bits.
        one_count = one_count + A[i]; //Add the bit to the count.
end
endmodule