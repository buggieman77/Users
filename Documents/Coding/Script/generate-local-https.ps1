$OutputDir = "C:\Users\erensa\https"
if (-Not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

Write-Host "Generate Root CA dan sertifikat localhost di $OutputDir ..."

$RootKey = Join-Path $OutputDir "rootCA.key"
$RootCert = Join-Path $OutputDir "rootCA.pem"
$LocalhostKey = Join-Path $OutputDir "localhost.key"
$LocalhostCsr = Join-Path $OutputDir "localhost.csr"
$LocalhostCert = Join-Path $OutputDir "localhost.crt"
$LocalhostExt = Join-Path $OutputDir "localhost.ext"

# 1. Generate Root CA private key
openssl genrsa -out $RootKey 2048

# 2. Generate Root CA self-signed certificate
openssl req -x509 -new -nodes -key $RootKey -sha256 -days 3650 -out $RootCert -subj "/C=ID/ST=Jawa Barat/L=Bandung/O=Local Dev CA/CN=Local Dev Root CA"

# 3. Generate private key untuk localhost
openssl genrsa -out $LocalhostKey 2048

# 4. Generate CSR untuk localhost
openssl req -new -key $LocalhostKey -out $LocalhostCsr -subj "/C=ID/ST=Jawa Barat/L=Bandung/O=Local Dev/CN=localhost"

# 5. Buat file ekstensi SAN untuk localhost
@"
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage=digitalSignature,nonRepudiation,keyEncipherment,dataEncipherment
subjectAltName=@alt_names

[alt_names]
DNS.1=localhost
"@ | Out-File -Encoding ASCII $LocalhostExt

# 6. Tandatangani sertifikat localhost dengan Root CA
openssl x509 -req -in $LocalhostCsr -CA $RootCert -CAkey $RootKey -CAcreateserial -out $LocalhostCert -days 3650 -sha256 -extfile $LocalhostExt

Write-Host "Selesai! File ada di $OutputDir"
