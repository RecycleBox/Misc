@echo	off
set	path=D:\JWasm\bin;%path%
set	include=D:\JWasm\include

set	lib=D:\JWasm\lib
jwasm	-nologo -coff default.asm
jwlink	option q format win pe runtime windows f default.obj n bin\default.exe

jwasm	-nologo -coff seh.asm
jwlink	option q format win pe runtime windows f seh.obj n bin\seh.exe

jwasm	-nologo -coff veh.asm
jwlink	option q format win pe runtime windows f veh.obj n bin\veh.exe

set	lib=D:\JWasm\lib64
jwasm	-nologo -win64 default_x64.asm
jwlink	option q format win pe runtime windows f default_x64.obj n bin\default_x64.exe

jwasm	-nologo -win64 seh_x64.asm
jwlink	option q format win pe runtime windows f seh_x64.obj n bin\seh_x64.exe

jwasm	-nologo -win64 veh_x64.asm
jwlink	option q format win pe runtime windows f veh_x64.obj n bin\veh_x64.exe

del	*.obj
pause