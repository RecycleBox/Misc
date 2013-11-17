TABLE_HEAD	struct
	hHeap		dd	?
TABLE_HEAD	ends
SDAYS_OPTIONAL	struct
	dwDelay		dd	?
	lpszUsername	dd	?
SDAYS_OPTIONAL	ends
ACCOUNT_TABLE	struct
	hKDays		dd	?
	stOptional	SDAYS_OPTIONAL	<?>
ACCOUNT_TABLE	ends

		.const
szFont		db	"Ms Shell Dlg",0
uszUsername	dw	'U','s','e','r','n','a','m','e',0
uszPassword	dw	'P','a','s','s','w','o','r','d',0
szDelay		db	"Delay",0
szInvalidInput	db	"Invalid input",0
szIncorrectAccount db	"Account information is incorrect.",0
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcDlgLogin	proc	uses ebx edi esi hWnd,uMsg,wParam,lParam
		local	@Buf[64]: byte
		local	@Buf2[64]: byte
		
		mov	eax,uMsg
;********************************************************************
		.if	eax ==	WM_COMMAND
			mov	eax,wParam
			.if	ax  ==	IDOK
				push	0
				pop	dword ptr @Buf2
				.repeat
					invoke	GetDlgItemText,hWnd,EDIT_PASSWORD,addr @Buf,sizeof @Buf
					invoke	lstrlen,addr @Buf
					.if	!eax
						invoke	MessageBox,0,addr szInvalidInput,0,0
						.break
					.endif
					invoke	kdays_str_to_md5,addr @Buf,addr @Buf2

					invoke	GetDlgItem,hWnd,EDIT_USERNAME
					mov	ebx,eax
					invoke	GetWindowText,ebx,addr @Buf,sizeof @Buf
					invoke	lstrlen,addr @Buf
					.if	!eax
						invoke	MessageBox,0,addr szInvalidInput,0,0
						.break
					.endif
					invoke	WritePrivateProfileString,addr @Buf,addr szPassword,addr @Buf2,addr szAccountFull
					invoke	EndDialog,hWnd,1
				.until	TRUE
			.elseif	ax  ==	IDCANCEL
				invoke	EndDialog,hWnd,NULL
			.endif
;********************************************************************
		.elseif	eax ==	WM_INITDIALOG
			invoke	SendMessage,hWnd,WM_SETICON,ICON_SMALL,hIcon
			
			.if	!hFont
				invoke	CreateFont,36,0,0,0,0,FALSE,FALSE,FALSE,0,0,0,ANTIALIASED_QUALITY or CLEARTYPE_QUALITY,0,addr szFont
				mov	hFont,eax
			.endif
			invoke	GetDlgItem,hWnd,EDIT_USERNAME
			mov	ebx,eax
			invoke	PostMessage,ebx,WM_SETFONT,hFont,TRUE
			invoke	PostMessage,ebx,EM_SETCUEBANNER,FALSE,addr uszUsername
			invoke	_CreateTooltip,hWnd,ebx,addr szUsername
			
			invoke	GetDlgItem,hWnd,EDIT_PASSWORD
			mov	ebx,eax
			invoke	PostMessage,ebx,WM_SETFONT,hFont,TRUE
			invoke	PostMessage,ebx,EM_SETCUEBANNER,FALSE,addr uszPassword
			invoke	_CreateTooltip,hWnd,ebx,addr szPassword
;********************************************************************
		.elseif	eax ==	WM_CLOSE
			invoke	EndDialog,hWnd,NULL
;********************************************************************
		.else
			mov	eax,FALSE
			ret
		.endif
		mov	eax,TRUE
		ret

_ProcDlgLogin	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_UserLogin	proc	uses ebx edi esi
		
		
		invoke	DialogBoxParam,hInstance,DLG_LOGIN,NULL,offset _ProcDlgLogin,NULL
		ret
		
