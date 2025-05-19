require('dotenv').config(); // Load environment variables from .env file FIRST

// Definir a variável de ambiente GOOGLE_API_KEY diretamente no código
process.env.GOOGLE_API_KEY = 'AIzaSyBMcwWGph2pJgdaI2naOlYbbWIQpyu79kw';
console.log('GOOGLE_API_KEY definida diretamente no código');

const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

// Import the compiled Genkit flows AFTER dotenv has loaded
const { helloFlow, onboardingQuestionFlow, habitSuggestionFlow } = require('./genkit-flows');

// Middleware to parse JSON bodies
app.use(express.json());

// Enable CORS for all routes
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }
  next();
});

// Health check endpoint
app.get('/', (req, res) => {
  res.send('Genkit API Server is running');
});

// Hello flow endpoint
app.post('/api/hello', async (req, res) => {
  try {
    const { name } = req.body;
    if (!name) {
      return res.status(400).json({ error: 'Name is required' });
    }
    
    const result = await helloFlow.run(name);
    res.json({ result });
  } catch (error) {
    console.error('Error in hello flow:', error);
    res.status(500).json({ error: 'Failed to process request', details: error.message });
  }
});

// Onboarding question flow endpoint
app.post('/api/onboarding-question', async (req, res) => {
  try {
    const { answer } = req.body;
    if (!answer) {
      return res.status(400).json({ error: 'Answer is required' });
    }
    
    const result = await onboardingQuestionFlow.run(answer);
    res.json(result);
  } catch (error) {
    console.error('Error in onboarding question flow:', error);
    res.status(500).json({ error: 'Failed to process request', details: error.message });
  }
});

// Habit suggestion flow endpoint
app.post('/api/habit-suggestions', async (req, res) => {
  try {
    const userInfo = req.body;
    if (!userInfo) {
      return res.status(400).json({ error: 'User information is required' });
    }
    
    const result = await habitSuggestionFlow.run(userInfo);
    res.json(result);
  } catch (error) {
    console.error('Error in habit suggestion flow:', error);
    res.status(500).json({ error: 'Failed to process request', details: error.message });
  }
});

// Start the server, listening on all available network interfaces
const server = app.listen(port, '0.0.0.0', () => {
  console.log(`Genkit API Server listening on port ${port}`);
  console.log(`Access locally at http://localhost:${port}`);
  console.log(`Access from emulator/network at http://<YOUR_LOCAL_IP>:${port}`);
});

// Handle graceful shutdown
process.on('SIGTERM', () => {
  console.log('Shutting down all Genkit servers...');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('Shutting down all Genkit servers...');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});
