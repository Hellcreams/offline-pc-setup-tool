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
set /p DISK_NUM= 윈도우를 재설치할 디스크 번호를 입력해주세요 : 
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
:: --- EFI 파티션 지정 ---
set /p EFI_NUM= EFI (시스템) 파티션 번호를 적어주세요 :  
(
	echo sel disk %DISK_NUM%
	echo sel part %EFI_NUM%
	echo assign letter S
) > temp_file.txt
diskpart /s temp_file.txt
del temp_file.txt

:: --- 경고창 ---
echo ************************** 경   고 ************************** 
echo * 이 작업은 한번 실행하면 되돌릴 수 없습니다!!!     
echo * 1. 중요한 자료는 백업이 되었는지                      
echo * 2. 초기화 대상 디스크가 정확한지
echo * 3. C 드라이브가 정확히 할당되어 있고, S 드라이브는 없는지                  
echo * 다시 한 번 확인하시기 바랍니다.                        
echo *************************************************************
ping -n 2 127.0.0.1 > nul

:: --- IP 데이터 조회 ---
reg load HKEY_LOCAL_MACHINE\LOCAL_REG C:\Windows\System32\Config\SYSTEM >nul 2>&1

if %errorlevel%==0 (
	reg query HKEY_LOCAL_MACHINE\LOCAL_REG\ControlSet001\Services\Tcpip\Parameters\Interfaces /s | findstr "HKEY IPAddress SubnetMask Gateway NameServer" | findstr /v /i "dhcp" >log\latest_mini.txt 2>nul
	reg unload HKEY_LOCAL_MACHINE\LOCAL_REG >nul 2>&1
) else (
	echo ************************** 심   각 ************************** 
	echo * !! C 드라이브가 윈도우가 깔리지 않은 디스크 같습니다! !!    
	echo * 디스크 %DISK_NUM%이 포맷 대상이 정확한지 다시한번 확인해주세요.                       
	echo *************************************************************
	ping -n 3 127.0.0.1 > nul
)

:: --- WinNTSetup 실행 ---
echo ***** WinNTSetup.exe 를 실행합니다... *****
echo Tip : C드라이브는 포맷 실행 후 재설치할 것을 권장합니다.
.\WinNTSetup\WinNTSetup64.exe NT6 -tempdrive:C: -syspart:S: -unattend:unattend.xml

echo 윈도우 재설치 작업을 마칩니다.
pause
exit /b