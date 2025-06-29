#!/bin/bash

# Tangkap Ctrl + C dan keluar dengan pesan
trap "echo -e '\n❌ Script dibatalkan'; exit" INT

read -p "Masukkan nama baru komputer: " nama

powershell.exe -Command "Rename-Computer -NewName '$nama' -Force"
