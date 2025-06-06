import 'dart:io';
import 'package:yaml/yaml.dart';

void main() async {
  print('🔍 Verificação Pré-Deploy Android - HabitAI\n');
  
  int issues = 0;
  int warnings = 0;
  
  // 1. Verificar pubspec.yaml
  print('📄 Verificando pubspec.yaml...');
  try {
    final pubspecFile = File('pubspec.yaml');
    final pubspecContent = await pubspecFile.readAsString();
    final pubspec = loadYaml(pubspecContent);
    
    final version = pubspec['version'];
    if (version == null) {
      print('   ❌ Versão não definida');
      issues++;
    } else {
      print('   ✅ Versão: $version');
    }
    
    final name = pubspec['name'];
    if (name == 'myapp') {
      print('   ⚠️  Nome do projeto ainda é "myapp"');
      warnings++;
    }
  } catch (e) {
    print('   ❌ Erro ao ler pubspec.yaml: $e');
    issues++;
  }
  
  // 2. Verificar Application ID
  print('\n📦 Verificando Application ID...');
  try {
    final buildGradle = File('android/app/build.gradle.kts');
    final content = await buildGradle.readAsString();
    
    if (content.contains('com.example.myapp')) {
      print('   ❌ Application ID ainda é com.example.myapp');
      issues++;
    } else if (content.contains('com.habitai.app')) {
      print('   ✅ Application ID: com.habitai.app');
    }
  } catch (e) {
    print('   ❌ Erro ao verificar build.gradle.kts: $e');
    issues++;
  }
  
  // 3. Verificar AndroidManifest
  print('\n📱 Verificando AndroidManifest.xml...');
  try {
    final manifest = File('android/app/src/main/AndroidManifest.xml');
    final content = await manifest.readAsString();
    
    if (content.contains('android:label="HabitAI"')) {
      print('   ✅ Nome do app: HabitAI');
    } else {
      print('   ⚠️  Nome do app pode estar incorreto');
      warnings++;
    }
    
    if (content.contains('android:usesCleartextTraffic="true"')) {
      print('   ⚠️  Cleartext traffic está habilitado (considere desabilitar para produção)');
      warnings++;
    }
  } catch (e) {
    print('   ❌ Erro ao verificar AndroidManifest.xml: $e');
    issues++;
  }
  
  // 4. Verificar google-services.json
  print('\n🔥 Verificando Firebase...');
  final googleServices = File('android/app/google-services.json');
  if (await googleServices.exists()) {
    print('   ✅ google-services.json encontrado');
  } else {
    print('   ❌ google-services.json não encontrado');
    issues++;
  }
  
  // 5. Verificar ícones
  print('\n🎨 Verificando ícones...');
  final iconPath = File('android/app/src/main/res/mipmap-hdpi/ic_launcher.png');
  if (await iconPath.exists()) {
    print('   ✅ Ícone launcher encontrado');
  } else {
    print('   ⚠️  Ícone launcher pode estar faltando');
    warnings++;
  }
  
  // 6. Verificar .env
  print('\n🔐 Verificando variáveis de ambiente...');
  final envFile = File('.env');
  if (await envFile.exists()) {
    print('   ✅ Arquivo .env encontrado');
    final envContent = await envFile.readAsString();
    if (envContent.contains('your_') || envContent.contains('_HERE')) {
      print('   ⚠️  Algumas API keys podem não estar configuradas');
      warnings++;
    }
  } else {
    print('   ❌ Arquivo .env não encontrado');
    issues++;
  }
  
  // 7. Verificar keystore (se existir)
  print('\n🔑 Verificando assinatura...');
  final keyProperties = File('android/key.properties');
  if (await keyProperties.exists()) {
    print('   ✅ key.properties encontrado');
  } else {
    print('   ⚠️  key.properties não encontrado (necessário para release)');
    warnings++;
  }
  
  // Resumo
  print('\n${'=' * 50}');
  print('📊 RESUMO DA VERIFICAÇÃO\n');
  
  if (issues == 0 && warnings == 0) {
    print('✅ Tudo está perfeito! Pronto para deploy! 🚀');
  } else {
    if (issues > 0) {
      print('❌ Problemas críticos encontrados: $issues');
      print('   Corrija estes problemas antes do deploy.');
    }
    if (warnings > 0) {
      print('⚠️  Avisos encontrados: $warnings');
      print('   Considere resolver antes do deploy.');
    }
  }
  
  print('\n💡 Próximos passos:');
  if (issues > 0 || warnings > 0) {
    print('   1. Corrija os problemas identificados');
    print('   2. Execute este script novamente');
  } else {
    print('   1. Execute: flutter emulators --launch Medium_Phone');
    print('   2. Execute: flutter run');
    print('   3. Teste todas as funcionalidades');
    print('   4. Execute: flutter build appbundle --release');
  }
}
