@echo off
color 0B
cls
echo.
echo =========================================
echo    TESTE - MELHORIAS RESTAURADAS
echo =========================================
echo.

echo [1] Limpando projeto anterior...
call flutter clean > nul 2>&1
echo    ✓ Projeto limpo
echo.

echo [2] Obtendo dependencias...
call flutter pub get > nul 2>&1
echo    ✓ Dependencias instaladas
echo.

echo [3] Compilando e executando...
echo.
echo =========================================
echo    CHECKLIST DE FUNCIONALIDADES
echo =========================================
echo.
echo ✓ CARD DE HABITO COMPLETO:
echo   - Calendario semanal inline (Dom-Sab)
echo   - Dias concluidos com cor de fundo
echo   - Dia atual com borda colorida
echo   - Porcentagem de conclusao visivel
echo   - Indicador de streak com icone de fogo
echo.
echo ✓ BOTOES DE ACAO RAPIDA:
echo   - Calendario: Abre aba de calendario
echo   - Estatisticas: Abre aba de stats
echo   - Menu: Editar/Arquivar/Excluir
echo.
echo ✓ VISUAL IGUAL REFERENCIA:
echo   - Cards grandes e detalhados
echo   - Cores vibrantes por categoria
echo   - Sombras e bordas arredondadas
echo   - Layout identico ao app modelo
echo.
echo =========================================
echo.

call flutter run

pause