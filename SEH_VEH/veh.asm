		.386
		.model flat,stdcall
		option casemap:none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include		windows.inc
includelib	kernel32.lib
includelib	user32.lib
AddVectoredExceptionHandler	proto	FirstHandler:ULONG,VectoredHandler:PVECTORED_EXCEPTION_HANDLER
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
dwTime		dd	?
dwCount		dd	?
szBuf		db	128 dup (?)
		.const
szFmt		db	"In %i ms, ExceptionHandler has been executed %i times.",0
szVEH		db	"VEH",0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
VectoredHandler	proc	uses ebx esi edi ExceptionInfo
		inc	dwCount
		invoke	GetTickCount
		sub	eax,dwTime
		.if	eax >= 1000
			invoke	wsprintf,addr szBuf,addr szFmt,eax,dwCount
			invoke	MessageBox,0,addr szBuf,addr szVEH,0
			invoke	ExitProcess,0
		.endif
		mov	eax,EXCEPTION_CONTINUE_EXECUTION 
		ret
VectoredHandler	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
		invoke	AddVectoredExceptionHandler,TRUE,VectoredHandler
		invoke	GetTickCount
		mov	dwTime,eax
		xor	eax,eax
		mov	[eax],eax
		ret
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start