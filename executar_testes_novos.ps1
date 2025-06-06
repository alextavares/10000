# Executar testes corrigidos
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:PATH = "$env:JAVA_HOME\bin;C:\maestro\bin;$env:PATH"

Set-Location "C:\codigos\HabitAiclaudedesktop\HabitAI"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Executando Testes Atualizados" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$tests = @(
    @{Name="Diagnóstico Visual"; File="test_diagnostico.yaml"},
    @{Name="App Launch v2"; File="test_app_launch_v2.yaml"},
    @{Name="Criar Hábito v2"; File="test_criar_habito_v2.yaml"},
    @{Name="Teste Genérico"; File="test_generico.yaml"},
    @{Name="Marcar Hábito"; File="test_marcar_habito.yaml"},
    @{Name="Navegação"; File="test_navegacao.yaml"}
)

Write-Host "Escolha um teste:" -ForegroundColor Yellow
for ($i = 0; $i -lt $tests.Count; $i++) {
    Write-Host "$($i+1). $($tests[$i].Name)"
}
Write-Host "0. Executar TODOS os testes novos"
Write-Host ""

$opcao = Read-Host "Digite o número"

if ($opcao -eq "0") {
    Write-Host "`nExecutando todos os testes..." -ForegroundColor Green
    maestro test .maestro\test_diagnostico.yaml .maestro\test_app_launch_v2.yaml .maestro\test_criar_habito_v2.yaml
} elseif ($opcao -ge 1 -and $opcao -le $tests.Count) {
    $test = $tests[$opcao - 1]
    Write-Host "`nExecutando: $($test.Name)" -ForegroundColor Green
    maestro test ".maestro\$($test.File)"
} else {
    Write-Host "Opção inválida!" -ForegroundColor Red
}

Write-Host "`nPressione qualquer tecla para sair..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
