		.386
		.model flat,stdcall
		option casemap:none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include		windows.inc
includelib	kernel32.lib
includelib	user32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
dwTime		dd	?
dwCount		dd	?
szBuf		db	128 dup (?)
		.const
szFmt		db	"In %i ms, ExceptionHandler has been executed %i times.",0
szSEH		db	"SEH",0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ExceptionRoutine proc	C uses ebx esi edi ExceptionRecord,EstablisherFrame,ContextRecord,DispatcherContext
		inc	dwCount
		invoke	GetTickCount
		sub	eax,dwTime
		.if	eax >= 1000
			invoke	wsprintf,addr szBuf,addr szFmt,eax,dwCount
			invoke	MessageBox,0,addr szBuf,addr szSEH,0
			invoke	ExitProcess,0
		.endif
		mov	eax,ExceptionContinueExecution 
		ret
ExceptionRoutine endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
		assume	fs:nothing
		push	offset ExceptionRoutine
		push	fs:[0]
		mov	fs:[0],esp
		invoke	GetTickCount
		mov	dwTime,eax
		xor	eax,eax
		mov	[eax],eax
		ret
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start