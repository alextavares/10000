@echo off
echo ========================================
echo   Maestro Cloud - Configuracao
echo ========================================
echo.

cd /d "C:\codigos\HabitAiclaudedesktop\HabitAI"

echo Para usar o Maestro Cloud, voce precisa:
echo.
echo 1. Criar uma conta em: https://cloud.maestro.dev
echo 2. Fazer login com: maestro cloud login
echo 3. Fazer upload dos testes: maestro cloud upload .maestro
echo.

echo Escolha uma opcao:
echo.
echo 1. Abrir documentacao do Maestro Cloud
echo 2. Fazer login no Maestro Cloud
echo 3. Verificar status do login
echo 4. Fazer upload dos testes para a nuvem
echo 5. Executar testes na nuvem
echo 6. Ver resultados dos testes na nuvem
echo 0. Sair
echo.

set /p opcao="Digite a opcao: "

if "%opcao%"=="1" (
    echo.
    echo Abrindo documentacao...
    start https://docs.maestro.dev/cloud/run-maestro-tests-in-the-cloud
) else if "%opcao%"=="2" (
    echo.
    echo Fazendo login no Maestro Cloud...
    maestro cloud login
) else if "%opcao%"=="3" (
    echo.
    echo Verificando status do login...
    maestro cloud status
) else if "%opcao%"=="4" (
    echo.
    echo Fazendo upload dos testes...
    maestro cloud upload .maestro
) else if "%opcao%"=="5" (
    echo.
    echo Executando testes na nuvem...
    maestro cloud test .maestro
) else if "%opcao%"=="6" (
    echo.
    echo Abrindo resultados na nuvem...
    start https://cloud.maestro.dev
) else if "%opcao%"=="0" (
    exit /b 0
) else (
    echo Opcao invalida!
)

echo.
pause
