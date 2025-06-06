@echo off
echo =====================================
echo Executando HabitAI - Script Alternativo
echo =====================================
echo.

REM Limpar cache do Flutter
echo Limpando cache...
flutter clean

echo.
echo Obtendo dependencias...
flutter pub get

echo.
echo Verificando dispositivos...
flutter devices

echo.
echo =====================================
echo OPCOES DE EXECUCAO:
echo =====================================
echo.
echo 1. Se voce tem um dispositivo Android fisico:
echo    - Conecte via USB
echo    - Ative o modo desenvolvedor
echo    - Execute: flutter run
echo.
echo 2. Para tentar novamente no emulador:
echo    - Execute: flutter run -d emulator-5554
echo.
echo 3. Para criar um APK para instalar manualmente:
echo    - Execute: flutter build apk
echo    - O APK estara em: build\app\outputs\flutter-apk\app-release.apk
echo.
echo 4. Para executar em modo debug sem emulador:
echo    - Execute: flutter build apk --debug
echo    - Transfira para o telefone e instale
echo.
pause
