@echo off
echo.
echo ======================================
echo  Compilando HabitAI com Melhorias UI
echo ======================================
echo.

echo [1/4] Limpando projeto...
call flutter clean

echo.
echo [2/4] Obtendo dependencias...
call flutter pub get

echo.
echo [3/4] Compilando APK...
call flutter build apk --release

echo.
echo [4/4] Instalando no dispositivo...
adb install -r build\app\outputs\flutter-apk\app-release.apk

echo.
echo ======================================
echo  Compilacao concluida!
echo ======================================
echo.
echo APK salvo em: build\app\outputs\flutter-apk\app-release.apk
echo.
pause