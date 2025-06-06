@echo off
echo ========================================
echo   Testes Maestro - HabitAI
echo ========================================
echo.

REM Verificar se o Maestro está instalado
maestro --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Maestro não encontrado ou Java não está configurado!
    echo.
    echo Por favor:
    echo 1. Instale o Java 17+ de https://adoptium.net/
    echo 2. Configure a variável JAVA_HOME
    echo 3. Reinicie o terminal
    echo.
    pause
    exit /b 1
)

echo Opções disponíveis:
echo.
echo 1. Executar todos os testes
echo 2. Teste de inicialização do app
echo 3. Teste de criar hábito
echo 4. Teste de marcar hábito
echo 5. Teste de navegação
echo 6. Abrir Maestro Studio (modo interativo)
echo 7. Listar dispositivos
echo 0. Sair
echo.

set /p opcao="Escolha uma opção: "

cd /d "C:\codigos\HabitAiclaudedesktop\HabitAI"

if "%opcao%"=="1" (
    echo.
    echo Executando todos os testes...
    maestro test .maestro\
) else if "%opcao%"=="2" (
    echo.
    echo Executando teste de inicialização...
    maestro test .maestro\test_app_launch.yaml
) else if "%opcao%"=="3" (
    echo.
    echo Executando teste de criar hábito...
    maestro test .maestro\test_criar_habito.yaml
) else if "%opcao%"=="4" (
    echo.
    echo Executando teste de marcar hábito...
    maestro test .maestro\test_marcar_habito.yaml
) else if "%opcao%"=="5" (
    echo.
    echo Executando teste de navegação...
    maestro test .maestro\test_navegacao.yaml
) else if "%opcao%"=="6" (
    echo.
    echo Abrindo Maestro Studio...
    maestro studio
) else if "%opcao%"=="7" (
    echo.
    echo Dispositivos disponíveis:
    echo.
    adb devices
    echo.
) else if "%opcao%"=="0" (
    exit /b 0
) else (
    echo Opção inválida!
)

echo.
pause
