@echo off
echo ================================================
echo   INSTRUCOES PARA CORRIGIR O ERRO DO FIREBASE
echo ================================================
echo.
echo ERRO IDENTIFICADO: 
echo - Failed to load resource: status 400
echo - Problema ao criar conta no Firebase
echo.
echo ================================================
echo   PASSO 1: FAZER HOT RELOAD
echo ================================================
echo.
echo 1. Va para o terminal do Flutter
echo 2. Pressione "R" (maiuscula)
echo 3. Aguarde a mensagem "Reloaded"
echo.
echo ================================================
echo   PASSO 2: CONFIGURAR FIREBASE CONSOLE
echo ================================================
echo.
echo 1. Acesse: https://console.firebase.google.com
echo 2. Selecione o projeto: android-habitai
echo.
echo 3. VERIFICAR AUTHENTICATION:
echo    - Menu lateral > Authentication
echo    - Aba "Sign-in method"
echo    - Email/Password deve estar HABILITADO
echo.
echo 4. VERIFICAR FIRESTORE:
echo    - Menu lateral > Firestore Database
echo    - Se nao existir, crie um novo
echo    - Escolha "Start in production mode"
echo.
echo 5. ATUALIZAR REGRAS DO FIRESTORE:
echo    - Em Firestore > Rules
echo    - Cole as regras do arquivo:
echo      test_results\CORRIGIR_FIREBASE_ERRO.md
echo    - Clique em "Publish"
echo.
echo 6. ADICIONAR DOMINIOS AUTORIZADOS:
echo    - Authentication > Settings > Authorized domains
echo    - Adicione: localhost e localhost:5004
echo.
echo ================================================
echo   PASSO 3: TESTAR NOVAMENTE
echo ================================================
echo.
echo 1. Recarregue a pagina (F5)
echo 2. Tente criar uma conta novamente
echo 3. Use um email valido (ex: teste@exemplo.com)
echo 4. Senha com pelo menos 6 caracteres
echo.
echo ================================================
echo.
echo Se continuar com erro, verifique:
echo - Console do Firebase para mais detalhes
echo - Logs do Flutter no terminal
echo.
pause
