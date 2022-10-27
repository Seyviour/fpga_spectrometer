module hdmi2(
  input hdmi_clk,
  input hdmi_clk_5x,
  input [2:0] hve_sync, // Image sync signals: { display_enable, vsync, hsync }
  input [23:0] rgb,
  input reset,

  output [3:0] hdmi_tx_n,
  output [3:0] hdmi_tx_p
);

	DVI_TX_Top your_instance_name(
		.I_rst_n(~reset), //input I_rst_n
		.I_serial_clk(hdmi_clk_5x), //input I_serial_clk
		.I_rgb_clk(hdmi_clk), //input I_rgb_clk
		.I_rgb_vs(hve_sync[1]), //input I_rgb_vs
		.I_rgb_hs(hve_sync[2]), //input I_rgb_hs
		.I_rgb_de(hve_sync[0]), //input I_rgb_de
		.I_rgb_r(rgb[7:0]), //input [7:0] I_rgb_r
		.I_rgb_g(rgb[15:8]), //input [7:0] I_rgb_g
		.I_rgb_b(rgb[23:16]), //input [7:0] I_rgb_b
		.O_tmds_clk_p(hdmi_tx_p[3]), //output O_tmds_clk_p
		.O_tmds_clk_n(hdmi_tx_n[3]), //output O_tmds_clk_n
		.O_tmds_data_p(hdmi_tx_p[2:0]), //output [2:0] O_tmds_data_p
		.O_tmds_data_n(hdmi_tx_n[2:0]) //output [2:0] O_tmds_data_n
	);


endmodule
