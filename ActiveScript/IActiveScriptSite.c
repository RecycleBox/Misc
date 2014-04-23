#define INITGUID
#include "IActiveScriptSite.h"

IActiveScriptSite_Vtbl _IActiveScriptSite_Vtbl = {
    IActiveScriptSite_QueryInterface,
    IActiveScriptSite_AddRef,
    IActiveScriptSite_Release,
    IActiveScriptSite_GetLCID,
    IActiveScriptSite_GetItemInfo,
    IActiveScriptSite_GetDocVersionString,
    IActiveScriptSite_OnScriptTerminate,
    IActiveScriptSite_OnStateChange,
    IActiveScriptSite_OnScriptError,
    IActiveScriptSite_OnEnterScript,
    IActiveScriptSite_OnLeaveScript
};

HRESULT STDMETHODCALLTYPE IActiveScriptSite_Create(
    __RPC__inout IActiveScriptSite_ **This
    )
{
    *This = (IActiveScriptSite_ *) GlobalAlloc(GPTR, sizeof(_IActiveScriptSite_));
    if (*This)
    {
        _IActiveScriptSite_ * hObject = (_IActiveScriptSite_ *) *This;

        hObject->lpVtbl = GlobalAlloc(GPTR, sizeof(IActiveScriptSite_Vtbl));
        RtlMoveMemory(hObject->lpVtbl, &_IActiveScriptSite_Vtbl, sizeof(*(hObject->lpVtbl)));
        hObject->RefCount = 0;
        hObject->lpVtbl->AddRef(*This);

        IHost_Create(&hObject->hHost);
        return S_OK;
    }
    else
    {
        return E_OUTOFMEMORY;
    }
}

HRESULT STDMETHODCALLTYPE IActiveScriptSite_QueryInterface(
    __RPC__in IActiveScriptSite_ *This,
    /* [in] */ __RPC__in REFIID riid,
    /* [annotation][iid_is][out] */
    _COM_Outptr_  void **ppvObject
    )
{
    if (IsEqualIID(riid, &IID_IUnknown) || IsEqualIID(riid, &IID_IActiveScriptSite) || IsEqualIID(riid, &IID_IActiveScriptSite_))
    {
        *ppvObject = This;
        This->lpVtbl->AddRef(This);
        return S_OK;
    }
    else
    {
        IActiveScriptSiteWindow_ * hObject;
        IActiveScriptSiteWindow_Create(&hObject);
        HRESULT hr = hObject->lpVtbl->QueryInterface(hObject, riid, ppvObject);
        if (FAILED(hr))
        {
            hObject->lpVtbl->Release(hObject);
        }
        return hr;
    }
}

ULONG STDMETHODCALLTYPE IActiveScriptSite_AddRef(
    __RPC__in IActiveScriptSite_ *This
    )
{
    InterlockedIncrement(&((_IActiveScriptSite_ *) This)->RefCount);

    return ((_IActiveScriptSite_ *) This)->RefCount;
}

ULONG STDMETHODCALLTYPE IActiveScriptSite_Release(
    __RPC__in IActiveScriptSite_ *This
    )
{
    InterlockedDecrement(&((_IActiveScriptSite_ *) This)->RefCount);
    if (!((_IActiveScriptSite_ *) This)->RefCount)
    {
        _IActiveScriptSite_ * hObject = (_IActiveScriptSite_ *) This;
        if (hObject->hHost)
        {
            hObject->hHost->lpVtbl->Release(hObject->hHost);
        }

        if (hObject->hParse)
        {
            hObject->hParse->lpVtbl->Release(hObject->hParse);
        }

        if (hObject->hScript)
        {
            hObject->hScript->lpVtbl->SetScriptState(hObject->hScript, SCRIPTSTATE_CLOSED);
            hObject->hScript->lpVtbl->Release(hObject->hScript);
        }

        GlobalFree(This->lpVtbl);
        GlobalFree(This);
        return 0;
    }
    else
    {
        return ((_IActiveScriptSite_ *) This)->RefCount;
    }
}

HRESULT STDMETHODCALLTYPE IActiveScriptSite_GetLCID(
    __RPC__in IActiveScriptSite_ *This,
    /* [out] */ __RPC__out LCID *plcid
    )
{
    *plcid = 0;
    return S_OK;
}

