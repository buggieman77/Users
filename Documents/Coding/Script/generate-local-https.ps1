# === SET FOLDER ROOT CA TETAP DI SINI ===
$RootDir = "C:\Users\erensa\https"
$RootKey = Join-Path $RootDir "rootCA.key"
$RootCert = Join-Path $RootDir "rootCA.pem"

# === TANYA FOLDER PENYIMPANAN UNTUK DOMAIN LOCALHOST ===
$UserSubFolder = Read-Host "Masukkan folder untuk menyimpan sertifikat domain (misal: project-a)"  # Hanya subfolder
if ([string]::IsNullOrWhiteSpace($UserSubFolder)) {
    $OutputDir = $RootDir  # Default fallback
} else {
    $OutputDir = Join-Path $RootDir $UserSubFolder
}

# === BUAT FOLDER JIKA BELUM ADA ===
if (-Not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

Write-Host "`n=== Mulai proses generate sertifikat ==="
Write-Host "📁 Folder output sertifikat domain: $OutputDir"
Write-Host "🔐 Lokasi Root CA: $RootDir`n"

# === DEFAULT VALUE UNTUK SUBJEK ===
$DefaultCountry = "ID"
$DefaultState = "Jawa Barat"
$DefaultCity = "Bandung"
$DefaultOrg = "Local Dev"
$DefaultCNRoot = "Local Dev Root CA"
$DefaultCNLocalhost = "localhost"

# === INPUT INTERAKTIF UNTUK DATA SERTIFIKAT ===
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

# === SUBJEK UNTUK OPENSSL ===
$RootSubj = "/C=$Country/ST=$State/L=$City/O=$Org/CN=$CommonNameRoot"
$LocalhostSubj = "/C=$Country/ST=$State/L=$City/O=$Org/CN=$CommonNameLocalhost"

# === GENERATE ROOT CA HANYA JIKA BELUM ADA ===
if (-Not (Test-Path $RootKey -and Test-Path $RootCert)) {
    Write-Host "`n🔧 Root CA belum ada. Membuat rootCA.key dan rootCA.pem ..."
    if (-Not (Test-Path $RootDir)) {
        New-Item -ItemType Directory -Path $RootDir | Out-Null
    }

    # === ROOT PRIVATE KEY ===
    openssl genrsa -out $RootKey 2048

    # === ROOT CERTIFICATE (SELF SIGNED) ===
    openssl req -x509 -new -nodes -key $RootKey -sha256 -days 3650 -out $RootCert -subj $RootSubj
} else {
    Write-Host "✅ Root CA sudah ada, tidak perlu membuat ulang."
}

# === SET PATH FILE LOCALHOST ===
$LocalhostKey = Join-Path $OutputDir "localhost.key"
$LocalhostCsr = Join-Path $OutputDir "localhost.csr"
$LocalhostCert = Join-Path $OutputDir "localhost.crt"
$LocalhostExt = Join-Path $OutputDir "localhost.ext"

# === BUAT PRIVATE KEY UNTUK DOMAIN LOCALHOST ===
openssl genrsa -out $LocalhostKey 2048

# === BUAT CERTIFICATE SIGNING REQUEST UNTUK LOCALHOST ===
openssl req -new -key $LocalhostKey -out $LocalhostCsr -subj $LocalhostSubj

# === BUAT FILE EXTENSION UNTUK SAN ===
@"
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage=digitalSignature,nonRepudiation,keyEncipherment,dataEncipherment
subjectAltName=@alt_names

[alt_names]
DNS.1=$CommonNameLocalhost
"@ | Out-File -Encoding ASCII $LocalhostExt

# === TANDA TANGANI CSR MENGGUNAKAN ROOT CA ===
openssl x509 -req -in $LocalhostCsr -CA $RootCert -CAkey $RootKey -CAcreateserial -out $LocalhostCert -days 3650 -sha256 -extfile $LocalhostExt

# === DONE ===
Write-Host "`n✅ Selesai!"
Write-Host "📁 Semua file untuk '$CommonNameLocalhost' disimpan di: $OutputDir"
Write-Host "🗝️  Root CA tetap berada di: $RootDir"
Write-Host "➡️  Langkah selanjutnya: Import $RootCert ke Certificate Manager (certmgr.msc) -> Trusted Root Certification Authorities -> alltask -> import"