_UserLogin	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_MultiLogin	proc	uses ebx edi esi
		local	@hFile,@dwFile,@lpSection
		local	@szPassword[36]:byte
		local	@hHeap,@lpAccountTable
		local	@stKDays:KDAYS_OBJECT


		invoke	CreateFile,addr szAccountFull,NULL,FILE_SHARE_DELETE,NULL,OPEN_ALWAYS,NULL,NULL
		mov	@hFile,eax
		invoke	GetFileSize,eax,NULL
		mov	@dwFile,eax
		invoke	GlobalAlloc,GPTR,eax
		mov	@lpSection,eax
		invoke	CloseHandle,@hFile

		invoke	GetPrivateProfileSectionNames,@lpSection,@dwFile,addr szAccountFull
		.if	!eax
			invoke	GlobalFree,addr @lpSection
			xor	eax,eax
			ret
		.endif

		invoke	HeapCreate,0,0,0
		mov	@hHeap,eax
		invoke	HeapAlloc,@hHeap,HEAP_ZERO_MEMORY,sizeof TABLE_HEAD
		mov	@lpAccountTable,eax
		assume	ecx:ptr TABLE_HEAD
		mov	ecx,eax
		push	@hHeap
		pop	[ecx].hHeap
		
		
		invoke	RtlZeroMemory,addr @stKDays,sizeof @stKDays
		mov	@stKDays.lpszPublicKey,offset szPublicKey
		mov	@stKDays.lpszPrivateKey,offset szPrivateKey
		mov	ebx,@lpSection
		.while	TRUE
			assume	esi:ptr ACCOUNT_TABLE
			mov	ecx,@lpAccountTable
			invoke	HeapSize,[ecx].hHeap,NULL,@lpAccountTable
			mov	edi,eax
			add	eax,sizeof ACCOUNT_TABLE
			mov	ecx,@lpAccountTable
			invoke	HeapReAlloc,[ecx].hHeap,HEAP_ZERO_MEMORY,ecx,eax
			mov	@lpAccountTable,eax
			mov	esi,eax
			
			;ebx:指向Section
			;esi:指向AccountTable
			;edi:新Account偏移量
			
			invoke	kdays_create,addr @stKDays
			mov	[esi+edi].hKDays,eax
@@:
			invoke	GetPrivateProfileString,ebx,addr szPassword,NULL,addr @szPassword,sizeof @szPassword,addr szAccountFull
			invoke	kdays_get_access_token,[esi+edi].hKDays,ebx,addr @szPassword
			.if	eax == SIG_TIME_ERROR
				jmp	@B
			.elseif	eax != KDAYS_SUCCESS
				invoke	WritePrivateProfileSection,ebx,NULL,addr szAccountFull
				invoke	lstrlen,ebx
				inc	eax
				add	ebx,eax
				.break	.if	byte ptr [ebx] == 0
				jmp	@B
			.endif
			invoke	GetPrivateProfileInt,ebx,addr szDelay,60000,addr szAccountFull
			mov	[esi+edi].stOptional.dwDelay,eax
			
			invoke	lstrlen,ebx
			inc	eax
			mov	ecx,@lpAccountTable
			invoke	HeapAlloc,[ecx].hHeap,HEAP_ZERO_MEMORY,eax
			mov	[esi+edi].stOptional.lpszUsername,eax
			invoke	lstrcpy,[esi+edi].stOptional.lpszUsername,ebx
			;叫线程出来干活了
			
			invoke	lstrlen,ebx
			inc	eax
			add	ebx,eax
			.break	.if	byte ptr [ebx] == 0
		.endw
		invoke	GlobalFree,@lpSection
		mov	esi,@lpAccountTable
		mov	edi,sizeof TABLE_HEAD
		mov	eax,[esi+edi].stOptional.dwDelay
		.if	eax
			invoke	CreateMutex,NULL,FALSE,NULL
			mov	hMutexTable,eax
			mov	ecx,@lpAccountTable
			invoke	HeapSize,[ecx].hHeap,NULL,@lpAccountTable
			mov	edi,eax
			add	eax,sizeof ACCOUNT_TABLE
			mov	ecx,@lpAccountTable
			invoke	HeapReAlloc,[ecx].hHeap,HEAP_ZERO_MEMORY,esi,eax
			mov	@lpAccountTable,eax
		.else
			invoke	kdays_release,[esi+edi].hKDays
			mov	ecx,@lpAccountTable
			invoke	HeapDestroy,[ecx].hHeap
			xor	eax,eax
		.endif
		assume	esi:nothing
		assume	ecx:nothing
		ret
