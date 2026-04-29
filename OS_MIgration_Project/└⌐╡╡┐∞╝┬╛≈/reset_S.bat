@echo off
(
	echo sel volume S
	echo remove letter=S
	echo exit
) > temp_file.txt
diskpart /s temp_file.txt
del temp_file.txt
echo S 드라이브 할당 제거 완료.
pause
exit /b