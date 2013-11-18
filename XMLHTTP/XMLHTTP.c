#include "XMLHTTP.h"

// Create a XMLHTTP object
HANDLE WINAPI HttpCreate(VOID)
{
    return HeapCreate(0, 0, 0);
}

// Release a XMLHTTP object
BOOL WINAPI HttpDestroy(
    _In_    HANDLE hHeap
    )
{
    return HeapDestroy(hHeap);
}

// Release a memory allocated by XMLHTTP. This is only useful when you
// want to send multiple requests.
BOOL WINAPI HttpFree(
    _In_    HANDLE hHeap,
    _In_    LPVOID lpMem
    )
{
    return HeapFree(hHeap, 0, lpMem);
}

// Post the request, unicode version with downloading information
LPVOID WINAPI HttpPostCbW(
    _In_    HANDLE hHeap,
    _In_    LPCWSTR lpszURL,
    _In_    LPVOID lpOptional,
    _In_    DWORD dwSize,
    _In_    LPHTTPCALLBACK lpCallback
    )
{
    LPWSTR lpData = NULL;

    // Allocate memory for WinHttpCrackUrl
    DWORD dwURLSize = (lstrlenW(lpszURL) + 2) * 4;
    LPWSTR lpszHostName = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, dwURLSize);
    if (!lpszHostName)
    {
        lpData = NULL;
        goto QuitAlloc3;
    }

    LPWSTR lpszUrlPath = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, dwURLSize);
    if (!lpszUrlPath)
    {
        lpData = NULL;
        goto QuitAlloc2;
    }

    LPWSTR lpszExtraInfo = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, dwURLSize);
    if (!lpszExtraInfo)
    {
        lpData = NULL;
        goto QuitAlloc1;
    }

    URL_COMPONENTS stURL;
    RtlZeroMemory(&stURL, sizeof(stURL));
    stURL.dwStructSize = sizeof(stURL);
    stURL.lpszHostName = lpszHostName;
    stURL.dwHostNameLength = dwURLSize;
    stURL.lpszUrlPath = lpszUrlPath;
    stURL.dwUrlPathLength = dwURLSize;
    stURL.lpszExtraInfo = lpszExtraInfo;
    stURL.dwExtraInfoLength = dwURLSize;

    if (!WinHttpCrackUrl(lpszURL, 0, ICU_ESCAPE, &stURL))
    {
        lpData = NULL;
        goto QuitAlloc0;
    }

    // Join the last two parts for WinHttpOpenRequest
    LPWSTR lpszRequest = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, (lstrlenW(stURL.lpszUrlPath) + lstrlenW(stURL.lpszExtraInfo) + 1) * 2);
    if (!lpszRequest)
    {
        lpData = NULL;
        goto Quit0;
    }
    lstrcpyW(lpszRequest, stURL.lpszUrlPath);
    lstrcatW(lpszRequest, stURL.lpszExtraInfo);
    // Create a session
    HINTERNET hSession = WinHttpOpen(NULL, WINHTTP_ACCESS_TYPE_DEFAULT_PROXY, WINHTTP_NO_PROXY_NAME, WINHTTP_NO_PROXY_BYPASS, 0);
    if (!hSession)
    {
        lpData = NULL;
        goto Quit0;
    }
    // Set timeout time
    /*
    if (!WinHttpSetTimeouts(hSession, 4000, 4000, 4000, 4000))
    {                              // DNS Connect Send Receive
        lpData = NULL;
        goto Quit1;
    }
    */
    // Connect server
    HINTERNET hConnect = WinHttpConnect(hSession, stURL.lpszHostName, INTERNET_DEFAULT_PORT, 0);
    if (!hConnect)
    {
        lpData = NULL;
        goto Quit1;
    }
    // Create request
    HINTERNET hHttp;
    if (lpOptional)
    {
        hHttp = WinHttpOpenRequest(hConnect, L"POST", lpszRequest, NULL, WINHTTP_NO_REFERER, WINHTTP_DEFAULT_ACCEPT_TYPES, WINHTTP_FLAG_ESCAPE_PERCENT | WINHTTP_FLAG_REFRESH);
    }
    else
    {
        hHttp = WinHttpOpenRequest(hConnect, L"GET", lpszRequest, NULL, WINHTTP_NO_REFERER, WINHTTP_DEFAULT_ACCEPT_TYPES, WINHTTP_FLAG_ESCAPE_PERCENT | WINHTTP_FLAG_REFRESH);
    }
    if (!hHttp)
    {
        lpData = NULL;
        goto	Quit2;
    }
    // Necessary header
    if (lpOptional)
    {

        if (!WinHttpAddRequestHeaders(hHttp, L"Content-Type: application/x-www-form-urlencoded", -1L, WINHTTP_ADDREQ_FLAG_ADD | WINHTTP_ADDREQ_FLAG_REPLACE))
        {
            lpData = NULL;
            goto Quit3;
        }
    }
    // Post
    DWORD dwLength;
    if (!dwSize)
    {
        dwLength = lstrlenA(lpOptional);
    }
    else
    {
        dwLength = dwSize;
    }

    if (!WinHttpSendRequest(hHttp, WINHTTP_NO_ADDITIONAL_HEADERS, 0, lpOptional, dwLength, dwLength, 0))
    {
        lpData = NULL;
        goto Quit3;
    }
    // Receive
    if (!WinHttpReceiveResponse(hHttp, NULL))
    {
        lpData = NULL;
        goto Quit3;
    }

    LPBYTE lpBuf = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, 1);
    if (!lpBuf)
    {
        goto Quit3;
    }
    DWORD dwDataSize = 0;
    DWORD nSize;
    for (;;)
    {
        // Get data size and resize buffer
        if (lpCallback)
        {
            lpCallback(dwDataSize);
        }
        if (!WinHttpQueryDataAvailable(hHttp, &nSize))
        {
            lpData = NULL;
            goto Quit4;
        }
        if (!nSize)
        {
            break;
        }
        else
        {
            lpBuf = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, lpBuf, dwDataSize + nSize);
            if (!lpBuf)
            {
                lpData = NULL;
                goto Quit4;
            }
        }
        // Read data
        if (!WinHttpReadData(hHttp, lpBuf + dwDataSize, nSize, &nSize))
        {
            lpData = NULL;
            goto Quit4;
        }
        dwDataSize += nSize;
    }
    // Allocate memory
    lpData = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, dwDataSize + 1);// for the last '\0'
    if (!lpData)
    {
        lpData = NULL;
        goto Quit4;
    }
    RtlMoveMemory(lpData, lpBuf, dwDataSize);
    // Clean up
