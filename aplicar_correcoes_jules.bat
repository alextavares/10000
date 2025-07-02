@echo off
echo === Aplicando correcoes do time local ===

REM 1. Salvar estado atual
echo Salvando estado atual...
git stash

REM 2. Aplicar o patch
echo Aplicando patch...
git apply correcoes_locais_para_jules.patch

if %errorlevel% == 0 (
    echo Patch aplicado com sucesso!
) else (
    echo Erro ao aplicar patch. Verifique os conflitos manualmente.
    echo.
    echo ATENCAO: Voce precisa:
    echo 1. Editar pubspec.yaml - mudar intl: ^0.18.1 para intl: ^0.20.2
    echo 2. Resolver conflitos em:
    echo    - lib/services/category_service.dart
    echo    - lib/services/achievement_service.dart
    echo    - lib/widgets/habit_card.dart
    echo    - lib/widgets/task_card.dart
)

REM 3. Limpar e reinstalar dependencias
echo.
echo Limpando cache e reinstalando dependencias...
call flutter clean
call flutter pub get

echo.
echo === Processo concluido ===
echo Proximo passo: flutter run -d web-server --web-port=5004
pause