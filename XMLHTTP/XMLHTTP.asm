;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Include
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifndef	WINHTTP_INC
	include		winhttp.inc
	includelib	winhttp.lib
endif

ifndef	UNICODE
	XMLHTTPPost		equ	XMLHTTPPostA
	XMLHTTPPostCallback	equ	XMLHTTPPostCallbackA
else
	XMLHTTPPost		equ	XMLHTTPPostW
	XMLHTTPPostCallback	equ	XMLHTTPPostCallbackW
endif
CP_UTF16	equ	1200	;Since this is x86 assembly, we know the endian.
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Data
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.const
wszPost		dw	'P','O','S','T',0
wszGet		dw	'G','E','T',0
wszContentType	dw	'C','o','n','t','e','n','t','-','T','y','p','e',':',' '
		dw	'a','p','p','l','i','c','a','t','i','o','n','/'
		dw	'x','-','w','w','w','-','f','o','r','m','-','u','r','l','e','n','c','o','d','e','d',0dh,0ah,0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;********************************************************************
; Create a XMLHTTP object
;********************************************************************
XMLHTTPCreate	proc	uses ebx edi esi

		invoke	HeapCreate,0,0,0
		.if	eax && (eax < 0c0000000h)
			
		.else
			xor	eax,eax
		.endif
		ret
XMLHTTPCreate	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;********************************************************************
; Release a XMLHTTP object
;********************************************************************
XMLHTTPDestroy	proc	uses ebx edi esi,_hHTTP

		invoke	HeapDestroy,_hHTTP
		ret
XMLHTTPDestroy	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;********************************************************************
; Release a memory allocated by XMLHTTP. This is only useful when you
; want to send multiple requests. 
;********************************************************************
XMLHTTPFree	proc	uses ebx edi esi,_hHTTP,_lpMem

		invoke	HeapFree,_hHTTP,NULL,_lpMem
		ret
XMLHTTPFree	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;********************************************************************
; Post the request, unicode version with downloading information
;********************************************************************
XMLHTTPPostCallbackW	proc	uses ebx edi esi,_hHTTP,_lpszURL,_lpOptional,_dwSize,_lpCallback
		local	@lpszHostName,@lpszUrlPath,@lpszExtraInfo,@nURLSize
		local	@lpszRequest
		local	@lpBuf,@nSize
		local	@lpData,@nDataSize
		local	@hSession,@hConnect,@hHTTP
		local	@stUrl:URL_COMPONENTS

;********************************************************************
; Analysis URL
;********************************************************************
		invoke	RtlZeroMemory,addr @stUrl,sizeof URL_COMPONENTS

		invoke	lstrlenW,_lpszURL
		add	eax,2
		shl	eax,2
		mov	@nURLSize,eax
		invoke	HeapAlloc,_hHTTP,HEAP_ZERO_MEMORY,@nURLSize
		.if	eax && (eax < 0c0000000h)
			mov	@lpszHostName,eax
		.else
			xor	eax,eax
			ret
		.endif
		invoke	HeapAlloc,_hHTTP,HEAP_ZERO_MEMORY,@nURLSize
		.if	eax && (eax < 0c0000000h)
			mov	@lpszUrlPath,eax
		.else
			xor	eax,eax
			mov	@lpData,eax
			jmp	QuitAlloc2
		.endif
		invoke	HeapAlloc,_hHTTP,HEAP_ZERO_MEMORY,@nURLSize
		.if	eax && (eax < 0c0000000h)
			mov	@lpszExtraInfo,eax
		.else
			xor	eax,eax
			mov	@lpData,eax
			jmp	QuitAlloc1
		.endif

		mov	@stUrl.dwStructSize,sizeof URL_COMPONENTS
;Allocate memory for WinHttpCrackUrl
		push	@lpszHostName
		pop	@stUrl.lpszHostName
		push	@nURLSize
		pop	@stUrl.dwHostNameLength
		
		push	@lpszUrlPath
		pop	@stUrl.lpszUrlPath
		push	@nURLSize
		pop	@stUrl.dwUrlPathLength
		
		push	@lpszExtraInfo
		pop	@stUrl.lpszExtraInfo
		push	@nURLSize
		pop	@stUrl.dwExtraInfoLength

		invoke	WinHttpCrackUrl,_lpszURL,0,ICU_ESCAPE,addr @stUrl
		.if	!eax
			xor	eax,eax
			mov	@lpData,eax
			jmp	QuitAlloc0
		.endif
;Join the last two parts for WinHttpOpenRequest
		invoke	lstrlenW,@stUrl.lpszUrlPath
		mov	ebx,eax
		invoke	lstrlenW,@stUrl.lpszExtraInfo
		add	ebx,eax
		inc	ebx
		mov	eax,2
		xchg	ebx,eax
		mul	ebx
		invoke	HeapAlloc,_hHTTP,HEAP_ZERO_MEMORY,eax
		.if	eax && (eax < 0c0000000h)
			mov	@lpszRequest,eax
		.else
			xor	eax,eax
			mov	@lpData,eax
			jmp	Quit0
		.endif
		invoke	lstrcpyW,@lpszRequest,@stUrl.lpszUrlPath
		invoke	lstrcatW,@lpszRequest,@stUrl.lpszExtraInfo
