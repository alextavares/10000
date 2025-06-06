# Script PowerShell para teste automatizado - HabitAI Sessão 1
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  TESTADOR AUTOMATICO - HabitAI" -ForegroundColor Yellow
Write-Host "  Sessão 1: Autenticação" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se a aplicação está rodando
Write-Host "Verificando se a aplicação está rodando..." -ForegroundColor Green
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5003" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Aplicação está rodando!" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Aplicação não está acessível. Verifique se o servidor Flutter está rodando." -ForegroundColor Red
    Write-Host "Use o comando: flutter run -d web-server --web-port=5003" -ForegroundColor Yellow
    Read-Host "Pressione Enter para sair"
    exit
}

# Abrir no navegador
Write-Host ""
Write-Host "Abrindo aplicação no navegador..." -ForegroundColor Green
Start-Process "msedge" "http://localhost:5003"

# Aguardar carregamento
Write-Host "Aguardando 5 segundos para carregamento completo..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Checklist interativo
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  CHECKLIST DE TESTES" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$resultados = @{}
$perguntas = @(
    "A página carregou completamente?",
    "O texto 'Carregando HabitAI...' desapareceu?",
    "Você vê a tela de login?",
    "Existem campos de Email e Senha?",
    "Há um botão de Entrar/Login?",
    "Existe opção de 'Criar conta'?",
    "Tem botão de login com Google?",
    "Há link 'Esqueceu a senha?'"
)

foreach ($pergunta in $perguntas) {
    $resposta = Read-Host "$pergunta (S/N)"
    $resultados[$pergunta] = $resposta.ToUpper() -eq "S"
    if ($resultados[$pergunta]) {
        Write-Host "✅ OK" -ForegroundColor Green
    } else {
        Write-Host "❌ FALHOU" -ForegroundColor Red
    }
    Write-Host ""
}

# Salvar resultados
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$logPath = "C:\codigos\HabitAiclaudedesktop\HabitAI\test_results\log_sessao1.txt"

Add-Content -Path $logPath -Value "===== Teste Executado: $timestamp ====="
foreach ($key in $resultados.Keys) {
    $status = if ($resultados[$key]) { "PASSOU" } else { "FALHOU" }
    Add-Content -Path $logPath -Value "$key - $status"
}
Add-Content -Path $logPath -Value ""

# Resumo
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  RESUMO DOS TESTES" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan
$passados = ($resultados.Values | Where-Object { $_ -eq $true }).Count
$total = $resultados.Count
Write-Host "Testes passados: $passados/$total" -ForegroundColor $(if ($passados -eq $total) { "Green" } else { "Yellow" })
Write-Host ""
Write-Host "Resultados salvos em: $logPath" -ForegroundColor Green
Write-Host ""
Read-Host "Pressione Enter para finalizar"
