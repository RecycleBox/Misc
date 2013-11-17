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
ThreadProc	proc	lpParameter
		local	@stKDays:KDAYS_OBJECT
		local	@hKDays
		.data
szBuf		db	128 dup (0)
szFmt		db	"%d",0

szTest		db	"lastvisit",0
		.const
szPublicKey	db	"70d01ff1ba1742",0
szPrivateKey	db	"b72eb0d5ad97",0
szUsername	db	"bugmenot1",0
szMd5Pswrd	db	"5e8734c8e7e36d50bfb0dcdffa609b88",0
szUsername1	db	"undefined",0
szMd5Pswrd1	db	"1bd9240b587c88d93df06a1122090287",0
		.code
		pushad
		invoke	RtlZeroMemory,addr @stKDays,sizeof @stKDays
		push	offset szPublicKey
		pop	@stKDays.lpszPublicKey
		push	offset szPrivateKey
		pop	@stKDays.lpszPrivateKey
		
		invoke	kdays_create,addr @stKDays
		mov	@hKDays,eax
		mov	esi,eax
		assume	esi:ptr KDAYS_OBJECT

		invoke	kdays_get_access_token,@hKDays,addr szUsername,addr szMd5Pswrd
		
		;invoke	kdays_key2value,@hKDays,addr szTest,addr szTest,NULL
		;invoke	kdays_key2value,@hKDays,addr szTest,NULL,addr szBuf
		;invoke	MessageBox,0,addr szBuf,0,0
		
		invoke	kdays_check_notify,@hKDays,0
		invoke	kdays_get_user_info,@hKDays,addr szTest,addr szBuf
		
		assume	esi:nothing
		invoke	ExitThread,0
		popad
		ret
ThreadProc	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
DllMain		proc	hinstDLL,fdwReason,lpvReserved

		.if	fdwReason == DLL_PROCESS_ATTACH
			push	eax
			invoke	CreateThread,NULL,0,offset ThreadProc,NULL,NULL,esp
			invoke	CloseHandle,eax
			pop	eax
		.endif
		mov	eax,TRUE
		ret

DllMain		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	DllMain