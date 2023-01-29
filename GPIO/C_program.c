/*
 * AXI-GPIO test
 */

#include <stdio.h>
#include "platform.h"
#include "sleep.h"
#include "xgpio.h"

// Pointers declaration
uint32_t *led_ptr = (uint32_t*) XPAR_AXI_GPIO_0_BASEADDR;
uint32_t *sw_ptr = (uint32_t*) XPAR_AXI_GPIO_1_BASEADDR;

// GPIO struct instances
XGpio my_gpio, my_gpio_2;

int main()
{
    init_platform();

    // Init GPIO struct intances
    XGpio_Initialize(&my_gpio, XPAR_GPIO_0_DEVICE_ID);
    XGpio_Initialize(&my_gpio_2, XPAR_GPIO_1_DEVICE_ID);

    uint32_t value;

    while (1) {
            /*
            *   -Read value from Switches, then wait 1 sec
            *   -Write value in LEDs, then wait 1 sec
            */
            value = XGpio_DiscreteRead(&my_gpio_2, 1U);
            XGpio_DiscreteWrite(&my_gpio, 1U, value);
            sleep(1);
            XGpio_DiscreteWrite(&my_gpio, 1U, 0x0);
            sleep(1);
        }

    return 0;
}