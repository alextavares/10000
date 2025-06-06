# Teste rápido Maestro - PowerShell
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:PATH = "$env:JAVA_HOME\bin;C:\maestro\bin;$env:PATH"

Set-Location "C:\codigos\HabitAiclaudedesktop\HabitAI"

Write-Host "Executando teste basico..." -ForegroundColor Green
maestro test .maestro\test_app_launch.yaml

Write-Host "`nPressione qualquer tecla para sair..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
