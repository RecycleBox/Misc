

/* this ALWAYS GENERATED file contains the definitions for the interfaces */


 /* File created by MIDL compiler version 8.00.0603 */
/* at Tue Apr 22 18:16:46 2014
 */
/* Compiler settings for IHost.idl:
    Oicf, W1, Zp8, env=Win32 (32b run), target_arch=X86 8.00.0603 
    protocol : dce , ms_ext, c_ext, robust
    error checks: allocation ref bounds_check enum stub_data 
    VC __declspec() decoration level: 
         __declspec(uuid()), __declspec(selectany), __declspec(novtable)
         DECLSPEC_UUID(), MIDL_INTERFACE()
*/
/* @@MIDL_FILE_HEADING(  ) */

#pragma warning( disable: 4049 )  /* more than 64k source lines */


/* verify that the <rpcndr.h> version is high enough to compile this file*/
#ifndef __REQUIRED_RPCNDR_H_VERSION__
#define __REQUIRED_RPCNDR_H_VERSION__ 475
#endif

#include "rpc.h"
#include "rpcndr.h"

#ifndef __RPCNDR_H_VERSION__
#error this stub requires an updated version of <rpcndr.h>
#endif // __RPCNDR_H_VERSION__


#ifndef __IHost_h_h__
#define __IHost_h_h__

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

/* Forward Declarations */ 

#ifndef __IHostVTable_FWD_DEFINED__
#define __IHostVTable_FWD_DEFINED__
typedef interface IHostVTable IHostVTable;

#endif 	/* __IHostVTable_FWD_DEFINED__ */


#ifndef __IHost_FWD_DEFINED__
#define __IHost_FWD_DEFINED__

#ifdef __cplusplus
typedef class IHost IHost;
#else
typedef struct IHost IHost;
#endif /* __cplusplus */

#endif 	/* __IHost_FWD_DEFINED__ */


#ifdef __cplusplus
extern "C"{
#endif 



#ifndef __IHost_LIBRARY_DEFINED__
#define __IHost_LIBRARY_DEFINED__

/* library IHost */
/* [helpstring][uuid] */ 


EXTERN_C const IID LIBID_IHost;

#ifndef __IHostVTable_INTERFACE_DEFINED__
#define __IHostVTable_INTERFACE_DEFINED__

/* interface IHostVTable */
/* [object][helpstring][dual][uuid] */ 


EXTERN_C const IID IID_IHostVTable;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("55431FA1-CD05-494e-B9F7-CD3EBFE0B7DC")
    IHostVTable : public IDispatch
    {
    public:
        virtual HRESULT STDMETHODCALLTYPE alert( 
            /* [in] */ BSTR bstrPromt) = 0;
        
        virtual HRESULT STDMETHODCALLTYPE getJSON( 
            /* [retval][out] */ BSTR *bstrJSON) = 0;
        
    };
    
    
#else 	/* C style interface */

    typedef struct IHostVTableVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            IHostVTable * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
            _COM_Outptr_  void **ppvObject);
        
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            IHostVTable * This);
        
        ULONG ( STDMETHODCALLTYPE *Release )( 
            IHostVTable * This);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            IHostVTable * This,
            /* [out] */ UINT *pctinfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            IHostVTable * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            IHostVTable * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [range][in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            IHostVTable * This,
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
            _Out_opt_  UINT *puArgErr);
        
        HRESULT ( STDMETHODCALLTYPE *alert )( 
            IHostVTable * This,
            /* [in] */ BSTR bstrPromt);
        
        HRESULT ( STDMETHODCALLTYPE *getJSON )( 
            IHostVTable * This,
            /* [retval][out] */ BSTR *bstrJSON);
        
        END_INTERFACE
    } IHostVTableVtbl;

    interface IHostVTable
    {
        CONST_VTBL struct IHostVTableVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IHostVTable_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IHostVTable_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IHostVTable_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IHostVTable_GetTypeInfoCount(This,pctinfo)	\
    ( (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo) ) 

#define IHostVTable_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    ( (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo) ) 

#define IHostVTable_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    ( (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId) ) 

#define IHostVTable_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    ( (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr) ) 


#define IHostVTable_alert(This,bstrPromt)	\
    ( (This)->lpVtbl -> alert(This,bstrPromt) ) 

#define IHostVTable_getJSON(This,bstrJSON)	\
    ( (This)->lpVtbl -> getJSON(This,bstrJSON) ) 

#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __IHostVTable_INTERFACE_DEFINED__ */


EXTERN_C const CLSID CLSID_IHost;

#ifdef __cplusplus

class DECLSPEC_UUID("01BD449E-4EB1-4443-BFDC-F36983779884")
IHost;
#endif
#endif /* __IHost_LIBRARY_DEFINED__ */

/* Additional Prototypes for ALL interfaces */

/* end of Additional Prototypes */

#ifdef __cplusplus
}
#endif

#endif


