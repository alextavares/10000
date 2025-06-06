import 'dart:io';

/// Script para substituir withOpacity() deprecated por withValues()
void main() async {
  print('🔄 Iniciando substituição de withOpacity() por withValues()...\n');
  
  final projectDir = Directory('lib');
  int totalReplaced = 0;
  int filesModified = 0;
  
  await for (final entity in projectDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final relativePath = entity.path.replaceAll(r'\', '/');
      
      final content = await entity.readAsString();
      final lines = content.split('\n');
      bool fileModified = false;
      
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        
        // Procurar por withOpacity
        if (line.contains('.withOpacity(')) {
          final originalLine = line;
          
          // Usar regex para encontrar e substituir withOpacity(value) por withValues(alpha: value)
          var modifiedLine = line.replaceAllMapped(
            RegExp(r'\.withOpacity\(([^)]+)\)'),
            (match) => '.withValues(alpha: ${match.group(1)})',
          );
          
          if (originalLine != modifiedLine) {
            lines[i] = modifiedLine;
            fileModified = true;
            totalReplaced++;
          }
        }
      }
      
      if (fileModified) {
        await entity.writeAsString(lines.join('\n'));
        filesModified++;
        print('✅ Modificado: $relativePath');
      }
    }
  }
  
  print('\n📊 Resumo da substituição:');
  print('   - Total de withOpacity() substituídos: $totalReplaced');
  print('   - Arquivos modificados: $filesModified');
  print('\n✅ Substituição concluída!');
}
