@echo off
setlocal

:: --- 설정값 ---
:: PARTITION_GUI : 파티션 현황 표시 (1=GUI, 0=CLI)

set PARTITION_GUI=1

:: --- 초기설정 ---
echo S 드라이브 할당 제거 중...
(
	echo sel volume S
	echo remove letter=S
	echo exit
) > temp_file.txt
diskpart /s temp_file.txt >nul
del temp_file.txt
echo.

:: --- 디스크 표기 ---

if %PARTITION_GUI% EQU 0 (
	echo ============================================================
	(
		echo list disk
		echo exit
	) > temp_file.txt
	diskpart /s temp_file.txt
	del temp_file.txt
	echo ============================================================
) else (
	echo 디스크 파티션 매니저 실행 중 ...
	start diskmgmt.msc
)
 
echo.

:: --- 디스크 번호 입력 ---
set /p DISK_NUM= 초기화 및 세팅할 디스크 번호를 입력해주세요 : 
echo.

:: --- 파티션 표기 ---
echo ===========================================================
(
	echo sel disk %DISK_NUM%
	echo list part
	echo exit
) > temp_file.txt
diskpart /s temp_file.txt
del temp_file.txt
echo ============================================================

:: '---윈도우 파티션 용량 지정 ---
set /p OS_GB_SIZE= 윈도우 파티션 [C드라이브]의 용량을 지정해주세요 [단위 : GB] [0 기입시 백업 하드 미생성] :
echo C 드라이브 총 용량 : %OS_GB_SIZE%GB
set /a OS_MB_SIZE=%OS_GB_SIZE%*1024
echo.

:: --- 경고창 ---
echo ************************** 경   고 ************************** 
echo * 이 작업은 한번 실행하면 되돌릴 수 없습니다!!!     
echo * 1. 중요한 자료는 백업이 되었는지                      
echo * 2. 초기화 대상 디스크가 정확한지
echo * 3. C 드라이브가 정확히 할당되어 있고, S 드라이브는 없는지                  
echo * 다시 한 번 확인하시기 바랍니다.                        
echo *************************************************************
ping -n 3 127.0.0.1 > nul
echo.
set /p ANSWER=%DISK_NUM%번 디스크 초기화 후 세팅을 진행할까요? (y라고 입력하면 진행됩니다.) [y/N]
echo.

:: --- y 외의 답변 exit 처리 ---
if /i not "%ANSWER%"=="y" (
	echo 작업이 취소되었습니다. 다시 시작해주세요.
	pause
	exit /b
)

:: --- IP 데이터 조회 ---
reg load HKEY_LOCAL_MACHINE\LOCAL_REG C:\Windows\System32\Config\SYSTEM >nul 2>&1

if %errorlevel%==0 (
	reg query HKEY_LOCAL_MACHINE\LOCAL_REG\ControlSet001\Services\Tcpip\Parameters\Interfaces /s | findstr "HKEY IPAddress SubnetMask Gateway NameServer" | findstr /v /i "dhcp" >log\latest_IP.txt 2>nul
	reg unload HKEY_LOCAL_MACHINE\LOCAL_REG >nul 2>&1
) else (
	echo ************************** 심   각 ************************** 
	echo * !! 선택하신 드라이브가 윈도우가 깔리지 않은 디스크 같습니다! !!    
	echo * 디스크 %DISK_NUM%이 포맷 대상이 정확한지 다시한번 확인해주세요.                       
	echo *************************************************************
	ping -n 4 127.0.0.1 > nul
	set /p ANSWER=정말로 초기화 후 세팅을 진행할까요? [y/N]
)

:: --- y 외의 답변 exit 처리 ---
if /i not "%ANSWER%"=="y" (
	echo 작업이 취소되었습니다. 다시 시작해주세요.
	pause
	exit /b
)


:: --- 디스크 초기화 ---
echo ***** 초기화 작업 시작... *****
(
	echo sel disk %DISK_NUM%
	echo clean
	echo convert gpt
	
	echo cre par efi size=512
	echo format fs=fat32 quick
	echo assign letter S

	echo cre par msr size=16
	
	if "%OS_GB_SIZE%"=="0" (
		echo cre par pri
	) else (
		echo cre par pri size=%OS_MB_SIZE%
	)
	echo format fs=ntfs quick
	echo assign letter C
	
	if not "%OS_GB_SIZE"=="0" (
		echo cre par pri
		echo format fs=ntfs quick
		echo assign letter D
	)
	
	echo sel %DISK_NUM%
	echo list part
	echo exit

) >> temp_file.txt
diskpart /s temp_file.txt
del temp_file.txt
echo ***** 초기화 작업 완료. *****

:: --- WinNTSetup 실행 ---
echo ***** WinNTSetup.exe 를 실행합니다... *****
echo Tip : 적절한 wim 파일 선택 후, 다른 옵션 선택 없이 '확인'만 눌러 설치하면 됩니다.
.\WinNTSetup\WinNTSetup64.exe NT6 -tempdrive:C: -syspart:S: -unattend:unattend.xml

echo 윈도우 초기화 및 설치 작업을 마칩니다.
pause
exit /b