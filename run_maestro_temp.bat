@echo off
set JAVA_HOME=C:\Program Files\Java\jdk-17
set PATH=%JAVA_HOME%\bin;C:\maestro\bin;%PATH%

echo Configuracao temporaria do Java e Maestro...
echo JAVA_HOME=%JAVA_HOME%
echo.

cd /d "C:\codigos\HabitAiclaudedesktop\HabitAI"

echo Verificando Maestro...
maestro --version
echo.

echo Listando dispositivos Android...
adb devices
echo.

pause
