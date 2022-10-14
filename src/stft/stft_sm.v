module STFT_SM #(
    parameter
     WORD_WIDTH = 16,
     FFT_SIZE = 512
) (
    input wire clk, reset, 
    input wire start_compute,
    input wire [WORD_WIDTH-1: 0] SAMPLE,
    input wire [WORD_WIDTH-1: 0] OLDEST_SAMPLE,
    
    output reg [WORD_WIDTH-1: 0] sample_diff,
    output reg sample_wr_en,
    output reg [$clog2(FFT_SIZE)-1: 0] oldest_sample_address, 
    output reg [$clog2(FFT_SIZE)-1: 0] idx,  // TO TWIDDLE ADDRESS GENERATION UNIT
    output reg wr_en
);


reg [WORD_WIDTH-1: 0] SAMPLE_RAM [FFT_SIZE-1: 0];

reg [1:0] COMPUTE_STATE;
    localparam IDLE = 2'b00;
    localparam BUSY = 2'b10; 

always @(posedge clk) begin
    if (reset) begin
        idx <= 0; 
        wr_en <= 0;
        COMPUTE_STATE <= IDLE;
        oldest_sample_address <= 0; 
    end else begin


        case (COMPUTE_STATE)
            IDLE: begin
                idx <= 0;
                wr_en <= 0;
                if (start_compute)
                    COMPUTE_STATE <= BUSY;
                    wr_en <= 1'b1;
                    sample_diff <= SAMPLE - OLDEST_SAMPLE;
                    sample_wr_en <= 1'b1; 
            end

            BUSY: begin
                idx <= idx + 1;
                if (&idx)
                    COMPUTE_STATE <= IDLE;
                    wr_en <= 0;
                    oldest_sample_address <= oldest_sample_address + 1'b1; 
            end
            
            default: COMPUTE_STATE <= IDLE; 
        endcase
    end
end

endmodule