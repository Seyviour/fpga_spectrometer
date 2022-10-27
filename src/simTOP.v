module simTOP #(
    parameter
    A = 22
) (
    input wire clk,
    input wire reset,

    output wire [3:0] hdmi_tx_n,
    output wire [3:0] hdmi_tx_p
);

wire SD, WS, SCK; 

i2sMicSim thisi2sMicSim 
    (
        .SCK (SCK ),
        .reset (~reset ),
        .WS (WS ),
        .SD ( SD)
    );

spectroTOP2 spectroTOP2_dut (
      .clk (clk ),
      .reset (reset ),
      .SD (SD ),
      .WS (WS ),
      .SCK (SCK ),
      .hdmi_tx_n (hdmi_tx_n ),
      .hdmi_tx_p  ( hdmi_tx_p)
    );
  

endmodule