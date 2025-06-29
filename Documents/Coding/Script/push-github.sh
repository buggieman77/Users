#!/bin/bash

# Tangkap Ctrl + C dan keluar dengan pesan
trap "echo -e '\n❌ Script dibatalkan'; exit" INT

# Periksa apakah GitHub CLI terinstall
if ! command -v gh &> /dev/null; then
  echo "Script ini butuh GitHub CLI (gh)"
  echo "GitHub CLI (gh) tidak ditemukan. Silakan install dulu: https://cli.github.com/"
  exit 1
fi

# Ambil URL remote github jika sudah ada
REMOTE_URL_EXISTING=$(git config --get remote.origin.url)

# Tanya username ke user
read -p "Masukkan username GitHub: " USERNAME

if [ -n "$REMOTE_URL_EXISTING" ]; then
  DETECTED_REPO_NAME=$(basename -s .git "$REMOTE_URL_EXISTING")
else
  DETECTED_REPO_NAME=$(basename "$PWD")
fi

echo "Nama Repository yang akan di  push ke Github : $DETECTED_REPO_NAME"
read -p "Apakah nama repository sudah sesuai? (y/n): " CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  read -p "Masukkan nama repository yang diinginkan: " CUSTOM_REPO_NAME
  REPO_NAME="$CUSTOM_REPO_NAME"
else
  REPO_NAME="$DETECTED_REPO_NAME"
fi
echo ""
REMOTE_URL="https://github.com/$USERNAME/$REPO_NAME.git"

# Cek apakah repo sudah ada di GitHub
echo "Memeriksa apakah repository $USERNAME/$REPO_NAME sudah ada di GitHub..."

if gh repo view "$USERNAME/$REPO_NAME" &> /dev/null; then
  echo "Repository sudah ada di GitHub."
else
  echo "Repository belum ada. Membuat repository di GitHub..."
  gh repo create "$USERNAME/$REPO_NAME" --public --confirm
fi

echo ""
# Tambahkan remote github jika belum ada
if git remote get-url "$USERNAME" &> /dev/null; then
  echo "Remote '$USERNAME' sudah ada: $(git remote get-url "$USERNAME")"
else
  echo "Menambahkan remote $USERNAME: $REMOTE_URL"
  git remote add "$USERNAME" "$REMOTE_URL"
fi

# Tanya nama branch yang akan dipush
echo ""
echo "buat gunain branch yang lagi aktif tekan ENTER"
read -p "Masukkan nama branch yang akan di-push ke GitHub : " INPUT_BRANCH

# Jika tidak diisi, pakai branch aktif
if [ -z "$INPUT_BRANCH" ]; then
  BRANCH=$(git branch --show-current)
else
  BRANCH="$INPUT_BRANCH"
fi

if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
  echo "✅ Branch '$BRANCH' ditemukan."
else
  echo "⚠️  Branch '$BRANCH' tidak ditemukan."
  read -p "Apakah kamu ingin membuat branch '$BRANCH'? (y/n): " CREATE_BRANCH
  if [[ "$CREATE_BRANCH" == "y" || "$CREATE_BRANCH" == "Y" ]]; then
    git checkout -b "$BRANCH"
    echo "✅ Branch '$BRANCH' berhasil dibuat dan checkout."
  else
    echo "⛔ Tidak jadi membuat branch. Keluar Script."
    exit 1
  fi
fi

# Push ke github branch main dengan set upstream
echo ""
echo "🚀 Memulai push ke GitHub:"
echo "   - User: $USERNAME"
echo "   - Repository: $REPO_NAME"
echo "   - Branch: '$BRANCH'"
echo ""
if git push -u "$USERNAME" "$BRANCH":main; then
  echo ""
  echo "🎉 Push dari branch '$BRANCH' ke '$USERNAME'/'main' di GitHub berhasil!"
  echo "🔗 Link: https://github.com/$USERNAME/$REPO_NAME"
else
  echo ""
  echo "❌ Push gagal. Periksa koneksi, konflik, atau izin repository."
  exit 1
fi
