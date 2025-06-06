@echo off
echo ========================================
echo   Teste Maestro Studio
echo ========================================
echo.

REM Configurar ambiente completo
set "JAVA_HOME=C:\Program Files\Java\jdk-17"
set "ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk"
set "PATH=%JAVA_HOME%\bin;C:\maestro\bin;%ANDROID_HOME%\platform-tools;%PATH%"

cd /d "C:\codigos\HabitAiclaudedesktop\HabitAI"

echo Verificando pre-requisitos...
echo.

echo Java:
java -version 2>&1 | findstr "version"
echo.

echo Maestro:
maestro --version
echo.

echo Dispositivos:
adb devices
echo.

echo ========================================
echo   Iniciando Maestro Studio
echo ========================================
echo.
echo Apos iniciar, acesse no navegador:
echo http://localhost:9999
echo.
echo Pressione Ctrl+C para parar o servidor
echo.

maestro studio

pause
