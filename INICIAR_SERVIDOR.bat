@echo off
echo ================================================
echo   INICIANDO HABITAI - SERVIDOR FLUTTER
echo ================================================
echo.
echo Navegando para o diretorio do projeto...
cd /d C:\codigos\HabitAiclaudedesktop\HabitAI
echo.
echo Iniciando servidor Flutter na porta 5004...
echo.
echo ================================================
echo   COMANDOS IMPORTANTES:
echo ================================================
echo   R  = Hot Reload (recarregar mudancas)
echo   r  = Hot Restart (reiniciar completo)
echo   q  = Quit (parar servidor)
echo   h  = Help (ajuda)
echo ================================================
echo.
flutter run -d web-server --web-port=5004
pause
