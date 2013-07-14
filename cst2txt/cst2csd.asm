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
include		Lib\zlib1.inc
includelib	Lib\zlib1.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Data
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.const
cszProgramName	db	"cst2csd"
cszZlib		db	": cannot uncompress",0dh,0ah,0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
include		common.asm
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
		invoke	_CommonInit
		invoke	_OpenInput
		
		;struct	cstfile
		;{ 
		;	byte magic[8]="CatScene";
		;	dword sizeZipStream;
		;	dword sizeOriginalStream;
		;	byte zipStream[sizeZipStream];
		;}

		mov	ebx,lpInput
		add	ebx,8
		mov	esi,[ebx]	;sizeZipStream
		mov	edi,[ebx+4]	;sizeOriginalStream
		mov	dwOutput,edi
		add	ebx,8		;ZipStream
		
		invoke	lstrlen,lpszFile
		mov	ecx,lpszFile
		add	ecx,eax
		dec	ecx
		mov	byte ptr [ecx],'d'	;decompress
		invoke	_OpenOutput,dwOutput
		
		;uncompress(Bytef *dest,uLongf *destLen,const Bytef *source,uLong sourceLen)
		invoke	uncompress,lpOutput,addr dwOutput,ebx,esi
		.if	eax != Z_OK
			invoke	_DisplayMessage,addr cszZlib
			invoke	ExitProcess,5
		.endif
		
		invoke	ExitProcess,0
		ret
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start