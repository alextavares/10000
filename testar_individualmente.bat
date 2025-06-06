@echo off
setlocal EnableDelayedExpansion

REM Configurar variáveis de ambiente
set "JAVA_HOME=C:\Program Files\Java\jdk-17"
set "PATH=%JAVA_HOME%\bin;C:\maestro\bin;%PATH%"

cd /d "C:\codigos\HabitAiclaudedesktop\HabitAI"

echo ========================================
echo   Executando Testes Individualmente
echo ========================================
echo.

set /a passed=0
set /a failed=0
set /a total=0

REM Lista de testes
set tests[1]=test_app_launch.yaml
set tests[2]=test_criar_habito.yaml
set tests[3]=test_marcar_habito.yaml
set tests[4]=test_navegacao.yaml
set tests[5]=test_validacao_erros.yaml
set tests[6]=test_funcionalidades_avancadas.yaml

REM Executar cada teste
for /l %%i in (1,1,6) do (
    set /a total+=1
    echo.
    echo ----------------------------------------
    echo Teste %%i/6: !tests[%%i]!
    echo ----------------------------------------
    
    maestro test .maestro\!tests[%%i]! >nul 2>&1
    
    if !errorlevel! equ 0 (
        echo [PASSOU] !tests[%%i]!
        set /a passed+=1
    ) else (
        echo [FALHOU] !tests[%%i]!
        set /a failed+=1
        echo.
        echo Executando novamente com detalhes...
        maestro test .maestro\!tests[%%i]! --format compact
    )
)

echo.
echo ========================================
echo   RESUMO DOS TESTES
echo ========================================
echo Total de testes: %total%
echo Passou: %passed%
echo Falhou: %failed%
echo ========================================
echo.

echo Screenshots salvas em:
echo %USERPROFILE%\.maestro\tests\
echo.

pause
