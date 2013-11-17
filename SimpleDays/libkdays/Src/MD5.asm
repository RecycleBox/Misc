;MD5计算函数
;作者：狂编,hg-soft@263.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数声明
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
MD5_GetCode	PROTO	pSrc:DWORD,nSize:DWORD,pDest:DWORD
;MD5_GetCode 一次性提交计算使用的函数

MD5_Encode	PROTO	pSrc:DWORD,nSize:DWORD,nTotal:DWORD,pDest:DWORD,nSlice:DWORD
;MD5_Encode 分段提交计算使用的函数，比如当你以内存映射打开文件时就可以使用这个函数。
;参数说明
;	pSrc,用来计算的源数据的起始地址
;	nSize,本次提交的数据字节数。当nSlice=1或2时，该值必须是64的整倍数
;	nTotal,参加计算的数据总字节数。比如你想计算一个文件时，nTotal就是整个文件的总长度。
;	pDest,用来输出结果的 16 字节的缓冲区地址
;	nSlice,提交数据分段,0=数据不分段,1=数据开始段,2=数据中间段,3=数据结束段,(当一次性提交时该值应等于0)
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.const
szMD5Fmt	db	"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",0
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 宏定义
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
F		macro	x,y,z
		mov	eax,x
		mov	ecx,eax
		and	eax,y
		not	ecx
		and	ecx,z
		or	eax,ecx
		endm

G		macro	x,y,z
		mov	eax,x
		mov	ecx,y
		mov	edx,z
		and	eax,edx
		not	edx
		and	ecx,edx
		or	eax,ecx
		endm

H		macro	x,y,z
		mov	eax,x
		xor	eax,y
		xor	eax,z
		endm

I		macro	x,y,z
		mov	eax,y
		mov	ecx,x
		mov	edx,z
		not	edx
		or	ecx,edx
		xor	eax,ecx
		endm

FF		macro	a,b,c,d,x,s,ac
		F	b,c,d
		add	eax,x
		add	eax,ac
		add	eax,a
		rol	eax,s
		add	eax,b
		mov	a,eax
		endm

GG		macro	a,b,c,d,x,s,ac
		G	b,c,d
		add	eax,x
		add	eax,ac
		add	eax,a
		rol	eax,s
		add	eax,b
		mov	a,eax
		endm

HH		macro	a,b,c,d,x,s,ac
		H	b,c,d
		add	eax,x
		add	eax,ac
		add	eax,a
		rol	eax,s
		add	eax,b
		mov	a,eax
		endm

II		macro	a,b,c,d,x,s,ac
		I	b,c,d
		add	eax,x
		add	eax,ac
		add	eax,a
		rol	eax,s
		add	eax,b
		mov	a,eax
		endm
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 常量定义
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
S11		equ	7
S12		equ	12
S13		equ	17
S14		equ	22
S21		equ	5
S22		equ	9
S23		equ	14
S24		equ	20
S31		equ	4
S32		equ	11
S33		equ	16
S34		equ	23
S41		equ	6
S42		equ	10
S43		equ	15
S44		equ	21
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
MD5_Encode	proc	uses ebx esi edi pSrc:DWORD,nSize:DWORD,nTotal:DWORD,pDest:DWORD,nSlice:DWORD
		local	@pRead,@End[4]:byte
		local	_a,_b,_c,_d,_x[16]
		
			mov	eax,nSlice
			dec	eax				
			jg	SkipBeg				;一次性提交?;数据开始段?
			mov	edi,pDest
			mov	dword ptr [edi+0*4] , 067452301h
			mov	dword ptr [edi+1*4] , 0EFCDAB89h
			mov	dword ptr [edi+2*4] , 098BADCFEh
			mov	dword ptr [edi+3*4] , 010325476h
SkipBeg:		xor	eax,eax
			mov	@pRead,eax
			mov	@End,al
	LoopBlk:	mov	esi,pSrc
			lea	edi,_x
			mov	ecx,10h				;每次提取64字节,因此当文件未结束时,nSize必须以64字节(40h)对齐
			mov	ebx,@pRead
	@@:		lea	edx,[ebx+4]
			cmp	edx,nSize
			ja	@F
			mov	eax,[esi+ebx]
			;bswap	eax
			stosd
			mov	ebx,edx
			loop	@B
			mov	@pRead,ebx
			jmp	Enc1
	@@:		mov	eax,nSlice
			or	eax,eax				;一次性提交?
			jz	setEnd
			cmp	eax,3				;数据结束段?
			jnz	Result
