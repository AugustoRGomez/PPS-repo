/* AXI Lite Slave interface, AXI Stream to AXI Lite adapter submodule HDL code */
`timescale 1 ns / 1 ps

	module axi_stream2lite_interface_v1_0_S00_AXI #
	(	
		// Width of S_AXI data bus
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		// Width of S_AXI address bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 5
	)
	(
		// Interconnection ports
		input  wire [C_S_AXI_DATA_WIDTH-1: 0]     incoming_data,
		input  wire 							  tvalid,
		input  wire 							  tlast,
		input  wire [2-1: 0]					  wr_ptr,	
		output wire								  ready,

		// Multiplier ports
		input	wire [C_S_AXI_DATA_WIDTH-1 : 0]   word_count,
		input	wire [C_S_AXI_DATA_WIDTH-1 : 0]   frame_count,
		
		// AXI Lite ports
		input  wire  								S_AXI_ACLK,
		input  wire  								S_AXI_ARESETN,
		input  wire [C_S_AXI_ADDR_WIDTH-1 : 0] 		S_AXI_AWADDR,
		input  wire [2 : 0] 						S_AXI_AWPROT,
		input  wire  								S_AXI_AWVALID,
		output wire  								S_AXI_AWREADY,
		input  wire [C_S_AXI_DATA_WIDTH-1 : 0] 		S_AXI_WDATA,
		input  wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] 	S_AXI_WSTRB,
		input  wire 								S_AXI_WVALID,
		output wire 								S_AXI_WREADY,
		output wire [1 : 0] 						S_AXI_BRESP,
		output wire  								S_AXI_BVALID,
		input  wire  								S_AXI_BREADY,
		input  wire [C_S_AXI_ADDR_WIDTH-1 : 0] 		S_AXI_ARADDR,
		input  wire [2 : 0] 						S_AXI_ARPROT,
		input  wire  								S_AXI_ARVALID,
		output wire  								S_AXI_ARREADY,
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] 		S_AXI_RDATA,
		output wire [1 : 0] 						S_AXI_RRESP,
		output wire  								S_AXI_RVALID,
		input  wire  								S_AXI_RREADY
	);

	// AXI-LITE signals
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  							axi_awready;
	reg  							axi_wready;
	reg [1 : 0] 					axi_bresp;
	reg  							axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  							axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 					axi_rresp;
	reg  							axi_rvalid;

	// Address decoding localparams
	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 2;
	
	//----------------------------------------------
	//-- Register space logic
	//------------------------------------------------
	reg [C_S_AXI_DATA_WIDTH-1:0]	ctrl_reg;
	reg [C_S_AXI_DATA_WIDTH-1:0]	word_reg;
	reg [C_S_AXI_DATA_WIDTH-1:0]	frame_reg;
	reg [C_S_AXI_DATA_WIDTH-1:0]	data_reg0;
	reg [C_S_AXI_DATA_WIDTH-1:0]	data_reg1;
	reg [C_S_AXI_DATA_WIDTH-1:0]	data_reg2;
	reg [C_S_AXI_DATA_WIDTH-1:0]	data_reg3;
	wire	 						slv_reg_rden;
	wire	 						slv_reg_wren;
	reg [C_S_AXI_DATA_WIDTH-1:0]	reg_data_out;
	integer	 						byte_index;
	reg	 							aw_en;

	// I/O Connections assignments
	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY		= axi_wready;
	assign S_AXI_BRESP		= axi_bresp;
	assign S_AXI_BVALID		= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RDATA		= axi_rdata;
	assign S_AXI_RRESP		= axi_rresp;
	assign S_AXI_RVALID		= axi_rvalid;
	
	// Implement axi_awready generation
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awready <= 1'b0;
	      aw_en <= 1'b1;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
	        begin
	          axi_awready <= 1'b1;
	          aw_en <= 1'b0;
	        end
	        else if (S_AXI_BREADY && axi_bvalid)
	            begin
	              aw_en <= 1'b1;
	              axi_awready <= 1'b0;
	            end
	      else           
	        begin
	          axi_awready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_awaddr latching
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
	        begin
	          // Write Address latching 
	          axi_awaddr <= S_AXI_AWADDR;
	        end
	    end 
	end       

	// Implement axi_wready generation
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en )
	        begin
	          axi_wready <= 1'b1;
	        end
	      else
	        begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       

	// Implement memory mapped register select and write logic generation
	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

	// Control register update
	always @( posedge S_AXI_ACLK )
	begin
	  	if ( S_AXI_ARESETN == 1'b0 )
	    		ctrl_reg  <= 0; 
	  	else if (slv_reg_wren) 
		begin
	        if ((axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 3'h0) && S_AXI_WDATA[0])
				ctrl_reg[0] <= 1'b0; // ready bit
		end
		else if (tvalid && tlast)
				ctrl_reg[0] <= 1'b1;
	end    

	// Frame and word reg update
	always @( posedge S_AXI_ACLK )
	begin
	  	if ( S_AXI_ARESETN == 1'b0 )
		begin
	    	word_reg  <= 0;
			frame_reg <= 0; 
		end
	  	else 
		begin
			word_reg  <= word_count ;
			frame_reg <= frame_count;
		end
	end  

	// Implement write response logic generation
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid  <= 0;
	      axi_bresp   <= 2'b0;
	    end 
	  else
	    begin    
	      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
	        begin
	          // indicates a valid write response is available
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0;
	        end                  
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid) 
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	end   

	// Implement axi_arready generation
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_araddr  <= 32'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID)
	        begin
	          axi_arready <= 1'b1;
	          axi_araddr  <= S_AXI_ARADDR;
	        end
	      else
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_arvalid generation
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
	        begin
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0; // 'OKAY' response
	        end   
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          axi_rvalid <= 1'b0;
	        end                
	    end
	end    

	// Implement memory mapped register select and read logic generation
	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
	always @(*)
	begin
	      // Address decoding for reading registers
	      case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	        3'h0   :  reg_data_out <= ctrl_reg;
	        3'h1   :  reg_data_out <= word_reg;
	        3'h2   :  reg_data_out <= frame_reg;
	        3'h3   :  reg_data_out <= data_reg0;
	        3'h4   :  reg_data_out <= data_reg1;
	        3'h5   :  reg_data_out <= data_reg2;
	        3'h6   :  reg_data_out <= data_reg3;
	        default : reg_data_out <= 0;
	      endcase
	end

	// Output register or memory read data
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rdata  <= 0;
	    end 
	  else
	    begin    
	      if (slv_reg_rden)
	        begin
	          axi_rdata <= reg_data_out; 
	        end   
	    end
	end    

	// ready generation
	assign ready = ctrl_reg[0];

	// registers update
	always @(posedge S_AXI_ACLK)
	begin
	    if (!S_AXI_ARESETN)
	    begin
            data_reg0 <= 0;
            data_reg1 <= 0;
            data_reg2 <= 0;
            data_reg3 <= 0;
        end
		else if (tvalid)
		begin
			case (wr_ptr)
				2'd0: 
					data_reg0 <= incoming_data;
				2'd1: 
					data_reg1 <= incoming_data;
				2'd2:
					data_reg2 <= incoming_data;
				2'd3: 
					data_reg3 <= incoming_data;
				default: 
				begin
					data_reg0 <= data_reg0;
					data_reg1 <= data_reg1;
					data_reg2 <= data_reg2;
					data_reg3 <= data_reg3;
				end
			endcase
            
        end
	end

endmodule