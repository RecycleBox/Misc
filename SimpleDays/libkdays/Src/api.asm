;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
			.const
szKDaysServer		db	"http://kdays.cn/api/index.php",0
szCode			db	"code",0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
			.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 时间转换
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_timestamp_to_utc	proc	uses ebx edi esi
kdays_timestamp_to_utc	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_utc_to_timestamp	proc	uses ebx edi esi
kdays_utc_to_timestamp	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 编码
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_str_to_md5	proc	uses ebx edi esi _lpszInput,_lpszOutput

			invoke	lstrlen,_lpszInput
			invoke	MD5_GetString,_lpszInput,eax,_lpszOutput
			ret
kdays_str_to_md5	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_str_to_base64	proc	uses ebx edi esi _lpszInput,_lpszOutput

			invoke	lstrlen,_lpszInput
			invoke	Base64Encode,_lpszInput,eax,_lpszOutput
			ret
kdays_str_to_base64	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_str_codepage	proc	uses ebx edi esi _lpszInput,_lpszOutput,_dwCodePageInput,_dwCodePageOutput
			local	@dwInput
			local	@lpUnicodeString
			
			invoke	lstrlen,_lpszInput
			inc	eax
			mov	@dwInput,eax
			shl	eax,2
			invoke	GlobalAlloc,GPTR,eax
			mov	@lpUnicodeString,eax
			invoke	MultiByteToWideChar,_dwCodePageInput,NULL,_lpszInput,@dwInput,@lpUnicodeString,@dwInput
			invoke	WideCharToMultiByte,_dwCodePageOutput,NULL,@lpUnicodeString,@dwInput,_lpszOutput,10000000h,NULL,NULL
			invoke	GlobalFree,@lpUnicodeString
			ret
kdays_str_codepage	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; KDays对象操作
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_create		proc	uses ebx edi esi _lpstKDays
			local	@hHeap,@lpstKDays
			
			mov	esi,_lpstKDays
			assume	esi:ptr KDAYS_OBJECT
			
			invoke	HeapCreate,0,0,0
			mov	@hHeap,eax
			
			invoke	HeapAlloc,@hHeap,HEAP_ZERO_MEMORY,sizeof KDAYS_OBJECT
			mov	@lpstKDays,eax
			mov	edi,eax
			assume	edi:ptr KDAYS_OBJECT
			
			push	@hHeap
			pop	[edi].hHeap
			
			mov	ebx,[esi].lpszServer
			.if	ebx
				invoke	lstrlen,ebx
				inc	eax
				invoke	HeapAlloc,[edi].hHeap,HEAP_ZERO_MEMORY,eax
				mov	[edi].lpszServer,eax
				invoke	lstrcpy,eax,ebx
			.else
				mov	[edi].lpszServer,offset szKDaysServer
			.endif
			
			mov	ebx,[esi].lpszPublicKey
			.if	ebx
				invoke	lstrlen,ebx
				inc	eax
				invoke	HeapAlloc,[edi].hHeap,HEAP_ZERO_MEMORY,eax
				mov	[edi].lpszPublicKey,eax
				invoke	lstrcpy,eax,ebx
			.endif
			
			mov	ebx,[esi].lpszPrivateKey
			.if	ebx
				invoke	lstrlen,ebx
				inc	eax
				invoke	HeapAlloc,[edi].hHeap,HEAP_ZERO_MEMORY,eax
				mov	[edi].lpszPrivateKey,eax
				invoke	lstrcpy,eax,ebx
			.endif

			mov	ebx,[esi].lpszToken
			.if	ebx
				invoke	lstrlen,ebx
				inc	eax
				invoke	HeapAlloc,[edi].hHeap,HEAP_ZERO_MEMORY,eax
				mov	[edi].lpszToken,eax
				invoke	lstrcpy,eax,ebx
			.endif

			invoke	CreateMutex,NULL,FALSE,NULL
			mov	[edi].hMutex,eax
			
			assume	edi:nothing
			assume	esi:nothing
			mov	eax,@lpstKDays
			ret
kdays_create		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_release		proc	uses ebx edi esi _hKDays

			mov	esi,_hKDays
			assume	esi:ptr KDAYS_OBJECT
			invoke	CloseHandle,[esi].hMutex
			invoke	HeapDestroy,[esi].hHeap
			assume	esi:nothing
			ret
