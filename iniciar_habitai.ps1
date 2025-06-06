# Script PowerShell para iniciar HabitAI
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   INICIANDO HABITAI - SERVIDOR FLUTTER" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Navegar para o diretório
Set-Location "C:\codigos\HabitAiclaudedesktop\HabitAI"
Write-Host "📁 Diretório: $(Get-Location)" -ForegroundColor Green
Write-Host ""

# Verificar se Flutter está instalado
try {
    flutter --version | Out-Null
    Write-Host "✅ Flutter encontrado!" -ForegroundColor Green
} catch {
    Write-Host "❌ Flutter não encontrado no PATH!" -ForegroundColor Red
    Write-Host "Instale o Flutter ou adicione ao PATH do sistema." -ForegroundColor Yellow
    Read-Host "Pressione Enter para sair"
    exit
}

Write-Host ""
Write-Host "🚀 Iniciando servidor na porta 5004..." -ForegroundColor Green
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   COMANDOS DISPONÍVEIS:" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   R  = Hot Reload (aplicar mudanças)" -ForegroundColor White
Write-Host "   r  = Hot Restart (reiniciar app)" -ForegroundColor White
Write-Host "   q  = Quit (parar servidor)" -ForegroundColor White
Write-Host "   h  = Help (mais comandos)" -ForegroundColor White
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "🌐 Após iniciar, acesse: http://localhost:5004" -ForegroundColor Green
Write-Host ""

# Iniciar Flutter
flutter run -d web-server --web-port=5004
