//COMPUTE BLOCK
//4CYCLE LATENCY
// `include "/home/saviour/study/fpga_spectrogram/src/stft/buffer.v"
// `include "/home/saviour/study/fpga_spectrogram/src/stft/cMult.v"
module SPU #(
    parameter
    WORD_WIDTH = 16,
    FFT_SIZE = 512
)(
    input wire clk, 
    input wire signed [WORD_WIDTH-1: 0] sample_diff,
    input wire [2*WORD_WIDTH-1: 0] twiddle, 
    input wire [2*WORD_WIDTH-1: 0] Xk_prev,
    input wire wr_en,
    input wire i_disp_wr_en, 

    output wire o_wr_en,
    output wire o_disp_wr_en,  
    input wire [$clog2(FFT_SIZE)-1:0] i_idx,
    output wire [2*WORD_WIDTH-1: 0] Xk,
    output wire [$clog2(FFT_SIZE)-1:0] o_idx
);

localparam MULTIPLIER_DELAY = 3; 


// always @(posedge clk) begin
//     o_idx <= i_idx;
//     o_wr_en <= wr_en;
//     o_disp_wr_en <= i_disp_wr_en; 
// end

wire [2*WORD_WIDTH-1: 0] product;

wire signed [WORD_WIDTH-1:0] Xk_prev_real, Xk_prev_imag;
assign Xk_prev_real = Xk_prev[WORD_WIDTH*2-1: WORD_WIDTH];
assign Xk_prev_imag = Xk_prev[WORD_WIDTH-1: 0];

wire signed [WORD_WIDTH-1: 0] Xk_prev_real_plus;
assign Xk_prev_real_plus =  Xk_prev_real + sample_diff;

wire [WORD_WIDTH*2-1:0] Xk_prev_plus;
assign Xk_prev_plus = {Xk_prev_real_plus, Xk_prev_imag};

cMult #(.word_size(WORD_WIDTH)) this_complex_multiplier
    (   .clk(clk),
        .i_valid(1'b1),
        .A(twiddle), //INPUT
        .B(Xk_prev_plus), //INPUT **XK_prev(real) _ sample_diff 
        .C(Xk) //OUTPUT
    );

// buffer #(.word_size($clog2(FFT_SIZE) ),.buffer_length (MULTIPLIER_DELAY ))buffer_d
//     (
//       .clk (clk ),
//       .en(1'b1),
//       .in_valid (),
//       .reset (1'b0),
//       .d_in ({i_idx}),
//       .d_out (o_idx )
//     );

wire [$clog2(FFT_SIZE)+2-1: 0] buff_out, buff_in; 
assign buff_in = {wr_en, i_disp_wr_en, i_idx};
assign {o_wr_en, o_disp_wr_en, o_idx} = buff_out;

buffer #(.word_size($clog2(FFT_SIZE)+2),.buffer_length (MULTIPLIER_DELAY ))buffer_dut 
(
    .clk (clk ),
    .en(1'b1),
    .in_valid (1'b1),
    .reset (1'b0),
    .d_in (buff_in),
    .d_out (buff_out)
);

endmodule