setEnd:			mov	edx,ecx
			cmp	ebx,nSize
			ja	Tail0
			sub	eax,eax
			mov	ch,4
	@@:		cmp	ebx,nSize
			jz	@F
			shl	eax,8
			mov	al,[esi+ebx]
			inc	ebx
			dec	ch
			jmp	@B
	@@:		inc	ebx
			mov	@pRead,ebx
			shl	eax,8
			mov	al,80h
	@@:		dec	ch
			jz	@F
			shl	eax,8
			jmp	@B
	@@:
	bswap eax
			stosd
			dec	ecx
			jz	Enc1
	Tail0:		sub	eax,eax
			rep	stosd
			cmp	dl,3
			jb	Enc1
			mov	al,8
			mul	nTotal
	xchg eax,edx
			mov	dword ptr _x[38h],edx
			mov	dword ptr _x[3Ch],eax
			mov	@End,1
;----------
	Enc1:		mov	eax,pDest
			mov	edx,[eax+0*4]
			mov	_a,edx
			mov	edx,[eax+1*4]
			mov	_b,edx
			mov	edx,[eax+2*4]
			mov	_c,edx
			mov	edx,[eax+3*4]
			mov	_d,edx
  ; Round 1
			FF _a,_b,_c,_d,_x[ 0*4], S11, 0D76AA478h		;* 1 *
			FF _d,_a,_b,_c,_x[ 1*4], S12, 0E8C7B756h		;* 2 *
			FF _c,_d,_a,_b,_x[ 2*4], S13, 0242070DBh		;* 3 *
			FF _b,_c,_d,_a,_x[ 3*4], S14, 0C1BDCEEEh		;* 4 *
			FF _a,_b,_c,_d,_x[ 4*4], S11, 0F57C0FAFh		;* 5 *
			FF _d,_a,_b,_c,_x[ 5*4], S12, 04787C62Ah		;* 6 *
			FF _c,_d,_a,_b,_x[ 6*4], S13, 0A8304613h		;* 7 *
			FF _b,_c,_d,_a,_x[ 7*4], S14, 0FD469501h		;* 8 *
			FF _a,_b,_c,_d,_x[ 8*4], S11, 0698098D8h		;* 9 *
			FF _d,_a,_b,_c,_x[ 9*4], S12, 08B44F7AFh		;* 10 *
			FF _c,_d,_a,_b,_x[10*4], S13, 0FFFF5BB1h		;* 11 *
			FF _b,_c,_d,_a,_x[11*4], S14, 0895CD7BEh		;* 12 *
			FF _a,_b,_c,_d,_x[12*4], S11, 06B901122h		;* 13 *
			FF _d,_a,_b,_c,_x[13*4], S12, 0FD987193h		;* 14 *
			FF _c,_d,_a,_b,_x[14*4], S13, 0A679438Eh		;* 15 *
			FF _b,_c,_d,_a,_x[15*4], S14, 049B40821h		;* 16 *
  ; Round 2
			GG _a,_b,_c,_d,_x[ 1*4], S21, 0f61e2562h		;* 17 *
			GG _d,_a,_b,_c,_x[ 6*4], S22, 0c040b340h		;* 18 *
			GG _c,_d,_a,_b,_x[11*4], S23, 0265e5a51h		;* 19 *
			GG _b,_c,_d,_a,_x[ 0*4], S24, 0e9b6c7aah		;* 20 *
			GG _a,_b,_c,_d,_x[ 5*4], S21, 0d62f105dh		;* 21 *
			GG _d,_a,_b,_c,_x[10*4], S22, 002441453h		;* 22 *
			GG _c,_d,_a,_b,_x[15*4], S23, 0d8a1e681h		;* 23 *
			GG _b,_c,_d,_a,_x[ 4*4], S24, 0e7d3fbc8h		;* 24 *
			GG _a,_b,_c,_d,_x[ 9*4], S21, 021e1cde6h		;* 25 *
			GG _d,_a,_b,_c,_x[14*4], S22, 0c33707d6h		;* 26 *
			GG _c,_d,_a,_b,_x[ 3*4], S23, 0f4d50d87h		;* 27 *
			GG _b,_c,_d,_a,_x[ 8*4], S24, 0455a14edh		;* 28 *
			GG _a,_b,_c,_d,_x[13*4], S21, 0a9e3e905h		;* 29 *
			GG _d,_a,_b,_c,_x[ 2*4], S22, 0fcefa3f8h		;* 30 *
			GG _c,_d,_a,_b,_x[ 7*4], S23, 0676f02d9h		;* 31 *
			GG _b,_c,_d,_a,_x[12*4], S24, 08d2a4c8ah		;* 32 *
  ; Round 3
			HH _a,_b,_c,_d,_x[ 5*4], S31, 0fffa3942h		;* 33 *
			HH _d,_a,_b,_c,_x[ 8*4], S32, 08771f681h		;* 34 *
			HH _c,_d,_a,_b,_x[11*4], S33, 06d9d6122h		;* 35 *
			HH _b,_c,_d,_a,_x[14*4], S34, 0fde5380ch		;* 36 *
			HH _a,_b,_c,_d,_x[ 1*4], S31, 0a4beea44h		;* 37 *
			HH _d,_a,_b,_c,_x[ 4*4], S32, 04bdecfa9h		;* 38 *
			HH _c,_d,_a,_b,_x[ 7*4], S33, 0f6bb4b60h		;* 39 *
			HH _b,_c,_d,_a,_x[10*4], S34, 0bebfbc70h		;* 40 *
			HH _a,_b,_c,_d,_x[13*4], S31, 0289b7ec6h		;* 41 *
			HH _d,_a,_b,_c,_x[ 0*4], S32, 0eaa127fah		;* 42 *
			HH _c,_d,_a,_b,_x[ 3*4], S33, 0d4ef3085h		;* 43 *
			HH _b,_c,_d,_a,_x[ 6*4], S34, 004881d05h		;* 44 *
			HH _a,_b,_c,_d,_x[ 9*4], S31, 0d9d4d039h		;* 45 *
			HH _d,_a,_b,_c,_x[12*4], S32, 0e6db99e5h		;* 46 *
			HH _c,_d,_a,_b,_x[15*4], S33, 01fa27cf8h		;* 47 *
			HH _b,_c,_d,_a,_x[ 2*4], S34, 0c4ac5665h		;* 48 *
  ; Round 4
			II _a,_b,_c,_d,_x[ 0*4], S41, 0f4292244h		;* 49 *
			II _d,_a,_b,_c,_x[ 7*4], S42, 0432aff97h		;* 50 *
			II _c,_d,_a,_b,_x[14*4], S43, 0ab9423a7h		;* 51 *
			II _b,_c,_d,_a,_x[ 5*4], S44, 0fc93a039h		;* 52 *
			II _a,_b,_c,_d,_x[12*4], S41, 0655b59c3h		;* 53 *
			II _d,_a,_b,_c,_x[ 3*4], S42, 08f0ccc92h		;* 54 *
			II _c,_d,_a,_b,_x[10*4], S43, 0ffeff47dh		;* 55 *
			II _b,_c,_d,_a,_x[ 1*4], S44, 085845dd1h		;* 56 *
			II _a,_b,_c,_d,_x[ 8*4], S41, 06fa87e4fh		;* 57 *
			II _d,_a,_b,_c,_x[15*4], S42, 0fe2ce6e0h		;* 58 *
			II _c,_d,_a,_b,_x[ 6*4], S43, 0a3014314h		;* 59 *
			II _b,_c,_d,_a,_x[13*4], S44, 04e0811a1h		;* 60 *
			II _a,_b,_c,_d,_x[ 4*4], S41, 0f7537e82h		;* 61 *
			II _d,_a,_b,_c,_x[11*4], S42, 0bd3af235h		;* 62 *
			II _c,_d,_a,_b,_x[ 2*4], S43, 02ad7d2bbh		;* 63 *
			II _b,_c,_d,_a,_x[ 9*4], S44, 0eb86d391h		;* 64 *
			mov	esi,pDest
			mov	eax,_a
			add	[esi+0*4],eax
			mov	eax,_b
			add	[esi+1*4],eax
			mov	eax,_c
			add	[esi+2*4],eax
			mov	eax,_d
			add	[esi+3*4],eax

			cmp	@End,0
			jz	LoopBlk
			mov	edi,pDest
			mov	ecx,4
	@@:		mov	eax,[edi]
			;bswap	eax
			stosd
			loop	@B
Result:			ret
MD5_Encode	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
MD5_GetString	proc	uses ebx esi edi pSrc:DWORD,nSize:DWORD,pDest:DWORD
		local	@Hash[16]:byte

		invoke	MD5_Encode,pSrc,nSize,nSize,addr @Hash,0
		lea	ebx,@Hash
		mov	ecx,16
		.while	ecx
			dec	ecx
			movzx	eax,byte ptr [ebx+ecx]
			push	eax
		.endw
		push	offset szMD5Fmt
		push	pDest
		invoke	wsprintf
		add	esp,4*18
		ret
MD5_GetString	endp