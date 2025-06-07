# Script para obter SHA-1 do aplicativo Android

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Obtendo SHA-1 do aplicativo HabitAI" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Navegar para o diretório android
Set-Location -Path "android"

Write-Host "[1/2] Executando signingReport..." -ForegroundColor Yellow
Write-Host ""

# Executar gradlew para obter o SHA-1
if (Test-Path ".\gradlew.bat") {
    .\gradlew.bat signingReport
} else {
    Write-Host "Erro: gradlew.bat não encontrado!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "IMPORTANTE:" -ForegroundColor Green
Write-Host "1. Procure pela seção 'debug' acima" -ForegroundColor Yellow
Write-Host "2. Copie o valor SHA1" -ForegroundColor Yellow
Write-Host "3. Adicione no Firebase Console:" -ForegroundColor Yellow
Write-Host "   - Vá para Project Settings" -ForegroundColor White
Write-Host "   - Android apps" -ForegroundColor White
Write-Host "   - Add fingerprint" -ForegroundColor White
Write-Host "   - Cole o SHA1" -ForegroundColor White
Write-Host "4. Baixe o novo google-services.json" -ForegroundColor Yellow
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "Pressione qualquer tecla para sair..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")