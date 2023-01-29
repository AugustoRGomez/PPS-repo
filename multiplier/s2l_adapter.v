
`timescale 1 ns / 1 ps

	module axi_stream2lite_interface_v1_0 #
	(
		// Parameters of Axi Slave Bus Interface
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 5,

		// Parameters of Axis Slave Bus Interface
		parameter integer C_S00_AXIS_TDATA_WIDTH = 32
	)
	(
		// Multiplier ports	
		input	wire	[C_S00_AXI_DATA_WIDTH-1 : 0] word_count, 
		input	wire	[C_S00_AXI_DATA_WIDTH-1 : 0] frame_count,

		// Ports of Axi Slave Bus Interface
		input  wire  								 s00_axi_aclk,
		input  wire  								 s00_axi_aresetn,
		input  wire [C_S00_AXI_ADDR_WIDTH-1 : 0] 	 s00_axi_awaddr,
		input  wire [2 : 0] 						 s00_axi_awprot,
		input  wire  								 s00_axi_awvalid,
		output wire 								 s00_axi_awready,
		input  wire [C_S00_AXI_DATA_WIDTH-1 : 0] 	 s00_axi_wdata,
		input  wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input  wire  								 s00_axi_wvalid,
		output wire  								 s00_axi_wready,
		output wire [1 : 0] 						 s00_axi_bresp,
		output wire  								 s00_axi_bvalid,
		input  wire  								 s00_axi_bready,
		input  wire [C_S00_AXI_ADDR_WIDTH-1 : 0] 	 s00_axi_araddr,
		input  wire [2 : 0] 						 s00_axi_arprot,
		input  wire  								 s00_axi_arvalid,
		output wire 								 s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] 	 s00_axi_rdata,
		output wire [1 : 0] 						 s00_axi_rresp,
		output wire  								 s00_axi_rvalid,
		input  wire  								 s00_axi_rready,

		// Ports of Axis Slave Bus Interface 
		input  wire  								   s00_axis_aclk,
		input  wire  								   s00_axis_aresetn,
		output wire 								   s00_axis_tready,
		input  wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] 	   s00_axis_tdata,
		input  wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] s00_axis_tstrb,
		input  wire  								   s00_axis_tlast,
		input  wire  								   s00_axis_tvalid
	);

	// Interconnect signals
	wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] incoming_data;
	wire 							    tvalid		 ;
	wire 							    tlast		 ;
	wire [2-1: 0]						wr_ptr		 ;
	wire								ready		 ;

	// Instantiation of Axi Bus Interface S00_AXI
	axi_stream2lite_interface_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) axi_stream2lite_interface_v1_0_S00_AXI_inst (
		.S_AXI_ACLK	  (s00_axi_aclk   ),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR (s00_axi_awaddr ),
		.S_AXI_AWPROT (s00_axi_awprot ),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA  (s00_axi_wdata  ),
		.S_AXI_WSTRB  (s00_axi_wstrb  ),
		.S_AXI_WVALID (s00_axi_wvalid ),
		.S_AXI_WREADY (s00_axi_wready ),
		.S_AXI_BRESP  (s00_axi_bresp  ),
		.S_AXI_BVALID (s00_axi_bvalid ),
		.S_AXI_BREADY (s00_axi_bready ),
		.S_AXI_ARADDR (s00_axi_araddr ),
		.S_AXI_ARPROT (s00_axi_arprot ),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA  (s00_axi_rdata  ),
		.S_AXI_RRESP  (s00_axi_rresp  ),
		.S_AXI_RVALID (s00_axi_rvalid ),
		.S_AXI_RREADY (s00_axi_rready ),

		// Multiplier signals
		.word_count   (word_count   ),
		.frame_count  (frame_count  ),

		// Interconnect signals
		.incoming_data(incoming_data),
		.tvalid		  (tvalid		),
		.tlast		  (tlast		),
		.wr_ptr		  (wr_ptr		),
		.ready		  (ready		)	
	);

	// Instantiation of Axi Bus Interface S00_AXIS
	axi_stream2lite_interface_v1_0_S00_AXIS # ( 
		.C_S_AXIS_TDATA_WIDTH(C_S00_AXIS_TDATA_WIDTH)
	) axi_stream2lite_interface_v1_0_S00_AXIS_inst (
		.S_AXIS_ACLK   (s00_axis_aclk   ),
		.S_AXIS_ARESETN(s00_axis_aresetn),
		.S_AXIS_TREADY (s00_axis_tready ),
		.S_AXIS_TDATA  (s00_axis_tdata  ),
		// .S_AXIS_TSTRB  (s00_axis_tstrb  ),
		.S_AXIS_TLAST  (s00_axis_tlast  ),
		.S_AXIS_TVALID (s00_axis_tvalid ),

		// Interconnect signals
		.incoming_data(incoming_data),
		.tvalid		  (tvalid		),
		.tlast		  (tlast		),
		.wr_ptr		  (wr_ptr		),
		.ready		  (ready		)
	);

endmodule