_MultiLogin	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_AddLogin	proc	uses ebx edi esi
		local	@hFile,@dwFile,@lpSection
		local	@hHeap,@hMutex
		local	@lpszUsername
		local	@stKDays:KDAYS_OBJECT,@hKDays,@szPassword[36]:byte
		local	@dwOffset

		invoke	CreateFile,addr szAccountFull,NULL,FILE_SHARE_DELETE,NULL,OPEN_ALWAYS,NULL,NULL
		mov	@hFile,eax
		invoke	GetFileSize,eax,NULL
		mov	@dwFile,eax
		invoke	GlobalAlloc,GPTR,eax
		mov	@lpSection,eax
		invoke	CloseHandle,@hFile

		invoke	GetPrivateProfileSectionNames,@lpSection,@dwFile,addr szAccountFull
		.if	!eax
			invoke	GlobalFree,addr @lpSection
			xor	eax,eax
			ret
		.endif

		invoke	RtlZeroMemory,addr @stKDays,sizeof @stKDays
		mov	@stKDays.lpszPublicKey,offset szPublicKey
		mov	@stKDays.lpszPrivateKey,offset szPrivateKey

		invoke	WaitForSingleObject,hMutexTable,INFINITE
		mov	esi,lpAccountTable
		assume	esi:ptr TABLE_HEAD
		push	[esi].hHeap
		pop	@hHeap
		add	esi,sizeof TABLE_HEAD
		assume	esi:ptr ACCOUNT_TABLE
		mov	ebx,@lpSection
		
		.while	TRUE
			.while	TRUE
				push	[esi].stOptional.lpszUsername
				pop	@lpszUsername
				.break	.if	!@lpszUsername
				invoke	lstrcmpi,ebx,@lpszUsername
				.break	.if	!eax
				add	esi,sizeof ACCOUNT_TABLE
			.endw
			.if	!eax	;已经登录过
				;invoke	MessageBox,0,ebx,0,0
			.else		;未登录过
				invoke	kdays_create,addr @stKDays
				mov	@hKDays,eax
				invoke	GetPrivateProfileString,ebx,addr szPassword,NULL,addr @szPassword,sizeof @szPassword,addr szAccountFull
@@:				invoke	kdays_get_access_token,@hKDays,ebx,addr @szPassword
				.if	eax == SIG_TIME_ERROR
					jmp	@B
				.elseif	eax != KDAYS_SUCCESS
					invoke	WritePrivateProfileSection,ebx,NULL,addr szAccountFull
					invoke	MessageBox,0,addr szIncorrectAccount,0,0
				.else
					invoke	HeapSize,@hHeap,NULL,lpAccountTable
					sub	eax,sizeof ACCOUNT_TABLE
					mov	@dwOffset,eax
					add	eax,2 * sizeof ACCOUNT_TABLE
					invoke	HeapReAlloc,@hHeap,HEAP_ZERO_MEMORY,lpAccountTable,eax
					mov	lpAccountTable,eax

					mov	esi,lpAccountTable
					add	esi,@dwOffset
					push	@hKDays
					pop	[esi].hKDays
					invoke	GetPrivateProfileInt,ebx,addr szDelay,10000,addr szAccountFull
					mov	[esi].stOptional.dwDelay,eax
					invoke	lstrlen,ebx
					inc	eax
					invoke	HeapAlloc,@hHeap,HEAP_ZERO_MEMORY,eax
					mov	[esi].stOptional.lpszUsername,eax
					invoke	lstrcpy,eax,ebx
					
					push	eax
						mov	eax,@dwOffset
						sub	eax,sizeof TABLE_HEAD
						xor	edx,edx
						mov	ecx,sizeof ACCOUNT_TABLE
						div	ecx
						invoke	CreateThread,NULL,0,offset _ProcThread,eax,NULL,esp
						invoke	CloseHandle,eax
					pop	eax
				.endif
				
				
				
			.endif
			invoke	lstrlen,ebx
			inc	eax
			add	ebx,eax
			.break	.if	byte ptr [ebx] == 0
		.endw
		invoke	ReleaseMutex,hMutexTable
		
		ret
_AddLogin	endp