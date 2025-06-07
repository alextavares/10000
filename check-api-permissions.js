// Script para verificar se a API do Gemini está habilitada para o projeto
require('dotenv').config();
const https = require('https');

// Usar a chave de API do Firebase
const apiKey = process.env.GOOGLE_GENAI_API_KEY;
console.log('Verificando permissões para a chave de API:', apiKey);

// Verificar quais APIs estão habilitadas para esta chave
function checkApiPermissions() {
  console.log('Verificando permissões da API...');
  
  // URL para verificar se a API do Gemini está habilitada
  const url = `https://generativelanguage.googleapis.com/v1beta/models?key=${apiKey}`;
  
  // Fazer uma solicitação para listar os modelos disponíveis
  https.get(url, (res) => {
    console.log('Status da resposta:', res.statusCode);
    console.log('Cabeçalhos da resposta:', res.headers);
    
    let data = '';
    
    res.on('data', (chunk) => {
      data += chunk;
    });
    
    res.on('end', () => {
      if (res.statusCode === 200) {
        console.log('A API do Gemini está habilitada para esta chave de API!');
        try {
          const models = JSON.parse(data);
          console.log('Modelos disponíveis:', models.models ? models.models.length : 0);
          console.log('Primeiros modelos:', models.models ? models.models.slice(0, 3).map(m => m.name) : 'Nenhum');
        } catch (e) {
          console.error('Erro ao analisar a resposta:', e);
        }
      } else {
        console.error('A API do Gemini NÃO está habilitada para esta chave de API');
        console.error('Detalhes do erro:', data);
        console.log('\nPara resolver este problema:');
        console.log('1. Acesse o Console do Google Cloud: https://console.cloud.google.com/');
        console.log('2. Selecione o projeto "android-habitai"');
        console.log('3. Navegue até "APIs e Serviços" > "APIs e serviços habilitados"');
        console.log('4. Clique em "+ HABILITAR APIS E SERVIÇOS"');
        console.log('5. Pesquise por "Gemini API" ou "Generative Language API"');
        console.log('6. Habilite a API para o seu projeto');
        console.log('\nOU');
        console.log('Crie uma nova chave de API específica para o Gemini AI no Google AI Studio: https://aistudio.google.com/');
      }
    });
  }).on('error', (e) => {
    console.error('Erro na solicitação HTTP:', e);
  });
}

// Executar a verificação
checkApiPermissions();
