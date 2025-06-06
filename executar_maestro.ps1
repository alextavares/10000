# Script PowerShell para executar testes Maestro
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:PATH = "$env:JAVA_HOME\bin;C:\maestro\bin;$env:PATH"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Executando Testes Maestro - HabitAI" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Set-Location "C:\codigos\HabitAiclaudedesktop\HabitAI"

Write-Host "Escolha uma opcao:" -ForegroundColor Yellow
Write-Host "1. Executar TODOS os testes"
Write-Host "2. Teste de inicializacao"
Write-Host "3. Teste de criar habito"
Write-Host "4. Teste de marcar habito"
Write-Host "5. Teste de navegacao"
Write-Host "6. Abrir Maestro Studio"
Write-Host ""

$opcao = Read-Host "Digite o numero da opcao"

switch ($opcao) {
    "1" {
        Write-Host "`nExecutando todos os testes..." -ForegroundColor Green
        & maestro test .maestro\
    }
    "2" {
        Write-Host "`nExecutando teste de inicializacao..." -ForegroundColor Green
        & maestro test .maestro\test_app_launch.yaml
    }
    "3" {
        Write-Host "`nExecutando teste de criar habito..." -ForegroundColor Green
        & maestro test .maestro\test_criar_habito.yaml
    }
    "4" {
        Write-Host "`nExecutando teste de marcar habito..." -ForegroundColor Green
        & maestro test .maestro\test_marcar_habito.yaml
    }
    "5" {
        Write-Host "`nExecutando teste de navegacao..." -ForegroundColor Green
        & maestro test .maestro\test_navegacao.yaml
    }
    "6" {
        Write-Host "`nExecutando teste generico..." -ForegroundColor Green
        & maestro test .maestro\test_generico.yaml
    }
    "7" {
        Write-Host "`nAbrindo Maestro Studio..." -ForegroundColor Green
        & maestro studio
    }
    default {
        Write-Host "Opcao invalida!" -ForegroundColor Red
    }
}

Write-Host "`nPressione qualquer tecla para sair..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
