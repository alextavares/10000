// A simple script to test the Context7 MCP server
const { execSync } = require('child_process');

// Run the Context7 MCP server with the get-library-docs tool
try {
  console.log('Testing Context7 MCP server...');
  
  // Use the get-library-docs tool to fetch documentation for a library
  const output = execSync('/home/user/.global_modules/bin/context7-mcp get-library-docs /react', { encoding: 'utf8' });
  
  console.log('Output:');
  console.log(output);
  
  console.log('Test completed successfully!');
} catch (error) {
  console.error('Error:', error.message);
  console.error('Stderr:', error.stderr);
}
