@echo off
REM use 7z.exe to compress files
del .\mail-forwarder-by-domain.zip
7z a mail-forwarder-by-domain.zip mail-forwarder-by-domain.js
REM aws lambda update-function-code --function-name mail-forwarder-by-domain --zip-file fileb://mail-forwarder-by-domain.zip