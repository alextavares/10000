// A simple script to test the Context7 MCP server using JSON-RPC
const { spawn } = require('child_process');
const readline = require('readline');

// Start the Context7 MCP server
const context7 = spawn('/home/user/.global_modules/bin/context7-mcp', []);

// Create readline interface to read from the server's stdout
const rl = readline.createInterface({
  input: context7.stdout,
  output: process.stdout,
  terminal: false
});

// Listen for data from the server
rl.on('line', (line) => {
  try {
    // Try to parse the line as JSON
    const json = JSON.parse(line);
    console.log('Received JSON response:');
    console.log(JSON.stringify(json, null, 2));
  } catch (error) {
    // If it's not JSON, just log the line
    console.log(`Received: ${line}`);
  }
});

// Handle errors
context7.stderr.on('data', (data) => {
  console.error(`stderr: ${data}`);
});

// Send a request to the server after a short delay
setTimeout(() => {
  console.log('Sending request to get library docs for React...');
  const request = {
    jsonrpc: '2.0',
    id: 1,
    method: 'mcp.call_tool',
    params: {
      name: 'get-library-docs',
      arguments: {
        context7CompatibleLibraryID: '/react',
        tokens: 1000
      }
    }
  };
  
  context7.stdin.write(JSON.stringify(request) + '\n');
  
  // Close the server after a short delay
  setTimeout(() => {
    console.log('Closing server...');
    context7.kill();
    process.exit(0);
  }, 5000);
}, 2000);
