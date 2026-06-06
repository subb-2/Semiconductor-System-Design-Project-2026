/*
 * SW.c
 *
 *  Created on: 2026. 5. 4.
 *      Author: kccistc
 */


#include "SW.h"

#include "../../HAL/GPIO/GPIO.h"

#define SW_PORT  GPIOB


void SW_Init() {
    GPIO_SetMode(SW_PORT,
            SW_PIN_0 | SW_PIN_1 | SW_PIN_2 | SW_PIN_3 | SW_PIN_4
                    | SW_PIN_5 | SW_PIN_6 | SW_PIN_7, INPUT);
}

uint8_t SW_ReadData(GPIO_Typedef_t *SW_Port) {
    return (uint8_t)GPIO_ReadPort(SW_Port);
}
