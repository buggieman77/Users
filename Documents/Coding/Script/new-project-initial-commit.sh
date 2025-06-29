# Git Initialitation project
git init
git add .
git commit -m "[✓] Initial commit [✓]"


#Project Name by Folder Name
PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel)")

echo "[✓] Git Initialitation project : $PROJECT_NAME [✓]"