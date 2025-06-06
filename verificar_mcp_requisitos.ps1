# Verificar pré-requisitos para MCPControl
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Verificando Pré-requisitos MCP" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$todosRequisitos = $true

# 1. Verificar Node.js
Write-Host "1. Node.js:" -ForegroundColor Yellow
try {
    $nodeVersion = node --version
    Write-Host "   ✅ Instalado: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Não encontrado" -ForegroundColor Red
    Write-Host "   📥 Instale de: https://nodejs.org/" -ForegroundColor Gray
    $todosRequisitos = $false
}

# 2. Verificar npm
Write-Host "`n2. NPM:" -ForegroundColor Yellow
try {
    $npmVersion = npm --version
    Write-Host "   ✅ Instalado: v$npmVersion" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Não encontrado" -ForegroundColor Red
    $todosRequisitos = $false
}

# 3. Verificar Claude Desktop
Write-Host "`n3. Claude Desktop:" -ForegroundColor Yellow
$claudePath = "$env:LOCALAPPDATA\Programs\claude\Claude.exe"
if (Test-Path $claudePath) {
    Write-Host "   ✅ Instalado" -ForegroundColor Green
} else {
    Write-Host "   ❌ Não encontrado" -ForegroundColor Red
    Write-Host "   📥 Instale de: https://claude.ai/download" -ForegroundColor Gray
    $todosRequisitos = $false
}

# 4. Verificar Visual Studio Build Tools
Write-Host "`n4. Visual Studio Build Tools:" -ForegroundColor Yellow
$vsPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (Test-Path $vsPath) {
    Write-Host "   ✅ Provavelmente instalado" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Pode não estar instalado" -ForegroundColor Yellow
    Write-Host "   📥 Se houver erros, instale com:" -ForegroundColor Gray
    Write-Host '   winget install Microsoft.VisualStudio.2022.BuildTools --override "--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"' -ForegroundColor DarkGray
}

# 5. Verificar configuração do Claude
Write-Host "`n5. Configuração Claude:" -ForegroundColor Yellow
$configPath = "$env:APPDATA\Claude\claude_desktop_config.json"
if (Test-Path $configPath) {
    Write-Host "   ✅ Arquivo encontrado" -ForegroundColor Green
    
    # Verificar se já tem MCP configurado
    $config = Get-Content $configPath -Raw | ConvertFrom-Json -ErrorAction SilentlyContinue
    if ($config.mcpServers) {
        Write-Host "   ℹ️  MCP servers já configurados:" -ForegroundColor Cyan
        $config.mcpServers.PSObject.Properties | ForEach-Object {
            Write-Host "      - $($_.Name)" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "   ⚠️  Arquivo não encontrado (será criado)" -ForegroundColor Yellow
}

# Resumo
Write-Host "`n========================================" -ForegroundColor Cyan
if ($todosRequisitos) {
    Write-Host "✅ Todos os requisitos básicos atendidos!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Próximos passos:" -ForegroundColor Yellow
    Write-Host "1. Execute: .\instalar_mcpcontrol.ps1" -ForegroundColor White
    Write-Host "2. Reinicie o Claude Desktop" -ForegroundColor White
    Write-Host "3. Procure o ícone de ferramentas (🔧)" -ForegroundColor White
} else {
    Write-Host "❌ Alguns requisitos estão faltando!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Instale os componentes faltantes antes de continuar." -ForegroundColor Yellow
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Opções adicionais
Write-Host "Opções disponíveis:" -ForegroundColor Cyan
Write-Host "1. Ver guia completo (GUIA_MCP_MOUSE_TECLADO.md)" -ForegroundColor White
Write-Host "2. Ver casos de uso (MCP_ACELERAR_DESENVOLVIMENTO.md)" -ForegroundColor White
Write-Host "3. Instalar MCPControl (se requisitos OK)" -ForegroundColor White
Write-Host "4. Sair" -ForegroundColor White
Write-Host ""

$opcao = Read-Host "Escolha uma opção (1-4)"

switch ($opcao) {
    "1" { 
        Start-Process notepad "GUIA_MCP_MOUSE_TECLADO.md"
    }
    "2" { 
        Start-Process notepad "MCP_ACELERAR_DESENVOLVIMENTO.md"
    }
    "3" { 
        if ($todosRequisitos) {
            & .\instalar_mcpcontrol.ps1
        } else {
            Write-Host "Instale os requisitos primeiro!" -ForegroundColor Red
            Start-Sleep -Seconds 3
        }
    }
}

Write-Host "`nPressione qualquer tecla para sair..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
