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
szDefault	db	"Default",0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
		invoke	GetTickCount
		mov	dwTime,eax
		
		.while	TRUE
			inc	dwCount
			invoke	GetTickCount
			sub	eax,dwTime
			.if	eax >= 1000
				invoke	wsprintf,addr szBuf,addr szFmt,eax,dwCount
				invoke	MessageBox,0,addr szBuf,addr szDefault,0
				invoke	ExitProcess,0
			.endif
		.endw
		ret
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start