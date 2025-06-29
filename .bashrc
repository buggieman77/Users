alias back='cd ..'
alias file='touch'
alias folder='mkdir'
alias Latihan='cd ~/Documents/Coding/Latihan'
alias Project='cd ~/Documents/Coding/Project'
alias Tutorial='cd ~/Documents/Coding/Tutorial'
alias Script='explorer.exe "$(cygpath -w ~/Documents/Coding/Script)"'
alias snippet='cd ~/Users/erensa/AppData/Roaming/Code/User/snippets'
alias htdocs='explorer.exe "$(cygpath -w /c/xampp/htdocs)"'

alias mysql='mysql -u root -p'

alias xampp='start "" "/c/xampp/xampp-control.exe"'
alias chrome='start "" "/c/Program Files/Google/Chrome/Application/chrome.exe"'
     
alias gpt='explorer "https://chatgpt.com"'
alias youtube='explorer "https://youtube.com"'
alias github='explorer "https://github.com"'

alias webpack='bash ~/Documents/Coding/Script/webpack-frame.sh'
alias project-initial='bash ~/Documents/Coding/Script/new-project-initial-commit.sh'
alias push-github='bash ~/Documents/Coding/Script/push-github.sh'

alias local-ip='ipconfig | grep "IPv4" | sed "s/.*: //"'
alias public-ip-detail='curl ipinfo.io'
alias public-ip='curl ifconfig.me'


alias branch='git checkout -b'
alias new-branch='git checkout --orphan'
alias log='git log'
alias graph='git log --all --decorate --oneline --graph'
alias add='git add .'
alias status='git status'
alias checkout='git checkout'
alias fetch='git fetch'

alias set='code ~/.bashrc'
alias apply='source ~/.bashrc'

alias edit='chmod 644'
alias read-only='chmod 444'

alias short='git log --pretty=short'
alias amend='git commit --amend'
alias commit='git commit -a'

alias main='git checkout main'
alias merge='git merge'
alias squash='git merge --squash'
alias pick='git cherry-pick'
alias cancel-merge='git merge --abort'
alias reset-merge='git reset --merge'
alias delete='git branch -D'
alias check-merge='git branch --merge'
alias check-unmerge='git branch --no-merged'

alias clone='git clone'
alias upstream='git push -u'
alias check-branch='git branch -vv'
alias push='git push'
alias back-to='git reset --hard'
alias reflog='git reflog show'
alias pull='git pull --rebase'
alias rebase='git rebase'
alias remote='git remote -v'

alias git-size='du -sh .git'
alias git-detail='git count-objects -vH'

alias login-github='gh auth login'
alias logout-github='gh auth logout'
alias check-github='gh auth status'

alias rename-pc='bash ~/Documents/Coding/Script/rename-pc.sh'
alias ls='ls --color=auto'

alias ssh='explorer.exe "$(cygpath -w ~/.ssh)"'
alias new-ssh='bash ~/Documents/Coding/Script/new-ssh.sh'

alias buggieman77='cat ~/Documents/Erensa/buggieman77.txt'
alias account='start notepad ~/Documents/Erensa/account.txt'
alias see='start notepad ~/Documents/Coding/Script/alias-list.txt'

export PATH=$PATH:/c/Program\ Files/GitHub\ CLI
export PATH=$PATH:/c/Program\ Files/Microsoft\ VS\ Code/bin
export PATH=$PATH:/c/xampp/mysql/bin

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





