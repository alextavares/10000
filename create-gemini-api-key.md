# Guia para Criar Credenciais para a API do Gemini

Você está vendo a mensagem "Talvez você precise de credenciais para usar essa API" porque a API do Gemini requer credenciais específicas para ser acessada. Vamos criar essas credenciais:

## Opção 1: Criar uma Chave de API no Google AI Studio (Recomendado)

1. Acesse o [Google AI Studio](https://aistudio.google.com/)
2. Faça login com sua conta Google
3. Clique no seu perfil no canto superior direito
4. Selecione "Obter API key" ou "Get API key"
5. Clique em "Create API key" para gerar uma nova chave
6. Copie a chave gerada
7. Atualize o arquivo `.env` com a nova chave:
   ```
   GOOGLE_GENAI_API_KEY=SUA_NOVA_CHAVE_AQUI
   ```

## Opção 2: Habilitar a API do Gemini no Google Cloud Console

1. Acesse o [Google Cloud Console](https://console.cloud.google.com/)
2. Selecione o projeto "android-habitai"
3. Navegue até "APIs e Serviços" > "Biblioteca"
4. Pesquise por "Generative Language API"
5. Clique na API e depois em "Habilitar"
6. Vá para "APIs e Serviços" > "Credenciais"
7. Clique em "Criar Credenciais" > "Chave de API"
8. Copie a chave gerada
9. Atualize o arquivo `.env` com a nova chave:
   ```
   GOOGLE_GENAI_API_KEY=SUA_NOVA_CHAVE_AQUI
   ```
10. (Opcional) Restrinja a chave para usar apenas a API do Gemini para maior segurança

## Após Criar a Chave

1. Pare o servidor atual (se estiver rodando):
   ```
   pkill -f "node genkit-server.js"
   ```

2. Inicie o servidor novamente:
   ```
   node genkit-server.js
   ```

3. Teste a API com:
   ```
   curl -X POST -H "Content-Type: application/json" -d '{"name":"Alexandre"}' http://localhost:3000/api/hello
   ```

## Notas Importantes

- A chave de API do Firebase que você está usando atualmente (`AIzaSyAayN2swkuxNZRV_htDIKc9CUjgcxQJK4M`) não tem permissão para acessar a API do Gemini.
- Você precisa de uma chave específica para a API do Gemini ou habilitar a API do Gemini para o seu projeto existente.
- Mantenha suas chaves de API seguras e não as compartilhe publicamente.
- Considere configurar cotas e restrições para suas chaves de API para evitar uso não autorizado.
