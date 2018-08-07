@echo off
REM use 7z.exe to compress files
del .\mail-forwarder.zip 2>nul
7z a mail-forwarder.zip mail-forwarder.js
REM aws lambda update-function-code --function-name mail-forwarder --zip-file fileb://mail-forwarder.zip