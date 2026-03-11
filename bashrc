# ==========================================
# COLORI
# ==========================================
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ==========================================
# LOGO ASCII ART
# ==========================================
clear
echo -e "${CYAN}"
cat << 'LOGO'
  _______    _             _______          _ _         
 |__   __|  | |           |__   __|        | | |        
    | | __ _| | ___  ___     | | ___   ___ | | |____  __
    | |/ _` | |/ _ \/ __|    | |/ _ \ / _ \| | '_ \ \/ /
    | | (_| | | (_) \__ \    | | (_) | (_) | | |_) >  < 
    |_|\__,_|_|\___/|___/    |_|\___/ \___/|_|_.__/_/\_\
                                                        
LOGO
echo -e "${YELLOW}           >>> K8s AND TALOS TOOLBX <<<${NC}\n"

# ==========================================
# PROMPT TATTICO (Nome Nodo Dinamico)
# ==========================================
# \u = root
# \h = Hostname dinamico (sarà il nome del nodo K8s!)
# \w = Directory corrente
PS1="\[${YELLOW}\][Talos Toolbx]\[${NC}\] \[${RED}\]\u\[${NC}\]@\[${GREEN}\]\h\[${NC}\]:\[${CYAN}\]\w\[${NC}\]\$ "

# ==========================================
# AUTOCOMPLETAMENTO
# ==========================================
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi

command -v kubectl >/dev/null 2>&1 && source <(kubectl completion bash)
command -v talosctl >/dev/null 2>&1 && source <(talosctl completion bash)
command -v omnictl >/dev/null 2>&1 && source <(omnictl completion bash)
command -v helm >/dev/null 2>&1 && source <(helm completion bash)

# ==========================================
# ALIAS & SHORTCUTS DI SISTEMA
# ==========================================
alias k='kubectl'
complete -o default -F __start_kubectl k

alias ll='ls -lah --color=auto'
alias grep='grep --color=auto'
alias ip='ip -color=auto'
alias c='clear'