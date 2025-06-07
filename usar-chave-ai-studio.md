# Usando uma Chave de API do Google AI Studio

Como você continua enfrentando problemas com a autenticação da conta de serviço, vamos implementar a solução alternativa usando uma chave de API direta do Google AI Studio.

## Passo 1: Obter uma Chave de API do Google AI Studio

1. Acesse o [Google AI Studio](https://aistudio.google.com/)
2. Faça login com sua conta Google
3. Clique no seu perfil no canto superior direito
4. Selecione **"Obter API key"** ou **"Get API key"**
5. Clique em **"Create API key"** para gerar uma nova chave
6. Copie a chave gerada

## Passo 2: Modificar o Código para Usar a Chave de API

Vamos modificar o arquivo `genkit-flows/index.ts` para usar a chave de API diretamente:

```typescript
import { genkit } from 'genkit';
import { googleAI, gemini15Flash } from '@genkit-ai/googleai';
import { enableFirebaseTelemetry } from '@genkit-ai/firebase';

// Configure a single Genkit instance for the project
export const ai = genkit({
  plugins: [
    googleAI({ apiKey: 'SUA_CHAVE_DO_AI_STUDIO_AQUI' }), // Substitua pelo valor real da chave
  ],
  model: gemini15Flash,
});

enableFirebaseTelemetry();

// Export the defined flows
export * from './helloFlow';
export * from './onboardingFlows';
export * from './habitSuggestionFlows';
```

Substitua `'SUA_CHAVE_DO_AI_STUDIO_AQUI'` pela chave real que você obteve do Google AI Studio.

## Passo 3: Recompilar e Reiniciar

1. Recompile os arquivos TypeScript:
```bash
tsc genkit-flows/*.ts --skipLibCheck
```

2. Reinicie o servidor:
```bash
pkill -f "node genkit-server.js"
node genkit-server.js
```

3. Teste a API:
```bash
curl -X POST -H "Content-Type: application/json" -d '{"name":"Alexandre"}' http://localhost:3000/api/hello
```

## Passo 4: Integrar com o Flutter

Depois de confirmar que o servidor Genkit está funcionando corretamente com a chave de API do AI Studio, você pode prosseguir com a integração no aplicativo Flutter.

O código Flutter para chamar o endpoint `/api/hello` seria algo como:

```dart
Future<String> testGenkitHello(String name) async {
  final url = Uri.parse('http://localhost:3000/api/hello');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'name': name}),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['result'];
  } else {
    throw Exception('Failed to call Genkit API: ${response.body}');
  }
}
```

## Observações Importantes

- Esta abordagem é mais simples e direta, mas menos segura para ambientes de produção
- A chave de API do AI Studio é específica para a API do Gemini e não requer configurações adicionais de permissão
- Mantenha sua chave de API segura e não a compartilhe publicamente
- Para um ambiente de produção, considere implementar limites de taxa e monitoramento de uso
- Se você precisar usar outros serviços do Google Cloud além do Gemini, a abordagem da conta de serviço seria mais apropriada

## Próximos Passos

Se esta abordagem funcionar, você pode:

1. Implementar os outros fluxos do Genkit (onboarding, sugestão de hábitos)
2. Integrar completamente com o aplicativo Flutter
3. Adicionar tratamento de erros e retentativas
4. Implementar cache para melhorar o desempenho