Quit4:      HeapFree(hHeap, 0, lpBuf);
Quit3:      WinHttpCloseHandle(hHttp);
Quit2:      WinHttpCloseHandle(hConnect);
Quit1:      WinHttpCloseHandle(hSession);

Quit0:      HeapFree(hHeap, 0, lpszRequest);

QuitAlloc0: HeapFree(hHeap, 0, lpszExtraInfo);
QuitAlloc1: HeapFree(hHeap, 0, lpszUrlPath);
QuitAlloc2: HeapFree(hHeap, 0, lpszHostName);
QuitAlloc3: return lpData;
}

// Post the request, ANSI version with downloading information
LPVOID WINAPI HttpPostCbA(
    _In_    HANDLE hHeap,
    _In_    LPCSTR lpszURL,
    _In_    LPVOID lpOptional,
    _In_    DWORD dwSize,
    _In_    LPHTTPCALLBACK lpCallback
    )
{
    LPWSTR lpData = NULL;
    int cchWideChar = (lstrlenA(lpszURL) + 1) * 4;
    LPWSTR lpuszURL = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, cchWideChar);
    if (!lpuszURL)
    {
        return lpData;
    }

    MultiByteToWideChar(CP_ACP, 0, lpszURL, -1, lpuszURL, cchWideChar);
    lpData = HttpPostCbW(hHeap, lpuszURL, lpOptional, dwSize, lpCallback);

    HeapFree(hHeap, 0, lpuszURL);

    return lpData;
}

// Convert MBCS to MBCS/UTF-16
LPVOID WINAPI HttpConvert(
    _In_    HANDLE hHeap,
    _In_    LPVOID lpData,
    _In_    UINT  dwOriCodePage,
    _In_    UINT  dwCodePage
    )
{
    if (!lpData)
    {
        return NULL;
    }

    int cchWideChar = (lstrlenA(lpData) + 1) * 4;
    LPWSTR lpwData = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, cchWideChar);
    if (!lpwData)
    {
        return NULL;
    }
    MultiByteToWideChar(dwOriCodePage, 0, lpData, -1, lpwData, cchWideChar);

    switch (dwCodePage)
    {
    case  CP_UTF16LE:
    case  CP_UTF16BE:
        {
            HeapFree(hHeap, 0, lpData);
            return lpwData;
            break;
        }
    default:
        {
            LPSTR lpReturn = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, cchWideChar);
            if (!lpReturn)
            {
                HeapFree(hHeap, 0, lpwData);
                return NULL;
            }
            WideCharToMultiByte(dwCodePage, 0, lpwData, -1, lpReturn, cchWideChar, NULL, NULL);
            HeapFree(hHeap, 0, lpwData);
            HeapFree(hHeap, 0, lpData);

            return lpReturn;
        }
    }
}