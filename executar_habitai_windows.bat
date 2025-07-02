@echo off
echo ================================
echo  Corrigindo Ambiente e Executando HabitAI
echo ================================
echo.

REM Configurar variáveis de ambiente necessárias
setx "PROGRAMFILES(X86)" "C:\Program Files (x86)" >nul 2>&1
set "PROGRAMFILES(X86)=C:\Program Files (x86)"
set "PATH=%PATH%;C:\flutter\bin"

echo Variavel de ambiente configurada!
echo.

echo Verificando Flutter...
call C:\flutter\bin\flutter --version

echo.
echo Limpando projeto...
call C:\flutter\bin\flutter clean

echo.
echo Obtendo dependencias...
call C:\flutter\bin\flutter pub get

echo.
echo Instalando ferramentas do Windows se necessario...
call C:\flutter\bin\flutter config --enable-windows-desktop

echo.
echo Executando o app no Windows...
call C:\flutter\bin\flutter run -d windows

pause
