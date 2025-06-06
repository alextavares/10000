# Script PowerShell para configurar ADB e Maestro
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Configurando ADB para Maestro" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se o ADB já está instalado
$adbPaths = @(
    "$env:LOCALAPPDATA\Android\Sdk\platform-tools",
    "$env:USERPROFILE\AppData\Local\Android\Sdk\platform-tools",
    "C:\Android\sdk\platform-tools",
    "C:\Program Files (x86)\Android\android-sdk\platform-tools"
)

$adbFound = $false
$adbPath = ""

foreach ($path in $adbPaths) {
    if (Test-Path "$path\adb.exe") {
        $adbFound = $true
        $adbPath = $path
        Write-Host "[OK] ADB encontrado em: $path" -ForegroundColor Green
        break
    }
}

if (-not $adbFound) {
    Write-Host "[!] ADB não encontrado!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Opções para instalar o ADB:" -ForegroundColor Yellow
    Write-Host "1. Instalar Android Studio (completo): https://developer.android.com/studio"
    Write-Host "2. Baixar apenas platform-tools (recomendado): https://developer.android.com/studio/releases/platform-tools"
    Write-Host ""
    Write-Host "Após baixar platform-tools:" -ForegroundColor Yellow
    Write-Host "1. Extraia o arquivo ZIP"
    Write-Host "2. Coloque a pasta em C:\Android\sdk\"
    Write-Host "3. Execute este script novamente"
    Write-Host ""
    
    $download = Read-Host "Deseja que eu abra o link para download? (S/N)"
    if ($download -eq "S" -or $download -eq "s") {
        Start-Process "https://developer.android.com/studio/releases/platform-tools"
    }
    
    exit
}

# Adicionar ADB ao PATH temporariamente
$env:PATH = "$adbPath;$env:PATH"

Write-Host ""
Write-Host "Verificando dispositivos conectados..." -ForegroundColor Yellow
& "$adbPath\adb.exe" devices -l

Write-Host ""
Write-Host "ADB configurado com sucesso!" -ForegroundColor Green
Write-Host ""
Write-Host "Para tornar permanente, adicione ao PATH do sistema:" -ForegroundColor Yellow
Write-Host "$adbPath" -ForegroundColor Cyan
Write-Host ""

# Configurar Java e Maestro
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:PATH = "$env:JAVA_HOME\bin;C:\maestro\bin;$env:PATH"

Write-Host "Verificando Maestro..." -ForegroundColor Yellow
maestro --version

Write-Host ""
Write-Host "Pronto! Agora você pode executar os testes." -ForegroundColor Green
Write-Host ""
Write-Host "Comandos disponíveis:" -ForegroundColor Yellow
Write-Host "maestro test .maestro\test_app_launch.yaml" -ForegroundColor Cyan
Write-Host "maestro test .maestro\" -ForegroundColor Cyan
Write-Host "maestro studio" -ForegroundColor Cyan
Write-Host ""

# Manter a sessão aberta
Write-Host "Esta janela está configurada com ADB e Maestro." -ForegroundColor Green
Write-Host "Execute os comandos Maestro diretamente aqui." -ForegroundColor Green
Write-Host ""
