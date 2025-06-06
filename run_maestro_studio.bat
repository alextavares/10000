@echo off
cd /d "C:\codigos\HabitAiclaudedesktop\HabitAI"

echo ========================================
echo    Configurando ambiente...
echo ========================================

set JAVA_HOME=C:\Program Files\Java\jdk-17
set ANDROID_HOME=C:\Users\alext\AppData\Local\Android\Sdk
set PATH=%JAVA_HOME%\bin;C:\maestro\bin;%ANDROID_HOME%\platform-tools;%PATH%

echo.
echo Verificando conexao com dispositivo...
adb devices -l

echo.
echo ========================================
echo    Iniciando Maestro Studio
echo ========================================
echo.
echo Acessar em: http://localhost:9999/interact
echo.

maestro studio --host 0.0.0.0 --port 9999

pause
