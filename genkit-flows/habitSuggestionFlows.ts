import { ai } from './index'; // Import the configured Genkit instance
import { googleAI, gemini15Flash } from '@genkit-ai/googleai';
// import { z } from 'zod'; // Remove Zod import for now

// Define a flow for generating habit suggestions
export const habitSuggestionFlow = ai.defineFlow( // Use the imported 'ai' instance
  'habitSuggestionFlow', // Flow name as the first argument
  async (userInfo: any) => { // Use 'any' type for input for now
    // Implement logic to generate habit suggestions based on user information
    // Use the AI model to create personalized suggestions

    const promptText = `Generate personalized habit suggestions based on the following user information: 
    ${JSON.stringify(userInfo, null, 2)}
    
    Provide 5 specific habit suggestions that are:
    1. Realistic and achievable
    2. Aligned with the user's goals and preferences
    3. Specific enough to be actionable
    4. Varied in terms of difficulty and time commitment
    
    For each habit suggestion, include:
    - A clear title for the habit
    - A brief description of the habit
    - Frequency recommendation (daily, weekly, etc.)
    - Estimated time commitment
    - Expected benefits
    - Tips for successful implementation
    
    Format your response as a JSON object with an array of habit suggestions.`;

    const aiResponse = await ai.generate({ // Use the imported 'ai' instance
      prompt: promptText,
      config: {
        responseMimeType: 'application/json', // Request JSON output
      },
    });

    try {
      // Parse the JSON response
      const responseJson = JSON.parse(aiResponse.text);
      
      return {
        suggestions: responseJson.habits || responseJson,
        timestamp: new Date().toISOString(),
        userInfo: userInfo
      };
    } catch (error) {
      console.error('Error parsing AI response:', error);
      // Fallback response if parsing fails
      return {
        suggestions: [
          {
            title: "Morning Walk",
            description: "Start your day with a 15-minute walk to boost energy and mood",
            frequency: "Daily",
            timeCommitment: "15 minutes",
            benefits: "Improved mood, energy, and metabolism",
            tips: "Prepare your walking shoes the night before"
          }
        ],
        timestamp: new Date().toISOString(),
        userInfo: userInfo,
        error: "Error parsing AI response, showing default suggestion"
      };
    }
  }
);

// Only run this when executing the file directly, not when importing
if (require.main === module) {
  const sampleUserInfo = {
    goals: ["Improve fitness", "Reduce stress"],
    preferences: ["Morning activities", "Outdoor activities"],
    challenges: ["Limited time", "Low motivation"],
    currentRoutine: {
      wakeUpTime: "7:00 AM",
      bedTime: "11:00 PM",
      workHours: "9:00 AM - 5:00 PM"
    }
  };
  
  habitSuggestionFlow(sampleUserInfo).then(result => {
    console.log(JSON.stringify(result, null, 2));
  });
}
