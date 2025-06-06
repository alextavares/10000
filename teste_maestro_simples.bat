@echo off
echo ========================================
echo   Teste Direto do Maestro
echo ========================================
echo.

REM Configurar ambiente
set "JAVA_HOME=C:\Program Files\Java\jdk-17"
set "ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk"
set "PATH=%JAVA_HOME%\bin;C:\maestro\bin;%ANDROID_HOME%\platform-tools;%PATH%"

cd /d "C:\codigos\HabitAiclaudedesktop\HabitAI"

echo Verificando Maestro...
maestro --version
echo.

echo Verificando dispositivos...
adb devices
echo.

echo Executando teste generico...
maestro test .maestro\test_generico.yaml
echo.

pause
