@echo off
echo =====================================
echo INSTALACAO MANUAL DO HABITAI
echo =====================================
echo.

echo O APK esta localizado em:
echo.
echo   build\app\outputs\flutter-apk\app-debug.apk
echo.
echo Como instalar no seu telefone:
echo.
echo 1. OPCAO MAIS FACIL - Via cabo USB:
echo    - Conecte o telefone no modo "Transferencia de arquivos"
echo    - Copie o arquivo app-debug.apk para a pasta Downloads do telefone
echo    - No telefone, abra o gerenciador de arquivos
echo    - Va ate Downloads e toque no app-debug.apk
echo    - Permita a instalacao de fontes desconhecidas se solicitado
echo.
echo 2. Via Google Drive ou similar:
echo    - Faca upload do app-debug.apk para o Google Drive
echo    - No telefone, baixe o arquivo do Drive
echo    - Instale o APK
echo.
echo 3. Via WhatsApp Web:
echo    - Envie o APK para voce mesmo no WhatsApp
echo    - Baixe e instale no telefone
echo.
echo Abrindo a pasta do APK...
start "" "build\app\outputs\flutter-apk\"
echo.
pause
