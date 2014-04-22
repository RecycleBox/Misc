#include <windows.h>
#include "IXMLHTTPRequest.h"

int CALLBACK WinMain(
    _In_  HINSTANCE hInstance,
    _In_  HINSTANCE hPrevInstance,
    _In_  LPSTR lpCmdLine,
    _In_  int nCmdShow
    )
{
    HRESULT hr = CoInitializeEx(NULL, COINIT_MULTITHREADED);

    // Init XMLHTTPRequest
    HXMLHTTP pXMLHTTPRequest;

    hr = XMLHTTPCreate(&pXMLHTTPRequest);

    if (!SUCCEEDED(hr))
    {
        MessageBox(NULL, TEXT("CoCreateInstance"), NULL, 0);
        ExitProcess(0);
    }

    // open
    hr = XMLHTTPOpen(pXMLHTTPRequest, L"GET", L"http://kdays.cn", FALSE, NULL, NULL);
    if (!SUCCEEDED(hr))
    {
        MessageBox(NULL, TEXT("open"), NULL, 0);
        ExitProcess(0);
    }

    // send
    hr = XMLHTTPSend(pXMLHTTPRequest, NULL);
    if (!SUCCEEDED(hr))
    {
        MessageBox(NULL, TEXT("send"), NULL, 0);
        ExitProcess(0);
    }

    // Display
    BSTR pbstrBody;
    hr = XMLHTTPGetResponseText(pXMLHTTPRequest, &pbstrBody);
    if (!SUCCEEDED(hr))
    {
        MessageBox(NULL, TEXT("responseText"), NULL, 0);
        ExitProcess(0);
    }
    else
    {
        MessageBox(NULL, pbstrBody, NULL, 0);
    }

    SysFreeString(pbstrBody);

    // Clean up
    hr = XMLHTTPClose(pXMLHTTPRequest);
    if (!SUCCEEDED(hr))
    {
        MessageBox(NULL, TEXT("Release"), NULL, 0);
        ExitProcess(0);
    }

    CoUninitialize();

    return 0;
}