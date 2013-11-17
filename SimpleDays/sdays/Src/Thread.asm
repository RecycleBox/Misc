		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcThread	proc	lParam
		local	@szOutput[128],@szLastCheck[128]

		pushad
		.while	TRUE
			invoke	WaitForSingleObject,hMutexTable,INFINITE
			
			mov	esi,lpAccountTable
			add	esi,sizeof TABLE_HEAD
			mov	eax,sizeof ACCOUNT_TABLE
			mul	lParam
			add	esi,eax
			assume	esi:ptr ACCOUNT_TABLE
			
			invoke	kdays_message,[esi].hKDays,0,addr @szOutput
			.if	eax
				invoke	lstrcmp,addr @szOutput,addr @szLastCheck
				.if	eax
					invoke	_ShowPopup,[esi].stOptional.lpszUsername,addr szNewMessage,NIIF_INFO
				.endif
				invoke	lstrcpy,addr @szLastCheck,addr @szOutput
			.endif
				
			push	[esi].stOptional.dwDelay
			
			invoke	ReleaseMutex,hMutexTable
			
			call	Sleep
			assume	esi:nothing
		.endw
		popad
		invoke	ExitThread,0
		ret
_ProcThread	endp