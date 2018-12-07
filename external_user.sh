## Install prerequisites.
apt-get update && apt-get install -y apt-transport-https ca-certificates curl software-properties-common zsh zsh-syntax-highlighting

# Create .zshrc file for zsh
cat <<EOF >~/.zshrc
export TERM=linux
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
if [ $commands[kubectl] ]; then
  source <(kubectl completion zsh)
fi
# PROMPT='%F{cyan}%n%f@%F{cyan}%m%f %F{red}%1~%f %# '
PROMPT='%F{cyan}%m%f %F{red}%1~%f %# '
# The following two lines should be the last one in the .zshrc file
# zsh-syntax-highlighting should be at the end of this file
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
EOF

sudo chown $(id -u cisco):$(id -g cisco) $HOME/.zshrc
# Make zsh the default shell for cisco user
chsh -s $(which zsh) cisco
zsh
export TERM=linux

