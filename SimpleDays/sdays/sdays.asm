		.486
		.model flat, stdcall
		option casemap :none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Include 文件定义
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include		windows.inc
include		user32.inc
includelib	user32.lib
include		kernel32.inc
includelib	kernel32.lib
include		shell32.inc
includelib	shell32.lib
include		gdi32.inc
includelib	gdi32.lib
include		..\libkdays\kdays.inc
includelib	..\libkdays\Bin\kdays.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Equ 等值定义
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
DLG_LOGIN	equ	1000
EDIT_USERNAME	equ	1100
EDIT_PASSWORD	equ	1101
ICO_MAIN	equ	2000
NOTIFY_ICON	equ	ICO_MAIN
WM_NOTIFYICON	equ	WM_USER + 100h

; //
; // Menu resources
; //
; LANGUAGE LANG_NEUTRAL, SUBLANG_NEUTRAL
; MNU_COMMAND MENUEX
; {
    ; POPUP "", 0, 0, 0
    ; {
        ; MENUITEM "", 0, MFT_SEPARATOR, 0
        ; MENUITEM "Add account...", IDLOGIN, 0, 0
        ; MENUITEM "Exit", IDEXIT, 0, 0
    ; }
; }
IDLOGIN		equ	3010
IDEXIT		equ	3011
IDUSER		equ	4000

NOTIFYICONDATAA_V2_SIZE	EQU	<FIELD_OFFSET ( NOTIFYICONDATAA , guidItem )>
NOTIFYICONDATAW_V2_SIZE	EQU	<FIELD_OFFSET ( NOTIFYICONDATAW , guidItem )>
ifdef UNICODE
NOTIFYICONDATA_V2_SIZE	EQU	<NOTIFYICONDATAW_V2_SIZE>
else 
NOTIFYICONDATA_V2_SIZE	EQU	<NOTIFYICONDATAA_V2_SIZE>
endif

NIN_SELECT		equ	WM_USER + 0
NIN_KEYSELECT		equ	WM_USER + 1
NIN_BALLOONSHOW		equ	WM_USER + 2
NIN_BALLOONHIDE		equ	WM_USER + 3
NIN_BALLOONTIMEOUT	equ	WM_USER + 4
NIN_BALLOONUSERCLICK	equ	WM_USER + 5
NIN_POPUPOPEN		equ	WM_USER + 6
NIN_POPUPCLOSE		equ	WM_USER + 7

NOTIFYICONDATA_ STRUCT
	cbSize			DWORD		?
	hWnd			DWORD		?
	uID			DWORD		?
	uFlags			DWORD		?
	uCallbackMessage	DWORD		?
	hIcon			DWORD		?
	szTip			BYTE		128 dup (?)
	dwState			DWORD		?
	dwStateMask		DWORD		?
	szInfo			BYTE		256 dup(?)
	union
		uTimeout	DWORD		?
		uVersion	DWORD		?
	ends
	szInfoTitle		BYTE		64 dup(?)
	dwInfoFlags		DWORD		?
NOTIFYICONDATA_ ENDS

_ShowPopup	proto	:DWORD,:DWORD,:DWORD
_ProcThread	proto	:DWORD
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
hInstance	dd	?
hWinMain	dd	?
hIcon		dd	?
hFont		dd	?
hMenu		dd	?
lpAccountTable	dd	?
hMutexTable	dd	?

szAccountFolder	db	MAX_PATH dup (?)
szAccountFull	db	MAX_PATH dup (?)

stWndClass	WNDCLASSEX	<?>
stNotify	NOTIFYICONDATA_	<?>
stMsg		MSG		<?>
		.const
szPublicKey	db	'70d01ff1ba1742',0
szPrivateKey	db	'b72eb0d5ad97',0

szUsername	db	"Username",0
szPassword	db	"Password",0
szAccount	db	'\account.ini',0

szClassName	db	"SimpleDays",0

szKDays		db	"http://kdays.cn/days/",0

szLogin		db	"Add account...",0
szExit		db	"Exit",0
szNewMessage	db	"You got a new message.",0

		.data?
szBuf		db	256 dup (?)
		.const
