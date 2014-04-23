#ifndef _IACTIVESCRIPTSITE_H_
#define _IACTIVESCRIPTSITE_H_

#include <windows.h>
#include <ActivScp.h>
#include "IHost.h"

// {48DB1CDE-41B6-4976-A3F8-A4525CDC68B2}
DEFINE_GUID(CLSID_IActiveScriptSite_,
    0x48db1cde, 0x41b6, 0x4976, 0xa3, 0xf8, 0xa4, 0x52, 0x5c, 0xdc, 0x68, 0xb2);
// {9E54DB60-BF25-4b67-A727-CC4F57407900}
DEFINE_GUID(IID_IActiveScriptSite_,
    0x9e54db60, 0xbf25, 0x4b67, 0xa7, 0x27, 0xcc, 0x4f, 0x57, 0x40, 0x79, 0x0);

#undef  INTERFACE
#define INTERFACE IActiveScriptSite_
DECLARE_INTERFACE_IID_(INTERFACE, IActiveScriptSite, IID_IActiveScriptSite_)
{
    STDMETHOD_(HRESULT, QueryInterface) (THIS, REFIID, void **) PURE;
    STDMETHOD_(ULONG, AddRef) (THIS) PURE;
    STDMETHOD_(ULONG, Release) (THIS) PURE;
    STDMETHOD_(HRESULT, GetLCID) (THIS, LCID *) PURE;
    STDMETHOD_(HRESULT, GetItemInfo) (THIS, LPCOLESTR, DWORD, IUnknown **, ITypeInfo **) PURE;
    STDMETHOD_(HRESULT, GetDocVersionString) (THIS, BSTR *) PURE;
    STDMETHOD_(HRESULT, OnScriptTerminate) (THIS, const VARIANT *, const EXCEPINFO *) PURE;
    STDMETHOD_(HRESULT, OnStateChange) (THIS, SCRIPTSTATE) PURE;
    STDMETHOD_(HRESULT, OnScriptError) (THIS, IActiveScriptError *) PURE;
    STDMETHOD_(HRESULT, OnEnterScript) (THIS) PURE;
    STDMETHOD_(HRESULT, OnLeaveScript) (THIS) PURE;
};

typedef struct __IActiveScriptSite_
{
    IActiveScriptSite_Vtbl *lpVtbl;
    volatile LONG RefCount;
    IActiveScript * hScript;
    IActiveScriptParse * hParse;
    IHost * hHost;
} _IActiveScriptSite_;

HRESULT STDMETHODCALLTYPE IActiveScriptSite_Create(
    __RPC__inout IActiveScriptSite_ **This
    );

HRESULT STDMETHODCALLTYPE IActiveScriptSite_QueryInterface(
    __RPC__in IActiveScriptSite_ *This,
    /* [in] */ __RPC__in REFIID riid,
    /* [annotation][iid_is][out] */
    _COM_Outptr_  void **ppvObject
    );

ULONG STDMETHODCALLTYPE IActiveScriptSite_AddRef(
    __RPC__in IActiveScriptSite_ *This
    );

ULONG STDMETHODCALLTYPE IActiveScriptSite_Release(
    __RPC__in IActiveScriptSite_ *This
    );

HRESULT STDMETHODCALLTYPE IActiveScriptSite_GetLCID(
    __RPC__in IActiveScriptSite_ *This,
    /* [out] */ __RPC__out LCID *plcid
    );

HRESULT STDMETHODCALLTYPE IActiveScriptSite_GetItemInfo(
    __RPC__in IActiveScriptSite_ *This,
    /* [in] */ __RPC__in LPCOLESTR pstrName,
    /* [in] */ DWORD dwReturnMask,
    /* [out] */ __RPC__deref_out_opt IUnknown **ppiunkItem,
    /* [out] */ __RPC__deref_out_opt ITypeInfo **ppti
    );

HRESULT STDMETHODCALLTYPE IActiveScriptSite_GetDocVersionString(
    __RPC__in IActiveScriptSite_ *This,
    /* [out] */ __RPC__deref_out_opt BSTR *pbstrVersion
    );

