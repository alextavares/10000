@echo off
setlocal

set "JAVA_HOME=C:\Program Files\Java\jdk-17"
set "PATH=%JAVA_HOME%\bin;C:\maestro\bin;%PATH%"

cd /d "C:\codigos\HabitAiclaudedesktop\HabitAI"

echo ========================================
echo   Diagnostico Maestro + Dispositivo
echo ========================================
echo.

echo 1. Verificando ADB...
where adb 2>nul
if %errorlevel% neq 0 (
    echo [!] ADB nao encontrado no PATH
    
    REM Tentar encontrar ADB
    if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" (
        set "PATH=%LOCALAPPDATA%\Android\Sdk\platform-tools;%PATH%"
        echo [OK] ADB encontrado em Android SDK
    )
)

echo.
echo 2. Listando dispositivos...
adb devices -l

echo.
echo 3. Verificando Maestro...
maestro --version

echo.
echo 4. Testando conexao com dispositivo...
maestro doctor

echo.
echo 5. Executando teste generico simples...
maestro test .maestro\test_generico.yaml

echo.
pause
