IF NOT EXIST mkcert.exe powershell Invoke-WebRequest https://github.com/FiloSottile/mkcert/releases/download/v1.4.1/mkcert-v1.4.1-windows-amd64.exe -UseBasicParsing -OutFile mkcert.exe

mkcert -install

del /Q /S ..\xc1-cxa\traefik\certs\*

mkcert -cert-file ..\xc1-cxa\traefik\certs\xc1cd.localhost.crt -key-file ..\xc1-cxa\traefik\certs\xc1cd.localhost.key "xc1cd.localhost"
mkcert -cert-file ..\xc1-cxa\traefik\certs\xc1cm.localhost.crt -key-file ..\xc1-cxa\traefik\certs\xc1cm.localhost.key "xc1cm.localhost"
mkcert -cert-file ..\xc1-cxa\traefik\certs\xc1id.localhost.crt -key-file ..\xc1-cxa\traefik\certs\xc1id.localhost.key "xc1id.localhost"
mkcert -cert-file ..\xc1-cxa\traefik\certs\authoring.localhost.crt -key-file ..\xc1-cxa\traefik\certs\authoring.localhost.key "authoring.localhost"
mkcert -cert-file ..\xc1-cxa\traefik\certs\shops.localhost.crt -key-file ..\xc1-cxa\traefik\certs\shops.localhost.key "shops.localhost"
mkcert -cert-file ..\xc1-cxa\traefik\certs\minions.localhost.crt -key-file ..\xc1-cxa\traefik\certs\minions.localhost.key "minions.localhost"
mkcert -cert-file ..\xc1-cxa\traefik\certs\ops.localhost.crt -key-file ..\xc1-cxa\traefik\certs\ops.localhost.key "ops.localhost"
mkcert -cert-file ..\xc1-cxa\traefik\certs\bizfx.localhost.crt -key-file ..\xc1-cxa\traefik\certs\bizfx.localhost.key "bizfx.localhost"