@echo off
echo ========================================
echo   Abrindo Maestro Studio + Navegador
echo ========================================
echo.

REM Configurar ambiente
set "JAVA_HOME=C:\Program Files\Java\jdk-17"
set "ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk"
set "PATH=%JAVA_HOME%\bin;C:\maestro\bin;%ANDROID_HOME%\platform-tools;%PATH%"

cd /d "C:\codigos\HabitAiclaudedesktop\HabitAI"

echo Verificando dispositivo...
adb devices
echo.

echo Iniciando Maestro Studio...
echo.

REM Iniciar o Maestro Studio em background
start /B maestro studio

REM Aguardar 3 segundos para o servidor iniciar
timeout /t 3 /nobreak >nul

REM Abrir o navegador
echo Abrindo navegador...
start http://localhost:9999

echo.
echo ========================================
echo   Maestro Studio esta rodando!
echo ========================================
echo.
echo URL: http://localhost:9999
echo.
echo Instrucoes:
echo 1. O navegador deve abrir automaticamente
echo 2. Se nao abrir, acesse: http://localhost:9999
echo 3. Use o console para testar comandos
echo 4. Clique na lupa para inspecionar elementos
echo 5. Para parar: Feche esta janela ou Ctrl+C
echo.
echo Veja o arquivo 'comandos_maestro_studio.md' para
echo comandos prontos para testar!
echo.
echo Pressione qualquer tecla para continuar com o servidor rodando...
pause >nul

REM Manter o servidor rodando
maestro studio
