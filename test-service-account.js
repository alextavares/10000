// Script para testar a autenticação da conta de serviço
require('dotenv').config();
const { GoogleAuth } = require('google-auth-library');

async function testAuth() {
  try {
    console.log('Arquivo de credenciais:', process.env.GOOGLE_APPLICATION_CREDENTIALS);
    
    if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
      console.error('ERRO: A variável de ambiente GOOGLE_APPLICATION_CREDENTIALS não está definida!');
      console.error('Defina-a no arquivo .env ou no terminal antes de executar este script.');
      console.error('Exemplo: GOOGLE_APPLICATION_CREDENTIALS=./service-account-key.json');
      return;
    }
    
    console.log('Tentando autenticar com a conta de serviço...');
    
    const auth = new GoogleAuth({
      scopes: 'https://www.googleapis.com/auth/cloud-platform'
    });
    
    const client = await auth.getClient();
    const projectId = await auth.getProjectId();
    
    console.log('✅ Autenticação bem-sucedida!');
    console.log('ID do projeto:', projectId);
    
    // Testar acesso à API do Gemini
    console.log('\nTestando acesso à API do Gemini...');
    const url = 'https://generativelanguage.googleapis.com/v1beta/models';
    
    try {
      const response = await client.request({ url });
      
      console.log('✅ Acesso à API do Gemini bem-sucedido!');
      console.log('Modelos disponíveis:', response.data.models ? response.data.models.length : 0);
      
      if (response.data.models && response.data.models.length > 0) {
        console.log('Primeiros modelos disponíveis:');
        response.data.models.slice(0, 3).forEach(model => {
          console.log(`- ${model.name}`);
        });
      }
      
      console.log('\nTudo está configurado corretamente! Você pode iniciar o servidor Genkit.');
    } catch (apiError) {
      console.error('❌ Erro ao acessar a API do Gemini:', apiError.message);
      
      if (apiError.message.includes('API has not been used') || apiError.message.includes('API not enabled')) {
        console.error('\n⚠️ A API do Gemini não está habilitada para este projeto!');
        console.error('Siga estas etapas:');
        console.error('1. Acesse o Console do Google Cloud: https://console.cloud.google.com/');
        console.error('2. Vá para "APIs e Serviços" > "Biblioteca"');
        console.error('3. Pesquise por "Generative Language API"');
        console.error('4. Clique na API e depois em "Habilitar"');
      } else if (apiError.message.includes('permission denied') || apiError.message.includes('Permission denied')) {
        console.error('\n⚠️ A conta de serviço não tem permissão para acessar a API do Gemini!');
        console.error('Siga estas etapas:');
        console.error('1. Acesse o Console do Google Cloud: https://console.cloud.google.com/');
        console.error('2. Vá para "IAM e Administrador" > "IAM"');
        console.error('3. Encontre a conta de serviço e adicione os papéis:');
        console.error('   - "AI Platform User" ou "Vertex AI User"');
        console.error('   - "Cloud AI Generative Language API User"');
      }
    }
  } catch (error) {
    console.error('❌ Erro na autenticação:', error.message);
    
    if (error.message.includes('no such file')) {
      console.error('\n⚠️ O arquivo de credenciais não foi encontrado!');
      console.error('Verifique se o caminho está correto e se o arquivo existe.');
    } else if (error.message.includes('invalid_grant') || error.message.includes('Invalid JWT')) {
      console.error('\n⚠️ As credenciais são inválidas!');
      console.error('Verifique se o arquivo JSON não está corrompido.');
      console.error('Tente gerar uma nova chave para a conta de serviço.');
    }
  }
}

// Executar o teste
testAuth();
