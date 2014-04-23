#ifndef _IACTIVESCRIPT_H_
#define _IACTIVESCRIPT_H_

#include <windows.h>
#include "IActiveScriptSite.h"
#include "IHost.h"

typedef IActiveScriptSite_ * HSCRIPT;

HRESULT STDMETHODCALLTYPE ScriptCreate(
    _Inout_     HSCRIPT * hObject,
    _In_        LPCWSTR szEngine
    );

HRESULT STDMETHODCALLTYPE ScriptClose(
    _In_    HSCRIPT hObject
    );

HRESULT STDMETHODCALLTYPE ScriptExecute(
    _In_        HSCRIPT hObject,
    _In_        LPCWSTR szScript
    );

HRESULT STDMETHODCALLTYPE ScriptSetJSON(
    __RPC__inout HSCRIPT hObject,
    _In_ LPCOLESTR bstrJSON
    );

HRESULT STDMETHODCALLTYPE ScriptCleanJSON(
    __RPC__inout HSCRIPT hObject
    );

#endif // _IACTIVESCRIPT_H_