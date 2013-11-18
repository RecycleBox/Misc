#ifndef _XMLHTTP_H_
#define _XMLHTTP_H_

#include <windows.h>
#include <winhttp.h>

#undef RtlMoveMemory
void WINAPI RtlMoveMemory(LPVOID,LPVOID,DWORD);

#ifndef UNICODE
#define HttpPost HttpPostA
#define HttpPostCb HttpPostCbA
#else
#define HttpPost HttpPostW
#define HttpPostCb HttpPostCbW
#endif

#define	CP_UTF16LE 1200
#define	CP_UTF16BE 1201
#define CP_UTF16 CP_UTF16LE

typedef VOID(WINAPI *LPHTTPCALLBACK)(
    _In_ DWORD dwDataSize
    );

HANDLE WINAPI HttpCreate(VOID);
BOOL WINAPI HttpDestroy(
    _In_    HANDLE hHeap
    );
BOOL WINAPI HttpFree(
    _In_    HANDLE hHeap,
    _In_    LPVOID lpMem
    );
LPVOID WINAPI HttpPostCbW(
    _In_    HANDLE hHeap,
    _In_    LPCWSTR lpszURL,
    _In_    LPVOID lpOptional,
    _In_    DWORD dwSize,
    _In_    LPHTTPCALLBACK lpCallback
    );
LPVOID WINAPI HttpPostCbA(
    _In_    HANDLE hHeap,
    _In_    LPCSTR lpszURL,
    _In_    LPVOID lpOptional,
    _In_    DWORD dwSize,
    _In_    LPHTTPCALLBACK lpCallback
    );
#define HttpPostW(a,b,c,d) HttpPostCbW(a,b,c,d,NULL)
#define HttpPostA(a,b,c,d) HttpPostCbA(a,b,c,d,NULL)
LPVOID WINAPI HttpConvert(
    _In_    HANDLE hHeap,
    _In_    LPVOID lpData,
    _In_    UINT  dwOriCodePage,
    _In_    UINT  dwCodePage
    );

#endif /* _XMLHTTP_H_ */