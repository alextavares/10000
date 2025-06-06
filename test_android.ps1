Write-Host "🚀 Preparando HabitAI para teste Android..." -ForegroundColor Green
Write-Host ""

# Limpar builds anteriores
Write-Host "🧹 Limpando builds anteriores..." -ForegroundColor Yellow
flutter clean

# Obter dependências
Write-Host "📦 Obtendo dependências..." -ForegroundColor Yellow
flutter pub get

# Verificar dispositivos conectados
Write-Host "📱 Dispositivos disponíveis:" -ForegroundColor Yellow
flutter devices

Write-Host ""
Write-Host "🔨 Escolha o tipo de build:" -ForegroundColor Cyan
Write-Host "1) Debug (desenvolvimento)"
Write-Host "2) Release (produção)"
$buildType = Read-Host "Opção (1 ou 2)"

if ($buildType -eq "2") {
    Write-Host "🏗️ Construindo APK Release..." -ForegroundColor Yellow
    flutter build apk --release
    Write-Host ""
    Write-Host "✅ APK Release gerado em:" -ForegroundColor Green
    Write-Host "   build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor White
    Write-Host ""
    $install = Read-Host "Deseja instalar no dispositivo? (s/n)"
    if ($install -eq "s") {
        flutter install --release
    }
} else {
    Write-Host "🐛 Executando em modo Debug..." -ForegroundColor Yellow
    flutter run
}
