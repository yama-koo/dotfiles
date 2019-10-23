source ~/.zplug/init.zsh

zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "rupa/z", use:z.sh

if [ -e /usr/local/share/zsh-completions ]; then
    fpath=(/usr/local/share/zsh-completions $fpath)
fi

export HISTFILE=~/.zsh_history
export HISTSIZE=1000
export SAVEHIST=100000
setopt EXTENDED_HISTORY
setopt append_history

alias ls='ls -FG'
alias dir='ls -FG'
alias cd..='cd ..'
alias cls='clear'
alias cks='cls'
alias grep='grep --color=auto'
alias history='history 1'

alias r='ruby'

alias fzf='fzf --ansi --height 40% --reverse'
alias c='code .'
alias codef='code `ls -a | fzf`'
alias vimf='vim `find . -maxdepth 1 -type f | fzf`'
alias cdf='cd `find . -maxdepth 1 -type d | fzf`'
alias catf='cat `find . -maxdepth 1 -type f | fzf`'
alias zf="cd \`z | fzf | awk '{print \$2}'\`"

# --------------------
# docker
# --------------------
alias dc='docker-compose'
alias dce="dc exec \`dc ps --services --filter status=running | fzf\`"
alias dp='docker ps'
alias di='docker images'
alias dv='docker volume ls'
alias log="dc logs -f \`dc ps --services --filter status=running | fzf\`"

# --------------------
# kubectl
# --------------------
alias kp='kubectl get pods'
alias kd="kubectl describe pod \`kp | fzf | awk '{print \$1}'\`"
alias ks='kubectl get services'
alias knsls='kubectl get ns'
alias kns="kubectl config set-context $(kubectl config current-context) --namespace=\`knsls | fzf | awk '{print \$1}'\`"
alias ke="kubectl exec -it \`kp | fzf | awk '{print \$1}'\`"
alias klog="kubectl logs \`kp | fzf | awk '{print \$1}'\`"

# --------------------
# gcloud
# --------------------
alias gccl='gcloud container clusters list'
alias cred="gcloud container clusters get-credentials --region \`gccl | fzf | awk '{print \$2,\$1}'\`"
alias gpls='gcloud projects list'
alias gpro="gcloud config set project \`gpls | fzf | awk '{print \$1}'\`"
alias gals='gcloud auth list'
alias gsa="gcloud config set account \`gals | rg @ | fzf | awk '{print \$2}'\`"

# --------------------
# gsutil
# --------------------
alias gsls='gsutil ls'
alias gslsf="gsls \`gsls | fzf | awk '{print \$1}'\`"

bindkey "^[[3~" delete-char

autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# --------------------
# git
# --------------------
alias gr='git reset --hard'
function rprompt-git-current-branch {
  local dir branch_name st branch_status
  # local result
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
  # branch_name=`git rev-parse --abbrev-ref HEAD 2> /dev/null`
  branch_name=`git rev-parse --abbrev-ref HEAD 2> /dev/null`
  st=`git status 2> /dev/null`
  if [[ -n `echo "$st" | grep "^nothing to"` ]]; then
    # 全てcommitされてクリーンな状態
    branch_status="%F{051}"
  elif [[ -n `echo "$st" | grep "^Untracked files"` ]]; then
    # gitに管理されていないファイルがある状態
    # branch_status="%F{red}?"
    branch_status="%F{051}?"
  elif [[ -n `echo "$st" | grep "^Changes not staged for commit"` ]]; then
    # git addされていないファイルがある状態
    # branch_status="%F{164}+"
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
  # echo "${branch_status}[$branch_name]"
  result="${branch_status}[$branch_name]"
}

function branch() {
  if [ ! -e  ".git" ]; then
    # gitで管理されていないディレクトリは何も返さない
    return
  fi
  branch=`git branch | grep "\*" | awk "{print \$2}"`
}

setopt prompt_subst
precmd() {
  # branch
  rprompt-git-current-branch
  # print -P "%F{049}%n%f@%F{118}%~${branch_status}[$branch_name]"
  print -P '%F{049}%n%f@%F{118}%~ $result'
}
# RPROMPT='`rprompt-git-current-branch`'
PROMPT='%F{153}$ '

export LSCOLORS=gxfxcxdxfxegedabagacad

export PATH=$HOME/.nodebrew/current/bin:$PATH

# --------------------
# golang
# --------------------
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export GO111MODULE=on

zplug load

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/mc mc