HRESULT STDMETHODCALLTYPE IActiveScriptSite_OnScriptTerminate(
    __RPC__in IActiveScriptSite_ *This,
    /* [in] */ __RPC__in const VARIANT *pvarResult,
    /* [in] */ __RPC__in const EXCEPINFO *pexcepinfo
    );

HRESULT STDMETHODCALLTYPE IActiveScriptSite_OnStateChange(
    __RPC__in IActiveScriptSite_ *This,
    /* [in] */ SCRIPTSTATE ssScriptState
    );

HRESULT STDMETHODCALLTYPE IActiveScriptSite_OnScriptError(
    __RPC__in IActiveScriptSite_ *This,
    /* [in] */ __RPC__in_opt IActiveScriptError *pscripterror
    );

HRESULT STDMETHODCALLTYPE IActiveScriptSite_OnEnterScript(
    __RPC__in IActiveScriptSite_ *This
    );

HRESULT STDMETHODCALLTYPE IActiveScriptSite_OnLeaveScript(
    __RPC__in IActiveScriptSite_ *This
    );

// {F34B16C2-7579-4ba9-83E0-EFE6A6EA4998}
DEFINE_GUID(CLSID_IActiveScriptSiteWindow_,
    0xf34b16c2, 0x7579, 0x4ba9, 0x83, 0xe0, 0xef, 0xe6, 0xa6, 0xea, 0x49, 0x98);
// {0EA4F184-F791-4c0d-A529-4E52EF25D4B2}
DEFINE_GUID(IID_IActiveScriptSiteWindow_,
    0xea4f184, 0xf791, 0x4c0d, 0xa5, 0x29, 0x4e, 0x52, 0xef, 0x25, 0xd4, 0xb2);

#undef  INTERFACE
#define INTERFACE IActiveScriptSiteWindow_
DECLARE_INTERFACE_IID_(INTERFACE, IActiveScriptSiteWindow, IID_IActiveScriptSiteWindow_)
{
    STDMETHOD_(HRESULT, QueryInterface) (THIS, REFIID, void **) PURE;
    STDMETHOD_(ULONG, AddRef) (THIS) PURE;
    STDMETHOD_(ULONG, Release) (THIS) PURE;
    STDMETHOD_(HRESULT, GetWindow) (THIS, HWND *) PURE;
    STDMETHOD_(HRESULT, EnableModeless) (THIS, BOOL) PURE;
};

typedef struct __IActiveScriptSiteWindow_
{
    IActiveScriptSiteWindow_Vtbl *lpVtbl;
    volatile LONG RefCount;
    HWND hwnd;
} _IActiveScriptSiteWindow_;

HRESULT STDMETHODCALLTYPE IActiveScriptSiteWindow_Create(
    __RPC__inout IActiveScriptSiteWindow_ **This
    );

HRESULT STDMETHODCALLTYPE IActiveScriptSiteWindow_QueryInterface(
    __RPC__in IActiveScriptSiteWindow_ *This,
    /* [in] */ __RPC__in REFIID riid,
    /* [annotation][iid_is][out] */
    _COM_Outptr_  void **ppvObject
    );

ULONG STDMETHODCALLTYPE IActiveScriptSiteWindow_AddRef(
    __RPC__in IActiveScriptSiteWindow_ *This
    );

ULONG STDMETHODCALLTYPE IActiveScriptSiteWindow_Release(
    __RPC__in IActiveScriptSiteWindow_ *This
    );

HRESULT STDMETHODCALLTYPE IActiveScriptSiteWindow_GetWindow(
    __RPC__in IActiveScriptSiteWindow_ *This,
    /* [out] */ __RPC__deref_out_opt HWND *phwnd
    );

HRESULT STDMETHODCALLTYPE IActiveScriptSiteWindow_EnableModeless(
    __RPC__in IActiveScriptSiteWindow_ *This,
    /* [in] */ BOOL fEnable
    );

#endif // _IACTIVESCRIPTSITE_H_