@echo off
echo ==========================================
echo   TESTE DO FLUXO "TRY FIRST REGISTER LATER"
echo ==========================================
echo.

echo [1/4] Limpando dados do app para simular primeira vez...
adb shell pm clear com.habitai.app
if errorlevel 1 (
    echo ERRO: Falha ao limpar dados. Verifique se o emulador esta rodando.
    pause
    exit /b 1
)
echo ✓ Dados limpos com sucesso!
echo.

echo [2/4] Aguardando 2 segundos...
timeout /t 2 /nobreak >nul

echo [3/4] Iniciando o app...
cd /d "C:\codigos\habitai2406\10000"
start /b flutter run

echo.
echo [4/4] INSTRUCOES PARA TESTAR:
echo.
echo 1. Aguarde o app carregar completamente
echo.
echo 2. FLUXO ESPERADO:
echo    - Splash Screen (logo HabitAI)
echo    - Onboarding (se primeira vez)
echo    - Welcome Screen com opcoes:
echo      * "Comecar Jornada" (sem login)
echo      * "Ja tenho uma conta" (com login)
echo.
echo 3. TESTE O TRIAL:
echo    - Clique em "Comecar Jornada"
echo    - Deve entrar direto no app
echo    - Criar ate 3 habitos sem cadastro
echo.
echo 4. PARA VER LOGS:
echo    adb logcat ^| findstr /i habitai
echo.
echo ==========================================
pause
