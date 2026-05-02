

#include "ap_main.h"
#include "../common/common.h"
#include "UpCounter/UpCounter.h"
#include "Time/Time.h"
#include "../driver/Button/Button.h"

typedef enum {
    WATCH = 0,
    UPCOUNTER = 1
} ModeState_t;

ModeState_t curMode = WATCH;
hBtn_t hBtnMode;

void ap_init()
{
    Watch_Init();
    UpCounter_Init();

    Button_Init(&hBtnMode, GPIOA, GPIO_PIN_5);
}

void ap_excute()
{
    while(1)
    {
        if (Button_GetState(&hBtnMode) == ACT_PUSHED) {

            if (curMode == WATCH) {
                curMode = UPCOUNTER;
            } else {
                curMode = WATCH;
            }

            FND_DispAllOff();
        }

        if (curMode == WATCH) {
            Watch_Execute();
        } else if (curMode == UPCOUNTER) {
            UpCounter_Excute();
        }

        millis_inc();
        delay_ms(1);
    }
}
