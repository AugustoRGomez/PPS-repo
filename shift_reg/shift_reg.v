/* Shift register IP HDL code */
`timescale 1ns / 1ps

module shift_register
    (
        input  wire       clk, rst_n,
        input  wire       dir, din, en,
        output wire [3:0] q
    );
    
    // Shift-reg internal signals
    reg [3:0] sreg_cv, sreg_nv;
    
    // Sequential behaviour implementation, with low active reset
    always @(posedge clk)
    begin
        if (!rst_n)
            sreg_cv <= 0;
        else
            sreg_cv <= sreg_nv;
    end
    
    // Shifting behaviour implementation
    always @(*)
    begin
        sreg_nv = sreg_cv;
        if (en)
            // Shifting direction based on dir value
            if (!dir)
                sreg_nv = {sreg_cv[2:0], din}; 
            else
                sreg_nv = {din, sreg_cv[3:1]};
    end
    
    assign q = sreg_cv;

endmodule