/* AXI multiplier test C program */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "axi_lite2stream_interface2.h"
#include "axi_stream2lite_interface.h"
#include "xil_io.h"

/***************** REGISTER DEFINES ***********************/
#define L2S_CTRL  (AXI_LITE2STREAM_INTERFACE2_S00_AXI_SLV_REG0_OFFSET + XPAR_AXI_LITE2STREAM_INTE_0_S00_AXI_BASEADDR)
#define L2S_DATA0 (AXI_LITE2STREAM_INTERFACE2_S00_AXI_SLV_REG1_OFFSET + XPAR_AXI_LITE2STREAM_INTE_0_S00_AXI_BASEADDR)
#define L2S_DATA1 (AXI_LITE2STREAM_INTERFACE2_S00_AXI_SLV_REG2_OFFSET + XPAR_AXI_LITE2STREAM_INTE_0_S00_AXI_BASEADDR)
#define L2S_DATA2 (AXI_LITE2STREAM_INTERFACE2_S00_AXI_SLV_REG3_OFFSET + XPAR_AXI_LITE2STREAM_INTE_0_S00_AXI_BASEADDR)
#define L2S_DATA3 (AXI_LITE2STREAM_INTERFACE2_S00_AXI_SLV_REG4_OFFSET + XPAR_AXI_LITE2STREAM_INTE_0_S00_AXI_BASEADDR)

#define S2L_CTRL  (AXI_STREAM2LITE_INTERFACE_S00_AXI_SLV_REG0_OFFSET + XPAR_AXI_STREAM2LITE_INTE_0_S00_AXI_BASEADDR)
#define S2L_WORD  (AXI_STREAM2LITE_INTERFACE_S00_AXI_SLV_REG1_OFFSET + XPAR_AXI_STREAM2LITE_INTE_0_S00_AXI_BASEADDR)
#define S2L_FRAME (AXI_STREAM2LITE_INTERFACE_S00_AXI_SLV_REG2_OFFSET + XPAR_AXI_STREAM2LITE_INTE_0_S00_AXI_BASEADDR)
#define S2L_DATA0 (AXI_STREAM2LITE_INTERFACE_S00_AXI_SLV_REG3_OFFSET + XPAR_AXI_STREAM2LITE_INTE_0_S00_AXI_BASEADDR)
#define S2L_DATA1 (AXI_STREAM2LITE_INTERFACE_S00_AXI_SLV_REG4_OFFSET + XPAR_AXI_STREAM2LITE_INTE_0_S00_AXI_BASEADDR)
#define S2L_DATA2 (AXI_STREAM2LITE_INTERFACE_S00_AXI_SLV_REG5_OFFSET + XPAR_AXI_STREAM2LITE_INTE_0_S00_AXI_BASEADDR)
#define S2L_DATA3 (AXI_STREAM2LITE_INTERFACE_S00_AXI_SLV_REG6_OFFSET + XPAR_AXI_STREAM2LITE_INTE_0_S00_AXI_BASEADDR)

// Pointer declaration
uint32_t *l2s_ptr;
uint32_t *s2l_ready = (uint32_t *) S2L_CTRL;

// Variables declaration
uint32_t d0, d1, d2, d3;

int main()
{
	init_platform();

    // ** Multiply 4 words frame (1,2,3,4) by 5 **
    Xil_Out32(L2S_CTRL, 0xC05); // MULT_CONST = 5, WORD = 4, EN = 1
    Xil_Out32(L2S_DATA0, 0x1);
    Xil_Out32(L2S_DATA1, 0x2);
    Xil_Out32(L2S_DATA2, 0x3);
    Xil_Out32(L2S_DATA3, 0x4);

    // Wait for ready bit
    while (!(*s2l_ready));

	d0 = Xil_In32(S2L_DATA0);
	d1 = Xil_In32(S2L_DATA1);
	d2 = Xil_In32(S2L_DATA2);
	d3 = Xil_In32(S2L_DATA3);

	xil_printf("Frame_1 = %d, %d, %d, %d", d0, d1, d2, d3);

	*s2l_ready = 1;

	// ** Multiply 3 words frame (5,6,7) by 2 **
	Xil_Out32(L2S_CTRL, 0xB02); // MULT_CONST = 2, WORD = 3, EN = 1
	Xil_Out32(L2S_DATA0, 0x5);
	Xil_Out32(L2S_DATA1, 0x6);
	Xil_Out32(L2S_DATA2, 0x7);

	// Wait for ready bit
	while (!(*s2l_ready));

	d0 = Xil_In32(S2L_DATA0);
	d1 = Xil_In32(S2L_DATA1);
	d2 = Xil_In32(S2L_DATA2);

	xil_printf("\nFrame_2 = %d, %d, %d", d0, d1, d2);

	*s2l_ready = 1;

	// ** Read Frame and Word count registers **
	xil_printf("\nWords = %d\nFrames = %d", Xil_In32(S2L_WORD), Xil_In32(S2L_FRAME));

    cleanup_platform();
    return 0;
}