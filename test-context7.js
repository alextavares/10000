// A simple script to test the Context7 MCP server
const { spawn } = require('child_process');
const readline = require('readline');

// Start the Context7 MCP server
const context7 = spawn('npx', ['-y', '@upstash/context7-mcp@latest']);

// Create readline interface to read from the server's stdout
const rl = readline.createInterface({
  input: context7.stdout,
  output: process.stdout,
  terminal: false
});

// Listen for data from the server
rl.on('line', (line) => {
  console.log(`Received: ${line}`);
});

// Handle errors
context7.stderr.on('data', (data) => {
  console.error(`stderr: ${data}`);
});

// Send a request to the server after a short delay
setTimeout(() => {
  console.log('Sending request to list tools...');
  const request = {
    jsonrpc: '2.0',
    id: 1,
    method: 'mcp.list_tools',
    params: {}
  };
  
  context7.stdin.write(JSON.stringify(request) + '\n');
  
  // Close the server after a short delay
  setTimeout(() => {
    console.log('Closing server...');
    context7.kill();
    process.exit(0);
  }, 5000);
}, 2000);
