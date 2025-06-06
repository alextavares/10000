# Abre o Maestro Studio para debug visual
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:PATH = "$env:JAVA_HOME\bin;C:\maestro\bin;$env:PATH"

Set-Location "C:\codigos\HabitAiclaudedesktop\HabitAI"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Abrindo Maestro Studio" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "O Maestro Studio permite:" -ForegroundColor Yellow
Write-Host "- Ver a tela do dispositivo em tempo real" -ForegroundColor Green
Write-Host "- Testar comandos interativamente" -ForegroundColor Green
Write-Host "- Inspecionar elementos da UI" -ForegroundColor Green
Write-Host "- Gravar acoes para criar novos testes" -ForegroundColor Green
Write-Host ""
Write-Host "Abrindo..." -ForegroundColor Yellow

maestro studio

Write-Host "`nStudio fechado."
