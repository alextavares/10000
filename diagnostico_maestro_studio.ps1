# Script PowerShell para iniciar Maestro Studio com diagnóstico
Clear-Host
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   INICIANDO MAESTRO STUDIO - DIAGNÓSTICO" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Configurar ambiente
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:ANDROID_HOME = "C:\Users\alext\AppData\Local\Android\Sdk"
$env:PATH = "$env:JAVA_HOME\bin;C:\maestro\bin;$env:ANDROID_HOME\platform-tools;$env:PATH"

# Navegar para o diretório
Set-Location "C:\codigos\HabitAiclaudedesktop\HabitAI"

Write-Host "📁 Diretório atual: $(Get-Location)" -ForegroundColor Green
Write-Host ""

# Verificar Java
Write-Host "☕ Verificando Java..." -ForegroundColor Yellow
try {
    $javaVersion = & java -version 2>&1 | Out-String
    Write-Host "✅ Java encontrado!" -ForegroundColor Green
    Write-Host $javaVersion -ForegroundColor Gray
} catch {
    Write-Host "❌ Java não encontrado!" -ForegroundColor Red
}

# Verificar Maestro
Write-Host "`n🎭 Verificando Maestro..." -ForegroundColor Yellow
try {
    $maestroVersion = & maestro --version 2>&1
    Write-Host "✅ Maestro versão: $maestroVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Maestro não encontrado!" -ForegroundColor Red
}

# Verificar ADB e dispositivos
Write-Host "`n📱 Verificando dispositivos conectados..." -ForegroundColor Yellow
$devices = & adb devices -l 2>&1
Write-Host $devices -ForegroundColor Gray

# Verificar portas em uso
Write-Host "`n🔌 Verificando portas..." -ForegroundColor Yellow
$port7001 = netstat -ano | Select-String ":7001.*LISTENING"
$port9999 = netstat -ano | Select-String ":9999.*LISTENING"

if ($port7001) {
    Write-Host "⚠️ Porta 7001 em uso!" -ForegroundColor Yellow
    Write-Host $port7001 -ForegroundColor Gray
}
if ($port9999) {
    Write-Host "⚠️ Porta 9999 em uso!" -ForegroundColor Yellow
    Write-Host $port9999 -ForegroundColor Gray
}

# Matar processos Maestro anteriores
Write-Host "`n🧹 Limpando processos anteriores..." -ForegroundColor Yellow
$maestroProcesses = Get-Process | Where-Object { $_.ProcessName -like "*maestro*" -or ($_.ProcessName -eq "java" -and $_.CommandLine -like "*maestro*") }
if ($maestroProcesses) {
    foreach ($proc in $maestroProcesses) {
        Write-Host "Finalizando processo: $($proc.ProcessName) (PID: $($proc.Id))" -ForegroundColor Yellow
        Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
    }
}

# Aguardar um momento
Start-Sleep -Seconds 2

# Tentar iniciar Maestro Studio
Write-Host "`n🚀 Iniciando Maestro Studio..." -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

try {
    # Executar Maestro Studio
    & maestro studio --no-window 2>&1 | Tee-Object -Variable maestroOutput
    
    Write-Host "`n❌ Maestro Studio foi encerrado" -ForegroundColor Red
    Write-Host "Output:" -ForegroundColor Yellow
    Write-Host $maestroOutput -ForegroundColor Gray
} catch {
    Write-Host "`n❌ Erro ao executar Maestro Studio:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "Pressione qualquer tecla para sair..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
