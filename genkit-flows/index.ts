import { genkit } from 'genkit';
import { googleAI, gemini15Flash } from '@genkit-ai/googleai';
import { enableFirebaseTelemetry } from '@genkit-ai/firebase'; // Import Firebase Telemetry

// Configure a single Genkit instance for the project
export const ai = genkit({ // Export the instance
  plugins: [
    googleAI({ apiKey: 'AIzaSyBMcwWGph2pJgdaI2naOlYbbWIQpyu79kw' }), // Usando a chave de API do AI Studio diretamente
  ],
  model: gemini15Flash, // set default model for the project
});

enableFirebaseTelemetry(); // Enable Firebase Telemetry

// Export the defined flows
export * from './helloFlow';
export * from './onboardingFlows';
export * from './habitSuggestionFlows';