szFmt		db	"%d",0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
include		Tooltip.asm
include		UserLogin.asm
include		Thread.asm
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ShowPopup	proc	uses ebx edi esi _lpszTitle,_lpszInfo,_dwInfoFlags
		local	@stNotify:NOTIFYICONDATA_


		invoke	RtlZeroMemory,addr @stNotify,sizeof @stNotify
		mov	@stNotify.cbSize,sizeof @stNotify
		push	hWinMain
		pop	@stNotify.hWnd
		mov	@stNotify.uID,NOTIFY_ICON
		mov	@stNotify.uFlags,NIF_INFO
		mov	@stNotify.uTimeout,5000
		invoke	lstrcpy,addr @stNotify.szInfo,_lpszInfo
		invoke	lstrcpy,addr @stNotify.szInfoTitle,_lpszTitle
		push	_dwInfoFlags
		pop	@stNotify.dwInfoFlags
		invoke	Shell_NotifyIcon,NIM_MODIFY,addr @stNotify
		ret
_ShowPopup	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_NotifyMain	proc	uses ebx edi esi hWnd,uMsg,wParam,lParam
		local	@stNotify:NOTIFYICONDATA_
		local	@stPoint:POINT
		local	@hMenu

		mov	eax,uMsg
;********************************************************************
		.if	eax ==	WM_NOTIFYICON
			mov	eax,wParam
			.if	eax  ==	NOTIFY_ICON
				mov	eax,lParam
				.if	eax  ==	WM_LBUTTONDBLCLK
					invoke	ShellExecute,NULL,NULL,addr szKDays,NULL,NULL,SW_SHOW
				.elseif	eax  ==	WM_RBUTTONUP
					invoke	SetForegroundWindow,hWnd
					invoke	GetCursorPos,addr @stPoint
					invoke	CreatePopupMenu
					mov	@hMenu,eax
					
					mov	esi,lpAccountTable
					add	esi,sizeof TABLE_HEAD
					assume	esi:ptr ACCOUNT_TABLE
					mov	edi,IDUSER
					.while	TRUE
						.break	.if	![esi].stOptional.lpszUsername
						invoke	AppendMenu,@hMenu,0,edi,[esi].stOptional.lpszUsername
						add	esi,sizeof ACCOUNT_TABLE
						inc	edi
					.endw
					assume	esi:nothing
					
					invoke	AppendMenu,@hMenu,MF_SEPARATOR,0,NULL
					invoke	AppendMenu,@hMenu,0,IDLOGIN,addr szLogin
					invoke	AppendMenu,@hMenu,0,IDEXIT,addr szExit
					
					invoke	TrackPopupMenu,@hMenu,TPM_LEFTALIGN or TPM_RIGHTBUTTON,@stPoint.x,@stPoint.y, 0, hWnd,NULL
					invoke	DestroyMenu,@hMenu
				.endif
			.endif
;********************************************************************
		.elseif	eax ==	WM_COMMAND
			mov	eax,wParam
			.if	ax  ==	IDEXIT
				invoke	PostMessage,hWnd,WM_DESTROY,0,0
			.elseif	ax  ==	IDLOGIN
				invoke	_UserLogin
				invoke	_AddLogin
			.elseif	ax  >=	IDUSER
				sub	ax,IDUSER
				movzx	eax,ax
				mov	ecx,sizeof ACCOUNT_TABLE
				mul	ecx
				mov	esi,lpAccountTable
				add	esi,sizeof TABLE_HEAD
				add	esi,eax
				assume	esi:ptr ACCOUNT_TABLE
				invoke	kdays_client_login,[esi].hKDays,NULL
				assume	esi:nothing
			.endif
;********************************************************************
		.elseif	eax ==	WM_CREATE
			.while	TRUE
				invoke	_MultiLogin
				.break	.if	eax
				invoke	_UserLogin
				.if	!eax
					invoke	ExitProcess,2
				.endif
			.endw
			mov	lpAccountTable,eax
			mov	esi,lpAccountTable
			add	esi,sizeof TABLE_HEAD
			assume	esi:ptr ACCOUNT_TABLE
			xor	edi,edi
			push	eax
			.while	TRUE
				.break	.if	![esi].stOptional.lpszUsername
				invoke	CreateThread,NULL,0,offset _ProcThread,edi,NULL,esp
				invoke	CloseHandle,eax
				add	esi,sizeof ACCOUNT_TABLE
				inc	edi
			.endw
			assume	esi:nothing
			pop	eax
