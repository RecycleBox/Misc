#define INITGUID
#include "IHost.h"

HRESULT STDMETHODCALLTYPE ITypeInfo_Create(
    _In_    const GUID * guid,
    _Inout_ ITypeInfo ** ppTInfo
    )
{
    WCHAR szFile[MAX_PATH];
    ITypeLib * pTLib;
    HRESULT hr;

    // Assume an error
    *ppTInfo = NULL;

    // Load the type library from our EXE's resources
    GetModuleFileNameW(0, szFile, sizeof(szFile) / sizeof(szFile[0]));
    hr = LoadTypeLib(szFile, &pTLib);
    if (SUCCEEDED(hr))
    {
        // Let Microsoft's GetTypeInfoOfGuid() create a generic ITypeInfo
        // for the requested item (whose GUID is passed)
        hr = pTLib->lpVtbl->GetTypeInfoOfGuid(pTLib, guid, ppTInfo);

        // We no longer need the type library
        pTLib->lpVtbl->Release(pTLib);
    }

    return hr;
}

IHostVtbl _IHostVtbl = {
    IHost_QueryInterface,
    IHost_AddRef,
    IHost_Release,
    IHost_GetTypeInfoCount,
    IHost_GetTypeInfo,
    IHost_GetIDsOfNames,
    IHost_Invoke,
    IHost_alert,
    IHost_getJSON
};

HRESULT STDMETHODCALLTYPE IHost_Create(
    __RPC__inout IHost **This
    )
{
    *This = (IHost *) GlobalAlloc(GPTR, sizeof(_IHost));
    if (*This)
    {
        _IHost * hObject = (_IHost *) *This;

        hObject->lpVtbl = GlobalAlloc(GPTR, sizeof(IHostVtbl));
        RtlMoveMemory(hObject->lpVtbl, &_IHostVtbl, sizeof(*(hObject->lpVtbl)));
        hObject->RefCount = 0;
        hObject->lpVtbl->AddRef(*This);

        ITypeInfo_Create(&IID_IHost, &hObject->pTypeInfo);
        return S_OK;
    }
    else
    {
        return E_OUTOFMEMORY;
    }
}

HRESULT STDMETHODCALLTYPE IHost_QueryInterface(
    __RPC__in IHost *This,
    /* [in] */ __RPC__in REFIID riid,
    /* [annotation][iid_is][out] */
    _COM_Outptr_  void **ppvObject
    )
{
    if (!IsEqualIID(riid, &IID_IUnknown) && !IsEqualIID(riid, &IID_IDispatch) && !IsEqualIID(riid, &IID_IHost))
    {
        *ppvObject = NULL;
        return E_NOINTERFACE;
    }

    *ppvObject = This;
    This->lpVtbl->AddRef(This);
    return S_OK;
}

ULONG STDMETHODCALLTYPE IHost_AddRef(
    __RPC__in IHost *This
    )
{
    InterlockedIncrement(&((_IHost *) This)->RefCount);

    return ((_IHost *) This)->RefCount;
}

ULONG STDMETHODCALLTYPE IHost_Release(
    __RPC__in IHost *This
    )
{
    InterlockedDecrement(&((_IHost *) This)->RefCount);
    if (!((_IHost *) This)->RefCount)
    {
        _IHost * hObject = (_IHost *) This;
        if (hObject->pTypeInfo)
        {
            hObject->pTypeInfo->lpVtbl->Release(hObject->pTypeInfo);
        }

        GlobalFree(This->lpVtbl);
        GlobalFree(This);
        return 0;
    }
    else
    {
        return ((_IHost *) This)->RefCount;
    }
}

HRESULT STDMETHODCALLTYPE IHost_GetTypeInfoCount(
    __RPC__in IHost *This,
    /* [out] */ __RPC__out UINT *pctinfo
    )
{
    *pctinfo = 1;
    return S_OK;
}

HRESULT STDMETHODCALLTYPE IHost_GetTypeInfo(
    __RPC__in IHost *This,
    /* [in] */ UINT iTInfo,
    /* [in] */ LCID lcid,
    /* [out] */ __RPC__deref_out_opt ITypeInfo **ppTInfo
    )
{
    HRESULT hr = S_OK;

    _IHost * hObject = (_IHost *) This;
    *ppTInfo = hObject->pTypeInfo;
    hr = (*ppTInfo)->lpVtbl->AddRef(*ppTInfo);

    return hr;
}

HRESULT STDMETHODCALLTYPE IHost_GetIDsOfNames(
    __RPC__in IHost *This,
    /* [in] */ __RPC__in REFIID riid,
    /* [size_is][in] */ __RPC__in_ecount_full(cNames) LPOLESTR *rgszNames,
    /* [range][in] */ __RPC__in_range(0, 16384) UINT cNames,
    /* [in] */ LCID lcid,
    /* [size_is][out] */ __RPC__out_ecount_full(cNames) DISPID *rgDispId
    )
{
    HRESULT hr = S_OK;

    _IHost * hObject = (_IHost *) This;
    hr = hObject->pTypeInfo->lpVtbl->GetIDsOfNames(hObject->pTypeInfo, rgszNames, cNames, rgDispId);
    
    return hr;
}

HRESULT STDMETHODCALLTYPE IHost_Invoke(
    __RPC__in IHost *This,
    /* [annotation][in] */
    _In_  DISPID dispIdMember,
    /* [annotation][in] */
    _In_  REFIID riid,
    /* [annotation][in] */
    _In_  LCID lcid,
    /* [annotation][in] */
    _In_  WORD wFlags,
    /* [annotation][out][in] */
    _In_  DISPPARAMS *pDispParams,
    /* [annotation][out] */
    _Out_opt_  VARIANT *pVarResult,
    /* [annotation][out] */
    _Out_opt_  EXCEPINFO *pExcepInfo,
    /* [annotation][out] */
    _Out_opt_  UINT *puArgErr
    )
{
    HRESULT hr = S_OK;

    _IHost * hObject = (_IHost *) This;
    hr = hObject->pTypeInfo->lpVtbl->Invoke(hObject->pTypeInfo, This, dispIdMember, wFlags, pDispParams, pVarResult, pExcepInfo, puArgErr);

    return hr;
}

HRESULT STDMETHODCALLTYPE IHost_alert(
    __RPC__in IHost *This,
    /* [in] */
    _In_ BSTR bstrPromt
    )
{
    MessageBoxW(NULL, bstrPromt, NULL, 0);
    return S_OK;
}

HRESULT STDMETHODCALLTYPE IHost_getJSON(
    __RPC__in IHost *This,
    /* [out] */
    _Out_ BSTR *bstrJSON
    )
{
    _IHost * hObject = (_IHost *) This;

    *bstrJSON = hObject->bstrJSON;
    return S_OK;
}