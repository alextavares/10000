@echo off
echo ========================================
echo   Debug de Testes Maestro - HabitAI
echo ========================================
echo.

REM Configurar ambiente
set "JAVA_HOME=C:\Program Files\Java\jdk-17"
set "ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk"
set "PATH=%JAVA_HOME%\bin;C:\maestro\bin;%ANDROID_HOME%\platform-tools;%PATH%"

cd /d "C:\codigos\HabitAiclaudedesktop\HabitAI"

echo Status dos testes (baseado no ultimo resumo):
echo.
echo [OK] test_generico.yaml
echo [OK] test_marcar_habito.yaml
echo [OK] test_navegacao.yaml
echo [OK] test_funcionalidades_avancadas.yaml
echo [FALHA] test_app_launch.yaml
echo [FALHA] test_criar_habito.yaml
echo [FALHA] test_validacao_erros.yaml
echo.

echo Escolha uma opcao:
echo.
echo 1. Executar teste que falhou com DEBUG (test_app_launch)
echo 2. Executar teste que falhou com DEBUG (test_criar_habito)
echo 3. Executar teste que falhou com DEBUG (test_validacao_erros)
echo 4. Re-executar apenas os testes que falharam
echo 5. Abrir Maestro Studio para debug visual
echo 6. Executar todos os testes novamente
echo 0. Sair
echo.

set /p opcao="Digite a opcao: "

if "%opcao%"=="1" (
    echo.
    echo Executando test_app_launch.yaml com DEBUG...
    maestro test .maestro\test_app_launch.yaml --debug
) else if "%opcao%"=="2" (
    echo.
    echo Executando test_criar_habito.yaml com DEBUG...
    maestro test .maestro\test_criar_habito.yaml --debug
) else if "%opcao%"=="3" (
    echo.
    echo Executando test_validacao_erros.yaml com DEBUG...
    maestro test .maestro\test_validacao_erros.yaml --debug
) else if "%opcao%"=="4" (
    echo.
    echo Re-executando testes que falharam...
    maestro test .maestro\test_app_launch.yaml .maestro\test_criar_habito.yaml .maestro\test_validacao_erros.yaml
) else if "%opcao%"=="5" (
    echo.
    echo Abrindo Maestro Studio...
    echo Acesse: http://localhost:9999
    echo.
    maestro studio
) else if "%opcao%"=="6" (
    echo.
    echo Executando todos os testes...
    maestro test .maestro\
) else if "%opcao%"=="0" (
    exit /b 0
) else (
    echo Opcao invalida!
)

echo.
pause
