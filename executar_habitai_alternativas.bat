@echo off
echo ================================
echo  Verificando Emuladores Android
echo ================================
echo.

echo Listando emuladores disponiveis...
C:\flutter\bin\flutter emulators

echo.
echo Para criar um emulador Android:
echo 1. Abra o Android Studio
echo 2. Va em Tools - AVD Manager
echo 3. Create Virtual Device
echo 4. Escolha um dispositivo (ex: Pixel 4)
echo 5. Baixe uma imagem do sistema (ex: Android 13)
echo 6. Finalize a criacao

echo.
echo Para executar com emulador:
echo 1. Inicie o emulador pelo Android Studio
echo 2. Execute: C:\flutter\bin\flutter run

echo.
echo Tentando executar no Chrome (alternativa)...
echo Instalando Chrome se necessario...
start https://www.google.com/chrome/

echo.
echo Apos instalar o Chrome, execute:
echo C:\flutter\bin\flutter run -d chrome

pause