;********************************************************************
; Create a session
;********************************************************************
		invoke	WinHttpOpen,0,WINHTTP_ACCESS_TYPE_DEFAULT_PROXY,WINHTTP_NO_PROXY_NAME,WINHTTP_NO_PROXY_BYPASS,NULL
		.if	!eax
			xor	eax,eax
			mov	@lpData,eax
			jmp	Quit0
		.endif
		mov	@hSession,eax
;********************************************************************
; Set timeout time
;********************************************************************		
		invoke	WinHttpSetTimeouts,@hSession,4000,4000,4000,4000
						;DNS Connect Send Receive
		.if	!eax
			xor	eax,eax
			mov	@lpData,eax
			jmp	Quit1
		.endif
;********************************************************************
; Connect server
;********************************************************************
		invoke	WinHttpConnect,@hSession,@stUrl.lpszHostName,INTERNET_DEFAULT_PORT,0
		.if	!eax
			xor	eax,eax
			mov	@lpData,eax
			jmp	Quit1
		.endif
		mov	@hConnect,eax
;********************************************************************
; Create request
;********************************************************************	
		.if	_lpOptional
			invoke	WinHttpOpenRequest,@hConnect,addr wszPost,@lpszRequest,NULL,WINHTTP_NO_REFERER,WINHTTP_DEFAULT_ACCEPT_TYPES,WINHTTP_FLAG_ESCAPE_PERCENT OR WINHTTP_FLAG_REFRESH
		.else
			invoke	WinHttpOpenRequest,@hConnect,addr wszGet,@lpszRequest,NULL,WINHTTP_NO_REFERER,WINHTTP_DEFAULT_ACCEPT_TYPES,WINHTTP_FLAG_ESCAPE_PERCENT OR WINHTTP_FLAG_REFRESH
		.endif
		.if	!eax
			xor	eax,eax
			mov	@lpData,eax
			jmp	Quit2
		.endif
		mov	@hHTTP,eax
;********************************************************************
; Necessary header
;********************************************************************
		.if	_lpOptional
			invoke	WinHttpAddRequestHeaders,@hHTTP,addr wszContentType,-1,WINHTTP_ADDREQ_FLAG_ADD OR WINHTTP_ADDREQ_FLAG_REPLACE
			.if	!eax
				xor	eax,eax
				mov	@lpData,eax
				jmp	Quit3
			.endif
		.endif
;********************************************************************
; Post
;********************************************************************
		.if	!_dwSize
			invoke	lstrlenA,_lpOptional
		.else
			mov	eax,_dwSize
		.endif
		invoke	WinHttpSendRequest,@hHTTP,WINHTTP_NO_ADDITIONAL_HEADERS,NULL,_lpOptional,eax,eax,0
		.if	!eax
			xor	eax,eax
			mov	@lpData,eax
			jmp	Quit3
		.endif
;********************************************************************
; Receive
;********************************************************************
		invoke	WinHttpReceiveResponse,@hHTTP,0
		.if	!eax
			xor	eax,eax
			mov	@lpData,eax
			jmp	Quit3
		.endif

		;invoke	GlobalAlloc,GMEM_ZEROINIT,1
		invoke	HeapAlloc,_hHTTP,HEAP_ZERO_MEMORY,1
		.if	eax
			mov	@lpBuf,eax
			mov	@nDataSize,0
		.else
			xor	eax,eax
			mov	@lpData,eax
			jmp	Quit3
		.endif
		.while	TRUE
;********************************************************************
; Get data size and resize buffer
;********************************************************************
			mov	eax,_lpCallback
			.if	eax
				push	@nDataSize
				call	eax		;;callback(size)
			.endif
			invoke	WinHttpQueryDataAvailable,@hHTTP,addr @nSize
			.if	!eax
				xor	eax,eax
				mov	@lpData,eax
				jmp	Quit4
			.endif
			.if	!@nSize
				.break
			.else
				mov	eax,@nDataSize	;@nDataSize=what we have now
				add	eax,@nSize	;eax=total length
				invoke	HeapReAlloc,_hHTTP,HEAP_ZERO_MEMORY,@lpBuf,eax
				.if	eax
					mov	@lpBuf,eax
				.else
					xor	eax,eax
					mov	@lpData,eax
					jmp	Quit4
				.endif
			.endif
;********************************************************************
; Read data
;********************************************************************
			add	eax,@nDataSize
			mov	ebx,eax
			invoke	WinHttpReadData,@hHTTP,ebx,@nSize,addr @nSize
			.if	!eax
				xor	eax,eax
				mov	@lpData,eax
				jmp	Quit4
			.endif
			mov	eax,@nDataSize
			add	eax,@nSize
			mov	@nDataSize,eax
		.endw
