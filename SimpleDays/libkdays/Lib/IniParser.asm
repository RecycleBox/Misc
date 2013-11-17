		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_IniParser	proc	uses ebx edi esi _lpszData,_lpszKeyName,_lpszValue
		
		.if	(!_lpszData) || (!_lpszKeyName) || (!_lpszValue)
			xor	eax,eax
			ret
		.endif
		mov	esi,_lpszData
		cld
		.while	TRUE	;以行为单位,判断Section,Key以及空行
			.break	.if	byte ptr [esi] == 0	;文件末尾
			.if	(byte ptr [esi] == 0dh) || (byte ptr [esi] == 0ah)	;空行
				inc	esi
				.continue
			.endif
			mov	edi,_lpszKeyName
			.while	TRUE	;判断键值
				.if	(byte ptr [esi] == 0dh) || (byte ptr [esi] == 0ah)	;查找到了行末尾也没有匹配
					inc	esi
					.break
				.endif
				.break	.if	byte ptr [esi] == 0				;查找到了文件末尾
				.if	(byte ptr [esi] == '=') && (byte ptr [edi] == 0)	;Key匹配
					inc	esi
					mov	edi,_lpszValue
					.while	TRUE
						lodsb
						.break	.if	(al == 0dh) || (al == 0ah)
						.if	al  ==	0
							dec	esi
							.break
						.endif
						stosb
					.endw
					xor	eax,eax
					stosb
					.break
				.endif
				cmpsb
				.if	!ZERO?	;Key不匹配
					.while	TRUE
						lodsb
						.break	.if	(al == 0dh) || (al == 0ah)
						.if	al  ==	0
							dec	edi
							.break
						.endif
					.endw
					.break
				.endif
			.endw
		.endw
		ret
_IniParser	endp