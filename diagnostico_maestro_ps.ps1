# Diagnostico Completo do Maestro - PowerShell
Write-Host "========================================"
Write-Host "  Diagnostico Completo do Maestro"
Write-Host "========================================"
Write-Host ""

# Configurar ambiente
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
$env:PATH = "$env:JAVA_HOME\bin;C:\maestro\bin;$env:ANDROID_HOME\platform-tools;$env:PATH"

Set-Location "C:\codigos\HabitAiclaudedesktop\HabitAI"

try {
    Write-Host "[1] Verificando Java..." -ForegroundColor Yellow
    $javaVersion = & java -version 2>&1 | Out-String
    Write-Host $javaVersion
    Write-Host "[OK] Java encontrado" -ForegroundColor Green
} catch {
    Write-Host "[ERRO] Java nao encontrado!" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

Write-Host ""

try {
    Write-Host "[2] Verificando ADB..." -ForegroundColor Yellow
    $adbVersion = & adb version 2>&1 | Out-String
    Write-Host $adbVersion
    Write-Host "[OK] ADB encontrado" -ForegroundColor Green
} catch {
    Write-Host "[ERRO] ADB nao encontrado!" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

Write-Host ""

Write-Host "[3] Verificando dispositivos conectados..." -ForegroundColor Yellow
$devices = & adb devices -l 2>&1 | Out-String
Write-Host $devices

Write-Host "[4] Verificando Maestro..." -ForegroundColor Yellow
try {
    $maestroVersion = & maestro --version 2>&1 | Out-String
    Write-Host "Versao: $maestroVersion"
    Write-Host "[OK] Maestro encontrado" -ForegroundColor Green
} catch {
    Write-Host "[ERRO] Maestro nao encontrado!" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

Write-Host ""

Write-Host "[5] Verificando app instalado..." -ForegroundColor Yellow
$packages = & adb shell pm list packages 2>&1 | Out-String
if ($packages -match "habitai") {
    Write-Host "[OK] App HabitAI instalado" -ForegroundColor Green
} else {
    Write-Host "[AVISO] App HabitAI nao encontrado no dispositivo" -ForegroundColor Yellow
}

Write-Host ""

Write-Host "[6] Executando Maestro Doctor..." -ForegroundColor Yellow
try {
    & maestro doctor
} catch {
    Write-Host "[ERRO] Falha ao executar Maestro Doctor" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

Write-Host ""

Write-Host "[7] Listando testes disponiveis..." -ForegroundColor Yellow
Get-ChildItem ".maestro\*.yaml" | ForEach-Object { Write-Host "  - $($_.Name)" }

Write-Host ""
$resposta = Read-Host "Deseja executar um teste simples? (S/N)"

if ($resposta -eq "S") {
    Write-Host ""
    Write-Host "Executando teste generico..." -ForegroundColor Green
    & maestro test .maestro\test_generico.yaml
}

Write-Host ""
Write-Host "Pressione qualquer tecla para continuar..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
