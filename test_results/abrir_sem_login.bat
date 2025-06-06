@echo off
echo ===============================================
echo   FORCAR LOGOUT - HabitAI
echo ===============================================
echo.
echo Este script vai:
echo 1. Abrir o navegador em modo privado
echo 2. Garantir que voce veja a tela de login
echo.
echo ===============================================
echo.
echo Abrindo HabitAI em modo privado...
echo.

REM Tentar abrir no Edge em modo InPrivate
start msedge -inprivate http://localhost:5004

echo.
echo ===============================================
echo   IMPORTANTE:
echo ===============================================
echo.
echo Se ainda aparecer logado:
echo 1. Pressione F12 no navegador
echo 2. Va para a aba "Application" ou "Armazenamento"
echo 3. Clique em "Clear storage" ou "Limpar dados"
echo 4. Recarregue a pagina (F5)
echo.
echo ===============================================
echo.
pause
