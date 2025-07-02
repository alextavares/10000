@echo off
echo Fazendo deploy dos indices do Firestore...
cd /d C:\codigos\habitai2406\10000
firebase deploy --only firestore:indexes
echo.
echo Indices do Firestore deployados com sucesso!
pause