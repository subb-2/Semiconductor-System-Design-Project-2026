
#include "Time.h"
#include <stdio.h>

Wath_State_t w_state = {0, 0, 0, 0};


void Watch_Init()
{
	FND_Init();
    w_state.hour = 0;
    w_state.min = 0;
    w_state.sec = 0;
    w_state.msec = 0;
}

void Watch_Execute()
{
    Watch_DispLoop();
    Watch_Run();
}

void Watch_DispLoop()
{
    FND_Digit();
}

void Watch_Run()
{
    static uint32_t WatchCounter = 0;


    if (millis() - WatchCounter < 10) {
        return;
    }
    WatchCounter = millis();

    w_state.msec++;

    if (w_state.msec >= 100) {
        w_state.msec = 0;
        w_state.sec++;

        if (w_state.sec >= 60) {
            w_state.sec = 0;
            w_state.min++;

            if (w_state.min >= 60) {
                w_state.min = 0;
                w_state.hour++;

                if (w_state.hour >= 24) {
                    w_state.hour = 0;
                }
            }
        }
        printf("%02d:%02d:%02d\r\n", w_state.hour, w_state.min, w_state.sec);
    }


    uint16_t FNDData = (w_state.min * 100) + w_state.sec;
    FND_SetNum(FNDData);


    if (w_state.msec < 50) {
    	FND_DP_ON();
    } else {
    	FND_DP_OFF();
    }
}
