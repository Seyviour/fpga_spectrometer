module AGU #(
    parameter N = 32,
    stage_width = $clog2($clog2(N)),
    pair_id_width = $clog2(N/2),
    address_width = $clog2(N)
) (
    input wire clk, reset,
    input wire i_valid, 
    input wire [stage_width-1: 0] stage,
    input wire [pair_id_width-1: 0] pair_id, 
    output reg [address_width-1 : 0] address1, address2, 
    output reg [address_width-1: 0] twiddle_address,
    output reg o_valid
);

// initial begin
//     $dumpfile("AGU.vcd");
//     $dumpvars(0,AGU);
// end

// N is the number of samples in the fourier transform
// log2N is the number of bits neccessary to represent N different states
// since the FFT has log2(N) stages, we need log2N bits to encode the stages
// we operate on pairs of samples => we need log(N/2) == logN2 -1 bits to encode pairs
localparam log2N = $clog2(N);

localparam half_mask = log2N - 1;
 
// signal declaration
//reg [log2N-1: 0] stage_reg;
//reg [(log2N -1)- 1: 0] pair_id_reg;
reg [address_width -1: 0] i_address1, i_address2;  

// addresses for the samples in the pair are computed as
// ROT_N_(2*pair_id, stage), ROT_N_(2*pair_id+1, stage)

// Twiddle address is computed by masking the LS log2N-stage-1 bits of pair_id

reg [pair_id_width : 0] pair_id_x_2, pair_id_x_2_1; // (pair_id*2, pair_id*2+1)
reg [address_width-1: 0] i_twiddle_address;

localparam [half_mask*2-1: 0] mask_extended = {{half_mask{1'b1}}, {half_mask{1'b0}}};

reg [half_mask-1: 0] mask;
// reg [address_width: 0] mask_;
// integer i; 

always @(*)begin
    pair_id_x_2 = {pair_id, 1'b0}; 

    //OR can be used to add 1 since the last bit of pair_id_x_2 is necessarily 0
    pair_id_x_2_1 = {pair_id, 1'b1};
    i_address1 = barrel_shift_left(pair_id_x_2, stage);
    i_address2 = barrel_shift_left(pair_id_x_2_1, stage);
    mask = mask_extended[stage +: half_mask];
    // mask_ = mask - 1'b1;
    i_twiddle_address = mask & pair_id; 
    
    //generate 
    // for (i = 0; i<log2N-1; i = i + 1) begin
    //     if (i < log2N-stage-1) 
    //         twiddle_address_reg[i] = pair_id[i]; 
    //     else
    //         twiddle_address_reg[i] = 1'b0; 
    // end
    //endgenerate

end

always @(posedge clk, posedge reset) begin
    // pair_id_reg <= pair_id; 
    // stage_reg <= stage;

    if (reset) begin
        address1 <= 0; 
        address2 <= 0; 
        twiddle_address <= 0;
        o_valid <= 0; 
    end else begin
        o_valid <= i_valid; 
        address1 <= i_address1;
        address2 <= i_address2;
        twiddle_address <= i_twiddle_address;
    end
end


// barrel shift vector j by vector i
function [log2N-1:0] barrel_shift_left;
    input [pair_id_width: 0] j; //vector to be barrel shifted
    input [stage_width-1: 0] i; // amount to shift by

    reg [stage_width-1: 0] max_index, temp;
    reg [2*pair_id_width+1: 0] doublej;

    //reg  [log2N-1:0] temp;
    begin
        max_index = log2N & {stage_width{1'b1}};
        doublej = {j, j};
        temp = max_index - i; 
        barrel_shift_left = doublej[temp+:log2N];   
    end 
    
    
endfunction
    
endmodule