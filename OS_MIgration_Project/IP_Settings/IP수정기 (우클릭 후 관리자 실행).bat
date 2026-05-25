@echo off
chcp 65001 >nul
setlocal

echo ===== 네트워크 아이피 설정 마법사 =====
echo.

:: 세팅 변수 설정

set SUBNET_MASK=255.255.255.0
set SUBNET_RANGE=3

set GT_IP1=0
set GT_IP2=0
set GT_IP3=0
set GT_IP4=6

set DNS1=8.8.8.8
set DNS2=4.4.4.4

:: 관리자 권한 확인
net session >nul 2>&1
if %errorlevel% neq 0 (
	echo 관리자 권한 실행이 필요합니다.
	echo 파일에 [우클릭] → [관리자 권한으로 실행]을 눌러 재실행해주세요.
	pause
	exit /b 1
)

:: 수정할 네트워크 인터페이스 지정
powershell -Command "Get-NetAdapter -Physical | Select-Object ifIndex, Name, InterfaceDescription | Sort-Object 
for /f %%i in ('powershell -Command "((Get-NetAdapter -Physical).ifIndex).Count"') do set COUNT=%%i
echo -------------------------------------

if %COUNT%==0 (
	echo 네트워크 장치가 감지되지 않습니다.
	echo 체계반[내선 ****]으로 문의바랍니다.
	pause
	exit /b 1
) else if %COUNT%==1 (
	for /f %%i in ('powershell -Command "@(Get-NetAdapter -Physical).ifIndex[0]"') do set NIC=%%i
) else (
	echo 네트워크 장치가 다수 감지되었습니다.
	set /p NIC = "설정할 장치 번호를 입력하세요 : "
)
echo 감지된 인터페이스 번호 : %NIC%
echo 아이피 입력기를 실행합니다...
ping -n 2 127.0.0.1 >nul

:: 아이피 입력

set LOCAL_IP1=_
set LOCAL_IP2=_
set LOCAL_IP3=_
set LOCAL_IP4=_

:: 1
cls
echo ===== 네트워크 아이피 설정 마법사 =====
set LOCAL_IP1=#
echo 아이피(IP) : [ %LOCAL_IP1% ] . [ %LOCAL_IP2% ] . [ %LOCAL_IP3% ] . [ %LOCAL_IP4% ]
echo.
set /p LOCAL_IP1="1번째 칸[#]에 들어갈 숫자를 입력해주세요 : "

:: 2
cls
echo ===== 네트워크 아이피 설정 마법사 =====
set LOCAL_IP2=#
echo 아이피(IP) : [ %LOCAL_IP1% ] . [ %LOCAL_IP2% ] . [ %LOCAL_IP3% ] . [ %LOCAL_IP4% ]
echo.
set /p LOCAL_IP2="2번째 칸[#]에 들어갈 숫자를 입력해주세요 : "

:: 3
cls
echo ===== 네트워크 아이피 설정 마법사 =====
set LOCAL_IP3=#
echo 아이피(IP) : [ %LOCAL_IP1% ] . [ %LOCAL_IP2% ] . [ %LOCAL_IP3% ] . [ %LOCAL_IP4% ]
echo.
set /p LOCAL_IP3="3번째 칸[#]에 들어갈 숫자를 입력해주세요 : "

:: 4
cls
echo ===== 네트워크 아이피 설정 마법사 =====
set LOCAL_IP4=#
echo 아이피(IP) : [ %LOCAL_IP1% ] . [ %LOCAL_IP2% ] . [ %LOCAL_IP3% ] . [ %LOCAL_IP4% ]
echo.
set /p LOCAL_IP4="4번째 칸[#]에 들어갈 숫자를 입력해주세요 : "

:: 아이피 세팅
echo.
echo.

set SET_IP=%LOCAL_IP1%.%LOCAL_IP2%.%LOCAL_IP3%.%LOCAL_IP4%

if %SUBNET_RANGE%==0 (
	set SET_GATEWAY=%GT_IP1%.%GT_IP2%.%GT_IP3%.%GT_IP4%
) else if %SUBNET_RANGE%==1 (
	set SET_GATEWAY=%LOCAL_IP1%.%GT_IP2%.%GT_IP3%.%GT_IP4%
) else if %SUBNET_RANGE%==2 (
	set SET_GATEWAY=%LOCAL_IP1%.%LOCAL_IP2%.%GT_IP3%.%GT_IP4%
) else if %SUBNET_RANGE%==3 (
	set SET_GATEWAY=%LOCAL_IP1%.%LOCAL_IP2%.%LOCAL_IP3%.%GT_IP4%
) else (
set SET_GATEWAY=0.0.0.0
)

:: 최종 확인
cls
echo ===== 네트워크 아이피 설정 마법사 =====
echo.
echo ----- 아이피 세팅 확인 -----
echo IP : %SET_IP%    ←    설정값 확인!
echo Subnet : %SUBNET_MASK%
echo Gateway : %SET_GATEWAY%
echo DNS_MAIN : %DNS1%
echo DNS_SUB : %DNS2%
echo.
ping -n 2 127.0.0.1 >nul
echo IP 값이 정확한지 확인해주세요. 아무 키나 누르면, 작업이 진행됩니다. 원하지 않으시면, Ctrl+C를 눌러주세요.
pause

:: netsh 설정
echo.
echo *** 세팅 시작... ***
echo.
netsh interface ip set address name="%NIC%" static %SET_IP% %SUBNET_MASK% %SET_GATEWAY% 1

if %errorlevel%==1 (
	echo *** 세팅 중단. ***
	echo IP 입력값이 정확히 숫자 [0~255]로 되어있는지 확인해주세요.
	echo 문제가 지속될 경우, 체계반[내선 ****]으로 문의해주세요.
	pause
	exit /b 1
)

netsh interface ip set dns name="%NIC%" static %DNS1%
netsh interface ip add dns name="%NIC%" %DNS2% index=2

echo.
echo *** 세팅 끝. ***
echo. 
echo IP 세팅이 완료되었습니다. [%SET_IP%]
echo 망 연결까지 최대 3분 정도 소요될 수 있습니다.
echo 올바르게 IP를 기입했으나, 인터넷이 되지 않는 경우 CERT (내선 ****)에 문의해주세요.
pause
exit /b 0