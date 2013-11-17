		.486
		.model flat, stdcall
		option casemap :none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Include 文件定义
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include		windows.inc
include		user32.inc
includelib	user32.lib
include		kernel32.inc
includelib	kernel32.lib
include		shell32.inc
includelib	shell32.lib
include		winhttp.inc
includelib	winhttp.lib
include		shlwapi.inc
includelib	shlwapi.lib
include		kdays.inc
__DEBUG__	equ	TRUE
debug		macro	__lpszText
		ifdef		__DEBUG__
			if	__DEBUG__
				pushad
				invoke	MessageBox,0,__lpszText,0,0
				popad
			endif
		endif
		endm
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
include		HttpRequest.asm
include		IniParser.asm
include		Base64.asm
include		MD5.asm
include		api.asm
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
DllMain		proc	hinstDLL,fdwReason,lpvReserved

		mov	eax,TRUE
		ret

DllMain		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	DllMain