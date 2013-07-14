		option casemap:none
		option frame:auto
		option win64:2
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include		windows.inc
includelib	kernel32.lib
includelib	user32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
dwTime		dd	?
dqCount		dq	?
szBuf		db	128 dup (?)
		.const
szFmt		db	"In %i ms, ExceptionHandler has been executed %I64i times.",0
szDefault_x64	db	"Default_x64",0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start		proc	frame
		invoke	GetTickCount
		mov	dwTime,eax
		
		.while	TRUE
			inc	dqCount
			invoke	GetTickCount
			sub	eax,dwTime
			.if	eax >= 1000
				invoke	wsprintf,addr szBuf,addr szFmt,eax,dqCount
				invoke	MessageBox,0,addr szBuf,addr szDefault_x64,0
				invoke	ExitProcess,0
			.endif
		.endw
		ret
start		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end start