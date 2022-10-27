module tmds_encoder2 (
    input wire clk,
    input wire reset, 
    input wire DE,
    input wire [0:7] D, 
    input wire C0,
    input wire C1,
    output reg [0:9] q_out
);
    
localparam COUNT_ONES_WIDTH = 5;

reg [COUNT_ONES_WIDTH-1:0] ones_count_D, ones_count_qm, zeros_count_qm;
reg cond1;
reg signed [5:0] cnt;
reg reset_i, C0_i, C1_i, DE_i; 

reg [0:8] q_m, q_m_R;
always @(*) begin
    ones_count_D = {$countones(D)}; 
    if ((ones_count_D>4) | (ones_count_D==4 && D[0]==1'b0)) begin
        q_m[0] = D[0];
        q_m[1] = q_m[0] ^~ D[1];
        q_m[2] = q_m[1] ^~ D[2];
        q_m[3] = q_m[2] ^~ D[3];
        q_m[4] = q_m[3] ^~ D[4];
        q_m[5] = q_m[4] ^~ D[5]; 
        q_m[6] = q_m[5] ^~ D[6];
        q_m[7] = q_m[6] ^~ D[7];
        q_m[8] = 0;
    end else begin
        q_m[0] = D[0];
        q_m[1] = q_m[0] ^ D[1];
        q_m[2] = q_m[1] ^ D[2];
        q_m[3] = q_m[2] ^ D[3];
        q_m[4] = q_m[3] ^ D[4];
        q_m[5] = q_m[4] ^ D[5]; 
        q_m[6] = q_m[5] ^ D[6];
        q_m[7] = q_m[6] ^ D[7];
        q_m[8] = 1;
    end
end

always @(posedge clk) begin
    ones_count_qm <= ($countones(q_m[0:7]));
    zeros_count_qm <= 8 - ($countones(q_m[0:7]));
    q_m_R <= q_m;
    DE_i <= DE;
    C0_i <= C0;
    C1_i <= C1;
    reset_i <= reset; 
end

// reg [0:9] q_out; 

always @(posedge clk) begin
    
    if(DE_i) begin
        if ((cnt == 0) | ones_count_qm == 4 ) begin
            q_out[9] <= ~q_m_R[8];
            q_out[8] <= q_m_R[8];
            q_out[0:7] <= (q_m_R[8])? q_m_R[0:7] : ~q_m_R[0:7];

            if (~q_m_R[8]) 
                cnt <= cnt - (8-ones_count_qm) + (ones_count_qm);
            else
                cnt <= cnt + (8-ones_count_qm) - ones_count_qm;


        end else begin
            if ((cnt > 0 && ones_count_qm > 4) | ((cnt < 0) && (ones_count_qm < 4))) begin
                q_out[9] <= 1'b1;
                q_out[8] <= q_m_R[8];
                q_out[0:7] <= ~q_m_R[0:7];
                cnt <= cnt + {q_m_R[8], 1'b0} + (8-ones_count_qm) - ones_count_qm;
            end else begin
                q_out[9] <= 1'b0;
                q_out[8] <= ~q_m_R[8];
                q_out[0:7] <= q_m_R[0:7];
                cnt <= cnt + 6'(-2 * ~q_m_R[8]) + ones_count_qm - (8 - ones_count_qm);

            end
        end
        
    end else begin
        cnt <= 0; 
        case ({C1_i, C0_i})
            2'b00: q_out <= 10'b0010101011;
            2'b01: q_out <= 10'b1101010100;
            2'b10: q_out <= 10'b0010101010;
            2'b11: q_out <= 10'b1101010101;
        endcase

    end

    if (reset_i) begin
        q_out <= 0; 
        cnt <= 0; 
    end

end
endmodule