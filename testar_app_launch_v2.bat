@echo off
echo ========================================
echo   Executando Teste App Launch V2
echo ========================================
echo.

REM Configurar ambiente
set "JAVA_HOME=C:\Program Files\Java\jdk-17"
set "ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk"
set "PATH=%JAVA_HOME%\bin;C:\maestro\bin;%ANDROID_HOME%\platform-tools;%PATH%"

cd /d "C:\codigos\HabitAiclaudedesktop\HabitAI"

echo Verificando dispositivo...
adb devices
echo.

echo Executando teste de inicializacao V2...
maestro test .maestro\test_app_launch_v2.yaml --format detailed
echo.

echo Para ver o screenshot capturado:
echo ver_screenshots.ps1
echo.

pause
