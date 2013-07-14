		.386
		.model flat,stdcall
		option casemap:none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Include
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include		windows.inc
include		user32.inc
includelib	user32.lib
include		kernel32.inc
includelib	kernel32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Data
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
lpText	dd	?
		.const
cszProgramName	db	"csr2txt"
cszNoOutput	db	": This file doesn't contain any conversation. THIS IS NOT AN ERROR.",0dh,0ah,0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
include		common.asm
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
		invoke	_CommonInit
		invoke	_OpenInput
		
		invoke	lstrlen,lpInput
		invoke	GlobalAlloc,GPTR,eax
		.if	!eax
			invoke	_DisplayMessage,addr cszAlloc
			invoke	ExitProcess,5
		.endif
		mov	lpText,eax
		
		mov	esi,lpInput
		mov	edi,lpText
		xor	eax,eax
		mov	ebx,lpInput
		add	ebx,dwInput	;End of memory
		cld
		.while	TRUE
			xor	eax,eax
			.break	.if	esi >= ebx
			lodsb
			.break	.if	!al
			.if	al == '0'	;Instruction
				.while	TRUE
					lodsb
					.break	.if	al == 0ah
				.endw
			.elseif	al == '#'	;CLS
				.while	TRUE
					lodsb
					.break	.if	al == 0ah
				.endw
			.elseif	al == '!'	;Character
				.while	TRUE
					lodsb
					.break	.if	al == 0dh
					stosb
				.endw
				inc	esi
			.elseif	al == ' '	;Conversation
				mov	ah,[esi]
				.if	ah == 0dh
					inc	esi
					inc	esi
					.continue
				.endif
				.while	TRUE
					lodsb
					.if	al == '\'
						;remove control characters, this list may be incomplete or even wrong
						;tested with Ikinari anata ni koishite iru(http://www.makura-soft.com/ikikoi/)
						mov	ah,[esi]
						.if	ah == 'n'
							inc	esi
							.continue
						.elseif	ah == '@'
							inc	esi
							.continue
						.elseif	ah == 'p'
							inc	esi
							inc	esi
							.continue
						.elseif	ah == 'f'
							.while	TRUE
								lodsb
								.break	.if	al == 0dh
								.break	.if	al > 127
							.endw
						.elseif	ah == 'w'
							.while	TRUE
								lodsb
								.break	.if	al > 127
							.endw
						.elseif	ah == 'c'
							.while	TRUE
								lodsb
								.break	.if	al == 0dh
								.break	.if	al == '['
								.break	.if	al > 127
							.endw
						.endif
					.endif
					stosb
					.break	.if	al == 0ah
				.endw
			.else			;For something I don't know
				stosb
				.while	TRUE
					lodsb
					stosb
					.break	.if	al == 0ah
				.endw
			.endif
		.endw
		stosb
		
		invoke	lstrlen,lpText
		.if	!eax
			invoke	_DisplayMessage,addr cszNoOutput
			invoke	ExitProcess,0
		.endif
		
		invoke	lstrlen,lpszFile
		mov	ecx,lpszFile
		add	ecx,eax
		sub	ecx,3
		mov	dword ptr [ecx],'.txt'
		
		invoke	lstrlen,lpText
		invoke	_OpenOutput,eax
		
		invoke	lstrcpy,lpOutput,lpText
		
		invoke	ExitProcess,0
		ret
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start