kdays_release		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_client_login	proc	uses ebx edi esi _hKDays,_lpszCallback
			local	@urlKDays[512]:byte
			
			local	@sig_time[16]:byte
			local	@sig_buf[128]:byte
			local	@sig[36]:byte
			.const
fmtClientLogin		db	"http://kdays.cn/api/client_login.php?apikey=%s&sig_time=%s&token=%s&sig=%s&callback_url=%s",0
sigClientLogin		db	"KQL-",0
fmtSigTime		db	"%d",0
szForum			db	"http%3A%2F%2Fkdays.cn%2Fdays%2F",0
			.code
			mov	esi,_hKDays
			assume	esi:ptr KDAYS_OBJECT
			
			
			invoke	kdays_get_timestamp
			invoke	wsprintf,addr @sig_time,addr fmtSigTime,eax
			
			invoke	RtlZeroMemory,addr @sig_buf,sizeof @sig_buf
			invoke	lstrcpy,addr @sig_buf,addr sigClientLogin
			invoke	lstrcat,addr @sig_buf,[esi].lpszPrivateKey
			invoke	lstrcat,addr @sig_buf,addr @sig_time
			invoke	lstrcat,addr @sig_buf,[esi].lpszToken
			invoke	kdays_str_to_md5,addr @sig_buf,addr @sig
			
			.if	!_lpszCallback
				mov	_lpszCallback,offset szForum
			.endif
			invoke	RtlZeroMemory,addr @urlKDays,sizeof @urlKDays
			invoke	wsprintf,addr @urlKDays,addr fmtClientLogin,[esi].lpszPublicKey,addr @sig_time,[esi].lpszToken,addr @sig,_lpszCallback

			debug	addr @urlKDays
			invoke	ShellExecute,NULL,NULL,addr @urlKDays,NULL,NULL,SW_SHOW
			
			assume	esi:nothing
			ret
kdays_client_login	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 工具
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_get_timestamp	proc	uses ebx edi esi
			local	@lpData
			.const
urlGetTimestamp		dw	'h','t','t','p',':','/','/','k','d','a','y','s','.','c','n','/','a','p','i','/','t','i','m','e','.','p','h','p',0
			.code
			invoke	_HttpRequestW,addr urlGetTimestamp,NULL
			mov	@lpData,eax
			invoke	StrToInt,@lpData
			mov	ebx,eax
			invoke	_HttpRequestFree,@lpData
			mov	eax,ebx
			ret
kdays_get_timestamp	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_user_exist	proc	uses ebx edi esi _hKDays,_lpszUsername,_dwGetBasic
			local	@utfUsername[32]
			local	@urlKDays[256]:byte
			local	@lpData
			local	@ReturnCode[8]:byte
			.const
actionUserExist		db	"user_exist",0
fmtUserExist		db	"%s?type=ini&apikey=%s&action=%s&username=%s&get_basic=%d",0
			.code
			mov	esi,_hKDays
			assume	esi:ptr KDAYS_OBJECT
			
			invoke	kdays_str_codepage,_lpszUsername,addr @utfUsername,CP_ACP,CP_UTF8
			invoke	wsprintf,addr @urlKDays,addr fmtUserExist,[esi].lpszServer,[esi].lpszPublicKey,addr actionUserExist,_lpszUsername,_dwGetBasic

			debug	addr @urlKDays
			invoke	_HttpRequest,addr @urlKDays,NULL
			mov	@lpData,eax
			debug	@lpData
			invoke	_IniParser,@lpData,addr szCode,addr @ReturnCode
			invoke	StrToInt,addr @ReturnCode
			.if	eax ==	KDAYS_SUCCESS
				.if	_dwGetBasic		;没写完呢
				.endif
			.endif
			
			mov	ebx,eax
			invoke	_HttpRequestFree,@lpData
			mov	eax,ebx
			assume	esi:nothing
			ret
kdays_user_exist	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 用户操作
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_get_access_token	proc	uses ebx edi esi _hKDays,_lpszUsername,_lpszMd5Pswrd
			local	@utfUsername[32]
			local	@urlKDays[512]:byte
			local	@lpData
			local	@ReturnCode[8]:byte
			local	@hHeap
			local	@Base64Usr,@sig_time,@sig_buf,@sig
			.const
