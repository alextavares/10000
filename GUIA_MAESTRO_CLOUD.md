# 🌩️ Guia Maestro Cloud - HabitAI

## 📋 O que é o Maestro Cloud?

O Maestro Cloud permite executar seus testes em uma infraestrutura de nuvem empresarial hospedada, oferecendo:

- ✅ Testes em dispositivos reais na nuvem
- ✅ Paralelização garantida
- ✅ Integração com CI/CD
- ✅ Relatórios detalhados
- ✅ Suporte para iOS e Android
- ✅ SOC 2 compliant (segurança e privacidade)

## 🚀 Como começar

### 1. Criar conta no Maestro Cloud
Acesse: https://cloud.maestro.dev

### 2. Instalar CLI do Maestro (já instalado!)
```bash
maestro --version
```

### 3. Fazer login
```bash
maestro cloud login
```

### 4. Fazer upload dos testes
```bash
cd C:\codigos\HabitAiclaudedesktop\HabitAI
maestro cloud upload .maestro
```

### 5. Executar testes na nuvem
```bash
maestro cloud test .maestro
```

## 📱 Dispositivos disponíveis

O Maestro Cloud oferece uma variedade de dispositivos:
- iPhone 15, 14, 13, 12, SE
- Samsung Galaxy S23, S22, S21
- Google Pixel 8, 7, 6
- E muitos outros...

## 💰 Planos

- **Free Trial**: 30 dias grátis
- **Team**: A partir de $99/mês
- **Enterprise**: Personalizado

## 🔧 Comandos úteis

### Verificar status
```bash
maestro cloud status
```

### Listar dispositivos disponíveis
```bash
maestro cloud devices
```

### Executar em dispositivo específico
```bash
maestro cloud test .maestro --device "iPhone 15"
```

### Ver resultados
```bash
maestro cloud results
```

## 🔗 Links úteis

- Documentação: https://docs.maestro.dev/cloud
- Dashboard: https://cloud.maestro.dev
- Suporte: https://maestro.dev/support

## 📊 Integração com CI/CD

### GitHub Actions
```yaml
- name: Run Maestro Tests
  uses: mobile-dev-inc/maestro-actions@v1
  with:
    api-key: ${{ secrets.MAESTRO_CLOUD_API_KEY }}
    flow-path: .maestro/
```

### Outros CI/CD
```bash
# Jenkins, CircleCI, etc
maestro cloud test .maestro --api-key $MAESTRO_API_KEY
```

## 💡 Dicas

1. Use `--include-tags` para executar testes específicos
2. Use `--exclude-tags` para pular testes
3. Configure timeouts adequados para testes longos
4. Monitore o dashboard para ver o progresso em tempo real

## 🎯 Script de automação

Execute `maestro_cloud_setup.bat` para acessar todas as funcionalidades do Maestro Cloud facilmente!
