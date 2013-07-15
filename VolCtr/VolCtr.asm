		.386
		.model flat,stdcall
		option casemap:none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include		windows.inc
include		user32.inc
includelib	user32.lib
include		kernel32.inc
includelib	kernel32.lib
include 	ole32.inc
includelib	ole32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; coinvoke MACRO
;
; invokes an arbitrary COM interface
;
; revised 12/29/00 to check for edx as a param and force compilation error
;                   (thanks to Andy Car for a how-to suggestion)
; revised 07/18/00 to pass pointer in edx (not eax) to avoid confusion with
;   parmas passed with ADDR  (Jeremy Collake's excellent suggestion)
; revised 05/04/00 for member function name decoration
; see http://ourworld.compuserve.com/homepages/ernies_world/coinvoke.php
;
; pInterface    pointer to a specific interface instance
; Interface     the Interface's struct typedef
; Function      which function or method of the interface to perform
; args          all required arguments
;                   (type, kind and count determined by the function)
;
cinvoke	MACRO	pInterface:REQ,Interface:REQ,Function:REQ,args:VARARG
	LOCAL	istatement,arg
	FOR	arg,<args>     ;; run thru args to see if edx is lurking in there
		IFIDNI	<&arg>, <edx>
		.ERR <edx is not allowed as a coinvoke parameter>
		ENDIF
	ENDM
	istatement CATSTR <invoke (Interface PTR[edx]).&Interface>,<_>,<&Function, pInterface>
	IFNB	<args>     ;; add the list of parameter arguments if any
		istatement CATSTR istatement, <, >, <&args>
	ENDIF
	mov	edx, pInterface
	mov	edx, [edx]
	istatement
	ENDM
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
comethod1Proto	typedef	proto	:DWORD
comethod2Proto	typedef	proto	:DWORD,:DWORD
comethod3Proto	typedef	proto	:DWORD,:DWORD,:DWORD
comethod4Proto	typedef	proto	:DWORD,:DWORD,:DWORD,:DWORD
comethod5Proto	typedef	proto	:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
comethod6Proto	typedef	proto	:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
comethod7Proto	typedef	proto	:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
comethod8Proto	typedef	proto	:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
comethod9Proto	typedef	proto	:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD

comethod1	typedef	ptr	comethod1Proto
comethod2	typedef	ptr	comethod2Proto
comethod3	typedef	ptr	comethod3Proto
comethod4	typedef	ptr	comethod4Proto
comethod5	typedef	ptr	comethod5Proto
comethod6	typedef	ptr	comethod6Proto
comethod7	typedef	ptr	comethod7Proto
comethod8	typedef	ptr	comethod8Proto
comethod9	typedef	ptr	comethod9Proto

eRender		equ	0
eConsole	equ	0
IMMDeviceEnumerator	STRUCT DWORD
	IMMDeviceEnumerator_QueryInterface				comethod3	?
	IMMDeviceEnumerator_AddRef					comethod1	?
	IMMDeviceEnumerator_Release					comethod1	?
	IMMDeviceEnumerator_EnumAudioEndpoints				comethod4	? 
	IMMDeviceEnumerator_GetDefaultAudioEndpoint			comethod4	? 
	IMMDeviceEnumerator_GetDevice					comethod3	?
	IMMDeviceEnumerator_RegisterEndpointNotificationCallback	comethod2	?
	IMMDeviceEnumerator_UnregisterEndpointNotificationCallback	comethod2	?
IMMDeviceEnumerator	ENDS

IMMDevice	STRUCT DWORD
	IMMDevice_QueryInterface	comethod3	?
	IMMDevice_AddRef		comethod1	?
	IMMDevice_Release		comethod1	?
	IMMDevice_Activate		comethod5	?
	IMMDevice_OpenPropertyStore	comethod3	?
	IMMDevice_GetId			comethod2	?
	IMMDevice_GetState		comethod2	?
IMMDevice	ENDS

IAudioEndpointVolume	STRUCT DWORD
	IAudioEndpointVolume_QueryInterface			comethod3	?
	IAudioEndpointVolume_AddRef				comethod1	?
	IAudioEndpointVolume_Release				comethod1	?
	IAudioEndpointVolume_RegisterControlChangeNotify	comethod2	?
	IAudioEndpointVolume_UnregisterControlChangeNotify	comethod2	?
	IAudioEndpointVolume_GetChannelCount			comethod2	?
	IAudioEndpointVolume_SetMasterVolumeLevel		comethod3	?
	IAudioEndpointVolume_SetMasterVolumeLevelScalar		comethod3	?
	IAudioEndpointVolume_GetMasterVolumeLevel		comethod2	?
	IAudioEndpointVolume_GetMasterVolumeLevelScalar		comethod2	?
	IAudioEndpointVolume_SetChannelVolumeLevel		comethod4	?
	IAudioEndpointVolume_SetChannelVolumeLevelScalar	comethod4	?
	IAudioEndpointVolume_GetChannelVolumeLevel		comethod3	?
	IAudioEndpointVolume_GetChannelVolumeLevelScalar	comethod3	?
	IAudioEndpointVolume_SetMute				comethod3	?
	IAudioEndpointVolume_GetMute				comethod2	?
	IAudioEndpointVolume_GetVolumeStepInfo			comethod3	?
	IAudioEndpointVolume_VolumeStepUp			comethod2	?
	IAudioEndpointVolume_VolumeStepDown			comethod2	?
	IAudioEndpointVolume_QueryHardwareSupport		comethod2	?
	IAudioEndpointVolume_GetVolumeRange			comethod4	?
IAudioEndpointVolume	ENDS
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data
fVolume		real4	0.5	;default volume

dwTen		dd	10
dwEax		dd	0

dwDiv		dd	0
		.const
IID_IMMDeviceEnumerator		GUID	{0A95664D2h,9614h,4F35h,{0A7h,46h,0DEh,8Dh,0B6h,36h,17h,0E6h}}
IID_MMDeviceEnumerator		GUID	{0BCDE0395h,0E52Fh,467Ch,{8Eh,3Dh,0C4h,57h,92h,91h,69h,2Eh}}
IID_IAudioEndpointVolume	GUID	{5CDF2C82h,841Eh,4546h,{97h,22h,0Ch,0F7h,40h,78h,22h,9Ah}}

szCoInitializeEx		db	"COM object failed to initialize",0
szMMDeviceEnumerator		db	"Failed to create the mixer object",0
szIMMDeviceEnumerator		db	"Failed to get the default audio endpoint",0
szIMMDevice			db	"Failed to get the audio endpoint volume",0
szSetMute			db	"Failed to unset to mute",0
szSetMasterVolumeLevelScalar	db	"Failed to change the volume",0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ´úÂë¶Î
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
Main		proc
		local	pEnumerator,pDevice,pEndptVol

		invoke	CoInitialize,NULL
		.if	eax !=	S_OK
			invoke	MessageBox,0,addr szCoInitializeEx,0,0
			jmp	@F
		.endif

		invoke	CoCreateInstance,addr IID_MMDeviceEnumerator,NULL,CLSCTX_INPROC_SERVER,addr IID_IMMDeviceEnumerator,addr pEnumerator
		.if	eax !=	S_OK
			invoke	MessageBox,0,addr szMMDeviceEnumerator,0,0
			jmp	@F
		.endif
		
		cinvoke	pEnumerator,IMMDeviceEnumerator,GetDefaultAudioEndpoint,eRender,eConsole,addr pDevice
		mov	eax,pDevice
		.if	!eax
			invoke	MessageBox,0,addr szIMMDeviceEnumerator,0,0
			jmp	@F
		.endif

		cinvoke	pDevice,IMMDevice,Activate,addr IID_IAudioEndpointVolume,CLSCTX_ALL,NULL,addr pEndptVol
		mov	eax,pEndptVol
		.if	!eax
			invoke	MessageBox,0,szIMMDevice,0,0
			jmp	@F
		.endif
comment	/*
		;If we set the volume to mute, even the following code set the volume to 100%, we are still in mute. Comment those As a temporary method to disable alarm
		cinvoke	pEndptVol,IAudioEndpointVolume,SetMute,FALSE,NULL
		.if	(eax != S_OK) && (eax != S_FALSE)
			invoke	MessageBox,0,addr szSetMute,0,0
			jmp	@F
		.endif
	*/
	
		invoke	GetCommandLine
		mov	esi,eax
		xor	eax,eax
		cld
		.repeat
			lodsb
			.if	eax == '"'
				.repeat
					lodsb
				.until	eax == '"'
			.elseif	(eax == 20h || eax == 09h)	;space and tab
				.while	(eax == 20h || eax == 09h)
					lodsb
				.endw
				dec	esi
				mov	edi,esi
				xor	eax,eax
				.while	TRUE
					lodsb
					.continue .if	al == '.'
					.break	.if	(al < '0') || (al > '9') || !al
				.endw
				.if	!al	;make sure we reach the end of command line with no problem
					mov	esi,edi
					finit
					fldz
					.while	TRUE
						lodsb
						.if	al == '.'
							inc	dwDiv
							.continue
						.elseif	al == 0
							.if	dwDiv
								dec	dwDiv
								mov	eax,1
								mov	ebx,dwDiv
								mov	ecx,10
								.while	ebx
									mul	ecx
									dec	ebx
								.endw
								
								mov	dwDiv,eax
								fidiv	dwDiv
							.endif
							fstp	fVolume
							fwait
							.break
						.endif
						sub	al,'0'
						mov	dwEax,eax
						fimul	dwTen
						fiadd	dwEax
						.if	dwDiv
							inc	dwDiv
						.endif
					.endw
				.endif
				.break
			.endif
		.until	eax == 0

		cinvoke	pEndptVol,IAudioEndpointVolume,SetMasterVolumeLevelScalar,fVolume,NULL
		.if	eax != S_OK
			invoke	MessageBox,0,szSetMasterVolumeLevelScalar,0,0
			jmp	@F
		.endif
		
		;release objects
		cinvoke	pEndptVol,IAudioEndpointVolume,Release
		cinvoke	pDevice,IMMDevice,Release
		cinvoke	pEnumerator,IMMDeviceEnumerator,Release
		invoke	CoUninitialize
@@:
		invoke	ExitProcess,NULL
		ret
Main		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	Main