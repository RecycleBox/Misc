		option casemap:none
		option frame:auto
		option win64:2
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include		windows.inc
includelib	kernel32.lib
includelib	user32.lib
AddVectoredExceptionHandler	proto	FirstHandler:ULONG,VectoredHandler:PVECTORED_EXCEPTION_HANDLER
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
dwTime		dd	?
dqCount		dq	?
szBuf		db	128 dup (?)
		.const
szFmt		db	"In %i ms, ExceptionHandler has been executed %I64i times.",0
szVEH_x64	db	"VEH_x64",0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
VectoredHandler	proc	frame	ExceptionInfo
		inc	dqCount
		invoke	GetTickCount
		sub	eax,dwTime
		.if	eax >= 1000
			invoke	wsprintf,addr szBuf,addr szFmt,eax,dqCount
			invoke	MessageBox,0,addr szBuf,addr szVEH_x64,0
			invoke	ExitProcess,0
		.endif
		mov	eax,EXCEPTION_CONTINUE_EXECUTION 
		ret
VectoredHandler	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start		proc	frame
		mov	rax,VectoredHandler
		invoke	AddVectoredExceptionHandler,TRUE,rax
		invoke	GetTickCount
		mov	dwTime,eax
		xor	rax,rax
		mov	[rax],rax
		ret
start		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end start