source ~/.zplug/init.zsh

zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "rupa/z", use:z.sh

if [ -e /usr/local/share/zsh-completions ]; then
  fpath=(/usr/local/share/zsh-completions $fpath)
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/kouta/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/kouta/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/kouta/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/kouta/google-cloud-sdk/completion.zsh.inc'; fi

[[ /usr/local/bin/kubectl ]] && source <(kubectl completion zsh)

autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
autoload -U +X bashcompinit && bashcompinit
zplug load

export HISTFILE=~/.zsh_history
export HISTSIZE=1000
export SAVEHIST=100000
setopt EXTENDED_HISTORY
setopt append_history
setopt hist_ignore_dups
setopt share_history
export LANG=en_US.UTF-8

alias ls='ls -FG'
alias dir='ls -FG'
alias cd..='cd ..'
alias cls='clear'
alias cks='cls'
alias grep='grep --color=auto'
alias history='history 1'
alias s='source ~/.zshrc'
alias cat='bat'
alias ps='procs'

alias r='ruby'

alias fzf='fzf --ansi --height 40% --reverse'
alias c='code .'
alias codef='code `ls -a | fzf`'
alias vimf='vim `find . -maxdepth 1 -type f | fzf`'
alias cdf='cd `find . -maxdepth 1 -type d | fzf`'
alias catf='cat `find . -maxdepth 1 -type f | fzf`'
alias zf="cd \`z | fzf | awk '{print \$2}'\`"

# --------------------
# tmux
# --------------------
alias t='tmux'
alias td='t detach-client'
alias ta="t a -t \`t ls | fzf | awk '{print \$1}'\` 2> /dev/null"

# --------------------
# docker
# --------------------
alias dc='docker-compose'
alias dce="dc exec \`dc ps --services --filter status=running | fzf\` 2> /dev/null"
alias dp='docker ps'
alias di='docker images'
alias dv='docker volume ls'
alias log="dc logs -f \`dc ps --services --filter status=running | fzf\` 2> /dev/null"

# --------------------
# kubectl
# --------------------
alias kp='kubectl get pods'
alias kd="kubectl describe pod \`kp | fzf | awk '{print \$1}'\` 2> /dev/null"
alias ks='kubectl get services'
alias knsls='kubectl get ns'
alias kcc='kubectl config current-context'
alias kns="kubectl config set-context `kcc` --namespace=\`knsls | fzf | awk '{print \$1}'\`"
alias ke="kubectl exec -it \`kp | fzf | awk '{print \$1}'\` 2> /dev/null"
alias klog="kubectl logs \`kp | fzf | awk '{print \$1}'\` 2> /dev/null"
# export PATH=$PATH:/usr/local/opt/helm@2/bin

# --------------------
# gcloud
# --------------------
export CLOUDSDK_PYTHON=python2
alias gcll='gcloud container clusters list'
alias cred="gcll | fzf | awk '{print \$2,\$1}' | xargs gcloud container clusters get-credentials --region"
alias gpls='gcloud projects list'
alias gpro="gcloud config set project \`gpls | fzf | awk '{print \$1}'\`"
alias gals='gcloud auth list'
alias gsa="gcloud config set account \`gals | rg @ | fzf | awk '{print \$2}'\`"
alias gccl='gcloud config configurations list'
alias gcac="gcloud config configurations activate \`gccl | fzf | awk '{print \$1}'\`"

# --------------------
# gsutil
# --------------------
alias gsls='gsutil ls'
alias gslsf="gsls \`gsls | fzf | awk '{print \$1}'\`"

bindkey "^[[3~" delete-char

# --------------------
# git
# --------------------
alias gr='git reset --hard'
alias branch='git branch'
alias bd="git branch -D \`git branch | fzf\` 2> /dev/null"

function rprompt-git-current-branch {
  local dir branch_name st branch_status
  dir=`git rev-parse --show-toplevel 2> /dev/null`
  if [[ $dir =~ fatal ]]; then
    result=''
    return
  fi
  if [ ! -e  "${dir}/.git" ]; then
    # gitで管理されていないディレクトリは何も返さない
    result=''
    return
  fi
  branch_name=`git rev-parse --abbrev-ref HEAD 2> /dev/null`
  st=`git status 2> /dev/null`
  if [[ -n `echo "$st" | grep "^nothing to"` ]]; then
    # 全てcommitされてクリーンな状態
    branch_status="%F{051}"
    elif [[ -n `echo "$st" | grep "^Untracked files"` ]]; then
    # gitに管理されていないファイルがある状態
    branch_status="%F{051}?"
    elif [[ -n `echo "$st" | grep "^Changes not staged for commit"` ]]; then
    # git addされていないファイルがある状態
    branch_status="%F{051}+"
    elif [[ -n `echo "$st" | grep "^Changes to be committed"` ]]; then
    # git commitされていないファイルがある状態
    branch_status="%F{051}!"
    elif [[ -n `echo "$st" | grep "^rebase in progress"` ]]; then
    # コンフリクトが起こった状態
    echo "%F{red}!(no branch)"
    return
  else
    # 上記以外の状態の場合は青色で表示させる
    branch_status="%F{051}"
  fi
  # ブランチ名を色付きで表示する
  result="${branch_status}[$branch_name]%f"
}

setopt prompt_subst
precmd() {
  rprompt-git-current-branch
  PROMPT='%F{049}%n%f@%F{118}%~ $result%F{153}
$%f '
}

export LSCOLORS=gxfxcxdxfxegedabagacad

export PATH=$HOME/.nodebrew/current/bin:$PATH

# --------------------
# golang
# --------------------
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export GO111MODULE=on

# --------------------
# flutter
# --------------------
export PATH=$HOME/Library/flutter/bin:$PATH

# --------------------
# python
# --------------------
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

complete -o nospace -C /usr/local/bin/mc mc
