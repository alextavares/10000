@echo off
echo ================================
echo  Executando HabitAI
echo ================================
echo.

echo Limpando o projeto...
call flutter clean

echo.
echo Obtendo dependencias...
call flutter pub get

echo.
echo Executando o app...
call flutter run

pause