export LSCOLORS=gaFxcxdxbxegedabagacad

export PS1="[\w] \[\e[0;32m\](\$(git branch 2>/dev/null | grep '^*' | colrm 1 2))\[\e[m\] > "

function out () {
    asciiquarium
}

# start-up applications to call from the CLI
function start () {
    open -a "Google Chrome"
    open -a "Microsoft Outlook"
    open -a "Microsoft Teams"
}

function iterm2_print_user_vars() {
  iterm2_set_user_var gitBranch $((git branch 2> /dev/null) | grep \* | cut -c3-)
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


complete -C /usr/local/bin/vault vault

source ~/git-completion.bash

# custom executables
export PATH="$PATH:/Users/zallin/executables"
# node8 via homebrew
export PATH="$PATH:/usr/local/opt/node@8/bin"

# allow multithreading for python ansible code
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
