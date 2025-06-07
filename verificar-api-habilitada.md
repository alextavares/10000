# Verificando se a API do Gemini está Habilitada

Você ainda está recebendo o erro "Insufficient Permission" mesmo após adicionar as permissões à conta de serviço. Isso geralmente indica que a API do Gemini não está habilitada para o projeto.

## Verificar se a API está Habilitada

1. Acesse o [Console do Google Cloud](https://console.cloud.google.com/)
2. Certifique-se de que o projeto `android-habitai` está selecionado
3. No menu lateral, vá para **"APIs e Serviços"** > **"Biblioteca"**
4. Na barra de pesquisa, digite **"Generative Language API"**
5. Clique na API quando aparecer nos resultados
6. Verifique se a API está habilitada. Se não estiver, clique no botão **"Habilitar"**

## Verificar o Status do Faturamento

A API do Gemini geralmente requer que o faturamento esteja habilitado para o projeto:

1. No menu lateral do Console do Google Cloud, vá para **"Faturamento"**
2. Verifique se o projeto `android-habitai` tem uma conta de faturamento associada
3. Se não tiver, clique em **"Vincular uma conta de faturamento"** e siga as instruções

## Verificar Cotas e Limites

Às vezes, o erro de permissão pode ocorrer devido a cotas ou limites:

1. No menu lateral, vá para **"APIs e Serviços"** > **"Cotas e limites"**
2. Procure por cotas relacionadas à "Generative Language API"
3. Verifique se alguma cota está em 0 ou muito baixa

## Testar com a Ferramenta de Exploração da API

O Google Cloud oferece uma ferramenta para testar APIs diretamente no console:

1. No menu lateral, vá para **"APIs e Serviços"** > **"Biblioteca"**
2. Encontre a "Generative Language API"
3. Clique em **"Experimentar esta API"** ou **"API Explorer"**
4. Tente fazer uma solicitação simples para verificar se a API está funcionando

## Verificar Logs de Erro

Os logs podem fornecer mais detalhes sobre o erro:

1. No menu lateral, vá para **"Logging"** > **"Logs Explorer"**
2. Filtre por:
   - Recurso: "API Gateway" ou "Cloud Functions"
   - Severidade: "Error"
   - Período: últimas 24 horas
3. Procure por erros relacionados à "Generative Language API" ou "Gemini"

## Solução Alternativa: Usar a API do Gemini Diretamente

Se você continuar enfrentando problemas com a autenticação da conta de serviço, uma alternativa é usar a API do Gemini diretamente com uma chave de API:

1. Acesse o [Google AI Studio](https://aistudio.google.com/)
2. Clique no seu perfil no canto superior direito
3. Selecione **"Obter API key"** ou **"Get API key"**
4. Crie uma nova chave de API
5. Modifique o arquivo `genkit-flows/index.ts` para usar esta chave:

```typescript
import { genkit } from 'genkit';
import { googleAI, gemini15Flash } from '@genkit-ai/googleai';
import { enableFirebaseTelemetry } from '@genkit-ai/firebase';

// Configure a single Genkit instance for the project
export const ai = genkit({
  plugins: [
    googleAI({ apiKey: 'SUA_CHAVE_DO_AI_STUDIO_AQUI' }),
  ],
  model: gemini15Flash,
});

enableFirebaseTelemetry();

// Export the defined flows
export * from './helloFlow';
export * from './onboardingFlows';
export * from './habitSuggestionFlows';
```

6. Recompile os arquivos TypeScript:
```
tsc genkit-flows/*.ts --skipLibCheck
```

7. Reinicie o servidor:
```
node genkit-server.js
```

Esta abordagem contorna os problemas de permissão da conta de serviço, mas é menos segura para ambientes de produção.
