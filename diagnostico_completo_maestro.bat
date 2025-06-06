@echo off
setlocal EnableDelayedExpansion

echo ========================================
echo   Diagnostico Completo do Maestro
echo ========================================
echo.

REM Configurar todas as variaveis de ambiente necessarias
set "JAVA_HOME=C:\Program Files\Java\jdk-17"
set "ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk"
set "PATH=%JAVA_HOME%\bin;C:\maestro\bin;%ANDROID_HOME%\platform-tools;%PATH%"

cd /d "C:\codigos\HabitAiclaudedesktop\HabitAI"

echo [1] Verificando Java...
java -version 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Java nao encontrado!
    goto :fim
) else (
    echo [OK] Java encontrado
)
echo.

echo [2] Verificando ADB...
adb version
if %errorlevel% neq 0 (
    echo [ERRO] ADB nao encontrado!
    goto :fim
) else (
    echo [OK] ADB encontrado
)
echo.

echo [3] Verificando dispositivos conectados...
adb devices -l
echo.

echo [4] Verificando Maestro...
maestro --version
if %errorlevel% neq 0 (
    echo [ERRO] Maestro nao encontrado!
    goto :fim
) else (
    echo [OK] Maestro encontrado
)
echo.

echo [5] Verificando app instalado...
adb shell pm list packages | findstr habitai
if %errorlevel% neq 0 (
    echo [AVISO] App HabitAI nao encontrado no dispositivo
) else (
    echo [OK] App HabitAI instalado
)
echo.

echo [6] Executando Maestro Doctor...
maestro doctor
echo.

echo [7] Listando testes disponiveis...
dir /b .maestro\*.yaml
echo.

echo Deseja executar um teste? (S/N)
set /p resposta=

if /i "%resposta%"=="S" (
    echo.
    echo Executando teste generico...
    maestro test .maestro\test_generico.yaml
)

:fim
echo.
pause
