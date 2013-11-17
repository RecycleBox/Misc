;http://www.rohitab.com/discuss/topic/10615-base64-encoding-example/
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数声明
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
Base64Encode	proto	pFile:DWORD,dwLen:DWORD,pBase64:DWORD
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.const
BASE64STRING	db	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/" 
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code 
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
Base64Encode	proc	uses ebx esi edi pFile:DWORD,dwLen:DWORD,pBase64:DWORD

		xor	eax,eax
		mov	edi,pBase64
		mov	esi,pFile
		mov	ecx,dwLen
		mov	edx,19
		xor	ebx,ebx
		cld
_loop:
		mov	al,byte ptr [esi]
		and	eax,0FCh
		sar	eax,2
		stosb

		lodsb
		and	eax,3h
		sal	eax,4
		stosb
		dec	ecx
		jz	_done

		dec	edi
		mov	al,byte ptr [esi]
		and	eax,0F0h
		sar	eax,4
		or	byte ptr [edi],al
		inc	edi

		lodsb
		and	eax,0Fh
		sal	eax,2
		stosb
		dec	ecx
		jz	_done

		dec	edi
		mov	al,byte ptr [esi]
		and	eax,0C0h
		sar	eax,6
		or	byte ptr [edi],al
		inc	edi

		lodsb
		and	eax,03Fh
		stosb

		dec	edx
		jnz	@F
		mov	edx,19
		mov	ax,0a0dh
		stosw
		xor	eax,eax
		add	ebx,2
@@:
		dec	ecx
		jnz	_loop
_done:
		mov	eax,edi
		sub	eax,pBase64
		mov	esi,eax		; esi = length of base64-encoded file
; table lookups
		push	ebx
		push	edi

		mov	edi,pBase64
		mov	ecx,esi
		lea	ebx,BASE64STRING
		xor	eax,eax
		mov	edx,76
_lutLoop:
		mov	al,byte ptr [edi]
		xlatb
		stosb

		dec	edx
		jnz	@F		; every 76:th char is a 'CRLF', skip those
		add	edi,2
		dec	ecx
		jz	_dooone
		dec	ecx
		jz	_dooone
		mov	edx,76
@@:
		dec	ecx		; fara= ecx skulle kunna bli -1
		jnz	_lutLoop
_dooone:
		pop	edi
		pop	ebx
; Check if padding is needed
		mov	eax,esi
		sub	eax,ebx

		mov	eax,esi
		xor	edx,edx
		mov	ecx,4
		div	ecx
		test	edx,edx
		jz	_noPad
		sub	ecx,edx
		add	esi,ecx		; add the nr. of pad-bytes to length of base64-encoded file
		mov	al,'='

		rep	stosb		; add ecx-nr. of "=" pad-bytes
_noPad:
		xor	eax,eax
		stosb
		mov	eax,esi		; return length of base64-encoded file
		ret
		
Base64Encode	endp