szGetAccessTokenSit	db	"md5",0
actionGetAccessToken	db	"get_access_token",0
fmtGetAccessToken	db	"%s?type=ini&apikey=%s&action=%s&username=%s&password=%s&sit=%s&sig_time=%s&sig=%s",0
szToken			db	"token",0
szUID			db	"uid",0
			.code
			mov	esi,_hKDays
			assume	esi:ptr KDAYS_OBJECT
			invoke	HeapCreate,0,0,0
			mov	@hHeap,eax
			
			invoke	kdays_str_codepage,_lpszUsername,addr @utfUsername,CP_ACP,CP_UTF8
			
			invoke	lstrlen,addr @utfUsername
			shl	eax,1
			invoke	HeapAlloc,@hHeap,HEAP_ZERO_MEMORY,eax
			mov	@Base64Usr,eax
			invoke	kdays_str_to_base64,addr @utfUsername,@Base64Usr
			
			invoke	HeapAlloc,@hHeap,HEAP_ZERO_MEMORY,32
			mov	@sig_time,eax
			invoke	kdays_get_timestamp
			invoke	wsprintf,@sig_time,addr fmtSigTime,eax
			
			invoke	HeapAlloc,@hHeap,HEAP_ZERO_MEMORY,256
			mov	@sig_buf,eax
			invoke	HeapAlloc,@hHeap,HEAP_ZERO_MEMORY,36
			mov	@sig,eax
			invoke	lstrcpy,@sig_buf,@Base64Usr
			invoke	lstrcat,@sig_buf,addr actionGetAccessToken
			invoke	lstrcat,@sig_buf,@sig_time
			invoke	lstrcat,@sig_buf,[esi].lpszPrivateKey
			invoke	kdays_str_to_md5,@sig_buf,@sig
			
			invoke	wsprintf,addr @urlKDays,addr fmtGetAccessToken,[esi].lpszServer,[esi].lpszPublicKey,addr actionGetAccessToken,@Base64Usr,_lpszMd5Pswrd,addr szGetAccessTokenSit,@sig_time,@sig

			debug	addr @urlKDays
			invoke	_HttpRequest,addr @urlKDays,NULL
			mov	@lpData,eax
			debug	@lpData
			invoke	_IniParser,@lpData,addr szCode,addr @ReturnCode
			invoke	StrToInt,addr @ReturnCode
			.if	eax ==	KDAYS_SUCCESS
				invoke	WaitForSingleObject,[esi].hMutex,INFINITE
				mov	eax,[esi].lpszToken
				.if	eax
					mov	eax,ALREADY_HAVE_TOKEN
				.else
					invoke	HeapAlloc,[esi].hHeap,HEAP_ZERO_MEMORY,TOKEN_LENGTH
					mov	[esi].lpszToken,eax
					invoke	_IniParser,@lpData,addr szToken,[esi].lpszToken
					invoke	HeapAlloc,[esi].hHeap,HEAP_ZERO_MEMORY,16
					mov	[esi].lpszUID,eax
					invoke	_IniParser,@lpData,addr szUID,[esi].lpszUID
				.endif
				invoke	ReleaseMutex,[esi].hMutex
				mov	eax,KDAYS_SUCCESS
			.endif
			
			mov	ebx,eax
			invoke	_HttpRequestFree,@lpData
			invoke	HeapDestroy,@hHeap
			mov	eax,ebx
			assume	esi:nothing
			ret
kdays_get_access_token	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_active_app	proc	uses ebx edi esi _hKDays
			local	@urlKDays[256]:byte
			local	@lpData
			local	@ReturnCode[8]:byte
			.const
actionActiveApp		db	"active_app",0
fmtActiveApp		db	"%s?type=ini&apikey=%s&action=%s&token=%s",0
			.code
			mov	esi,_hKDays
			assume	esi:ptr KDAYS_OBJECT
			
			invoke	wsprintf,addr @urlKDays,addr fmtActiveApp,[esi].lpszServer,[esi].lpszPublicKey,addr actionActiveApp,[esi].lpszToken

			debug	addr @urlKDays
			invoke	_HttpRequest,addr @urlKDays,NULL
			mov	@lpData,eax
			debug	@lpData
			invoke	_IniParser,@lpData,addr szCode,addr @ReturnCode
			invoke	StrToInt,addr @ReturnCode
			
			mov	ebx,eax
			invoke	_HttpRequestFree,@lpData
			mov	eax,ebx
			assume	esi:nothing
			ret
kdays_active_app	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_insert_login_log	proc	uses ebx edi esi
			xor	eax,eax
			ret
kdays_insert_login_log	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_get_user_info	proc	uses ebx edi esi _hKDays,_lpszGets,_lpszOutput
			local	@urlKDays[256]:byte
			local	@lpData
			local	@ReturnCode[8]:byte
			.const
