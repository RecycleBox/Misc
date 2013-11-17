		.const
szClsTooltip	db	"tooltips_class32",0
		.code
;********************************************************************
_CreateTooltip	proc	uses ebx edi esi _hWnd,_hItem,_lpszText
		local	@hWndTip
		local	@stToolInfo:TOOLINFO
		
		invoke	CreateWindowEx,NULL,addr szClsTooltip,NULL,WS_POPUP or TTS_ALWAYSTIP or TTS_BALLOON,\
				CW_USEDEFAULT,CW_USEDEFAULT,\
				CW_USEDEFAULT,CW_USEDEFAULT,\
				_hWnd,NULL,\
				hInstance,NULL
		mov	@hWndTip,eax
		mov	@stToolInfo.cbSize,sizeof TOOLINFO
		push	_hWnd
		pop	@stToolInfo.hwnd
		mov	@stToolInfo.uFlags,TTF_IDISHWND or TTF_SUBCLASS
		push	_hItem
		pop	@stToolInfo.uId
		push	_lpszText
		pop	@stToolInfo.lpszText
		invoke	SendMessage,@hWndTip,TTM_ADDTOOL,0,addr @stToolInfo
		ret
_CreateTooltip	endp