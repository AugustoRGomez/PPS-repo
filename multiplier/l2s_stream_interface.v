/* AXI-Stream master interface, AXI-Lite to AXI-Stream adapter submodule HDL code */
`timescale 1 ns / 1 ps

	module axi_lite2stream_interface2_v1_0_M00_AXIS #
	(
		// Width of S_AXIS address bus.
		parameter integer C_M_AXIS_TDATA_WIDTH	= 32,
		// Number of clock cycles the master will wait before initiating any transaction.
		parameter integer C_M_START_COUNT	= 32
	)
	(
		// Interconnection ports
		input  wire [C_M_AXIS_TDATA_WIDTH - 1 : 0]      data0, data1, data2, data3,
		input  wire 							        start,
		input  wire [3-1: 0] 					        word ,
		output wire 							        busy ,

		// AXI-Stream ports
		input  wire                                     M_AXIS_ACLK,
		input  wire                                     M_AXIS_ARESETN,
		output wire                                     M_AXIS_TVALID,
		output wire [C_M_AXIS_TDATA_WIDTH-1 : 0]        M_AXIS_TDATA,
		output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0]    M_AXIS_TSTRB,
		output wire                                     M_AXIS_TLAST,
		input  wire                                     M_AXIS_TREADY
	);

	// Total number of output data                                                 
	localparam NUMBER_OF_OUTPUT_WORDS = 4;                                               
	                                                                                     
	// Aux function log2                                       
	function integer clogb2 (input integer bit_depth);                                   
	  begin                                                                              
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                                      
	      bit_depth = bit_depth >> 1;                                                    
	  end                                                                                
	endfunction                                                                          
	                                                                                     
	// Width of the wait counter.                                 
	localparam integer WAIT_COUNT_BITS = clogb2(C_M_START_COUNT-1);                      
	                                                                                     
	// Minimum number of bits needed to address 'depth' size of FIFO.  
	localparam bit_num  = clogb2(NUMBER_OF_OUTPUT_WORDS);                                
	                                                                                     
	// States of state machine                                                
	parameter [1:0] IDLE          = 2'b00;   // initial/idle state                                                    
	parameter [1:0] INIT_COUNTER  = 2'b01;   // initializes the counter, once   
	                                         // the counter reaches C_M_START_COUNT count,        
	                                         // the state machine changes state to SEND_STREAM     
	parameter [1:0] SEND_STREAM   = 2'b10;   // stream data is output through M_AXIS_TDATA   

	// State variable                                                                    
	reg [1:0] mst_exec_state;                                                            
	// FIFO read pointer                                                  
	reg [bit_num-1:0] read_pointer;                                                      

	// AXI Stream internal signals
	reg [WAIT_COUNT_BITS-1 : 0] 	    count;
	reg  	                            axis_tvalid;
	wire  	                            axis_tlast;
	reg [C_M_AXIS_TDATA_WIDTH-1 : 0] 	stream_data_out;

	wire  	tx_en;

	// I/O Connections assignments
	assign M_AXIS_TVALID = axis_tvalid; 
	assign M_AXIS_TDATA	 = stream_data_out;   
	assign M_AXIS_TLAST	 = axis_tlast;  
	assign M_AXIS_TSTRB	 = {(C_M_AXIS_TDATA_WIDTH/8){1'b1}};

	// Control state machine implementation                             
	always @(posedge M_AXIS_ACLK)                                             
	begin                                                                     
	  if (!M_AXIS_ARESETN)                                                    
	  // Synchronous reset (active low)                                       
	    begin                                                                 
	      mst_exec_state <= IDLE;                                             
	      count    		 <= 0;                                                      
	    end                                                                   
	  else                                                                    
	    case (mst_exec_state)                                                 
	      IDLE:                                                                                                                                                     
	        mst_exec_state  <= (start)? INIT_COUNTER: IDLE;
                                                                                                                        
	      INIT_COUNTER:                                                                                    
	        if ( count == C_M_START_COUNT - 1 )                               
	          begin                                                           
	            mst_exec_state  <= SEND_STREAM;                               
	          end                                                             
	        else                                                              
	          begin                                                           
	            count <= count + 1;                                           
	            mst_exec_state  <= INIT_COUNTER;                              
	          end                                                             
	                                                                          
	      SEND_STREAM:                                                                               
	        if (axis_tlast && M_AXIS_TREADY)                                                      
	          begin                                                           
	            mst_exec_state <= IDLE;                                       
	          end                                                             
	        else                                                              
	          begin                                                           
	            mst_exec_state <= SEND_STREAM;                                
	          end                                                             
	    endcase                                                               
	end                                                                       

	// AXI tlast generation                                                                                                                             
	assign axis_tlast = (mst_exec_state == SEND_STREAM) && (read_pointer == word);                                
	                                                                                                                                                                                  
	//read_pointer pointer
	always@(posedge M_AXIS_ACLK)                                               
	begin                                                                            
		if(!M_AXIS_ARESETN)                                                            
		begin                                                                        
	      read_pointer <= 0;                                                            
		  axis_tvalid  <= 1'b0;                                                    
		end                                                                          
		else if (tx_en)   
		begin   
			if (M_AXIS_TREADY)
			begin
				if (read_pointer <= word-1)                                                                                                                     									  
					axis_tvalid  <= 1'b1;                                                                                                               
				else if (read_pointer == word)
					axis_tvalid  <= 1'b0;
				read_pointer 	 <= (axis_tlast)? 1'b0: read_pointer + 1;
			end 
		end                                                          
	end                                                                              

	//FIFO read enable generation 
	assign tx_en = (mst_exec_state == SEND_STREAM);     

    // Streaming output data is read from FIFO       
    always @( posedge M_AXIS_ACLK )                  
    begin                                            
        if(!M_AXIS_ARESETN)                            
        begin                                        
            stream_data_out <= 0;                    
        end                                          
        else if (M_AXIS_TREADY && tx_en && ~axis_tlast)
        begin                                        
            case (read_pointer)
            3'd0:    stream_data_out <= data0; 
            3'd1:    stream_data_out <= data1;
            3'd2:    stream_data_out <= data2;
            3'd3:    stream_data_out <= data3;
            default: stream_data_out <= stream_data_out;
            endcase
        end      
        else
            stream_data_out <= stream_data_out;                                 
    end                                              

	// Busy signal generation
	assign busy = (mst_exec_state == SEND_STREAM);

endmodule
