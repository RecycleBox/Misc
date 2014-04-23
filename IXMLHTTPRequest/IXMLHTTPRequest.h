#ifndef _IXMLHTTPREQUEST_H_
#define _IXMLHTTPREQUEST_H_

#include <windows.h>
#include <msxml6.h>

typedef IXMLHTTPRequest *HXMLHTTP;

HRESULT XMLHTTPCreate(
    _Inout_     HXMLHTTP * hObject
    );

HRESULT XMLHTTPClose(
    _In_    HXMLHTTP hObject
    );

HRESULT XMLHTTPOpen(
    _In_        HXMLHTTP hObject,
    _In_        LPCWSTR szMethod,
    _In_        LPCWSTR szUrl,
    _In_opt_    BOOL bAsync,
    _In_opt_    LPCWSTR szUser,
    _In_opt_    LPCWSTR szPassword
    );

HRESULT XMLHTTPSend(
    _In_        HXMLHTTP hObject,
    _In_opt_    LPCWSTR szBody
    );

HRESULT XMLHTTPGetResponseText(
    _In_    HXMLHTTP hObject,
    _In_    BSTR * szBody
    );

#endif // _IXMLHTTPREQUEST_H_