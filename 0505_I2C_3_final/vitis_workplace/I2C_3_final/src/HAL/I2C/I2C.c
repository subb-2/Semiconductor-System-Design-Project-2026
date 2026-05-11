/*
 * I2C.c
 *
 *  Created on: 2026. 5. 4.
 *      Author: kccistc
 */
#include "xil_printf.h"
#include "I2C.h"
#include "../../common/common.h"
// I2C.c

void I2C_Wait_Done(I2C_Typedef_t *I2Cx) {
    uint32_t timeout = 0;

    while (!(I2Cx->RX_STATUS & (1 << 10))) {
        if (++timeout > 1000000) {
            xil_printf("[ERROR] Timeout!\r\n");
            break;
        }
    }

}



void I2C_CMD_START(I2C_Typedef_t *I2Cx) {
    I2Cx->COMMAND = (1 << I2C_CMD_START_BIT);
    I2C_Wait_Done(I2Cx);
    I2Cx->COMMAND = 0x00;  // done 확인 후 클리어
    for(volatile int i=0; i<50; i++);
}

void I2C_CMD_WRITE(I2C_Typedef_t *I2Cx) {
    I2Cx->COMMAND = (1 << I2C_CMD_WRITE_BIT);
    I2C_Wait_Done(I2Cx);
    I2Cx->COMMAND = 0x00;
    for(volatile int i=0; i<500; i++);
}

void I2C_CMD_STOP(I2C_Typedef_t *I2Cx) {
    I2Cx->COMMAND = (1 << I2C_CMD_STOP_BIT);
    I2C_Wait_Done(I2Cx);
    I2Cx->COMMAND = 0x00;
    for(volatile int i=0; i<50; i++);
}

uint8_t I2C_Read_Data(I2C_Typedef_t *I2Cx, uint8_t ack) {
    I2Cx->TX_REG = (ack == 1) ? I2C_ACK_IN_BIT : 0x00;

    volatile uint32_t dummy = I2Cx->TX_REG;
    (void)dummy;

    I2Cx->COMMAND = (1 << I2C_CMD_READ_BIT);

    uint32_t timeout = 0;
    while (!(I2Cx->RX_STATUS & I2C_DONE_BIT)) {
        if (++timeout > 1000000) {
            xil_printf("[ERROR] Read Timeout!\r\n");
            return 0xFF;
        }
    }
    uint8_t rx = (uint8_t)(I2Cx->RX_STATUS & 0xFF);
    I2Cx->COMMAND = 0x00;
    for (volatile int i = 0; i < 500; i++);
    return rx;
}
