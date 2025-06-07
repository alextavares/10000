#!/bin/bash
# Script para obter SHA-1 do aplicativo Android

echo "======================================"
echo "Obtendo SHA-1 do aplicativo HabitAI"
echo "======================================"
echo ""

cd android

echo "[1/2] Executando signingReport..."
echo ""

./gradlew signingReport

echo ""
echo "======================================"
echo "IMPORTANTE:"
echo "1. Procure pela seção 'debug' acima"
echo "2. Copie o valor SHA1"
echo "3. Adicione no Firebase Console:"
echo "   - Vá para Project Settings"
echo "   - Android apps"
echo "   - Add fingerprint"
echo "   - Cole o SHA1"
echo "4. Baixe o novo google-services.json"
echo "======================================"