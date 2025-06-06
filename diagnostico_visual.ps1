# Script de diagnóstico Maestro
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:PATH = "$env:JAVA_HOME\bin;C:\maestro\bin;$env:PATH"

Set-Location "C:\codigos\HabitAiclaudedesktop\HabitAI"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Diagnóstico Visual do App" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Este teste vai capturar screenshots do seu app para entender a UI." -ForegroundColor Yellow
Write-Host ""

# Executar teste de diagnóstico
Write-Host "Executando teste de diagnóstico..." -ForegroundColor Green
maestro test .maestro\test_diagnostico.yaml

Write-Host ""
Write-Host "Screenshots foram salvas!" -ForegroundColor Green
Write-Host ""

# Tentar encontrar pasta de screenshots
$maestroDir = "$env:USERPROFILE\.maestro\tests"
Write-Host "Procurando screenshots em: $maestroDir" -ForegroundColor Yellow

# Abrir a pasta mais recente
$latestTest = Get-ChildItem $maestroDir | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($latestTest) {
    $screenshotPath = $latestTest.FullName
    Write-Host "Abrindo pasta de screenshots: $screenshotPath" -ForegroundColor Green
    Start-Process explorer $screenshotPath
} else {
    Write-Host "Pasta de screenshots não encontrada." -ForegroundColor Red
}

Write-Host ""
Write-Host "Analise as screenshots e me diga:" -ForegroundColor Cyan
Write-Host "1. Qual texto aparece na tela inicial?"
Write-Host "2. Há uma tela de login?"
Write-Host "3. Quais botões são visíveis?"
Write-Host ""

Write-Host "Pressione qualquer tecla para sair..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
