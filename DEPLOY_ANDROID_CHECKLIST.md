# 🚀 Guia de Deploy Android - HabitAI

## 📋 Checklist Completo para Deploy

### ✅ 1. Configurações Básicas

#### 1.1 Application ID (Package Name)
- [ ] Mudar de `com.example.myapp` para algo único
- [ ] Sugestão: `com.habitai.app` ou `com.seudominio.habitai`
- [ ] Arquivo: `android/app/build.gradle.kts`

#### 1.2 Nome do App
- [ ] Verificar em `android/app/src/main/AndroidManifest.xml`
- [ ] Atualizar `android:label="HabitAI"`

#### 1.3 Versão do App
- [ ] Atualizar em `pubspec.yaml`
- [ ] version: 1.0.0+1 (version+buildNumber)

### ✅ 2. Assets e Recursos

#### 2.1 Ícone do App
- [ ] Criar ícone 512x512px
- [ ] Usar flutter_launcher_icons package
- [ ] Gerar todos os tamanhos necessários

#### 2.2 Splash Screen
- [ ] Configurar tela de splash nativa
- [ ] Usar flutter_native_splash package

### ✅ 3. Permissões e Configurações

#### 3.1 Permissões Android
- [ ] Revisar `AndroidManifest.xml`
- [ ] Remover permissões desnecessárias
- [ ] Adicionar apenas as necessárias:
  - Internet (já deve estar)
  - Notificações locais (se usar)

#### 3.2 ProGuard Rules
- [ ] Configurar para Firebase
- [ ] Configurar para outras libs

### ✅ 4. Assinatura e Build

#### 4.1 Criar Keystore
```bash
keytool -genkey -v -keystore ~/habitai-release.keystore -alias habitai -keyalg RSA -keysize 2048 -validity 10000
```

#### 4.2 Configurar Assinatura
- [ ] Criar `android/key.properties`
- [ ] Configurar em `build.gradle.kts`

### ✅ 5. Testes Essenciais

#### 5.1 Funcionalidades Core
- [ ] Login/Registro funcionando
- [ ] Criar/Editar/Deletar hábitos
- [ ] Marcar hábitos como completos
- [ ] Notificações (se implementado)
- [ ] Sincronização com Firebase

#### 5.2 Testes de UI
- [ ] Testar em diferentes tamanhos de tela
- [ ] Testar orientação portrait/landscape
- [ ] Verificar dark mode (se suportado)
- [ ] Performance em dispositivos antigos

#### 5.3 Testes de Conectividade
- [ ] App funciona offline?
- [ ] Sincroniza quando volta online?
- [ ] Tratamento de erros de rede

### ✅ 6. Otimizações

#### 6.1 Tamanho do APK
- [ ] Habilitar minificação
- [ ] Remover recursos não utilizados
- [ ] Considerar App Bundle (.aab)

#### 6.2 Performance
- [ ] Verificar com Flutter DevTools
- [ ] Otimizar imagens
- [ ] Lazy loading onde possível

### ✅ 7. Preparação para Play Store

#### 7.1 Screenshots
- [ ] Mínimo 2 screenshots
- [ ] Diferentes tamanhos de dispositivo
- [ ] Mostrar principais funcionalidades

#### 7.2 Descrições
- [ ] Descrição curta (80 caracteres)
- [ ] Descrição completa (4000 caracteres)
- [ ] Keywords relevantes

#### 7.3 Políticas
- [ ] Política de Privacidade
- [ ] Termos de Uso
- [ ] Classificação etária

### ✅ 8. Build Final

#### 8.1 Gerar Release Build
```bash
flutter build apk --release
# ou melhor ainda:
flutter build appbundle --release
```

#### 8.2 Testar Release Build
- [ ] Instalar em dispositivo real
- [ ] Verificar todas as funcionalidades
- [ ] Verificar performance

## 🛠️ Comandos Úteis

```bash
# Limpar e reconstruir
flutter clean
flutter pub get

# Build para teste
flutter build apk --debug

# Build para produção
flutter build appbundle --release

# Verificar tamanho do APK
flutter build apk --analyze-size

# Executar em dispositivo específico
flutter devices
flutter run -d <device_id>
```

## 📱 Dispositivos de Teste Recomendados

1. **Mínimo**: Android 6.0 (API 23)
2. **Tamanhos**: 
   - Pequeno: 5"
   - Médio: 6"
   - Grande: Tablet 10"
3. **Performance**:
   - Low-end: 2GB RAM
   - Mid-range: 4GB RAM
   - High-end: 8GB+ RAM

## ⚠️ Avisos Importantes

1. **NUNCA commitar**:
   - keystore files
   - key.properties
   - google-services.json com dados sensíveis

2. **Backup do Keystore**:
   - Faça múltiplos backups
   - Guarde senha em local seguro
   - Sem ele, não pode atualizar o app!

3. **Versioning**:
   - Sempre incrementar versionCode
   - Manter versionName legível
