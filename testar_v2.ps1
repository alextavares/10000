# Script para executar os testes corrigidos
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:PATH = "$env:JAVA_HOME\bin;C:\maestro\bin;$env:PATH"

Set-Location "C:\codigos\HabitAiclaudedesktop\HabitAI"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Executando Testes Corrigidos v2" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Teste 1: App Launch v2
Write-Host "1. Testando inicializacao (v2)..." -ForegroundColor Yellow
maestro test .maestro\test_app_launch_v2.yaml
Write-Host ""

Start-Sleep -Seconds 2

# Teste 2: Criar Hábito v2
Write-Host "2. Testando criacao de habito (v2)..." -ForegroundColor Yellow
maestro test .maestro\test_criar_habito_v2.yaml
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Dicas para melhorar os testes:" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Use 'maestro studio' para ver a tela real" -ForegroundColor Green
Write-Host "2. As screenshots estao em:" -ForegroundColor Green
Write-Host "   $env:USERPROFILE\.maestro\tests\" -ForegroundColor Cyan
Write-Host "3. Ajuste os seletores baseado no que voce ve" -ForegroundColor Green
Write-Host ""

Write-Host "Pressione qualquer tecla para sair..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
