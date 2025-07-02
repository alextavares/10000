@echo off
echo ================================
echo  Configurando e Executando HabitAI
echo ================================
echo.

REM Configurar variavel de ambiente temporariamente
set "PROGRAMFILES(X86)=C:\Program Files (x86)"

echo Configuracao aplicada!
echo.

echo Executando HabitAI...
cd /d C:\codigos\habitai2406\10000
C:\flutter\bin\flutter run -d windows

pause
