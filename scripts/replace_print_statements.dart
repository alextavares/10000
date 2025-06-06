import 'dart:io';

/// Script para substituir automaticamente print() statements por Logger calls
void main() async {
  print('🔄 Iniciando substituição automática de print() statements...\n');
  
  final projectDir = Directory('lib');
  int totalReplaced = 0;
  int filesModified = 0;
  
  await for (final entity in projectDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final relativePath = entity.path.replaceAll(r'\', '/');
      
      // Pular arquivos de logger e configuração
      if (relativePath.contains('logger.dart') || 
          relativePath.contains('find_print_statements.dart')) {
        continue;
      }
      
      final content = await entity.readAsString();
      final lines = content.split('\n');
      bool fileModified = false;
      
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        
        // Pular linhas comentadas
        if (line.trim().startsWith('//')) continue;
        
        // Substituir print statements
        if (line.contains('print(')) {
          final originalLine = line;
          var modifiedLine = line;
          
          // Determinar o tipo de log baseado no conteúdo
          if (line.toLowerCase().contains('error') || 
              line.toLowerCase().contains('erro') ||
              line.toLowerCase().contains('exception')) {
            modifiedLine = modifiedLine.replaceAll('print(', 'Logger.error(');
          } else if (line.toLowerCase().contains('warning') || 
                     line.toLowerCase().contains('aviso')) {
            modifiedLine = modifiedLine.replaceAll('print(', 'Logger.warning(');
          } else if (line.toLowerCase().contains('success') || 
                     line.toLowerCase().contains('sucesso') ||
                     line.toLowerCase().contains('created') ||
                     line.toLowerCase().contains('updated') ||
                     line.toLowerCase().contains('completed')) {
            modifiedLine = modifiedLine.replaceAll('print(', 'Logger.info(');
          } else {
            modifiedLine = modifiedLine.replaceAll('print(', 'Logger.debug(');
          }
          
          if (originalLine != modifiedLine) {
            lines[i] = modifiedLine;
            fileModified = true;
            totalReplaced++;
          }
        }
      }
      
      if (fileModified) {
        // Adicionar import do logger se não existir
        var finalContent = lines.join('\n');
        
        if (!finalContent.contains("import 'package:myapp/utils/logger.dart';") &&
            !finalContent.contains('import "package:myapp/utils/logger.dart";')) {
          
          // Encontrar a posição para adicionar o import
          int insertPosition = 0;
          bool foundImports = false;
          
          for (int i = 0; i < lines.length; i++) {
            if (lines[i].startsWith('import ')) {
              foundImports = true;
              insertPosition = i + 1;
            } else if (foundImports && !lines[i].startsWith('import ')) {
              break;
            }
          }
          
          if (insertPosition > 0) {
            lines.insert(insertPosition, "import 'package:myapp/utils/logger.dart';");
          } else {
            // Se não houver imports, adicionar após o início do arquivo
            lines.insert(0, "import 'package:myapp/utils/logger.dart';");
          }
          
          finalContent = lines.join('\n');
        }
        
        await entity.writeAsString(finalContent);
        filesModified++;
        print('✅ Modificado: $relativePath');
      }
    }
  }
  
  print('\n📊 Resumo da substituição:');
  print('   - Total de print() substituídos: $totalReplaced');
  print('   - Arquivos modificados: $filesModified');
  print('\n✅ Substituição concluída!');
  print('\n⚠️  Lembre-se de:');
  print('   1. Executar "flutter analyze" para verificar erros');
  print('   2. Revisar as mudanças com "git diff"');
  print('   3. Testar o aplicativo antes de commitar');
}
