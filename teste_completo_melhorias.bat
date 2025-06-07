@echo off
color 0A
echo.
echo =========================================
echo    TESTE COMPLETO - MELHORIAS UI/UX
echo =========================================
echo.

echo [PASSO 1] Verificando Flutter...
call flutter doctor --version
echo.

echo [PASSO 2] Limpando projeto...
call flutter clean
echo.

echo [PASSO 3] Obtendo dependencias...
call flutter pub get
echo.

echo [PASSO 4] Analisando codigo...
call flutter analyze
echo.

echo [PASSO 5] Executando testes...
call flutter test
echo.

echo [PASSO 6] Compilando em modo debug...
call flutter build apk --debug
echo.

echo [PASSO 7] Instalando no dispositivo...
adb devices
adb install -r build\app\outputs\flutter-apk\app-debug.apk
echo.

echo =========================================
echo           TESTES MANUAIS
echo =========================================
echo.
echo Por favor, teste as seguintes funcionalidades:
echo.
echo ✓ TELA DE HABITOS:
echo   - Cards com cores vibrantes por categoria
echo   - Checkbox circular ao inves de quadrado
echo   - Toque no habito abre modal de acoes rapidas
echo   - Modal com opcoes: Sucesso, Falhou, Pular
echo   - Tags coloridas de categoria visiveis
echo   - Icones personalizados por categoria
echo.
echo ✓ MODAL DE ACOES RAPIDAS:
echo   - Opcoes de status bem visiveis
echo   - Botoes: Adicionar lembrete, Adicionar nota
echo   - Opcao: Pular, Redefinir valor
echo   - Visual consistente com tema escuro
echo.
echo ✓ VISUAL GERAL:
echo   - Cores vibrantes (vermelho, laranja, rosa, verde)
echo   - Sombras suaves nos cards
echo   - Bordas arredondadas (16px)
echo   - Animacoes suaves ao tocar
echo   - Feedback haptico funcionando
echo.
echo ✓ FUNCIONALIDADES:
echo   - Marcar habito como concluido funciona
echo   - Navegacao para detalhes funciona
echo   - Streak (sequencia) aparece corretamente
echo   - Frequencia do habito exibida
echo.
echo =========================================
echo.
echo APK compilado em: build\app\outputs\flutter-apk\app-debug.apk
echo.
echo Pressione qualquer tecla apos testar no dispositivo...
pause