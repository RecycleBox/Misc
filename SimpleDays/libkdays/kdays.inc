;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数定义
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 编码
	kdays_str_to_md5	proto	:DWORD,:DWORD
	kdays_str_to_base64	proto	:DWORD,:DWORD
	kdays_str_codepage	proto	:DWORD,:DWORD,:DWORD,:DWORD
; KDays对象操作
	kdays_create		proto	:DWORD
	kdays_release		proto	:DWORD
	kdays_client_login	proto	:DWORD,:DWORD
; 工具
        kdays_get_timestamp	proto
	kdays_user_exist	proto	:DWORD,:DWORD,:DWORD
; 用户操作
        kdays_get_access_token	proto	:DWORD,:DWORD,:DWORD
	kdays_active_app	proto	:DWORD
	kdays_insert_login_log	proto
	kdays_get_user_info	proto	:DWORD,:DWORD,:DWORD
	kdays_username_convert	proto
	kdays_check_notify	proto	:DWORD,:DWORD
	kdays_add_feed		proto
; 推送&数据持久化保存
	kdays_pull		proto
	kdays_push		proto
	kdays_key2value		proto	:DWORD,:DWORD,:DWORD,:DWORD
; 论坛操作
	kdays_message		proto	:DWORD,:DWORD,:DWORD
	kdays_get_forum_topic	proto
	kdays_get_forum_list	proto
	kdays_get_topic_list	proto
	kdays_post_topic	proto
	kdays_get_forum_reply	proto
	kdays_get_hot_topic	proto
	kdays_get_topic_info	proto
	kdays_get_forum_vote	proto
	kdays_update_user_honor	proto
; 萝莉插件&伪春菜&FM
	kdays_get_fm_list	proto
	kdays_get_loli_basic	proto
	kdays_get_loli_info	proto
	kdays_get_loli_talk	proto
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 常量定义
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
TOKEN_LENGTH_A		equ	100
TOKEN_LENGTH_W		equ	200
ifdef	UNICODE
	TOKEN_LENGTH	equ	TOKEN_LENGTH_W
else
	TOKEN_LENGTH	equ	TOKEN_LENGTH_A
endif

UNKNOWN_ERROR		equ	0
ALREADY_HAVE_TOKEN	equ	100

KDAYS_SUCCESS		equ	200

TOKEN_ILLEGAL		equ	307
NOT_FOUND_DATA		equ	400
ERROR_PASSWOD		equ	401
NOT_YOUR_MESSAGE	equ	402
NOT_FOUND_USER		equ	404
NOT_FOUND_VALUE		equ	404
SIG_TIME_ERROR		equ	405
NO_APP_ID		equ	500
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 结构定义
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
KDAYS_OBJECT		struct
	hHeap		dd	?
	hMutex		dd	?
	lpszServer	dd	?
	lpszPublicKey	dd	?
	lpszPrivateKey	dd	?
	lpszToken	dd	?
	lpszUID		dd	?
KDAYS_OBJECT		ends