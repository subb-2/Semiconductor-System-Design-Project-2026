/*
 * TMR.c
 *
 *  Created on: 2026. 4. 29.
 *      Author: kccistc
 */

#include "TMR.h"

void TMR_SetPSC(TMR_Typedef_f *TMRx, uint32_t psc) {
	//timer 몇 번인지 알려줘야 하니까
	TMRx->PSC = psc;
}

void TMR_SetARR(TMR_Typedef_f *TMRx, uint32_t arr) {
	TMRx->ARR = arr;
}

void TMR_StartIntr(TMR_Typedef_f *TMRx) {
	TMRx->CR |= 1 << TMR_INTR_BIT;
}

void TMR_StopIntr(TMR_Typedef_f *TMRx) {
	TMRx->CR &= ~(1 << TMR_INTR_BIT);
}

void TMR_StartTimer(TMR_Typedef_f *TMRx) {
	TMRx->CR |= 1 << TMR_ENABLE_BIT;
}

void TMR_StopTimer(TMR_Typedef_f *TMRx) {
	TMRx->CR &= ~(1 << TMR_ENABLE_BIT);
}

void TMR_ClearTimer(TMR_Typedef_f *TMRx) {
	//clear는 1해주고 다시 0으로 만들어줘야 함
	TMRx->CR |= 1 << TMR_CLEAR_BIT;
	TMRx->CR &= ~(1 << TMR_CLEAR_BIT);
}
