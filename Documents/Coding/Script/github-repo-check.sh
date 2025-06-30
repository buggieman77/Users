#!/bin/bash
echo ""
# Prompt for GitHub username
read -p "Masukkan username GitHub: " username

# Prompt for repository name
read -p "Masukkan nama repository: " repo

# Buat URL & API GitHub
url="https://github.com/$username/$repo"
api="https://api.github.com/repos/$username/$repo"
echo ""

# Tampilin URL
echo -e "Menampilkan repo GUI:\n$url\n"
echo -e "Menampilkan detail repo:\n$api\n"
echo ""