@echo off
setlocal

REM Configurar variáveis de ambiente temporariamente
set "JAVA_HOME=C:\Program Files\Java\jdk-17"
set "PATH=%JAVA_HOME%\bin;C:\maestro\bin;%PATH%"

cd /d "C:\codigos\HabitAiclaudedesktop\HabitAI"

echo ========================================
echo   Executando Suite de Testes Maestro
echo ========================================
echo.

REM Executar todos os testes e mostrar resultados
maestro test .maestro\

echo.
echo ========================================
echo   Resumo dos Testes
echo ========================================
echo.

REM Listar arquivos de teste
echo Testes disponíveis:
dir /b .maestro\*.yaml

echo.
pause
