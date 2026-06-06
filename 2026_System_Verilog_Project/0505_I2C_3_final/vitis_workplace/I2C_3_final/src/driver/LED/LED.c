/*
 * LED.c
 *
 *  Created on: 2026. 4. 30.
 *      Author: kccistc
 */

#include "LED.h"
#include "../../HAL/GPIO/GPIO.h"
#include "../../common/common.h"

round_stat_t round_state_counter = round1;
round_stat_t round_state_clock = round1;

void LED_Init() {
	GPIO_SetMode(LED_PORT,
			LED_PIN_0 | LED_PIN_1 | LED_PIN_2 | LED_PIN_3 | LED_PIN_4
					| LED_PIN_5 | LED_PIN_6 | LED_PIN_7, OUTPUT);
}

void LED_SetPort(GPIO_Typedef_t *LED_Port, uint32_t LED_Pin, int OnOff) {
	GPIO_WritePin(LED_Port, LED_Pin, OnOff);
}

void LED_Count_Mode_ON() {
	LED_SetPort(LED_PORT, LED_PIN_0, ON);
}
void LED_Count_Mode_OFF() {
	LED_SetPort(LED_PORT, LED_PIN_0, OFF);
}
void LED_Clock_Mode_ON() {
	LED_SetPort(LED_PORT, LED_PIN_1, ON);
}
void LED_Clock_Mode_OFF() {
	LED_SetPort(LED_PORT, LED_PIN_1, OFF);
}

void LED_Clock_FND_HM() {
	LED_SetPort(LED_PORT, LED_PIN_2, ON);
	LED_SetPort(LED_PORT, LED_PIN_3, OFF);
}
void LED_Clock_FND_SMS() {
	LED_SetPort(LED_PORT, LED_PIN_3, ON);
	LED_SetPort(LED_PORT, LED_PIN_2, OFF);
}

int LED_Delay_Counter() {
	static uint32_t prevTime = 0;
	if (millis() - prevTime <= 100 - 1) {
		return 0;
	}
	prevTime = millis();
	return 1;
}
int LED_Delay_Clock() {
	static uint32_t prevTime = 0;
	if (millis() - prevTime <= 100 - 1) {
		return 0;
	}
	prevTime = millis();
	return 1;
}
void LED_Round_UpCounter() {
	switch (round_state_counter) {
	case round1:
		LED_SetPort(LED_PORT, LED_PIN_4, OFF);
		if (LED_Delay_Counter() == 1) {
			LED_SetPort(LED_PORT, LED_PIN_4, ON);
			round_state_counter = round2;
		}
		break;
	case round2:
		LED_SetPort(LED_PORT, LED_PIN_5, OFF);
		if (LED_Delay_Counter() == 1) {
			LED_SetPort(LED_PORT, LED_PIN_5, ON);
			round_state_counter = round3;
		}
		break;
	case round3:
		LED_SetPort(LED_PORT, LED_PIN_6, OFF);
		if (LED_Delay_Counter() == 1) {
			LED_SetPort(LED_PORT, LED_PIN_6, ON);
			round_state_counter = round4;
		}
		break;
	case round4:
		LED_SetPort(LED_PORT, LED_PIN_7, OFF);
		if (LED_Delay_Counter() == 1) {
			LED_SetPort(LED_PORT, LED_PIN_7, ON);
			round_state_counter = round1;
		}
		break;
	}
}

void LED_Round_Clock() {
	switch (round_state_clock) {
	case round1:
		LED_SetPort(LED_PORT, LED_PIN_7, OFF);
		if (LED_Delay_Clock() == 1) {
			LED_SetPort(LED_PORT, LED_PIN_7, ON);
			round_state_clock = round2;
		}
		break;
	case round2:
		LED_SetPort(LED_PORT, LED_PIN_6, OFF);
		if (LED_Delay_Clock() == 1) {
			LED_SetPort(LED_PORT, LED_PIN_6, ON);
			round_state_clock = round3;
		}
		break;
	case round3:
		LED_SetPort(LED_PORT, LED_PIN_5, OFF);
		if (LED_Delay_Clock() == 1) {
			LED_SetPort(LED_PORT, LED_PIN_5, ON);
			round_state_clock = round4;
		}
		break;
	case round4:
		LED_SetPort(LED_PORT, LED_PIN_4, OFF);
		if (LED_Delay_Clock() == 1) {
			LED_SetPort(LED_PORT, LED_PIN_4, ON);
			round_state_clock = round1;
		}
		break;
	}
}

