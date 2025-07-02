#!/bin/bash
# Script para Jules aplicar as correções

echo "=== Aplicando correções do time local ==="

# 1. Salvar estado atual
echo "Salvando estado atual..."
git stash

# 2. Aplicar o patch
echo "Aplicando patch..."
git apply correções_locais_para_jules.patch

if [ $? -eq 0 ]; then
    echo "✅ Patch aplicado com sucesso!"
else
    echo "❌ Erro ao aplicar patch. Tentando correções manuais..."
    
    # Correção manual do pubspec.yaml
    echo "Atualizando pubspec.yaml..."
    sed -i 's/intl: \^0.18.1/intl: ^0.20.2/' pubspec.yaml
    
    echo "⚠️  ATENÇÃO: Você precisa resolver manualmente os conflitos em:"
    echo "  - lib/services/category_service.dart"
    echo "  - lib/services/achievement_service.dart"
    echo "  - lib/widgets/habit_card.dart"
    echo "  - lib/widgets/task_card.dart"
fi

# 3. Limpar e reinstalar dependências
echo "Limpando cache e reinstalando dependências..."
flutter clean
flutter pub get

echo "=== Processo concluído ==="
echo "Próximo passo: flutter run -d web-server --web-port=5004"