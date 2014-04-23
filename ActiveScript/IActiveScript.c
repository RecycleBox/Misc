#include "IActiveScript.h"

HRESULT STDMETHODCALLTYPE ScriptCreate(
    _Inout_     HSCRIPT * hObject,
    _In_        LPCWSTR szEngine
    )
{
    HRESULT hr = S_OK;
    if (!hObject)
    {
        return E_POINTER;
    }
    
    _IActiveScriptSite_ ** hSite = (_IActiveScriptSite_ **) hObject;
    hr = IActiveScriptSite_Create(hObject);
    if (FAILED(hr))
    {
        return hr;
    }

    CLSID CLSID_SCRIPT_ENGINE;
    hr = CLSIDFromProgID(szEngine, &CLSID_SCRIPT_ENGINE);
    if (FAILED(hr))
    {
        (*hObject)->lpVtbl->Release(*hObject);
        *hObject = NULL;
        return hr;
    }

    IActiveScript ** hScript = &(*hSite)->hScript;
    hr = CoCreateInstance(&CLSID_SCRIPT_ENGINE, NULL, CLSCTX_INPROC_SERVER, &IID_IActiveScript, hScript);
    if (FAILED(hr))
    {
        (*hObject)->lpVtbl->Release(*hObject);
        *hObject = NULL;
        return hr;
    }

    hr = (*hScript)->lpVtbl->SetScriptSite(*hScript, (IActiveScriptSite*) *hObject);
    if (FAILED(hr))
    {
        (*hScript)->lpVtbl->Release(*hScript);
        (*hObject)->lpVtbl->Release(*hObject);
        *hObject = NULL;
        return hr;
    }

    if (!lstrcmpiW(szEngine, L"JScript"))
    {
        IActiveScriptProperty * hProperty;
        hr = (*hScript)->lpVtbl->QueryInterface(*hScript, &IID_IActiveScriptProperty, &hProperty);
        if (SUCCEEDED(hr))
        {
            VARIANT varValue;
            varValue.vt = VT_I4;
            varValue.intVal = SCRIPTLANGUAGEVERSION_5_8;

            hr = hProperty->lpVtbl->SetProperty(hProperty, SCRIPTPROP_INVOKEVERSIONING, NULL, &varValue);
            hProperty->lpVtbl->Release(hProperty);
        }
    }

    IActiveScriptParse ** hParse = &(*hSite)->hParse;
    hr = (*hScript)->lpVtbl->QueryInterface(*hScript, &IID_IActiveScriptParse, hParse);
    if (FAILED(hr))
    {
        (*hScript)->lpVtbl->Release(*hScript);
        (*hObject)->lpVtbl->Release(*hObject);
        *hObject = NULL;
        return hr;
    }

    hr = (*hParse)->lpVtbl->InitNew(*hParse);
    if (FAILED(hr))
    {
        (*hParse)->lpVtbl->Release(*hParse);
        (*hScript)->lpVtbl->Release(*hScript);
        (*hObject)->lpVtbl->Release(*hObject);
        *hObject = NULL;
        return hr;
    }

    hr = (*hScript)->lpVtbl->AddNamedItem(*hScript, IHOST_GLOBAL_NAME, SCRIPTITEM_ISPERSISTENT | SCRIPTITEM_ISVISIBLE);
    if (FAILED(hr))
    {
        (*hScript)->lpVtbl->Release(*hScript);
        (*hObject)->lpVtbl->Release(*hObject);
        *hObject = NULL;
        return hr;
    }

    return hr;
}

HRESULT STDMETHODCALLTYPE ScriptClose(
    _In_    HSCRIPT hObject
    )
{
    if (!hObject)
    {
        return E_POINTER;
    }

    hObject->lpVtbl->Release(hObject);

    return S_OK;
}

HRESULT STDMETHODCALLTYPE ScriptExecute(
    _In_        HSCRIPT hObject,
    _In_        LPCWSTR szScript
    )
{
    HRESULT hr = S_OK;
    if (!hObject)
    {
        return E_POINTER;
    }

    _IActiveScriptSite_ * hSite = (_IActiveScriptSite_ *) hObject;
    IActiveScript * hScript = hSite->hScript;
    if (!hScript)
    {
        return E_FAIL;
    }
    IActiveScriptParse * hParse = hSite->hParse;
    if (!hParse)
    {
        return E_FAIL;
    }

    EXCEPINFO stException;
    RtlZeroMemory(&stException, sizeof(stException));
    BSTR pstrCode = SysAllocString(szScript);

    hr = hParse->lpVtbl->ParseScriptText(hParse, pstrCode, NULL, NULL, NULL, 0, 0, 0L, NULL, &stException);
    if (FAILED(hr))
    {
        return hr;
    }

    hr = hScript->lpVtbl->SetScriptState(hScript, SCRIPTSTATE_CONNECTED);
    if (FAILED(hr))
    {
        return hr;
    }

    SysFreeString(pstrCode);

    return hr;
}

HRESULT STDMETHODCALLTYPE ScriptSetJSON(
    __RPC__inout HSCRIPT hObject,
    _In_ LPCOLESTR bstrJSON
    )
{
    ((_IHost *) ((_IActiveScriptSite_ *) hObject)->hHost)->bstrJSON = SysAllocString(bstrJSON);
    return S_OK;
}

HRESULT STDMETHODCALLTYPE ScriptCleanJSON(
    __RPC__inout HSCRIPT hObject
    )
{
    SysFreeString(((_IHost *) ((_IActiveScriptSite_ *) hObject)->hHost)->bstrJSON);
    return S_OK;
}