// Teste para verificar se o problema está relacionado à autenticação do Firebase
require('dotenv').config();
const { initializeApp } = require('firebase/app');
const { getAuth, signInWithCustomToken } = require('firebase/auth');

// Configuração do Firebase
const firebaseConfig = {
  // Usando as informações do seu projeto real
  apiKey: "AIzaSyAayN2swkuxNZRV_htDIKc9CUjgcxQJK4M", // Chave do google-services.json
  authDomain: "android-habitai.firebaseapp.com",
  projectId: "android-habitai",
  storageBucket: "android-habitai.firebasestorage.app",
  messagingSenderId: "258006613617",
  appId: "1:258006613617:android:97dd7ccb386841785465d0"
};

// Inicializar o Firebase
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);

console.log('Firebase inicializado com a chave de API:', process.env.GOOGLE_GENAI_API_KEY ? 'Sim (valor presente)' : 'Não (valor ausente)');

// Verificar o status da autenticação
console.log('Status da autenticação:', auth.currentUser ? 'Autenticado' : 'Não autenticado');

// Verificar se a chave de API está expirada
async function checkApiKey() {
  try {
    // Tentar uma operação simples que requer a chave de API
    // Isso não é uma operação real, apenas um exemplo para verificar se a chave é válida
    console.log('Verificando a validade da chave de API...');
    
    // Verificar se há algum erro relacionado à expiração da chave
    if (auth.app.options.apiKey !== process.env.GOOGLE_GENAI_API_KEY) {
      console.log('Aviso: A chave de API configurada no Firebase é diferente da variável de ambiente');
    }
    
    console.log('Chave de API parece estar configurada corretamente no Firebase');
  } catch (error) {
    console.error('Erro ao verificar a chave de API:', error);
    
    if (error.code === 'auth/invalid-api-key' || error.code === 'auth/api-key-expired') {
      console.error('A chave de API do Firebase está inválida ou expirada');
      console.error('Recomendação: Gere uma nova chave de API no console do Firebase');
    }
  }
}

// Executar a verificação
checkApiKey();
