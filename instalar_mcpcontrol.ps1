# Script para instalar MCPControl no Claude Desktop
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Instalando MCPControl para Claude" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar Node.js
Write-Host "Verificando Node.js..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version
    Write-Host "[OK] Node.js instalado: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "[!] Node.js não encontrado!" -ForegroundColor Red
    Write-Host "Baixe de: https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# Caminho do arquivo de configuração do Claude
$configPath = "$env:APPDATA\Claude\claude_desktop_config.json"

Write-Host ""
Write-Host "Verificando configuração do Claude..." -ForegroundColor Yellow

if (Test-Path $configPath) {
    Write-Host "[OK] Arquivo de configuração encontrado" -ForegroundColor Green
    
    # Fazer backup
    $backupPath = "$configPath.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item $configPath $backupPath
    Write-Host "[OK] Backup criado: $backupPath" -ForegroundColor Green
} else {
    Write-Host "[!] Arquivo de configuração não encontrado" -ForegroundColor Red
    Write-Host "Criando novo arquivo..." -ForegroundColor Yellow
    
    # Criar diretório se não existir
    $configDir = Split-Path $configPath
    if (!(Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    }
}

# Configuração do MCPControl
$mcpConfig = @'
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "C:\\codigos",
        "C:\\Users\\alext\\Desktop",
        "C:\\Users\\alext\\Downloads"
      ]
    },
    "desktop-commander": {
      "command": "npx",
      "args": [
        "-y",
        "@wonderwhy-er/desktop-commander"
      ]
    },
    "MCPControl": {
      "command": "npx",
      "args": [
        "-y",
        "mcp-control"
      ]
    }
  }
}
'@

Write-Host ""
Write-Host "Adicionando MCPControl à configuração..." -ForegroundColor Yellow

# Salvar configuração
$mcpConfig | Out-File -FilePath $configPath -Encoding UTF8
Write-Host "[OK] Configuração salva!" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Instalação Concluída!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Próximos passos:" -ForegroundColor Yellow
Write-Host "1. Feche o Claude Desktop completamente" -ForegroundColor White
Write-Host "2. Abra o Claude Desktop novamente" -ForegroundColor White
Write-Host "3. Procure pelo ícone de ferramentas (slider) no canto inferior esquerdo" -ForegroundColor White
Write-Host ""
Write-Host "IMPORTANTE:" -ForegroundColor Red
Write-Host "- MCPControl dá controle total do computador ao Claude" -ForegroundColor Yellow
Write-Host "- Use com EXTREMA CAUTELA" -ForegroundColor Yellow
Write-Host "- Recomenda-se usar em VM para segurança" -ForegroundColor Yellow
Write-Host ""
Write-Host "Para instalar Visual Studio Build Tools (se necessário):" -ForegroundColor Cyan
Write-Host "winget install Microsoft.VisualStudio.2022.BuildTools --override `"--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended`"" -ForegroundColor Gray
Write-Host ""
Write-Host "Pressione qualquer tecla para sair..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
