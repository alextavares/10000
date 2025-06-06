# Script para abrir a pasta de screenshots do Maestro
$screenshotsPath = "$env:USERPROFILE\.maestro\tests"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Screenshots dos Testes Maestro" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (Test-Path $screenshotsPath) {
    Write-Host "Abrindo pasta de screenshots..." -ForegroundColor Green
    Write-Host "Caminho: $screenshotsPath" -ForegroundColor Yellow
    Write-Host ""
    
    # Listar pastas de teste recentes
    Write-Host "Testes recentes:" -ForegroundColor Cyan
    Get-ChildItem $screenshotsPath -Directory | 
        Sort-Object CreationTime -Descending | 
        Select-Object -First 5 | 
        ForEach-Object {
            Write-Host "  - $($_.Name)" -ForegroundColor Gray
        }
    
    # Abrir no explorador
    Start-Process explorer.exe $screenshotsPath
} else {
    Write-Host "Pasta de screenshots nao encontrada!" -ForegroundColor Red
    Write-Host "Execute alguns testes primeiro." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Dica: As screenshots mostram exatamente o que o Maestro viu!" -ForegroundColor Green
Write-Host "Use elas para ajustar seus testes." -ForegroundColor Green
Write-Host ""
Write-Host "Pressione qualquer tecla para sair..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
