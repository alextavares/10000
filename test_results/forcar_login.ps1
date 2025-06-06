# Abrir HabitAI forçando tela de login
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Abrindo HabitAI - Modo Login Limpo" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se está rodando
$porta = 5004
Write-Host "Verificando servidor na porta $porta..." -ForegroundColor Green

try {
    $response = Invoke-WebRequest -Uri "http://localhost:$porta" -UseBasicParsing -TimeoutSec 3
    Write-Host "✅ Servidor ativo!" -ForegroundColor Green
} catch {
    Write-Host "❌ Servidor não encontrado na porta $porta" -ForegroundColor Red
    Write-Host "Execute: flutter run -d web-server --web-port=$porta" -ForegroundColor Yellow
    Read-Host "Pressione Enter para sair"
    exit
}

# Abrir em modo privado
Write-Host ""
Write-Host "Abrindo em modo privado para garantir login limpo..." -ForegroundColor Green
Start-Process "msedge" "-inprivate http://localhost:$porta"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  O QUE VOCÊ DEVE VER:" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✓ Tela de login com campos de email/senha" -ForegroundColor White
Write-Host "✓ Botão de login com Google" -ForegroundColor White
Write-Host "✓ Links de 'Criar conta' e 'Esqueceu senha'" -ForegroundColor White
Write-Host ""
Write-Host "Se ainda estiver logado:" -ForegroundColor Yellow
Write-Host "1. Pressione Ctrl+Shift+Delete" -ForegroundColor White
Write-Host "2. Selecione 'Cookies e dados de sites'" -ForegroundColor White
Write-Host "3. Clique em 'Limpar agora'" -ForegroundColor White
Write-Host "4. Recarregue a página (F5)" -ForegroundColor White
Write-Host ""
Read-Host "Pressione Enter quando a tela de login aparecer"
