# Configurar Flutter no PowerShell

Write-Host "================================" -ForegroundColor Cyan
Write-Host "  Configurando Flutter no Sistema" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Adicionar Flutter ao PATH do usuário
$flutterPath = "C:\flutter\bin"
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

if ($currentPath -notlike "*$flutterPath*") {
    Write-Host "Adicionando Flutter ao PATH..." -ForegroundColor Yellow
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$flutterPath", "User")
    Write-Host "✓ Flutter adicionado ao PATH!" -ForegroundColor Green
} else {
    Write-Host "✓ Flutter já está no PATH!" -ForegroundColor Green
}

# Definir PROGRAMFILES(X86)
Write-Host ""
Write-Host "Configurando variável PROGRAMFILES(X86)..." -ForegroundColor Yellow
[Environment]::SetEnvironmentVariable("PROGRAMFILES(X86)", "C:\Program Files (x86)", "User")
$env:PROGRAMFILESX86 = "C:\Program Files (x86)"
Write-Host "✓ Variável configurada!" -ForegroundColor Green

# Atualizar PATH na sessão atual
$env:Path = [Environment]::GetEnvironmentVariable("Path", "User") + ";" + [Environment]::GetEnvironmentVariable("Path", "Machine")

Write-Host ""
Write-Host "Verificando instalação do Flutter..." -ForegroundColor Yellow
& "C:\flutter\bin\flutter" --version

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "  Configuração Concluída!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Agora você pode executar:" -ForegroundColor Yellow
Write-Host "  cd C:\codigos\habitai2406\10000" -ForegroundColor White
Write-Host "  flutter run -d windows" -ForegroundColor White
Write-Host ""
Write-Host "Ou use o script:" -ForegroundColor Yellow
Write-Host "  .\executar_habitai_windows.bat" -ForegroundColor White
Write-Host ""
