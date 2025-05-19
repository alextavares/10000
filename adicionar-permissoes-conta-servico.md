# Adicionando Permissões à Conta de Serviço Correta

Observei que você tem duas contas de serviço diferentes no seu projeto:

1. `firebase-adminsdk-fbsvc@android-habitai.iam.gserviceaccount.com` - Esta conta já tem várias permissões, incluindo "Administrador do AI Platform" e "Usuário da Plataforma Vertex AI Express".

2. `android-habitai@android-habitai.iam.gserviceaccount.com` - Esta é a conta de serviço que estamos usando para o Genkit (a que está no arquivo JSON), mas parece que ela não aparece na sua lista de IAM ou não tem as permissões necessárias.

## Opção 1: Usar a Conta de Serviço do Firebase Admin SDK

Uma opção é usar a conta de serviço do Firebase Admin SDK que já tem as permissões necessárias. Para isso, você precisaria:

1. Gerar uma nova chave JSON para a conta `firebase-adminsdk-fbsvc@android-habitai.iam.gserviceaccount.com`
2. Substituir o arquivo `service-account-key.json` atual por essa nova chave

## Opção 2: Adicionar Permissões à Conta de Serviço Atual

Outra opção é adicionar as permissões necessárias à conta de serviço `android-habitai@android-habitai.iam.gserviceaccount.com`:

1. Acesse o [Console do Google Cloud](https://console.cloud.google.com/)
2. Vá para "IAM e Administrador" > "IAM"
3. Clique em "+ CONCEDER ACESSO"
4. No campo "Novos principais", digite `android-habitai@android-habitai.iam.gserviceaccount.com`
5. No campo "Selecionar um papel", adicione os seguintes papéis:
   - "Administrador do AI Platform" ou "Usuário do AI Platform"
   - "Usuário da Plataforma VAPIertex AI Express"
   - "Cloud AI Generative Language  User"
6. Clique em "Salvar"

## Opção 3: Verificar se a API está Habilitada

Independentemente da conta de serviço que você usar, certifique-se de que a API do Gemini está habilitada:

1. Acesse o [Console do Google Cloud](https://console.cloud.google.com/)
2. Vá para "APIs e Serviços" > "Biblioteca"
3. Pesquise por "Generative Language API"
4. Clique na API e depois em "Habilitar" (se ainda não estiver habilitada)

## Testando Novamente

Depois de fazer as alterações acima, execute novamente o script de teste:

```bash
node test-service-account.js
```

Se você optar por usar a conta de serviço do Firebase Admin SDK, lembre-se de atualizar o arquivo `.env` para apontar para o novo arquivo JSON:

```
GOOGLE_APPLICATION_CREDENTIALS=./firebase-admin-key.json
```

## Observações Importantes

- As alterações de permissão podem levar alguns minutos para se propagar
- Certifique-se de que o faturamento está habilitado para o projeto, pois a API do Gemini pode exigir isso
- Se você continuar enfrentando problemas, verifique as cotas e limites da API no Console do Google Cloud
