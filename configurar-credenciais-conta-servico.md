# Configurando as Credenciais da Conta de Serviço

Agora que você criou uma chave para a conta de serviço do Google Cloud, vamos configurar o ambiente para usar essas credenciais com o Genkit.

## Passo 1: Mover o Arquivo JSON para o Projeto

1. Localize o arquivo JSON da chave da conta de serviço que foi baixado para o seu computador.
2. Mova-o para a raiz do seu projeto ou para uma pasta segura dentro do projeto.
3. Recomendamos renomeá-lo para algo simples como `service-account-key.json`.

## Passo 2: Configurar a Variável de Ambiente

### Opção A: Usando o arquivo .env

Edite o arquivo `.env` na raiz do projeto para apontar para o arquivo JSON:

```
GOOGLE_APPLICATION_CREDENTIALS=./service-account-key.json
```

Substitua `./service-account-key.json` pelo caminho correto para o seu arquivo.

### Opção B: Configurar diretamente no terminal

Você também pode configurar a variável de ambiente diretamente no terminal antes de iniciar o servidor:

```bash
export GOOGLE_APPLICATION_CREDENTIALS=./service-account-key.json
node genkit-server.js
```

## Passo 3: Verificar a Configuração

Para verificar se a configuração está correta, você pode criar um script de teste:

```javascript
// test-service-account.js
require('dotenv').config();
const { GoogleAuth } = require('google-auth-library');

async function testAuth() {
  try {
    console.log('Arquivo de credenciais:', process.env.GOOGLE_APPLICATION_CREDENTIALS);
    
    const auth = new GoogleAuth({
      scopes: 'https://www.googleapis.com/auth/cloud-platform'
    });
    
    const client = await auth.getClient();
    const projectId = await auth.getProjectId();
    
    console.log('Autenticação bem-sucedida!');
    console.log('ID do projeto:', projectId);
    
    // Testar acesso à API do Gemini
    const url = 'https://generativelanguage.googleapis.com/v1beta/models';
    const response = await client.request({ url });
    
    console.log('Acesso à API do Gemini bem-sucedido!');
    console.log('Modelos disponíveis:', response.data.models ? response.data.models.length : 0);
  } catch (error) {
    console.error('Erro na autenticação:', error);
    
    if (error.message && error.message.includes('API has not been used')) {
      console.error('\nA API do Gemini não está habilitada para este projeto!');
      console.error('Vá para o Console do Google Cloud e habilite a "Generative Language API".');
    }
  }
}

testAuth();
```

Execute este script com:

```bash
npm install google-auth-library
node test-service-account.js
```

## Passo 4: Iniciar o Servidor Genkit

Se tudo estiver configurado corretamente, você pode iniciar o servidor Genkit:

```bash
node genkit-server.js
```

## Solução de Problemas

### Erro: "API has not been used in project"

Se você receber um erro indicando que a API não foi usada no projeto, significa que a API do Gemini não está habilitada. Siga estas etapas:

1. Acesse o [Console do Google Cloud](https://console.cloud.google.com/)
2. Vá para "APIs e Serviços" > "Biblioteca"
3. Pesquise por "Generative Language API"
4. Clique na API e depois em "Habilitar"

### Erro: "Permission denied"

Se você receber um erro de permissão negada, verifique se a conta de serviço tem os papéis corretos:

1. Acesse o [Console do Google Cloud](https://console.cloud.google.com/)
2. Vá para "IAM e Administrador" > "IAM"
3. Encontre a conta de serviço e adicione os papéis:
   - "AI Platform User" ou "Vertex AI User"
   - "Cloud AI Generative Language API User"

### Erro: "Invalid credentials"

Se as credenciais forem inválidas, verifique:

1. Se o caminho para o arquivo JSON está correto
2. Se o arquivo JSON não está corrompido
3. Se a conta de serviço não foi excluída ou desativada

## Próximos Passos

Depois de configurar as credenciais da conta de serviço, você pode:

1. Testar a API com `curl`:
   ```bash
   curl -X POST -H "Content-Type: application/json" -d '{"name":"Alexandre"}' http://localhost:3000/api/hello
   ```

2. Testar a integração com o aplicativo Flutter usando a tela de teste que criamos.
