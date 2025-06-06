@echo off
echo ========================================
echo   Teste Rapido Maestro - HabitAI
echo ========================================
echo.

set JAVA_HOME=C:\Program Files\Java\jdk-17
set PATH=%JAVA_HOME%\bin;C:\maestro\bin;%PATH%

cd /d "C:\codigos\HabitAiclaudedesktop\HabitAI"

echo Executando teste de inicializacao...
echo.

maestro test .maestro\test_app_launch.yaml --format junit --output test_results.xml

echo.
echo Para ver mais detalhes, execute:
echo maestro test .maestro\test_app_launch.yaml --debug
echo.

echo Para abrir o Maestro Studio (interface visual):
echo maestro studio
echo.

pause
