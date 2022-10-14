//NICE TO REUSE CODE I WROTE, LOL
module buffer #(
    parameter word_size = 16,
    buffer_length = 3
) (
    input wire clk, en, in_valid, reset,   
    input wire [word_size-1: 0] d_in,
    output wire [word_size-1: 0] d_out,
    output wire d_valid
);


//SIGNAL DECLARATION
reg [word_size: 0] ibuffer [buffer_length-1: 0];
integer i;

always @(posedge clk, posedge reset) begin

    if (reset) begin
        for (i = 0; i <= buffer_length-1; i = i + 1) begin
            ibuffer[i] <= 0;
        end
       
    end
    else  begin
        // if(en)
        ibuffer[buffer_length-1] <= {in_valid, d_in};

        //generate
        for (i = 0; i <= buffer_length-2; i = i + 1) begin
            // if (en)
            ibuffer[i] <= ibuffer[i + 1];
        end
        //endgenerate
    end
end
assign d_out = ibuffer[0][word_size-1: 0];
assign d_valid = ibuffer[0][word_size];
    
endmodule