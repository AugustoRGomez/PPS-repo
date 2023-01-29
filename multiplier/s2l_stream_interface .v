/* AXI-Stream slave interface, AXI-Stream to AXI-Lite adapter submodule HDL code */
`timescale 1 ns / 1 ps

	module axi_stream2lite_interface_v1_0_S00_AXIS #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// AXI4Stream sink: Data Width
		parameter integer C_S_AXIS_TDATA_WIDTH	= 32
	)
	(
		// Interconnection ports
		output wire [C_S_AXIS_TDATA_WIDTH-1: 0] incoming_data,
		output wire 							tvalid,
		output wire 							tlast,	
		output wire [2-1: 0] 					wr_ptr,
		input  wire								ready,
	
		// AXI-Stream ports
		input wire  S_AXIS_ACLK,
		input wire  S_AXIS_ARESETN,
		output wire S_AXIS_TREADY,
		input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA,
		input wire  S_AXIS_TLAST,
		input wire  S_AXIS_TVALID
	);

	// Aux funcion log2
	function integer clogb2 (input integer bit_depth);
	  begin
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
	      bit_depth = bit_depth >> 1;
	  end
	endfunction

	// Total number of input data.
	localparam NUMBER_OF_INPUT_WORDS  = 4;
	localparam bit_num  = clogb2(NUMBER_OF_INPUT_WORDS-1);

	// States of state machine
	parameter [1:0] IDLE 		= 2'b00;
	parameter [1:0] WRITE_FIFO  = 2'b01; 		                            		
	parameter [1:0] BUSY 		= 2'b10;

	// State variable	
	reg 	[2-1: 0] 		mst_exec_state;  
	// Write pointer
	reg	 	[bit_num-1:0] 	write_pointer;
	
	wire 					fifo_wren;
	wire  					axis_tready;
	genvar 					byte_index;     

	// I/O Assigment
	assign S_AXIS_TREADY	= axis_tready;

	// Control state machine implementation
	always @(posedge S_AXIS_ACLK) 
	begin  
	  if (!S_AXIS_ARESETN) 
	  // Synchronous reset (active low)
	    begin
	      mst_exec_state <= IDLE;
	    end  
	  else
	    case (mst_exec_state)
	      IDLE: 
	        if (S_AXIS_TVALID)
	        begin
	            mst_exec_state <= WRITE_FIFO;
	        end
	        else
	        begin
	            mst_exec_state <= IDLE;
	        end
	      WRITE_FIFO: 
	        if (ready)
	        begin
	            mst_exec_state <= BUSY;
	        end
	        else
	        begin
	        	mst_exec_state <= WRITE_FIFO;
	        end
		  BUSY:
		  	if(!ready)
				mst_exec_state <= IDLE;
	    endcase
	end

	// AXI Stream tready generation
	assign axis_tready = ((mst_exec_state == WRITE_FIFO) && (write_pointer <= NUMBER_OF_INPUT_WORDS-1));

	always@(posedge S_AXIS_ACLK)
	begin
	  if(!S_AXIS_ARESETN)
	    write_pointer <= 0; 
	  else
		if (fifo_wren)
		begin
			// write pointer is incremented after every write to the FIFO
			// when FIFO write signal is enabled.
			if (S_AXIS_TLAST)
				write_pointer <= 0;
			else
				write_pointer <= write_pointer + 1;
		end
	end

	// FIFO write enable generation
	assign fifo_wren = S_AXIS_TVALID && axis_tready;

	// Interconnection signal generation
	assign incoming_data = S_AXIS_TDATA ;
	assign tvalid		 = fifo_wren    ;
	assign tlast		 = S_AXIS_TLAST ;
	assign wr_ptr		 = write_pointer;	

endmodule