;********************************************************************
; Allocate memory
;********************************************************************
		inc	@nDataSize	;for the last '\0'
		invoke	HeapAlloc,_hHTTP,HEAP_ZERO_MEMORY,@nDataSize
		.if	eax && (eax < 0c0000000h)
			mov	@lpData,eax
		.else
			xor	eax,eax
			mov	@lpData,eax
			jmp	Quit4
		.endif
		mov	ecx,@nDataSize
		mov	esi,@lpBuf
		mov	edi,eax
		cld
		rep	movsb
;********************************************************************
; Clean up
;********************************************************************
Quit4:		invoke	HeapFree,_hHTTP,NULL,@lpBuf
Quit3:		invoke	WinHttpCloseHandle,@hHTTP
Quit2:		invoke	WinHttpCloseHandle,@hConnect
Quit1:		invoke	WinHttpCloseHandle,@hSession

Quit0:		invoke	HeapFree,_hHTTP,NULL,@lpszRequest
		
QuitAlloc0:	invoke	HeapFree,_hHTTP,NULL,@lpszExtraInfo
QuitAlloc1:	invoke	HeapFree,_hHTTP,NULL,@lpszUrlPath
QuitAlloc2:	invoke	HeapFree,_hHTTP,NULL,@lpszHostName
		mov	eax,@lpData
		ret

XMLHTTPPostCallbackW	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
XMLHTTPPostW	proc	uses ebx edi esi,_hHTTP,_lpszURL,_lpOptional,_dwSize

		invoke	XMLHTTPPostCallbackW,_hHTTP,_lpszURL,_lpOptional,_dwSize,NULL
		ret
XMLHTTPPostW	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;********************************************************************
; Post the request, ansi version with downloading information
;********************************************************************
XMLHTTPPostCallbackA	proc	uses ebx edi esi,_hHTTP,_lpszURL,_lpOptional,_dwSize,_lpCallback
		local	@lpszURL,@cchWideChar

		invoke	lstrlenA,_lpszURL
		inc	eax
		shl	eax,1
		mov	@cchWideChar,eax
		invoke	HeapAlloc,_hHTTP,HEAP_ZERO_MEMORY,eax
		.if	eax && (eax < 0c0000000h)
			mov	@lpszURL,eax
		.else
			xor	eax,eax
			ret
		.endif

		invoke	MultiByteToWideChar,CP_ACP,NULL,_lpszURL,-1,@lpszURL,@cchWideChar
		invoke	XMLHTTPPostCallbackW,_hHTTP,@lpszURL,_lpOptional,_dwSize,_lpCallback
		
		push	eax
		invoke	HeapFree,_hHTTP,NULL,@lpszURL
		pop	eax
		ret
XMLHTTPPostCallbackA	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
XMLHTTPPostA	proc	uses ebx edi esi,_hHTTP,_lpszURL,_lpOptional,_dwSize

		invoke	XMLHTTPPostCallbackA,_hHTTP,_lpszURL,_lpOptional,_dwSize,NULL
		ret
XMLHTTPPostA	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;********************************************************************
; Convert MBCS to MBCS/UTF-16LE
;********************************************************************
XMLHTTPConvert	proc	uses ebx edi esi,_hHTTP,_lpData,_dwOriCodePage,_dwCodePage
		local	@lpwData,@lpData,@cchWideChar

		invoke	lstrlenA,_lpData
		inc	eax
		shl	eax,2
		mov	@cchWideChar,eax

		invoke	HeapAlloc,_hHTTP,HEAP_ZERO_MEMORY,@cchWideChar
		.if	eax && (eax < 0c0000000h)
			mov	@lpwData,eax
		.else
			xor	eax,eax
			ret
		.endif
		invoke	MultiByteToWideChar,_dwOriCodePage,NULL,_lpData,-1,@lpwData,@cchWideChar

		mov	eax,_dwCodePage
		.if	eax ==	CP_UTF16
			invoke	HeapFree,_hHTTP,NULL,_lpData
			mov	eax,@lpwData
		.else
			invoke	HeapAlloc,_hHTTP,HEAP_ZERO_MEMORY,@cchWideChar
			.if	eax && (eax < 0c0000000h)
				mov	@lpData,eax
			.else
				invoke	HeapFree,_hHTTP,NULL,@lpwData
				xor	eax,eax
				ret
			.endif
			invoke	WideCharToMultiByte,_dwCodePage,NULL,@lpwData,-1,@lpData,@cchWideChar,0,0
			invoke	HeapFree,_hHTTP,NULL,@lpwData
			invoke	HeapFree,_hHTTP,NULL,_lpData
			
			mov	eax,@lpData
		.endif
		ret
XMLHTTPConvert	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>