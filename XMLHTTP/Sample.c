#include "xmlhttp.h"

VOID WINAPI Main(VOID)
{
	HANDLE hHttp = HttpCreate();
	LPSTR lpStr = HttpPost(hHttp,TEXT("http://google.com"),NULL,0);
	MessageBoxA(0, lpStr, 0, 0);
	lpStr = HttpConvert(hHttp, lpStr, CP_UTF8, CP_ACP);
	MessageBoxA(0, lpStr, 0, 0);
	HttpDestroy(hHttp);
	ExitProcess(0);
}