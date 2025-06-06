@echo off
echo =====================================
echo Configurando ambiente HabitAI
echo =====================================
echo.

REM Configurar variavel de ambiente PROGRAMFILES(X86)
echo Configurando variaveis de ambiente...
setx PROGRAMFILES(X86) "C:\Program Files (x86)" /M

REM Adicionar ADB ao PATH
echo Adicionando ADB ao PATH...
setx PATH "%PATH%;C:\Users\alext\AppData\Local\Android\sdk\platform-tools" /M

REM Reiniciar o servidor ADB
echo.
echo Reiniciando servidor ADB...
C:\Users\alext\AppData\Local\Android\sdk\platform-tools\adb.exe kill-server
timeout /t 2 /nobreak > nul
C:\Users\alext\AppData\Local\Android\sdk\platform-tools\adb.exe start-server
timeout /t 2 /nobreak > nul

REM Verificar dispositivos
echo.
echo Verificando dispositivos conectados...
C:\Users\alext\AppData\Local\Android\sdk\platform-tools\adb.exe devices

echo.
echo =====================================
echo INSTRUCOES IMPORTANTES:
echo =====================================
echo.
echo 1. Se o emulador estiver "offline" ou "authorizing":
echo    - Abra o emulador Android
echo    - No emulador, va em Settings > Developer options
echo    - Desative e reative "USB debugging"
echo    - Se aparecer um dialogo de autorizacao, aceite
echo.
echo 2. Para aplicar as variaveis de ambiente:
echo    - Feche e reabra o terminal/VS Code
echo    - Ou reinicie o computador
echo.
echo 3. Apos isso, execute novamente:
echo    flutter run -d emulator-5554
echo.
pause
