@echo off
echo ====================================
echo   TESTADOR AUTOMATICO - HabitAI
echo   Sessao 1: Autenticacao
echo ====================================
echo.
echo Abrindo a aplicacao no navegador...
start msedge http://localhost:5003
echo.
echo Aguarde 5 segundos para a aplicacao carregar...
timeout /t 5 /nobreak > nul
echo.
echo ====================================
echo   CHECKLIST DE TESTES MANUAIS:
echo ====================================
echo.
echo [ ] 1. A pagina carregou completamente?
echo [ ] 2. O texto "Carregando HabitAI..." desapareceu?
echo [ ] 3. Voce ve a tela de login?
echo [ ] 4. Existem campos de Email e Senha?
echo [ ] 5. Ha um botao de Entrar/Login?
echo [ ] 6. Existe opcao de "Criar conta"?
echo [ ] 7. Tem botao de login com Google?
echo [ ] 8. Ha link "Esqueceu a senha?"
echo.
echo ====================================
echo.
echo Pressione qualquer tecla quando terminar de verificar...
pause > nul
echo.
echo Salvando resultados...
echo Teste executado em: %date% %time% >> test_results\log_execucao.txt
echo.
echo Teste concluido! Verifique os resultados em:
echo test_results\sessao1_autenticacao.md
echo.
pause