actionGetUserInfo	db	"get_user_info",0
fmtGetUserInfo		db	"%s?type=ini&apikey=%s&action=%s&token=%s&gets=%s",0
			.code
			mov	esi,_hKDays
			assume	esi:ptr KDAYS_OBJECT
			
			invoke	wsprintf,addr @urlKDays,addr fmtGetUserInfo,[esi].lpszServer,[esi].lpszPublicKey,addr actionGetUserInfo,[esi].lpszToken,_lpszGets

			debug	addr @urlKDays
			invoke	_HttpRequest,addr @urlKDays,NULL
			mov	@lpData,eax
			debug	@lpData
			invoke	_IniParser,@lpData,addr szCode,addr @ReturnCode
			invoke	StrToInt,addr @ReturnCode
			.if	eax ==	KDAYS_SUCCESS
				.if	(_lpszOutput)
					invoke	_IniParser,@lpData,_lpszGets,_lpszOutput
				.endif
				mov	eax,KDAYS_SUCCESS
			.endif
			
			mov	ebx,eax
			invoke	_HttpRequestFree,@lpData
			mov	eax,ebx
			assume	esi:nothing
			ret
kdays_get_user_info	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_username_convert	proc	uses ebx edi esi
			xor	eax,eax
			ret
kdays_username_convert	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_check_notify	proc	uses ebx edi esi _hKDays,_dwTimestamp
			local	@urlKDays[256]:byte
			local	@lpData
			local	@ReturnCode[8]:byte
			.const
actionCheckNotify	db	"check_notify",0
fmtCheckNotify		db	"%s?type=ini&apikey=%s&action=%s&token=%s&timestamp=%d",0
			.code
			mov	esi,_hKDays
			assume	esi:ptr KDAYS_OBJECT
			
			invoke	wsprintf,addr @urlKDays,addr fmtCheckNotify,[esi].lpszServer,[esi].lpszPublicKey,addr actionCheckNotify,[esi].lpszToken,_dwTimestamp

			debug	addr @urlKDays
			invoke	_HttpRequest,addr @urlKDays,NULL
			mov	@lpData,eax
			debug	@lpData
			invoke	_IniParser,@lpData,addr szCode,addr @ReturnCode
			invoke	StrToInt,addr @ReturnCode
			
			mov	ebx,eax
			invoke	_HttpRequestFree,@lpData
			mov	eax,ebx
			assume	esi:nothing
			ret
kdays_check_notify	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_add_feed		proc	uses ebx edi esi
			xor	eax,eax
			ret
kdays_add_feed		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 推送&数据持久化保存
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_pull		proc	uses ebx edi esi
			xor	eax,eax
			ret
kdays_pull		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_push		proc	uses ebx edi esi
			xor	eax,eax
			ret
kdays_push		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_key2value		proc	uses ebx edi esi _hKDays,_lpszKey,_lpszValue,_lpszOutput
			local	@urlKDays[256]:byte
			local	@lpData
			local	@ReturnCode[8]:byte
			local	@lpszKey,@lpszValue
			.const
actionKey2Value		db	"key2value",0
fmtKey2Value		db	"%s?type=ini&apikey=%s&action=%s&token=%s&key=%s&value=%s&life=-1",0
szData			db	"data",0
			.code
			mov	esi,_hKDays
			assume	esi:ptr KDAYS_OBJECT
			
			invoke	lstrlen,_lpszKey
			mov	ecx,2
			mul	ecx
			invoke	GlobalAlloc,GPTR,eax
			mov	@lpszKey,eax
			invoke	kdays_str_codepage,_lpszKey,@lpszKey,CP_ACP,CP_UTF8
			
			.if	_lpszValue
				invoke	lstrlen,_lpszValue
				mov	ecx,2
				mul	ecx
				invoke	GlobalAlloc,GPTR,eax
				mov	@lpszValue,eax
				invoke	kdays_str_codepage,_lpszValue,@lpszValue,CP_ACP,CP_UTF8
			.else
				xor	eax,eax
				mov	@lpszValue,eax
			.endif
			
			invoke	wsprintf,addr @urlKDays,addr fmtKey2Value,[esi].lpszServer,[esi].lpszPublicKey,addr actionKey2Value,[esi].lpszToken,@lpszKey,@lpszValue

			debug	addr @urlKDays
			invoke	_HttpRequest,addr @urlKDays,NULL
			mov	@lpData,eax
			debug	@lpData
			invoke	_IniParser,@lpData,addr szCode,addr @ReturnCode
			invoke	StrToInt,addr @ReturnCode
			.if	eax ==	KDAYS_SUCCESS
				.if	(_lpszOutput) && (!_lpszValue)
					invoke	_IniParser,@lpData,addr szData,_lpszOutput
				.endif
				mov	eax,KDAYS_SUCCESS
			.endif
			
			mov	ebx,eax
			invoke	_HttpRequestFree,@lpData
			invoke	GlobalFree,@lpszKey
			invoke	GlobalFree,@lpszValue
			mov	eax,ebx
			assume	esi:nothing
			ret
