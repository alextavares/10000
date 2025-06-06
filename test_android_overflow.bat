@echo off
echo === Teste de Correcao de Overflow Android ===
echo.
echo Este script ajuda a testar a correcao de overflow no Android
echo.

REM Verificar se o Flutter esta instalado
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo X Flutter nao encontrado. Por favor, instale o Flutter.
    pause
    exit /b 1
)

REM Verificar dispositivos conectados
echo Verificando dispositivos conectados...
flutter devices
echo.

echo Compilando o aplicativo...
flutter clean
flutter pub get
flutter build apk --debug

echo.
echo === Instrucoes de Teste ===
echo.
echo 1. Instale o APK no dispositivo:
echo    flutter install
echo.
echo 2. Verifique os seguintes pontos:
echo    - A tela principal nao apresenta overflow
echo    - O conteudo nao fica cortado na parte superior (status bar)
echo    - O conteudo nao fica cortado na parte inferior (navigation bar)
echo    - Em dispositivos com notch, o conteudo nao fica sobreposto
echo.
echo 3. Teste em diferentes orientacoes:
echo    - Portrait
echo    - Landscape
echo.
echo 4. Teste com diferentes configuracoes de navegacao:
echo    - Navegacao por gestos
echo    - Navegacao por botoes
echo.
echo 5. Para debug detalhado, verifique o logcat:
echo    adb logcat ^| findstr "System Insets"
echo.
echo 6. Capture screenshots se encontrar problemas:
echo    adb shell screencap /sdcard/overflow_test.png
echo    adb pull /sdcard/overflow_test.png
echo.

REM Oferecer instalacao automatica
set /p install="Deseja instalar o APK agora? (s/n): "
if /i "%install%"=="s" (
    flutter install
    echo.
    echo APK instalado! Por favor, execute os testes manuais listados acima.
)

echo.
echo Para ver os logs de insets do sistema em tempo real:
echo flutter logs ^| findstr /C:"System Insets" /C:"viewInsets" /C:"viewPadding" /C:"systemPadding"
echo.
pause
