@echo off
echo ================================
echo  Teste Rapido de Criacao de Habitos
echo ================================
echo.

echo Verificando se o Flutter esta funcionando...
flutter --version

echo.
echo Executando teste basico...
echo import 'package:flutter/material.dart'; > teste_basico.dart
echo void main() { >> teste_basico.dart
echo   print('Sistema funcionando!'); >> teste_basico.dart
echo   print('Habito de teste: Beber 8 copos de agua'); >> teste_basico.dart
echo } >> teste_basico.dart

dart run teste_basico.dart
del teste_basico.dart

echo.
echo ================================
echo  Instrucoes para Criar Habito
echo ================================
echo.
echo 1. Execute o app com: flutter run -d windows
echo 2. Faca login ou crie uma conta
echo 3. Va para a aba "Habitos"
echo 4. Clique no botao "+"
echo 5. Preencha os campos:
echo    - Nome: Beber 8 copos de agua
echo    - Categoria: Saude
echo    - Tipo: Quantidade
echo    - Meta: 8 copos
echo 6. Clique em Salvar
echo.
echo Se houver erro, execute: dart run diagnostico_habitos.dart
echo.
pause
