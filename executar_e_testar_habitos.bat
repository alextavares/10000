@echo off
echo ============================================
echo   EXECUTAR HABITAI E TESTAR CRIACAO HABITOS
echo ============================================
echo.

echo 1. Iniciando emulador Android...
echo.
flutter emulators --launch Pixel_9_Pro_XL
timeout /t 30 /nobreak > nul

echo.
echo 2. Verificando dispositivos conectados...
echo.
flutter devices

echo.
echo 3. Executando o HabitAI...
echo.
echo IMPORTANTE: Quando o app abrir:
echo - Faca login com sua conta
echo - Va para aba "Habitos" 
echo - Clique no botao "+" para criar habito
echo - Preencha o formulario e salve
echo.
echo Iniciando app em 5 segundos...
timeout /t 5 /nobreak > nul

flutter run

pause
