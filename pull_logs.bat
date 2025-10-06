@echo off
setlocal enabledelayedexpansion
chcp 65001 > nul
echo ========================================
echo   TimeDog 로그 파일 가져오기
echo ========================================
echo.

REM logs 디렉토리 생성
if not exist "logs" mkdir logs

REM Android SDK 경로 찾기
echo ADB 경로 확인 중...
for /f "tokens=*" %%i in ('where flutter 2^>nul') do set "FLUTTER_PATH=%%i"

if defined FLUTTER_PATH (
    for %%i in ("%FLUTTER_PATH%") do set "FLUTTER_DIR=%%~dpi"
    set "FLUTTER_DIR=!FLUTTER_DIR:~0,-1!"

    REM Android SDK 경로는 보통 flutter\bin\..\.. 구조
    for %%i in ("!FLUTTER_DIR!\..") do set "FLUTTER_ROOT=%%~fi"

    REM ANDROID_HOME 환경변수 확인
    if defined ANDROID_HOME (
        set "ADB_PATH=!ANDROID_HOME!\platform-tools\adb.exe"
    ) else (
        REM 기본 Android SDK 경로들 시도
        if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" (
            set "ADB_PATH=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
        ) else if exist "C:\Android\Sdk\platform-tools\adb.exe" (
            set "ADB_PATH=C:\Android\Sdk\platform-tools\adb.exe"
        )
    )
)

if not defined ADB_PATH (
    echo.
    echo ❌ ADB를 찾을 수 없습니다.
    echo.
    echo Android SDK 경로를 수동으로 설정하거나
    echo 다음 명령어로 환경변수를 설정하세요:
    echo setx ANDROID_HOME "C:\Users\%USERNAME%\AppData\Local\Android\Sdk"
    echo.
    pause
    exit /b 1
)

if not exist "!ADB_PATH!" (
    echo.
    echo ❌ ADB 파일을 찾을 수 없습니다: !ADB_PATH!
    echo.
    pause
    exit /b 1
)

echo ADB 경로: !ADB_PATH!
echo.

REM 로그 파일을 logs 폴더로 가져오기
echo 로그 파일 다운로드 중...
"!ADB_PATH!" shell "run-as com.example.timedog_test cat app_flutter/logs/app_logs.txt" > logs\app_logs.txt 2>&1

REM 파일 크기 확인
for %%A in (logs\app_logs.txt) do set size=%%~zA

if !size! GTR 0 (
    echo.
    echo ✅ 로그 파일 저장 완료: logs\app_logs.txt
    echo 📊 파일 크기: !size! bytes
    echo.
    echo VS Code로 열기...
    code logs\app_logs.txt 2>nul || (
        echo VS Code를 찾을 수 없습니다. 메모장으로 열기...
        notepad logs\app_logs.txt
    )
) else (
    echo.
    echo ❌ 로그 파일이 비어있거나 가져오기 실패
    echo.
    echo 파일 내용:
    type logs\app_logs.txt
    echo.
    echo 해결 방법:
    echo 1. 디바이스가 USB로 연결되어 있는지 확인
    echo 2. USB 디버깅이 활성화되어 있는지 확인
    echo 3. 앱이 실행되고 로그가 기록되었는지 확인
    echo 4. adb devices 명령으로 연결 확인
    echo.
    pause
)
