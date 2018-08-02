@echo off
REM use 7z.exe to compress files
del .\mail-forwarder-mydomain-com.zip
7z a mail-forwarder-mydomain-com.zip mail-forwarder-mydomain-com.js
aws lambda update-function-code --function-name mail-forwarder-mydomain-com --zip-file fileb://mail-forwarder-mydomain-com.zip