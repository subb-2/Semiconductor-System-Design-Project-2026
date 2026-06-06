/*
 * SPI.c
 *
 *  Created on: 2026. 5. 4.
 *      Author: kccistc
 */

#include "SPI.h"

void SPI_SetCR(SPI_Typedef_t *SPIx, uint8_t clk_div, uint8_t cpol, uint8_t cpha)
{
	SPIx->CR = clk_div | (cpol << 8) | (cpha << 9);
}

void SPI_Start(SPI_Typedef_t *SPIx, uint8_t start)
{
	if(start == 1) SPIx->CR |= (1 << 10);
	else if (start == 0) SPIx->CR &= ~(1 << 10);
}

void SPI_SetTX(SPI_Typedef_t *SPIx, uint8_t tx_data)
{
	SPIx->TX = tx_data;
}
uint8_t SPI_GetRX_Data(SPI_Typedef_t *SPIx)
{
	return (uint8_t)(SPIx->RX & 0xFF);
}
uint8_t SPI_GetRX_Busy(SPI_Typedef_t *SPIx)
{
	if (SPIx->RX & (1 << 8)) return 1;
	else return 0;
}
uint8_t SPI_GetRX_Done(SPI_Typedef_t *SPIx)
{
	if (SPIx->RX & (1 << 9)) return 1;
	else return 0;
}
