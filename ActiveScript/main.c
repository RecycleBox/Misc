#include <windows.h>
#include "IActiveScript.h"

#define JSON_STRING OLESTR("{\"firstname\":\"John\",\"lastname\":\"Smith\",\"phone\":[\"123456789\",\"987654321\"]}")

WCHAR szScript[] =
L"var json = JSON.parse(App.getJSON());\n"
L"var text = json.firstname + \' \' + json.lastname + \' Tel:\';\n"
L"for(var i = 0; i < json.phone.length; i++)\n"
L"{\n"
L"    text += json.phone[i] + \' \';\n"
L"}\n"
L"App.alert(text);\n";

int CALLBACK WinMain(
    _In_  HINSTANCE hInstance,
    _In_  HINSTANCE hPrevInstance,
    _In_  LPSTR lpCmdLine,
    _In_  int nCmdShow
    )
{
    HRESULT hr = CoInitializeEx(NULL, COINIT_MULTITHREADED);

    // Init HSCRIPT
    HSCRIPT hScript;

    hr = ScriptCreate(&hScript, L"JScript");

    if (FAILED(hr))
    {
        MessageBox(NULL, TEXT("ScriptCreate"), NULL, 0);
        ExitProcess(0);
    }

    // Execute
    ScriptSetJSON(hScript, JSON_STRING);
    hr = ScriptExecute(hScript, szScript);
    if (FAILED(hr))
    {
        MessageBox(NULL, TEXT("ScriptExecute"), NULL, 0);
        ExitProcess(0);
    }

    // Clean up
    ScriptCleanJSON(hScript);
    hr = ScriptClose(hScript);
    if (FAILED(hr))
    {
        MessageBox(NULL, TEXT("ScriptClose"), NULL, 0);
        ExitProcess(0);
    }

    CoUninitialize();

    return 0;
}