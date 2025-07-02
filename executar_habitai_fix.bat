@echo off
echo ================================
echo  Configurando e Executando HabitAI
echo ================================
echo.

REM Definir variáveis de ambiente necessárias
set "PROGRAMFILES(X86)=C:\Program Files (x86)"
set "PATH=%PATH%;C:\flutter\bin"

echo Verificando Flutter...
C:\flutter\bin\flutter --version

echo.
echo Limpando projeto...
C:\flutter\bin\flutter clean

echo.
echo Obtendo dependências...
C:\flutter\bin\flutter pub get

echo.
echo Executando o app...
C:\flutter\bin\flutter run -d windows

pause
