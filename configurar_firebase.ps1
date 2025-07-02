# Configurar Firebase no HabitAI
# PowerShell Script

Clear-Host
Write-Host "========================================"
Write-Host "   CONFIGURAR FIREBASE NO HABITAI" -ForegroundColor Cyan
Write-Host "========================================"
Write-Host ""

# Navegar para o diretório do projeto
Set-Location -Path "C:\codigos\habitai2406\10000"

# Verificar arquivo .env
Write-Host "[1] Verificando arquivo .env..." -ForegroundColor Yellow
if (Test-Path ".env") {
    Write-Host "[OK] Arquivo .env encontrado" -ForegroundColor Green
} else {
    Write-Host "[!] Arquivo .env NAO encontrado" -ForegroundColor Red
    Write-Host ""
    Write-Host "Criando .env a partir do modelo..."
    
    if (Test-Path ".env.firebase") {
        Copy-Item ".env.firebase" ".env"
        Write-Host "[OK] Arquivo .env criado!" -ForegroundColor Green
        Write-Host ""
        Write-Host "IMPORTANTE: Edite o arquivo .env e adicione:" -ForegroundColor Yellow
        Write-Host "- FIREBASE_API_KEY (obtenha no Firebase Console)"
        Write-Host "- FIREBASE_APP_ID (obtenha no Firebase Console)"
        Write-Host ""
        Write-Host "Pressione qualquer tecla para abrir o arquivo .env..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        notepad .env
        Write-Host ""
        Write-Host "Após preencher o .env, execute este script novamente."
        Read-Host "Pressione Enter para sair"
        exit
    } else {
        Write-Host "[ERRO] Arquivo .env.firebase não encontrado!" -ForegroundColor Red
        Read-Host "Pressione Enter para sair"
        exit
    }
}

Write-Host ""
Write-Host "[2] Verificando dependências Flutter..." -ForegroundColor Yellow
$output = flutter pub get 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Dependências instaladas" -ForegroundColor Green
} else {
    Write-Host "[ERRO] Falha ao instalar dependências" -ForegroundColor Red
    Read-Host "Pressione Enter para sair"
    exit
}

Write-Host ""
Write-Host "[3] Verificando configuração do Firebase..." -ForegroundColor Yellow
Write-Host ""
dart run verificar_firebase_config.dart

Write-Host ""
Write-Host "========================================"
Write-Host ""
Write-Host "Escolha uma opção:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Criar usuário de teste"
Write-Host "2. Executar o app"
Write-Host "3. Abrir Firebase Console"
Write-Host "4. Ver instruções completas"
Write-Host "5. Sair"
Write-Host ""
$opcao = Read-Host "Digite o número da opção"

switch ($opcao) {
    "1" {
        Write-Host ""
        Write-Host "Criando usuário de teste..." -ForegroundColor Yellow
        dart run scripts\criar_usuario_teste.dart
        Read-Host "Pressione Enter para continuar"
    }
    "2" {
        Write-Host ""
        Write-Host "Iniciando o app HabitAI..." -ForegroundColor Yellow
        Start-Process cmd -ArgumentList "/k", "flutter run"
    }
    "3" {
        Write-Host ""
        Write-Host "Abrindo Firebase Console..." -ForegroundColor Yellow
        Start-Process "https://console.firebase.google.com/"
    }
    "4" {
        Write-Host ""
        Write-Host "Abrindo guia de configuração..." -ForegroundColor Yellow
        if (Test-Path "GUIA_CONFIGURAR_FIREBASE_LOGIN.md") {
            Start-Process "GUIA_CONFIGURAR_FIREBASE_LOGIN.md"
        } else {
            Write-Host "[ERRO] Arquivo de instruções não encontrado!" -ForegroundColor Red
        }
        Read-Host "Pressione Enter para continuar"
    }
}

Write-Host ""
Write-Host "Processo concluído!" -ForegroundColor Green
Read-Host "Pressione Enter para sair"
