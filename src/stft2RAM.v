module stft2RAM #(
    parameter
    COUNT_HIGH = 20,
    FFT_SIZE = 256,
    WORD_WIDTH = 16,
    NO_FFTS = 50,
    ADDRESS_WIDTH = 12,
    NO_BANKS = 2   
) (
    input wire clk, //27MHz
    input wire reset,
    input wire wr_en,
    input wire [$clog2(FFT_SIZE/2)-1:0] idx,
    input wire [WORD_WIDTH*2-1:0] i_data,

    output reg  [$clog2(NO_FFTS)-1: 0] OLDEST_FFT_IDX,

    output reg disp_wr_en,
    output wire [NO_BANKS-1:0] bank_wr,
    output wire [ADDRESS_WIDTH-1:0] addr_wr,
    output wire [3:0] data_wr
);


wire pulse;
wire count_true; 

//COMBINATIONAL **yes, I see the clk, lol**
//All necessary signals are ready before hand
pulseDetectCount #( .COUNTHIGH (COUNT_HIGH )) thisPulseDetectCount 
    (
        .clk (clk),
        .reset (reset),
        .wr_en (wr_en),
        .count_true (count_true),
        .pulse(pulse)
    );

always @(posedge clk)
    disp_wr_en <= wr_en && count_true;

// 1 clk cycle delay
magnitudeAndLog #(.WORD_WIDTH (WORD_WIDTH )) thisMagnitudeAndLog 
    (
        .clk (clk),
        .Xk (i_data),
        .log (data_wr)
    );

// 1 cycle delay
idx2RAM #(.ADDRESS_WIDTH(ADDRESS_WIDTH),.NO_FFTS(NO_FFTS),.FFT_SIZE(FFT_SIZE),.NO_BANKS (NO_BANKS)) thisidx2RAM
    (
        .clk(clk),
        .FFT_IDX (OLDEST_FFT_IDX), //write newest dft to location of oldest fft
        .sample_idx (idx),
        .bank_select (bank_wr),
        .wr_address  (addr_wr)
    );

//READY BEFORE HAND
always @(posedge clk) begin
    if (reset) begin
        OLDEST_FFT_IDX <= 0; 
    end else begin 
        if (pulse && count_true) begin 
            if (OLDEST_FFT_IDX == NO_FFTS-1)
                OLDEST_FFT_IDX <= 0;
            else
                OLDEST_FFT_IDX <= OLDEST_FFT_IDX + 1'b1;
            end
        else ; 
    end
end

initial begin
    $dumpfile("stft2RAM.vcd");
    $dumpvars(0, stft2RAM);
end 

endmodule