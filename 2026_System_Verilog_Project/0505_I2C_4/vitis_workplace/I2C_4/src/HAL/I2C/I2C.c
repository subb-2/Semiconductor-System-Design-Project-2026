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

    // 1. done_real이 1이 될 때까지 대기
    while (!(I2Cx->RX_STATUS & (1 << 10))) {
        if (++timeout > 1000000) {
            xil_printf("[ERROR] Timeout!\r\n");
            break;
        }
    }

    // 2. COMMAND 클리어 → done_real도 클리어됨
    I2Cx->COMMAND = 0x00;

    // 3. ★ done_real이 확실히 0이 될 때까지 대기
    timeout = 0;
    while (I2Cx->RX_STATUS & (1 << 10)) {
        if (++timeout > 100000) break;
    }

    for (volatile int i = 0; i < 100; i++);
}

// CMD 함수들: COMMAND 세팅만, 클리어는 Wait_Done 후 다음 명령이 알아서 함
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
    for(volatile int i=0; i<50; i++);
}

void I2C_CMD_STOP(I2C_Typedef_t *I2Cx) {
    I2Cx->COMMAND = (1 << I2C_CMD_STOP_BIT);
    I2C_Wait_Done(I2Cx);
    I2Cx->COMMAND = 0x00;
    for(volatile int i=0; i<50; i++);
}

uint8_t I2C_Read_Data(I2C_Typedef_t *I2Cx, uint8_t ack) {
    I2Cx->TX_REG = (ack == 1) ? I2C_ACK_IN_BIT : 0x00;
    I2Cx->COMMAND = (1 << I2C_CMD_READ_BIT);

    // done 대기
    uint32_t timeout = 0;
    while (!(I2Cx->RX_STATUS & (1 << 10))) {
        if (++timeout > 1000000) {
            xil_printf("[ERROR] Read Timeout!\r\n");
            return 0xFF;
        }
    }

    // done=1인 상태에서 먼저 읽고
    uint8_t rx = (uint8_t)(I2Cx->RX_STATUS & 0xFF);

    // 그 다음 클리어
    I2Cx->COMMAND = 0x00;
    for (volatile int i = 0; i < 100; i++);

    return rx;
}
