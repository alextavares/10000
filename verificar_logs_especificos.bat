@echo off
echo ========================================
echo  VERIFICADOR DE LOGS - HABITAI
echo  Monitorando erros especificos
echo ========================================
echo.

echo Iniciando monitoramento de logs...
echo Pressione Ctrl+C para parar
echo.
echo Procurando pelos seguintes erros:
echo - libpenguin.so
echo - resource ID 0x6d0b000f
echo - DNS failures
echo - exact alarms
echo - ClassLoader issues
echo.

adb logcat -c
adb logcat | findstr /i "libpenguin\|0x6d0b000f\|DNS.*fail\|exact.*alarm\|ClassLoader\|HabitAI\|com.habitai.app"
