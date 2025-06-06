#!/bin/bash

echo "=== Teste de Correção de Overflow Android ==="
echo ""
echo "Este script ajuda a testar a correção de overflow no Android"
echo ""

# Verificar se o Flutter está instalado
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter não encontrado. Por favor, instale o Flutter."
    exit 1
fi

# Verificar se há dispositivos conectados
echo "📱 Verificando dispositivos conectados..."
flutter devices

echo ""
echo "🔧 Compilando o aplicativo..."
flutter clean
flutter pub get
flutter build apk --debug

echo ""
echo "📋 Instruções de Teste:"
echo ""
echo "1. Instale o APK no dispositivo:"
echo "   flutter install"
echo ""
echo "2. Verifique os seguintes pontos:"
echo "   ✓ A tela principal não apresenta overflow"
echo "   ✓ O conteúdo não fica cortado na parte superior (status bar)"
echo "   ✓ O conteúdo não fica cortado na parte inferior (navigation bar)"
echo "   ✓ Em dispositivos com notch, o conteúdo não fica sobreposto"
echo ""
echo "3. Teste em diferentes orientações:"
echo "   ✓ Portrait"
echo "   ✓ Landscape"
echo ""
echo "4. Teste com diferentes configurações de navegação:"
echo "   ✓ Navegação por gestos"
echo "   ✓ Navegação por botões"
echo ""
echo "5. Para debug detalhado, verifique o logcat:"
echo "   adb logcat | grep 'System Insets'"
echo ""
echo "6. Capture screenshots se encontrar problemas:"
echo "   adb shell screencap /sdcard/overflow_test.png"
echo "   adb pull /sdcard/overflow_test.png"
echo ""

# Oferecer instalação automática
read -p "Deseja instalar o APK agora? (s/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    flutter install
    echo ""
    echo "✅ APK instalado! Por favor, execute os testes manuais listados acima."
fi

echo ""
echo "📊 Para ver os logs de insets do sistema em tempo real:"
echo "flutter logs | grep -E '(System Insets|viewInsets|viewPadding|systemPadding)'"