;********************************************************************
		.elseif	eax ==	WM_CLOSE
			invoke	ShowWindow,hWnd,SW_HIDE
;********************************************************************
		.elseif	eax ==	WM_DESTROY
			invoke	RtlZeroMemory,addr @stNotify,sizeof @stNotify
			mov	@stNotify.cbSize,sizeof NOTIFYICONDATA_
			push	hWnd
			pop	@stNotify.hWnd
			mov	@stNotify.uID,NOTIFY_ICON
			invoke	Shell_NotifyIcon,NIM_DELETE,addr @stNotify
			
			invoke	DestroyWindow,hWnd
			invoke	PostQuitMessage,NULL
;********************************************************************
		.else
			invoke	DefWindowProc,hWnd,uMsg,wParam,lParam
			ret
		.endif
		xor	eax,eax
		ret

_NotifyMain	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
		invoke	GetModuleHandle,NULL
		mov	hInstance,eax
;********************************************************************
; 检查重入
;********************************************************************
		invoke	CreateMutex,NULL,TRUE,addr szClassName
		invoke	GetLastError
		.if	eax == ERROR_ALREADY_EXISTS
			invoke	ExitProcess,1
		.endif
;********************************************************************
; 设置Ini文件路径
;********************************************************************
		invoke	GetModuleHandle,NULL
		invoke	GetModuleFileName,eax,addr szAccountFolder,MAX_PATH
		invoke	lstrlen,addr szAccountFolder
		mov	edi,offset szAccountFolder
		add	edi,eax
		mov	al,'\'
		std
		repne	scasb
		xor	eax,eax
		inc	edi
		cld
		stosb
		invoke	lstrcpy,addr szAccountFull,addr szAccountFolder
		invoke	lstrcat,addr szAccountFull,addr szAccount
		
		;invoke	LoadIcon,hInstance,ICO_MAIN
		invoke	LoadIcon,NULL,IDI_INFORMATION
		mov	hIcon,eax
;********************************************************************
; 注册窗口类
;********************************************************************
		mov	stWndClass.cbSize,sizeof WNDCLASSEX
		mov	stWndClass.style,CS_HREDRAW or CS_VREDRAW
		mov	stWndClass.lpfnWndProc,offset _NotifyMain
		push	hInstance
		pop	stWndClass.hInstance
		invoke	LoadCursor,0,IDC_ARROW
		mov	stWndClass.hCursor,eax
		mov	stWndClass.hbrBackground,COLOR_WINDOW + 1
		mov	stWndClass.lpszClassName,offset szClassName
		invoke	RegisterClassEx,addr stWndClass
;********************************************************************
; 建立并显示窗口
;********************************************************************
		invoke	CreateWindowEx,0,offset szClassName,NULL,\
			0,\
			CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,\
			NULL,NULL,hInstance,NULL
		mov	hWinMain,eax
		invoke	ShowWindow,hWinMain,SW_HIDE
		invoke	UpdateWindow,hWinMain
;********************************************************************
; 添加托盘图标
;********************************************************************
		mov	stNotify.cbSize,sizeof NOTIFYICONDATA_
		push	hWinMain
		pop	stNotify.hWnd
		mov	stNotify.uID,NOTIFY_ICON
		mov	stNotify.uFlags,NIF_MESSAGE or NIF_ICON or NIF_TIP or NIF_SHOWTIP
		mov	stNotify.uCallbackMessage,WM_NOTIFYICON
		push	hIcon
		pop	stNotify.hIcon
		invoke	lstrcpy,addr stNotify.szTip,addr szClassName
		invoke	Shell_NotifyIcon,NIM_ADD,addr stNotify
;********************************************************************
; 消息循环
;********************************************************************
		.while	TRUE
			invoke	GetMessage,addr stMsg,NULL,0,0
			.break	.if eax	== 0
			invoke	TranslateMessage,addr stMsg
			invoke	DispatchMessage,addr stMsg
		.endw
		invoke	ExitProcess,NULL
		ret
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
