import { ai } from './index'; // Import the configured Genkit instance
import { googleAI, gemini15Flash } from '@genkit-ai/googleai'; // Import googleAI and gemini15Flash
// import { z } from 'zod'; // Remove Zod import for now

// Define a flow for interactive onboarding questions
export const onboardingQuestionFlow = ai.defineFlow( // Use the imported 'ai' instance
  'onboardingQuestionFlow', // Flow name as the first argument
  async (input: string) => { // Use 'string' type for input
    // Process user's answer to an onboarding question
    // Use the AI model to analyze the answer and determine the next question or step

    const promptText = `Analyze the user's answer to an onboarding question: "${input}".
    Based on the answer, determine the next relevant question to ask to understand their habits, goals, and preferences for habit tracking.
    If enough information has been gathered to provide initial habit suggestions, indicate that the onboarding is complete.
    Extract key information provided by the user (e.g., interests, challenges, preferred habit types, daily routine aspects).
    
    Respond in a structured format, providing the next question (or null if complete), a boolean indicating if onboarding is complete, and the extracted data.`;

    const aiResponse = await ai.generate({ // Use the imported 'ai' instance
      prompt: promptText,
      config: {
        responseMimeType: 'application/json', // Request JSON output
      },
    });

    try {
      // Parse and validate the JSON response
      const responseJson = JSON.parse(aiResponse.text);

      return {
        nextQuestion: responseJson.nextQuestion || null,
        onboardingComplete: responseJson.onboardingComplete || false,
        extractedData: responseJson.extractedData || {},
      };
    } catch (error) {
      console.error('Error parsing AI response:', error);
      // Fallback response if parsing fails
      return {
        nextQuestion: "Could you tell me more about your daily routine?",
        onboardingComplete: false,
        extractedData: { userInput: input },
      };
    }
  }
);

// Only run this when executing the file directly, not when importing
if (require.main === module) {
  onboardingQuestionFlow("I want to improve my fitness and wake up earlier").then(result => {
    console.log(JSON.stringify(result, null, 2));
  });
}
