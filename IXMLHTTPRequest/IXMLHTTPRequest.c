#include "IXMLHTTPRequest.h"

HRESULT XMLHTTPCreate(
    _Inout_     HXMLHTTP * hObject
    )
{
    return CoCreateInstance(&CLSID_XMLHTTP60, 0, CLSCTX_INPROC_SERVER, &IID_IXMLHTTPRequest, hObject);
}

HRESULT XMLHTTPClose(
    _In_    HXMLHTTP hObject
    )
{
    return hObject->lpVtbl->Release(hObject);
}

HRESULT XMLHTTPOpen(
    _In_        HXMLHTTP hObject,
    _In_        LPCWSTR szMethod,
    _In_        LPCWSTR szUrl,
    _In_opt_    BOOL bAsync,
    _In_opt_    LPCWSTR szUser,
    _In_opt_    LPCWSTR szPassword
    )
{
    BSTR bstrMethod = SysAllocString(szMethod);

    BSTR bstrUrl = SysAllocString(szUrl);

    VARIANT varAsync;
    varAsync.vt = VT_BOOL;
    varAsync.boolVal = bAsync ? VARIANT_TRUE : VARIANT_FALSE;

    VARIANT bstrUser;
    bstrUser.vt = VT_BSTR;
    if (szUser == NULL)
    {
        szUser = L"";
    }
    bstrUser.bstrVal = SysAllocString(szUser);

    VARIANT bstrPassword;
    bstrPassword.vt = VT_BSTR;
    if (szPassword == NULL)
    {
        szPassword = L"";
    }
    bstrPassword.bstrVal = SysAllocString(szPassword);

    HRESULT hr = hObject->lpVtbl->open(hObject, bstrMethod, bstrUrl, varAsync, bstrUser, bstrPassword);

    SysFreeString(bstrMethod);
    SysFreeString(bstrUrl);
    SysFreeString(bstrUser.bstrVal);
    SysFreeString(bstrPassword.bstrVal);

    return hr;
}

HRESULT XMLHTTPSend(
    _In_        HXMLHTTP hObject,
    _In_opt_    LPCWSTR szBody
    )
{
    VARIANT varBody;
    varBody.vt = VT_BSTR;
    if (szBody == NULL)
    {
        szBody = L"";
    }
    varBody.bstrVal = SysAllocString(szBody);

    HRESULT hr = hObject->lpVtbl->send(hObject, varBody);

    SysFreeString(varBody.bstrVal);

    return hr;
}

HRESULT XMLHTTPGetResponseText(
    _In_    HXMLHTTP hObject,
    _In_    BSTR * szBody
    )
{
    return hObject->lpVtbl->get_responseText(hObject, szBody);
}