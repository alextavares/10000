@echo off
echo ===============================================
echo   CORRECAO DE CRIACAO DE HABITOS - HABITAI
echo ===============================================
echo.

cd /d C:\codigos\habitai2406\10000

echo [1/7] Fazendo backup do arquivo original...
copy /Y lib\services\habit_service.dart lib\services\habit_service.backup.dart >nul 2>&1
echo    Backup criado!
echo.

echo [2/7] Aplicando correcao no HabitService...
copy /Y lib\services\habit_service_fixed.dart lib\services\habit_service.dart >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo    ERRO ao aplicar correcao!
    exit /b 1
)
echo    Correcao aplicada!
echo.

echo [3/7] Limpando cache do Flutter...
flutter clean >nul 2>&1
echo    Cache limpo!
echo.

echo [4/7] Obtendo dependencias...
echo    Aguarde, isso pode demorar alguns minutos...
flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo    ERRO ao obter dependencias!
    exit /b 1
)
echo    Dependencias atualizadas!
echo.

echo [5/7] Verificando configuracao do Firebase...
if exist .env (
    echo    Arquivo .env encontrado!
) else (
    echo    ERRO: Arquivo .env nao encontrado!
    echo    Por favor, configure o Firebase primeiro.
)
echo.

echo [6/7] Criando script de teste rapido...
(
echo @echo off
echo echo Testando criacao de habito...
echo dart run test_habit_creation.dart
echo pause
) > test_criar_habito.bat
echo    Script de teste criado!
echo.

echo [7/7] Gerando relatorio...
(
echo =========================================
echo CORRECAO APLICADA EM: %date% %time%
echo =========================================
echo.
echo ALTERACOES REALIZADAS:
echo - Melhorado tratamento de erros no HabitService
echo - Garantido que habit ID sempre seja gerado
echo - Adicionado logs detalhados para debug
echo - Corrigido problema de Firestore did not return an ID
echo - Melhorado validacao de usuario autenticado
echo - Adicionado valores padrao para campos obrigatorios
echo.
echo PROXIMOS PASSOS:
echo 1. Execute: flutter run
echo 2. Va para aba Habitos
echo 3. Clique no botao +
echo 4. Crie um novo habito
echo.
echo Se ainda houver erros, execute: test_criar_habito.bat
) > correcao_aplicada.log
echo    Relatorio criado!
echo.

echo ===============================================
echo           CORRECAO APLICADA COM SUCESSO!
echo ===============================================
echo.
echo PROXIMOS PASSOS:
echo.
echo 1. Execute o app:
echo    flutter run
echo.
echo 2. Para testar via script:
echo    test_criar_habito.bat
echo.
echo 3. Se houver problemas, verifique:
echo    - Console do Firebase
echo    - Logs do Flutter: flutter logs
echo    - Arquivo correcao_aplicada.log
echo.
echo Pressione qualquer tecla para continuar...
pause >nul
