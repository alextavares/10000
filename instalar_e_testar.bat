@echo off
echo ========================================
echo   Instalando HabitAI no dispositivo
echo ========================================
echo.

set JAVA_HOME=C:\Program Files\Java\jdk-17
set PATH=%JAVA_HOME%\bin;C:\maestro\bin;%PATH%

cd /d "C:\codigos\HabitAiclaudedesktop\HabitAI"

echo Verificando dispositivos conectados...
echo.

REM Tentar encontrar o ADB do Android SDK
set ADB_PATH=
if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" (
    set ADB_PATH=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe
) else if exist "%USERPROFILE%\AppData\Local\Android\Sdk\platform-tools\adb.exe" (
    set ADB_PATH=%USERPROFILE%\AppData\Local\Android\Sdk\platform-tools\adb.exe
) else if exist "C:\Android\sdk\platform-tools\adb.exe" (
    set ADB_PATH=C:\Android\sdk\platform-tools\adb.exe
) else (
    echo [ERRO] ADB nao encontrado!
    echo.
    echo Por favor, instale o Android SDK ou Android Studio
    echo Ou adicione o caminho do ADB ao PATH
    echo.
    pause
    exit /b 1
)

echo Usando ADB: %ADB_PATH%
echo.

"%ADB_PATH%" devices
echo.

echo Se o dispositivo esta listado acima, pressione qualquer tecla para instalar...
pause

echo.
echo Desinstalando versao anterior (se existir)...
"%ADB_PATH%" uninstall com.habitai.app 2>nul

echo.
echo Instalando HabitAI...
"%ADB_PATH%" install -r "build\app\outputs\flutter-apk\app-debug.apk"

if %errorlevel% equ 0 (
    echo.
    echo ✅ App instalado com sucesso!
    echo.
    echo Iniciando o app...
    "%ADB_PATH%" shell monkey -p com.habitai.app -c android.intent.category.LAUNCHER 1
    
    echo.
    echo Aguardando app iniciar...
    timeout /t 5 /nobreak >nul
    
    echo.
    echo Pronto para executar testes Maestro!
) else (
    echo.
    echo ❌ Erro ao instalar o app!
    echo.
    echo Possiveis problemas:
    echo 1. Dispositivo nao conectado ou nao autorizado
    echo 2. Depuracao USB desativada
    echo 3. APK corrompido
)

echo.
pause
