#!/bin/bash

echo "========================================"
echo "Executando Testes do HabitAI"
echo "========================================"
echo

echo "[1/4] Gerando mocks necessários..."
flutter pub run build_runner build --delete-conflicting-outputs
echo

echo "[2/4] Executando testes unitários..."
flutter test test/services/
echo

echo "[3/4] Executando testes de widget..."
flutter test test/screens/
echo

echo "[4/4] Gerando relatório de cobertura..."
flutter test --coverage

# Verificar se genhtml está instalado
if command -v genhtml &> /dev/null; then
    genhtml coverage/lcov.info -o coverage/html
    echo
    echo "========================================"
    echo "Testes concluídos!"
    echo "Relatório de cobertura disponível em: coverage/html/index.html"
    echo "========================================"
else
    echo
    echo "========================================"
    echo "Testes concluídos!"
    echo "Para gerar relatório HTML, instale lcov:"
    echo "  Ubuntu/Debian: sudo apt-get install lcov"
    echo "  macOS: brew install lcov"
    echo "========================================"
fi
