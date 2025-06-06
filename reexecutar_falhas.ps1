# Script para executar apenas os testes que falharam
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:PATH = "$env:JAVA_HOME\bin;C:\maestro\bin;$env:PATH"

Set-Location "C:\codigos\HabitAiclaudedesktop\HabitAI"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Re-executando Testes que Falharam" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Teste 1: App Launch
Write-Host "1. Testando inicializacao do app..." -ForegroundColor Yellow
maestro test .maestro\test_app_launch.yaml
Write-Host ""

# Pequena pausa
Start-Sleep -Seconds 2

# Teste 2: Criar Hábito
Write-Host "2. Testando criacao de habito..." -ForegroundColor Yellow
maestro test .maestro\test_criar_habito.yaml
Write-Host ""

# Pequena pausa
Start-Sleep -Seconds 2

# Teste 3: Validação de Erros
Write-Host "3. Testando validacoes..." -ForegroundColor Yellow
maestro test .maestro\test_validacao_erros.yaml
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Se algum teste falhou, execute:" -ForegroundColor Yellow
Write-Host "maestro studio" -ForegroundColor Green
Write-Host "para ver a tela do dispositivo e ajustar os seletores" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`nPressione qualquer tecla para sair..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
