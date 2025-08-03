# === SETUP OUTPUT FOLDER ===
$OutputDir = "C:\Users\erensa\https"
if (-Not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

Write-Host "=== Buat Sertifikat Root CA dan localhost (interaktif + default) ===`n"

# === NILAI DEFAULT ===
$DefaultCountry = "ID"
$DefaultState = "Jawa Barat"
$DefaultCity = "Bandung"
$DefaultOrg = "Local Dev"
$DefaultCNRoot = "Local Dev Root CA"
$DefaultCNLocalhost = "localhost"

# === INPUT USER (DENGAN DEFAULT) ===
$Country = Read-Host "Masukkan Country (C) [Default: $DefaultCountry]"
if ([string]::IsNullOrWhiteSpace($Country)) { $Country = $DefaultCountry }

$State = Read-Host "Masukkan State (ST) [Default: $DefaultState]"
if ([string]::IsNullOrWhiteSpace($State)) { $State = $DefaultState }

$City = Read-Host "Masukkan City (L) [Default: $DefaultCity]"
if ([string]::IsNullOrWhiteSpace($City)) { $City = $DefaultCity }

$Org = Read-Host "Masukkan Organization (O) [Default: $DefaultOrg]"
if ([string]::IsNullOrWhiteSpace($Org)) { $Org = $DefaultOrg }

$CommonNameRoot = Read-Host "Masukkan Common Name untuk Root CA (CN) [Default: $DefaultCNRoot]"
if ([string]::IsNullOrWhiteSpace($CommonNameRoot)) { $CommonNameRoot = $DefaultCNRoot }

$CommonNameLocalhost = Read-Host "Masukkan Common Name untuk localhost (CN) [Default: $DefaultCNLocalhost]"
if ([string]::IsNullOrWhiteSpace($CommonNameLocalhost)) { $CommonNameLocalhost = $DefaultCNLocalhost }

# === SET FILE PATHS ===
$RootKey = Join-Path $OutputDir "rootCA.key"
$RootCert = Join-Path $OutputDir "rootCA.pem"
$LocalhostKey = Join-Path $OutputDir "localhost.key"
$LocalhostCsr = Join-Path $OutputDir "localhost.csr"
$LocalhostCert = Join-Path $OutputDir "localhost.crt"
$LocalhostExt = Join-Path $OutputDir "localhost.ext"

# === SUBJECT STRINGS ===
$RootSubj = "/C=$Country/ST=$State/L=$City/O=$Org/CN=$CommonNameRoot"
$LocalhostSubj = "/C=$Country/ST=$State/L=$City/O=$Org/CN=$CommonNameLocalhost"

# === STEP 1: Generate Root CA Private Key ===
openssl genrsa -out $RootKey 2048

# === STEP 2: Generate Root CA Self-Signed Cert ===
openssl req -x509 -new -nodes -key $RootKey -sha256 -days 3650 -out $RootCert -subj $RootSubj

# === STEP 3: Generate localhost Private Key ===
openssl genrsa -out $LocalhostKey 2048

# === STEP 4: Generate CSR untuk localhost ===
openssl req -new -key $LocalhostKey -out $LocalhostCsr -subj $LocalhostSubj

# === STEP 5: Buat File SAN ===
@"
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage=digitalSignature,nonRepudiation,keyEncipherment,dataEncipherment
subjectAltName=@alt_names

[alt_names]
DNS.1=$CommonNameLocalhost
"@ | Out-File -Encoding ASCII $LocalhostExt

# === STEP 6: Tanda tangan localhost cert dengan Root CA ===
openssl x509 -req -in $LocalhostCsr -CA $RootCert -CAkey $RootKey -CAcreateserial -out $LocalhostCert -days 3650 -sha256 -extfile $LocalhostExt

Write-Host "`n✅ Selesai! Semua file ada di: $OutputDir"
