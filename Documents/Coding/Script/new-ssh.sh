#!/bin/bash

# Tangkap Ctrl + C dan keluar dengan pesan
trap "echo -e '\n❌ Script dibatalkan'; exit" INT

# Minta input dari user
read -p "Masukkan email: " email
read -p "Masukkan nama folder: " folder
read -p "Masukkan nama file SSH key: " filename

# Path lengkap folder dan file
ssh_dir=~/.ssh/ssh-$folder
ssh_file=$ssh_dir/id_rsa_$filename

# Buat folder jika belum ada
mkdir -p "$ssh_dir"

# Generate SSH key
ssh-keygen -t rsa -b 4096 -C "$email" -f "$ssh_file"

# Tampilkan pesan sukses
echo
echo "✅ SSH key berhasil dibuat: $ssh_file"
echo

# Tampilkan instruksi konfigurasi
echo "📝 Sekarang edit file konfigurasi SSH:"
echo "Tambahkan konfigurasi seperti ini (ganti Host & IdentityFile sesuai):"
echo
echo "Host github-$filename"
echo "  HostName github.com"
echo "  User git"
echo "  IdentityFile ~/.ssh/$folder/id_rsa_$filename"
echo

# Buka file config (buat jika belum ada)
notepad ~/.ssh/config

# Buka folder SSH di Windows Explorer
explorer.exe "$(cygpath -w ~/.ssh)"
