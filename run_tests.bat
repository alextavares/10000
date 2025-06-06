@echo off
echo ========================================
echo Executando Testes do HabitAI
echo ========================================
echo.

echo [1/4] Gerando mocks necessários...
call flutter pub run build_runner build --delete-conflicting-outputs
echo.

echo [2/4] Executando testes unitários...
call flutter test test/services/
echo.

echo [3/4] Executando testes de widget...
call flutter test test/screens/
echo.

echo [4/4] Gerando relatório de cobertura...
call flutter test --coverage
call genhtml coverage/lcov.info -o coverage/html
echo.

echo ========================================
echo Testes concluídos!
echo Relatório de cobertura disponível em: coverage/html/index.html
echo ========================================
pause
