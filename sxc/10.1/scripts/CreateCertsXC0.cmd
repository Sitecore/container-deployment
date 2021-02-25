IF NOT EXIST mkcert.exe powershell Invoke-WebRequest https://github.com/FiloSottile/mkcert/releases/download/v1.4.1/mkcert-v1.4.1-windows-amd64.exe -UseBasicParsing -OutFile mkcert.exe

mkcert -install

del /Q /S ..\xc0\traefik\certs\*

mkcert -cert-file ..\xc0\traefik\certs\xc0cm.localhost.crt -key-file ..\xc0\traefik\certs\xc0cm.localhost.key "xc0cm.localhost"
mkcert -cert-file ..\xc0\traefik\certs\xc0id.localhost.crt -key-file ..\xc0\traefik\certs\xc0id.localhost.key "xc0id.localhost"
mkcert -cert-file ..\xc0\traefik\certs\authoring.localhost.crt -key-file ..\xc0\traefik\certs\authoring.localhost.key "authoring.localhost"
mkcert -cert-file ..\xc0\traefik\certs\shops.localhost.crt -key-file ..\xc0\traefik\certs\shops.localhost.key "shops.localhost"
mkcert -cert-file ..\xc0\traefik\certs\minions.localhost.crt -key-file ..\xc0\traefik\certs\minions.localhost.key "minions.localhost"
mkcert -cert-file ..\xc0\traefik\certs\ops.localhost.crt -key-file ..\xc0\traefik\certs\ops.localhost.key "ops.localhost"
mkcert -cert-file ..\xc0\traefik\certs\bizfx.localhost.crt -key-file ..\xc0\traefik\certs\bizfx.localhost.key "bizfx.localhost"