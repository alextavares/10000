@echo off
set JAVA_HOME=C:\Program Files\Java\jdk-17
set PATH=%JAVA_HOME%\bin;C:\maestro\bin;%PATH%

cd /d "C:\codigos\HabitAiclaudedesktop\HabitAI"

echo ========================================
echo   Executando Teste Maestro - HabitAI
echo ========================================
echo.
echo IMPORTANTE: Certifique-se de que:
echo 1. Um emulador Android esta aberto OU
echo 2. Um dispositivo fisico esta conectado via USB
echo 3. O app HabitAI esta instalado no dispositivo
echo.
echo Pressione CTRL+C para cancelar ou...
pause

echo.
echo Executando teste de inicializacao do app...
echo.

maestro test .maestro\test_app_launch.yaml

echo.
echo Teste concluido! Verifique os resultados acima.
echo.
pause