HRESULT STDMETHODCALLTYPE IActiveScriptSite_GetItemInfo(
    __RPC__in IActiveScriptSite_ *This,
    /* [in] */ __RPC__in LPCOLESTR pstrName,
    /* [in] */ DWORD dwReturnMask,
    /* [out] */ __RPC__deref_out_opt IUnknown **ppiunkItem,
    /* [out] */ __RPC__deref_out_opt ITypeInfo **ppti
    )
{
    HRESULT hr = S_OK;

    if (dwReturnMask & SCRIPTINFO_ITYPEINFO)
    {
        if (!ppti)
        {
            return E_INVALIDARG;
        }
        *ppti = NULL;
    }

    if (dwReturnMask & SCRIPTINFO_IUNKNOWN)
    {
        if (!ppiunkItem)
        {
            return E_INVALIDARG;
        }
        *ppiunkItem = NULL;
    }

    _IActiveScriptSite_ * hObject = (_IActiveScriptSite_ *) This;
    IActiveScript * hScript = hObject->hScript;

    if (!lstrcmpiW(IHOST_GLOBAL_NAME, pstrName))
    {
        hr = S_OK;

        if (dwReturnMask & SCRIPTINFO_IUNKNOWN)
        {
            *ppiunkItem = (IUnknown *) hObject->hHost;
        }

        if (dwReturnMask & SCRIPTINFO_ITYPEINFO)
        {
            _IHost * hHostEx = (_IHost *) hObject->hHost;
            *ppti = hHostEx->pTypeInfo;
        }
    }
    else
    {
        hr = TYPE_E_ELEMENTNOTFOUND;
    }

    return hr;
}

HRESULT STDMETHODCALLTYPE IActiveScriptSite_GetDocVersionString(
    __RPC__in IActiveScriptSite_ *This,
    /* [out] */ __RPC__deref_out_opt BSTR *pbstrVersion
    )
{
    *pbstrVersion = SysAllocString(L"1.0");
    return S_OK;
}

HRESULT STDMETHODCALLTYPE IActiveScriptSite_OnScriptTerminate(
    __RPC__in IActiveScriptSite_ *This,
    /* [in] */ __RPC__in const VARIANT *pvarResult,
    /* [in] */ __RPC__in const EXCEPINFO *pexcepinfo
    )
{
    return S_OK;
}

HRESULT STDMETHODCALLTYPE IActiveScriptSite_OnStateChange(
    __RPC__in IActiveScriptSite_ *This,
    /* [in] */ SCRIPTSTATE ssScriptState
    )
{
    return S_OK;
}

HRESULT STDMETHODCALLTYPE IActiveScriptSite_OnScriptError(
    __RPC__in IActiveScriptSite_ *This,
    /* [in] */ __RPC__in_opt IActiveScriptError *pscripterror
    )
{
    HRESULT hr = S_OK;
    LPWSTR lpszError = NULL;
    LPWSTR lpszErrorFmt =
        L"Line number\t%lu\n"
        L"Character position\t%li\n"
        L"Description\t%s\n"
        L"Error code\t%lX\n"
        L"Source\t\t%s\n"
        L"\n%s";

    EXCEPINFO stExcepInfo;
    EXCEPINFO *lpstExcepInfo = &stExcepInfo;
    hr = pscripterror->lpVtbl->GetExceptionInfo(pscripterror, &stExcepInfo);
    if (FAILED(hr))
    {
        lpstExcepInfo = NULL;
    }

    BSTR bstrSourceLine;
    hr = pscripterror->lpVtbl->GetSourceLineText(pscripterror, &bstrSourceLine);
    if (FAILED(hr))
    {
        bstrSourceLine = NULL;
    }

    DWORD dwSourceContext;
    ULONG ulLineNumber;
    LONG lCharacterPosition;
    hr = pscripterror->lpVtbl->GetSourcePosition(pscripterror, &dwSourceContext, &ulLineNumber, &lCharacterPosition);
    if (FAILED(hr))
    {
        ulLineNumber = 0;
        lCharacterPosition = 0;
    }

    SIZE_T nCount = lstrlenW(bstrSourceLine);
    nCount += lstrlenW(stExcepInfo.bstrDescription);
    nCount += lstrlenW(stExcepInfo.bstrHelpFile);
    nCount += lstrlenW(stExcepInfo.bstrSource);
    nCount += lstrlenW(lpszErrorFmt);
    lpszError = (LPWSTR) GlobalAlloc(GPTR, nCount * sizeof(lpszError[0]));
    if (lpszError)
    {
        wsprintf(lpszError, lpszErrorFmt, ulLineNumber, lCharacterPosition, stExcepInfo.bstrDescription, stExcepInfo.scode + stExcepInfo.wCode, stExcepInfo.bstrSource, bstrSourceLine);
        MessageBoxW(NULL, lpszError, NULL, MB_ICONERROR);
        GlobalFree(lpszError);
    }

    if (bstrSourceLine)
    {
        SysFreeString(bstrSourceLine);
    }

    return S_OK;
}

