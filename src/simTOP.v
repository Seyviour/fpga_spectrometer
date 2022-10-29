`timescale 1 ns / 10 ps


module simTOP #(
    parameter
    SIM=0
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

spectroTOP2 #(.SIM(SIM)) thisSpectroTOP2 (
      .clk (clk ),
      .reset (reset ),
      .SD (SD ),
      .WS (WS ),
      .SCK (SCK ),
      .hdmi_tx_n (hdmi_tx_n ),
      .hdmi_tx_p  ( hdmi_tx_p)
    );
 

initial begin
 $dumpfile("spectrosim.vcd");
 $dumpvars(0, simTOP); 
end

endmodule