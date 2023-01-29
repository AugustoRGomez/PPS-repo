/* AXI Shift register test program */
#include <stdio.h>
#include <stdint.h>
#include <sleep.h>
#include "xil_printf.h"

// Pointers declaration
uint32_t *shift_reg_in;
uint32_t *shift_reg_out;

int main()
{
    // Pointer to CTRL reg
    shift_reg_in = (uint32_t *) XPAR_AXI_SR_0_S00_AXI_BASEADDR;
    // Pointer to STATUS reg
    shift_reg_out = (uint32_t *) (XPAR_AXI_SR_0_S00_AXI_BASEADDR) + 3;

    *shift_reg_in = 0x7         // DIR = 1, DIN = 1, EN = 1

	while(1) {	
		// *** Shift left ***
		*shift_reg_in = 0x5;		// DIR = 1, DIN = 1, EN = 1
		sleep(1);
		*shift_reg_in = 0x5;		// DIR = 1, DIN = 0, EN = 1
		sleep(1);
		*shift_reg_in = 0x5;		// DIR = 1, DIN = 0, EN = 1
		sleep(1);
		
		// Read State reg
		xil_printf("Data: 0x%X\n", (unsigned int)(*shift_reg_out));

		// *** Shift right ***
		*shift_reg_in = 0x1;		// DIR = 0, DIN = 0, EN = 1
		sleep(1);
		*shift_reg_in = 0x1;		// DIR = 0, DIN = 0, EN = 1
		sleep(1);
		*shift_reg_in = 0x1;		// DIR = 0, DIN = 1, EN = 1
		sleep(1)

		// Read shift register data
		xil_printf("Data: 0x%X\n", (unsigned int)(*shift_reg_out));
	}

	return 0;
}