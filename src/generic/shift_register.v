module delayShiftRegister #(
    parameter
    DATA_WIDTH=2,
    DELAY_CYCLES=4,
    USE_EN=1'B0
) (
    input wire clk,
    input wire en, 
    input wire [DATA_WIDTH-1: 0] datain,
    input wire i_valid, 
    output wire [DATA_WIDTH-1: 0] dataout,
    output wire o_valid 
);
    
reg [DATA_WIDTH: 0] SREG [DELAY_CYCLES-1: 0];
integer i;

always @(posedge clk) begin

    // if (en) begin
        SREG[DELAY_CYCLES-1] <= {i_valid, datain};

        for (i = 0; i <= DELAY_CYCLES-2; i = i + 1) begin
            if ((USE_EN & en) | ~USE_EN )
                SREG[i] <= SREG[i + 1];
            else ;
        end

    // end
        
    end

assign dataout = SREG[0][DATA_WIDTH-1: 0];
assign o_valid = SREG[0][DATA_WIDTH];
    



endmodule