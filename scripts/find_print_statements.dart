import 'dart:io';

void main() async {
  print('🔍 Procurando por print() statements no projeto...\n');
  
  final projectDir = Directory('lib');
  final printStatements = <String, List<PrintLocation>>{};
  
  await for (final entity in projectDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final relativePath = entity.path.replaceAll(r'\', '/');
      final lines = await entity.readAsLines();
      
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        final lineNumber = i + 1;
        
        // Procurar por print statements
        if (line.contains('print(') && !line.trim().startsWith('//')) {
          printStatements.putIfAbsent(relativePath, () => []);
          printStatements[relativePath]!.add(
            PrintLocation(lineNumber, line.trim()),
          );
        }
      }
    }
  }
  
  // Exibir resultados
  if (printStatements.isEmpty) {
    print('✅ Nenhum print() statement encontrado!');
  } else {
    int totalCount = 0;
    
    print('❌ Print statements encontrados:\n');
    
    printStatements.forEach((file, locations) {
      print('📄 $file:');
      for (final location in locations) {
        print('   Linha ${location.line}: ${location.content}');
        totalCount++;
      }
      print('');
    });
    
    print('📊 Total: $totalCount print() statements em ${printStatements.length} arquivos');
    print('\n💡 Sugestão: Substitua por Logger.debug(), Logger.info(), Logger.warning() ou Logger.error()');
    print('   Exemplo: print("mensagem") → Logger.debug("mensagem")');
  }
}

class PrintLocation {
  final int line;
  final String content;
  
  PrintLocation(this.line, this.content);
}
