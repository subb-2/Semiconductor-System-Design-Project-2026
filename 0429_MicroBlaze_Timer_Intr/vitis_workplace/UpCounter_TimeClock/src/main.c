#include "ap/ap_main.h"
#include "xparameters.h"

int main()
{
	//ap 초기화
	ap_init();

	while(1) {
		//ap 실행
		ap_excute();

		//char str[30] = {"Watch"};
		//xil_printf("str : %s\n", str);
		//xil_printf(" a(%d) + b(%d) = %d\n", a, b, sum);
	}

	return 0;
}
