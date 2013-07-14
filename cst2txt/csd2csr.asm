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
lpScript	dd	?
		.const
cszProgramName	db	"csd2csr"
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
include		common.asm
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
		invoke	_CommonInit
		invoke	_OpenInput
		
		;struct	csstring
		;{
		;	byte beginning=0x01;
		;	byte[] string;
		;	byte end=0x00;
		;}
		;struct	csdfile
		;{
		;	dword size;
		;	dword totalCLR; //the number of "clear screen command"(02h) + 1
		;	dword sizeControlByte;
		;	dword sizeControlByteAndTextOffset;
		;	byte ControlByte[sizeControlByte];
		;	dword TextOffset[(sizeControlByteAndTextOffset-sizeControlByte)/4];
		;	csstring Text[];
		;}

		mov	eax,lpInput
		mov	eax,dword ptr [eax]
		invoke	GlobalAlloc,GPTR,eax
		.if	!eax
			invoke	_DisplayMessage,addr cszAlloc
			invoke	ExitProcess,5
		.endif
		mov	lpScript,eax
		
		mov	esi,lpInput
		mov	eax,[esi+12]	;[esi+12]=sizeControlByteAndTextOffset
		add	esi,eax		;now esi=>text[]-16
		add	esi,16		;size + totalCLR + sizeControlByte + sizeControlByteAndTextOffset
		mov	edi,lpScript
		xor	eax,eax
		mov	ebx,lpInput
		add	ebx,dwInput	;end of file
		cld
		.while	TRUE
			xor	eax,eax
			.break	.if	esi >= ebx
			lodsb
			.break	.if	al != 01h	;beginning of csstring
			.while	TRUE
				lodsb
				.if	al == 00h	;end of csstring
					mov	ax,0a0dh
					stosw
					.break
				.elseif	al == 02h	;CLS byte
					mov	eax,534C4323h	;#CLS
					stosd
					.continue
				.endif
				stosb
			.endw
		.endw
		stosb
		
		invoke	lstrlen,lpszFile
		mov	ecx,lpszFile
		add	ecx,eax
		dec	ecx
		mov	byte ptr [ecx],'r'	;rearrange
		
		invoke	lstrlen,lpScript
		invoke	_OpenOutput,eax
		
		invoke	lstrcpy,lpOutput,lpScript
		
		invoke	ExitProcess,0
		ret
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start