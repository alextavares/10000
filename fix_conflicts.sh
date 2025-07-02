#!/bin/bash

echo "Aplicando correções do Jules..."

# Para cada arquivo com conflito, pegar apenas a parte após =======
for file in lib/services/category_service.dart lib/widgets/habit_card.dart lib/widgets/task_card.dart; do
    echo "Processando $file..."
    
    # Criar backup
    cp "$file" "$file.backup_conflict"
    
    # Extrair apenas a parte após ======= até o final (removendo >>>>>>> REPLACE)
    sed -n '/^=======/,/^>>>>>>> REPLACE/{/^=======/d;/^>>>>>>> REPLACE/d;p}' "$file" > "$file.tmp"
    
    # Se o arquivo temporário não estiver vazio, usar ele
    if [ -s "$file.tmp" ]; then
        mv "$file.tmp" "$file"
        echo "✓ $file corrigido"
    else
        echo "✗ Erro ao processar $file"
        rm "$file.tmp"
    fi
done

echo "Concluído!"