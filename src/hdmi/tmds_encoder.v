// DVI TMDS ENCODER AS SPECIFIED IN https://glenwing.github.io/docs/DVI-1.0.pdf

// `include "/home/saviour/study/fpga_spectrogram/src/hdmi/count_ones.v"


module dvi_tmds_encoder #(
    parameter
    DATAWIDTH = 8
) (
    input wire clk, reset, 
    input wire DE,
    input wire [7: 0] D,
    input wire C0,
    input wire C1,

    output reg [DATAWIDTH+1: 0] QOUT
);

reg [1:0] cnt_case; 
reg signed [3:0] cnt, cnt_next; 
reg  signed [DATAWIDTH: 0] q;

wire cnt_N, cnt_P, cnt_0;
wire signed [4:0] N1_q, N0_q; 

//this is dysfunction
count_ones #(.COUNTWIDTH(5)) this_count (.A(q[7:0]), .one_count(N1_q)); 

assign cnt_N = cnt[3];
assign cnt_P = (~cnt_N & (cnt[1] | cnt[0]));
assign cnt_0 = ~(cnt_N|cnt_P); 
assign N0_q = 8 - N1_q;









integer i; 
always @(*) begin
    q[0] = D[0]; 
    for (integer i = 1; i < DATAWIDTH; i = i + 1)
        q[i] = D[1] ^ q[i-1];
    q[8] = 1; 
end


always @(*) begin
    if (~DE) begin
        cnt_case = 2'b00; 
        case ({C1, C0})
            2'b00: QOUT = 10'b0010101011;
            2'b01: QOUT = 10'b1101010100;
            2'b10: QOUT = 10'b0010101010;
            2'b11: QOUT = 10'b1101010101;
            default: QOUT  = 10'b0010101011;
        endcase
    end else  begin
        QOUT = 10'b0010101011;
        cnt_case = 2'b00;
        if ((cnt==0)| (N1_q == 4)) begin
            QOUT[9] = ~q[8];
            QOUT[8] = q[8];
            QOUT[7:0] = q[8]? q[7:0]: ~q[7:0];
        end else begin
            if ((cnt_P & (N1_q > 4)) | (cnt_N & N1_q < 4) ) begin
                QOUT = {1'b1, q[8], ~q[7:0]}; 
                cnt_case = 2'b01; 
            end 
            else begin 
                QOUT = {1'b0, q[8], q[7:0]};
                cnt_case = 2'b10; 
            end
        end
    end
end

reg signed [4:0] N1_minus_N0, N0_minus_N1;

always @(*) begin
    N0_minus_N1 = N0_q - N1_q;
    N1_minus_N0 = N1_q - N0_q; 
end


always @(*) begin
    case (cnt_case)
        2'b00: begin
            if (q[8])
                cnt_next = cnt + N0_minus_N1;
            else
                cnt_next = cnt + N1_minus_N0; 
            end
        2'b01:
            cnt_next = cnt - {q[8],1'b0} + N1_minus_N0; 
        2'b10:
            cnt_next = cnt + {q[8], 1'b0} + N0_minus_N1;

        default: cnt_next = 0; 

    endcase
end



always @(posedge clk)
    if (reset|DE)
        cnt <= 0; 
    else begin
        cnt <= cnt_next; 
    end


    
endmodule