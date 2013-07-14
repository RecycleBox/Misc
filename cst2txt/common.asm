		.data?
hStdOut		dd	?
dwBytesWrite	dd	?

lpInput		dd	?
dwInput		dd	?
lpOutput	dd	?
dwOutput	dd	?

lpszFile	dd	?
		.const
cszUsage	db	"usage: "
cszUsage2	db	" <input file>",0dh,0ah,"MAX_PATH = 260",0dh,0ah

cszIOpenFile	db	": cannot open input file",0dh,0ah,0
cszIFileMapping	db	": cannot create mapping object for input file",0dh,0ah,0
cszIMapView	db	": cannot map the view of input file into the address space",0dh,0ah,0

cszAlloc	db	": cannot allocate the memory for conversion",0dh,0ah,0

cszOOpenFile	db	": cannot open output file",0dh,0ah,0
cszOFileMapping	db	": cannot create mapping object for output file",0dh,0ah,0
cszOMapView	db	": cannot map the view of output file into the address space",0dh,0ah,0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_DisplayMessage	proc	_lpszMessage

		invoke	WriteConsole,hStdOut,addr cszProgramName,sizeof cszProgramName,addr dwBytesWrite,NULL
		invoke	lstrlen,_lpszMessage
		.if	eax
			mov	ecx,eax
			invoke	WriteConsole,hStdOut,_lpszMessage,ecx,addr dwBytesWrite,NULL
		.endif
		ret
_DisplayMessage	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_CommonInit	proc

		invoke	GetStdHandle,STD_OUTPUT_HANDLE
		mov	hStdOut,eax
		ret
_CommonInit	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_OpenInput	proc

		invoke	GetCommandLine
		mov	esi,eax
		xor	eax,eax
		xor	edx,edx
		cld
		.repeat
			lodsb
			.if	eax == '"'
				.repeat
					lodsb
				.until	eax == '"'
			.elseif	(eax == ' ' || eax == '	')	;space and tab
				inc	edx
				.while	(eax == ' ' || eax == '	')
					lodsb
				.endw
				dec	esi
			.endif
		.until	eax == 0

		.if	edx == 0
			invoke	WriteConsole,hStdOut,addr cszUsage,sizeof cszUsage,addr dwBytesWrite,NULL
			invoke	WriteConsole,hStdOut,addr cszProgramName,sizeof cszProgramName,addr dwBytesWrite,NULL
			invoke	WriteConsole,hStdOut,addr cszUsage2,sizeof cszUsage2,addr dwBytesWrite,NULL
			invoke	ExitProcess,1
		.endif

		invoke	GetCommandLine
		mov	esi,eax
		xor	eax,eax
		cld
		.repeat
			lodsb
			.if	eax == '"'
				.repeat
					lodsb
				.until	eax == '"'
			.elseif	(eax == ' ' || eax == '	')	;space and tab
				.while	(eax == ' ' || eax == '	')
					lodsb
				.endw
				dec	esi
				invoke	lstrlen,esi
				inc	eax
				invoke	GlobalAlloc,GPTR,eax
				mov	lpszFile,eax
				invoke	lstrcpy,lpszFile,esi
				.break
			.endif
		.until	eax == 0
		invoke	CreateFile,lpszFile,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,NULL,NULL
		.if	eax == INVALID_HANDLE_VALUE
			invoke	_DisplayMessage,addr cszIOpenFile
			invoke	ExitProcess,2
		.endif
		mov	ebx,eax
		invoke	GetFileSize,ebx,NULL
		mov	dwInput,eax
		invoke	CreateFileMapping,ebx,NULL,PAGE_READONLY,NULL,NULL,NULL
		.if	!eax
			invoke	_DisplayMessage,addr cszIFileMapping
			invoke	ExitProcess,3
		.endif
		invoke	MapViewOfFile,eax,FILE_MAP_READ,NULL,NULL,NULL
		.if	!eax
			invoke	_DisplayMessage,addr cszIMapView
			invoke	ExitProcess,4
		.endif
		mov	lpInput,eax
		ret
_OpenInput	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_OpenOutput	proc	_dwFileSize

		invoke	CreateFile,lpszFile,GENERIC_READ or GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,NULL,NULL
		.if	eax == INVALID_HANDLE_VALUE
			invoke	_DisplayMessage,addr cszOOpenFile
			invoke	ExitProcess,2
		.endif
		invoke	CreateFileMapping,eax,NULL,PAGE_READWRITE,NULL,_dwFileSize,NULL
		.if	!eax
			invoke	_DisplayMessage,addr cszOFileMapping
			invoke	ExitProcess,3
		.endif
		invoke	MapViewOfFile,eax,FILE_MAP_WRITE,NULL,NULL,NULL
		.if	!eax
			invoke	_DisplayMessage,addr cszOMapView
			invoke	ExitProcess,4
		.endif
		mov	lpOutput,eax
		ret
_OpenOutput	endp