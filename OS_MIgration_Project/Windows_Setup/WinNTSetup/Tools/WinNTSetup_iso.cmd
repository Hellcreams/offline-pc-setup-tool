@echo off

IF %1!==! (
echo.
echo  WinNTSetup ISO 파일 열기
echo.
echo  이 배치를 실행하면 ISO 파일이 열립니다.
echo  "소스"버튼을 우클릭하여, ISO 파일을 선택하십시오.
echo  ISO가 % 1에 저장되었습니다.
echo.
echo  "Imdisk 가상 디스크 드라이버" 샘플
echo  http://www.ltr-data.se/opencode.html/#ImDisk
echo.
echo  silent install: imdiskinst -y
echo  mount command : imdisk -a -m #: -f %1
echo.
pause
goto :EOF
)

imdisk -a -m #: -f %1