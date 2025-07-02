@echo off
echo ========================================
echo   CRIAR NOVO HABITO NO HABITAI
echo ========================================
echo.

REM Navegar para o diretório do projeto
cd /d C:\codigos\habitai2406\10000

REM Verificar se o Node.js está instalado
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Node.js nao esta instalado ou nao esta no PATH
    echo Por favor, instale o Node.js de https://nodejs.org/
    pause
    exit /b 1
)

REM Verificar se o Flutter está instalado
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Flutter nao esta instalado ou nao esta no PATH
    echo Por favor, configure o Flutter seguindo https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo [OK] Dependencias verificadas
echo.

REM Menu de opções
echo Escolha uma opcao:
echo.
echo 1. Criar habito de Gratidao (lista de atividades)
echo 2. Criar habito de Beber Agua (quantidade)
echo 3. Criar habito de Meditacao (cronometro)
echo 4. Criar habito de Exercicio (sim/nao)
echo 5. Criar habito personalizado (editar script primeiro)
echo.
set /p opcao="Digite o numero da opcao desejada: "

REM Executar ação baseada na escolha
if "%opcao%"=="1" goto gratidao
if "%opcao%"=="2" goto agua
if "%opcao%"=="3" goto meditacao
if "%opcao%"=="4" goto exercicio
if "%opcao%"=="5" goto personalizado
goto invalido

:gratidao
echo.
echo Criando habito de Gratidao...
dart run scripts\criar_habito_gratidao.dart
goto fim

:agua
echo.
echo Criando habito de Beber Agua...
dart run scripts\criar_habito_agua.dart
goto fim

:meditacao
echo.
echo Criando habito de Meditacao...
dart run scripts\criar_habito_meditacao.dart
goto fim

:exercicio
echo.
echo Criando habito de Exercicio...
dart run scripts\criar_habito_exercicio.dart
goto fim

:personalizado
echo.
echo Executando script personalizado...
node scripts\criar_habito_automatizado.js
goto fim

:invalido
echo.
echo [ERRO] Opcao invalida!
goto fim

:fim
echo.
echo ========================================
echo Processo concluido!
echo Abra o app HabitAI para ver seu novo habito.
echo ========================================
pause
