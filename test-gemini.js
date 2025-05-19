// Teste direto da API do Google Gemini sem usar o Genkit
require('dotenv').config();
const { GoogleGenerativeAI } = require('@google/generative-ai');

// Obter a chave de API do arquivo .env
const apiKey = process.env.GOOGLE_GENAI_API_KEY;
console.log('API Key carregada:', apiKey ? 'Sim' : 'Não');

// Inicializar a API do Google Generative AI
const genAI = new GoogleGenerativeAI(apiKey);

async function run() {
  try {
    // Usar o modelo Gemini 1.5 Flash
    const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
    
    // Gerar uma resposta
    const result = await model.generateContent("Olá, meu nome é Alexandre. Como você está?");
    const response = await result.response;
    const text = response.text();
    
    console.log("Resposta do Gemini:", text);
    console.log("Teste concluído com sucesso!");
  } catch (error) {
    console.error("Erro ao chamar a API do Gemini:", error);
    
    // Verificar se é um erro de chave de API
    if (error.message && error.message.includes("API key")) {
      console.error("\nErro de chave de API detectado!");
      console.error("Possíveis causas:");
      console.error("1. A chave de API expirou ou foi revogada");
      console.error("2. A chave de API não tem permissões para acessar o modelo Gemini");
      console.error("3. A chave de API está incorreta");
      console.error("\nSoluções sugeridas:");
      console.error("1. Gere uma nova chave de API no Google AI Studio");
      console.error("2. Verifique se a chave tem as permissões corretas");
      console.error("3. Verifique se a variável de ambiente está configurada corretamente");
    }
  }
}

// Executar o teste
run();
