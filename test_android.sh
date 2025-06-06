#!/bin/bash

echo "🚀 Preparando HabitAI para teste Android..."
echo ""

# Limpar builds anteriores
echo "🧹 Limpando builds anteriores..."
flutter clean

# Obter dependências
echo "📦 Obtendo dependências..."
flutter pub get

# Verificar dispositivos conectados
echo "📱 Dispositivos disponíveis:"
flutter devices

echo ""
echo "🔨 Escolha o tipo de build:"
echo "1) Debug (desenvolvimento)"
echo "2) Release (produção)"
read -p "Opção (1 ou 2): " build_type

if [ "$build_type" == "2" ]; then
    echo "🏗️ Construindo APK Release..."
    flutter build apk --release
    echo ""
    echo "✅ APK Release gerado em:"
    echo "   build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    read -p "Deseja instalar no dispositivo? (s/n): " install
    if [ "$install" == "s" ]; then
        flutter install --release
    fi
else
    echo "🐛 Executando em modo Debug..."
    flutter run
fi