HRESULT STDMETHODCALLTYPE IActiveScriptSite_OnEnterScript(
    __RPC__in IActiveScriptSite_ *This
    )
{
    return S_OK;
}

HRESULT STDMETHODCALLTYPE IActiveScriptSite_OnLeaveScript(
    __RPC__in IActiveScriptSite_ *This
    )
{
    return S_OK;
}

IActiveScriptSiteWindow_Vtbl _IActiveScriptSiteWindow_Vtbl = {
    IActiveScriptSiteWindow_QueryInterface,
    IActiveScriptSiteWindow_AddRef,
    IActiveScriptSiteWindow_Release,
    IActiveScriptSiteWindow_GetWindow,
    IActiveScriptSiteWindow_EnableModeless
};

HRESULT STDMETHODCALLTYPE IActiveScriptSiteWindow_Create(
    __RPC__inout IActiveScriptSiteWindow_ **This
    )
{
    *This = (IActiveScriptSiteWindow_ *) GlobalAlloc(GPTR, sizeof(_IActiveScriptSiteWindow_));
    if (*This)
    {
        (*This)->lpVtbl = GlobalAlloc(GPTR, sizeof(IActiveScriptSiteWindow_Vtbl));
        RtlMoveMemory((*This)->lpVtbl, &_IActiveScriptSiteWindow_Vtbl, sizeof(*((*This)->lpVtbl)));
        (*This)->lpVtbl->AddRef(*This);
        return S_OK;
    }
    else
    {
        return E_OUTOFMEMORY;
    }
}

HRESULT STDMETHODCALLTYPE IActiveScriptSiteWindow_QueryInterface(
    __RPC__in IActiveScriptSiteWindow_ *This,
    /* [in] */ __RPC__in REFIID riid,
    /* [annotation][iid_is][out] */
    _COM_Outptr_  void **ppvObject
    )
{
    if (!IsEqualIID(riid, &IID_IUnknown) && !IsEqualIID(riid, &IID_IActiveScriptSiteWindow) && !IsEqualIID(riid, &IID_IActiveScriptSiteWindow_))
    {
        *ppvObject = NULL;
        return E_NOINTERFACE;
    }

    *ppvObject = This;
    This->lpVtbl->AddRef(This);
    return S_OK;
}

ULONG STDMETHODCALLTYPE IActiveScriptSiteWindow_AddRef(
    __RPC__in IActiveScriptSiteWindow_ *This
    )
{
    InterlockedIncrement(&((_IActiveScriptSiteWindow_ *) This)->RefCount);

    return ((_IActiveScriptSiteWindow_ *) This)->RefCount;
}

ULONG STDMETHODCALLTYPE IActiveScriptSiteWindow_Release(
    __RPC__in IActiveScriptSiteWindow_ *This
    )
{
    InterlockedDecrement(&((_IActiveScriptSiteWindow_ *) This)->RefCount);
    if (!((_IActiveScriptSiteWindow_ *) This)->RefCount)
    {
        GlobalFree(This->lpVtbl);
        GlobalFree(This);
        return 0;
    }
    else
    {
        return ((_IActiveScriptSiteWindow_ *) This)->RefCount;
    }
}

HRESULT STDMETHODCALLTYPE IActiveScriptSiteWindow_GetWindow(
    __RPC__in IActiveScriptSiteWindow_ *This,
    /* [out] */ __RPC__deref_out_opt HWND *phwnd
    )
{
    *phwnd = ((_IActiveScriptSiteWindow_ *) This)->hwnd;
    return S_OK;
}

HRESULT STDMETHODCALLTYPE IActiveScriptSiteWindow_EnableModeless(
    __RPC__in IActiveScriptSiteWindow_ *This,
    /* [in] */ BOOL fEnable
    )
{
    return S_OK;
}