@echo off
echo ========================================
echo   Build e Teste HabitAI com Maestro
echo ========================================
echo.

set JAVA_HOME=C:\Program Files\Java\jdk-17
set PATH=%JAVA_HOME%\bin;C:\maestro\bin;%PATH%

cd /d "C:\codigos\HabitAiclaudedesktop\HabitAI"

echo Opcoes:
echo.
echo 1. Usar APK existente (gerado ontem)
echo 2. Gerar novo APK e instalar
echo 3. Apenas executar testes (app ja instalado)
echo.

set /p opcao="Escolha uma opcao: "

if "%opcao%"=="1" (
    call instalar_e_testar.bat
) else if "%opcao%"=="2" (
    echo.
    echo Limpando build anterior...
    flutter clean
    
    echo.
    echo Obtendo dependencias...
    flutter pub get
    
    echo.
    echo Gerando APK debug...
    flutter build apk --debug
    
    if %errorlevel% equ 0 (
        echo.
        echo ✅ APK gerado com sucesso!
        call instalar_e_testar.bat
    ) else (
        echo.
        echo ❌ Erro ao gerar APK!
        pause
        exit /b 1
    )
) else if "%opcao%"=="3" (
    echo.
    echo Verificando Maestro...
    maestro --version
    echo.
    
    echo Executando teste basico...
    maestro test .maestro\test_app_launch.yaml
) else (
    echo Opcao invalida!
)

echo.
echo Deseja executar os testes Maestro agora? (S/N)
set /p executar="Resposta: "

if /i "%executar%"=="S" (
    echo.
    echo Executando suite de testes...
    echo.
    maestro test .maestro\
    
    echo.
    echo Testes concluidos! Screenshots salvas em:
    echo %USERPROFILE%\.maestro\tests\
)

echo.
pause
