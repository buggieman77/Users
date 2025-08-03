alias back='cd ..'
alias file='touch'
alias folder='mkdir'
alias Latihan='cd ~/Documents/Coding/Latihan'

alias project-dir='cd ~/Documents/Coding/Project'
alias tutorial-dir='cd ~/Documents/Coding/Tutorial'

alias https-dir='cd ~/https'
alias https='explorer.exe "$(cygpath -w ~/https)"'
alias script-dir='cd ~/Documents/Coding/Script'
alias script='explorer.exe "$(cygpath -w ~/Documents/Coding/Script)"'
alias test-script='bash ~/Documents/Coding/Script/test-script.sh'
alias new-script='code ~/Documents/Coding/Script/test-script.sh'

alias snippet='cd ~/Users/erensa/AppData/Roaming/Code/User/snippets'
alias htdocs-dir='cd /c/xampp/htdocs'
alias htdocs='explorer.exe "$(cygpath -w /c/xampp/htdocs)"'

alias mysql='mysql -u root -p'
alias php-mysql='bash ~/Documents/Coding/Script/php-mysql-database.sh'

alias xampp='start "" "/c/xampp/xampp-control.exe"'
alias chrome='start "" "/c/Program Files/Google/Chrome/Application/chrome.exe"'
     
alias gpt='explorer "https://chatgpt.com"'
alias youtube='explorer "https://youtube.com"'
alias localhost='explorer "http://localhost/tutorial/"'

alias webpack='bash ~/Documents/Coding/Script/webpack-frame.sh'
alias project-initial='bash ~/Documents/Coding/Script/new-project-initial-commit.sh'
alias generate-https='bash ~/Documents/Coding/Script/generate-local-https.sh'

alias local-ip='ipconfig | grep "IPv4" | sed "s/.*: //"'
alias public-ip-detail='curl ipinfo.io'
alias public-ip='curl ifconfig.me'

alias login-github='gh auth login'
alias logout-github='gh auth logout'
alias check-github='gh auth status'

alias push-github='bash ~/Documents/Coding/Script/push-github.sh'
alias repo-check='bash ~/Documents/Coding/Script/github-repo-check.sh'

alias merge='git merge'
alias squash='git merge --squash'
alias pick='git cherry-pick'
alias cancel-merge='git merge --abort'
alias reset-merge='git reset --merge'
alias delete='git branch -D'
alias check-merge='git branch --merge'
alias check-unmerge='git branch --no-merged'

alias check-branch='git branch -vv'
alias branch='git checkout -b'
alias new-branch='git checkout --orphan'
alias main='git checkout main'
alias online='git checkout online'
alias checkout='git checkout'

alias tracked='git ls-files'
alias log='git log'
alias graph='git log --all --decorate --oneline --graph'
alias short='git log --pretty=short'

alias clone='git clone'
alias upstream='git push -u'
alias fetch='git fetch'

alias add='git add .'
alias delete-track='git rm -r --cached'
alias status='git status'

alias amend='git commit --amend'
alias commit='git commit -a'

alias set='code ~/.bashrc'
alias apply='source ~/.bashrc'

alias push='git push'
alias back-to='git reset --hard'
alias reflog='git reflog show'
alias pull='git pull --rebase'
alias rebase='git rebase'
alias remote='git remote -v'

alias rename-pc='bash ~/Documents/Coding/Script/rename-pc.sh'
alias ls='ls --color=auto'

alias ssh='explorer.exe "$(cygpath -w ~/.ssh)"'
alias new-ssh='bash ~/Documents/Coding/Script/new-ssh.sh'

alias buggieman77='cat ~/Documents/Erensa/buggieman77.txt'
alias account='start notepad ~/Documents/Erensa/account.txt'
alias see='start notepad ~/Documents/Coding/Script/alias-list.txt'

alias php-cs-fixer='php /c/php-tools/php-cs-fixer.phar'

export PATH=$PATH:/c/Program\ Files/GitHub\ CLI
export PATH=$PATH:/c/Program\ Files/Microsoft\ VS\ Code/bin
export PATH=$PATH:/c/xampp/mysql/bin
export PATH=$PATH:/c/php-tools

# Fungsi untuk mengubah nama tab di Git Bash sesuai basename PWD, pakai huruf besar
set_tab_title() {
  # Ambil basename dari direktori sekarang, lalu ubah ke uppercase
  local base_dir=$(basename "$PWD" | tr '[:lower:]' '[:upper:]')
  # Kirim escape sequence untuk mengubah nama tab terminal
  echo -ne "\033]0;${base_dir}\007"
}

if [[ $- == *i* && $SHLVL -eq 1 ]]; then
    # Fungsi untuk men-center-kan teks di terminal
    center() {
        local term_width=$(tput cols)
        local text="$1"
        local text_length=${#text}
        local padding=$(( (term_width - text_length) / 2 ))
        printf "%*s%s\n\n" "$padding" "" "$text"
    }

    echo -e "\n\n"  # Jarak atas
    center '💻 Welcome to BASH64, Solissa! 💻'
    echo ""         # Baris kosong di bawahnya
    center '🔞 input "see" to check command list bro 🔞'
    echo -e "\n"    # Jarak bawah
fi

# Warna dan bagian statis PS1
PS1_HEADER='\[\e[36m\]Solissa\[\e[37m\]@\[\e[35m\]\h \[\e[33m\]BASH64 \[\e[32m\]\w'

PROMPT_COMMAND='
  set_tab_title
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    PS1="${PS1_HEADER} \[\e[31m\](${branch})\[\e[0m\]\n\[\e[37m\]\\$ "
  else
    PS1="${PS1_HEADER}\n\[\e[37m\]\\$ "
  fi
'

# echo "[DEBUG] PROMPT_COMMAND active: $PROMPT_COMMAND"





