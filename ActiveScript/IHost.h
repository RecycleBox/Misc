#ifndef _IHOST_H_
#define _IHOST_H_

#include <windows.h>
#include <ActivScp.h>

#define IHOST_GLOBAL_NAME OLESTR("App")

// {01BD449E-4EB1-4443-BFDC-F36983779884}
DEFINE_GUID(CLSID_IHost,
    0x1bd449e, 0x4eb1, 0x4443, 0xbf, 0xdc, 0xf3, 0x69, 0x83, 0x77, 0x98, 0x84);
// {55431FA1-CD05-494e-B9F7-CD3EBFE0B7DC}
DEFINE_GUID(IID_IHost,
    0x55431fa1, 0xcd05, 0x494e, 0xb9, 0xf7, 0xcd, 0x3e, 0xbf, 0xe0, 0xb7, 0xdc);

#undef  INTERFACE
#define INTERFACE IHost
DECLARE_INTERFACE_IID_(INTERFACE, IDispatch, IID_IHost)
{
    STDMETHOD_(HRESULT, QueryInterface) (THIS, REFIID, void **) PURE;
    STDMETHOD_(ULONG, AddRef) (THIS) PURE;
    STDMETHOD_(ULONG, Release) (THIS) PURE;
    STDMETHOD_(HRESULT, GetTypeInfoCount) (THIS, UINT *) PURE;
    STDMETHOD_(HRESULT, GetTypeInfo) (THIS, UINT, LCID, ITypeInfo **) PURE;
    STDMETHOD_(HRESULT, GetIDsOfNames) (THIS, REFIID, LPOLESTR *, UINT, LCID, DISPID *) PURE;
    STDMETHOD_(HRESULT, Invoke) (THIS, DISPID, REFIID, LCID, WORD, DISPPARAMS *, VARIANT *, EXCEPINFO *, UINT *) PURE;

    STDMETHOD_(HRESULT, alert) (THIS, BSTR) PURE;
    STDMETHOD_(HRESULT, getJSON) (THIS, BSTR *) PURE;
};

typedef struct __IHost
{
    IHostVtbl *lpVtbl;
    volatile LONG RefCount;
    ITypeInfo *pTypeInfo;
    BSTR bstrJSON;
} _IHost;

HRESULT STDMETHODCALLTYPE IHost_Create(
    __RPC__inout IHost **This
    );

HRESULT STDMETHODCALLTYPE IHost_QueryInterface(
    __RPC__in IHost *This,
    /* [in] */ __RPC__in REFIID riid,
    /* [annotation][iid_is][out] */
    _COM_Outptr_  void **ppvObject
    );

ULONG STDMETHODCALLTYPE IHost_AddRef(
    __RPC__in IHost *This
    );

ULONG STDMETHODCALLTYPE IHost_Release(
    __RPC__in IHost *This
    );

HRESULT STDMETHODCALLTYPE IHost_GetTypeInfoCount(
    __RPC__in IHost *This,
    /* [out] */ __RPC__out UINT *pctinfo
    );

HRESULT STDMETHODCALLTYPE IHost_GetTypeInfo(
    __RPC__in IHost *This,
    /* [in] */ UINT iTInfo,
    /* [in] */ LCID lcid,
    /* [out] */ __RPC__deref_out_opt ITypeInfo **ppTInfo
    );

HRESULT STDMETHODCALLTYPE IHost_GetIDsOfNames(
    __RPC__in IHost *This,
    /* [in] */ __RPC__in REFIID riid,
    /* [size_is][in] */ __RPC__in_ecount_full(cNames) LPOLESTR *rgszNames,
    /* [range][in] */ __RPC__in_range(0, 16384) UINT cNames,
    /* [in] */ LCID lcid,
    /* [size_is][out] */ __RPC__out_ecount_full(cNames) DISPID *rgDispId
    );

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
    );

HRESULT STDMETHODCALLTYPE IHost_alert(
    __RPC__in IHost *This,
    /* [in] */
    _In_ BSTR bstrPromt
    );

HRESULT STDMETHODCALLTYPE IHost_getJSON(
    __RPC__in IHost *This,
    /* [out] */
    _Out_ BSTR *bstrJSON
    );

#endif // _IHOST_H_