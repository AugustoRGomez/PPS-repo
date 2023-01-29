
/* AXI-Lite to AXI-Stream adapter IP HDL code */
`timescale 1 ns / 1 ps

	module axi_lite2stream_interface #
	(
		// Parameters of Axi Slave Bus Interface
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 5,

		// Parameters of Axi Master Bus Interface
		parameter integer C_M00_AXIS_TDATA_WIDTH	= 32,
		parameter integer C_M00_AXIS_START_COUNT	= 32
	)
	(
		// AXIS multiplier ports
        output wire          mul_en,
        output wire [8-1: 0] mul_mult_const,
		
		// Ports of Axi Slave Bus Interface
		input  wire  									s00_axi_aclk,
		input  wire  									s00_axi_aresetn,
		input  wire [C_S00_AXI_ADDR_WIDTH-1 : 0] 		s00_axi_awaddr,
		input  wire [2 : 0] 							s00_axi_awprot,
		input  wire  									s00_axi_awvalid,
		output wire  									s00_axi_awready,
		input  wire [C_S00_AXI_DATA_WIDTH-1 : 0] 		s00_axi_wdata,
		input  wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] 	s00_axi_wstrb,
		input  wire  									s00_axi_wvalid,
		output wire  									s00_axi_wready,
		output wire [1 : 0] 							s00_axi_bresp,
		output wire  									s00_axi_bvalid,
		input  wire  									s00_axi_bready,
		input  wire [C_S00_AXI_ADDR_WIDTH-1 : 0] 		s00_axi_araddr,
		input  wire [2 : 0] 							s00_axi_arprot,
		input  wire  									s00_axi_arvalid,
		output wire  									s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] 		s00_axi_rdata,
		output wire [1 : 0] 							s00_axi_rresp,
		output wire  									s00_axi_rvalid,
		input  wire  									s00_axi_rready,

		// Ports of Axi Master Bus Interface
		input  wire  									m00_axis_aclk,
		input  wire  									m00_axis_aresetn,
		output wire  									m00_axis_tvalid,
		output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] 		m00_axis_tdata,
		output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] 	m00_axis_tstrb,
		output wire  									m00_axis_tlast,
		input  wire  									m00_axis_tready
	);
	
	// Interconnection signals
	wire [C_S00_AXI_DATA_WIDTH - 1 : 0] data0, data1, data2, data3;
	wire 								start;
	wire [3-1: 0] 						word;
	wire 								busy;
	
	
// Instantiation of Axi Bus Slave Interface
	axi_lite2stream_interface2_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) axi_lite2stream_interface2_v1_0_S00_AXI_inst (
		.S_AXI_ACLK   (s00_axi_aclk	  ),
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
		
		// Interconnection signals
		.data0(data0),
		.data1(data1),
		.data2(data2),
		.data3(data3),
		.start(start),
		.word (word ),
		.busy (busy ),
		
		// Multiplier signals
		.mult_const (mul_mult_const),
		.en         (mul_en        )
	);

// Instantiation of Axis Bus Master Interface 
	axi_lite2stream_interface2_v1_0_M00_AXIS # ( 
		.C_M_AXIS_TDATA_WIDTH(C_M00_AXIS_TDATA_WIDTH),
		.C_M_START_COUNT(C_M00_AXIS_START_COUNT)
	) axi_lite2stream_interface2_v1_0_M00_AXIS_inst (
		.M_AXIS_ACLK   (m00_axis_aclk   ),
		.M_AXIS_ARESETN(m00_axis_aresetn),
		.M_AXIS_TVALID (m00_axis_tvalid ),
		.M_AXIS_TDATA  (m00_axis_tdata  ),
		.M_AXIS_TSTRB  (m00_axis_tstrb  ),
		.M_AXIS_TLAST  (m00_axis_tlast  ),
		.M_AXIS_TREADY (m00_axis_tready ),
		
		// Interconnection signals
		.data0(data0),
		.data1(data1),
		.data2(data2),
		.data3(data3),
		.start(start),
		.word (word ),
		.busy (busy )
	);

endmodule