kdays_key2value		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 论坛操作
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_message		proc	uses ebx edi esi _hKDays,_dwMessageID,_lpOutput
			local	@mid[16]:byte
			local	@newmsg[16]:byte
			local	@urlKDays[256]:byte
			local	@lpData
			local	@ReturnCode[8]:byte
			.const
fmtMessageID		db	"%d",0
actionMessage		db	"message",0
fmtMessage		db	"%s?type=ini&apikey=%s&action=%s&token=%s",0
fmtMessage2		db	"%s?type=ini&apikey=%s&action=%s&token=%s&mid=%s",0
szNewmsg		db	"newmsg",0
			.code
			mov	esi,_hKDays
			assume	esi:ptr KDAYS_OBJECT

			invoke	wsprintf,addr @mid,addr fmtMessageID,_dwMessageID
			
			.if	_dwMessageID
				invoke	wsprintf,addr @urlKDays,addr fmtMessage2,[esi].lpszServer,[esi].lpszPublicKey,addr actionMessage,[esi].lpszToken,addr @mid
			.else
				invoke	wsprintf,addr @urlKDays,addr fmtMessage,[esi].lpszServer,[esi].lpszPublicKey,addr actionMessage,[esi].lpszToken
			.endif

			debug	addr @urlKDays
			invoke	_HttpRequest,addr @urlKDays,NULL
			mov	@lpData,eax
			debug	@lpData
			invoke	_IniParser,@lpData,addr szCode,addr @ReturnCode
			invoke	StrToInt,addr @ReturnCode
			.if	eax ==	KDAYS_SUCCESS
				.if	_dwMessageID
					mov	eax,KDAYS_SUCCESS
				.else
					invoke	_IniParser,@lpData,addr szNewmsg,addr @newmsg
					invoke	StrToInt,addr @newmsg
				.endif
			.else
				xor	eax,eax
			.endif
			
			mov	ebx,eax
			invoke	lstrcpy,_lpOutput,@lpData
			invoke	_HttpRequestFree,@lpData
			mov	eax,ebx
			assume	esi:nothing
			ret
kdays_message		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_get_forum_topic	proc	uses ebx edi esi
			xor	eax,eax
			ret
kdays_get_forum_topic	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_get_forum_list	proc	uses ebx edi esi
			xor	eax,eax
			ret
kdays_get_forum_list	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_get_topic_list	proc	uses ebx edi esi
			xor	eax,eax
			ret
kdays_get_topic_list	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_post_topic	proc	uses ebx edi esi
			xor	eax,eax
			ret
kdays_post_topic	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_get_forum_reply	proc	uses ebx edi esi
			xor	eax,eax
			ret
kdays_get_forum_reply	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_get_hot_topic	proc	uses ebx edi esi
			xor	eax,eax
			ret
kdays_get_hot_topic	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_get_topic_info	proc	uses ebx edi esi
			xor	eax,eax
			ret
kdays_get_topic_info	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_get_forum_vote	proc	uses ebx edi esi
			xor	eax,eax
			ret
kdays_get_forum_vote	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_update_user_honor	proc	uses ebx edi esi
			xor	eax,eax
			ret
kdays_update_user_honor	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 萝莉插件&伪春菜&FM
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_get_fm_list	proc	uses ebx edi esi
			xor	eax,eax
			ret
kdays_get_fm_list	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_get_loli_basic	proc	uses ebx edi esi
			xor	eax,eax
			ret
kdays_get_loli_basic	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_get_loli_info	proc	uses ebx edi esi
			xor	eax,eax
			ret
kdays_get_loli_info	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
kdays_get_loli_talk	proc	uses ebx edi esi
			xor	eax,eax
			ret
kdays_get_loli_talk	endp