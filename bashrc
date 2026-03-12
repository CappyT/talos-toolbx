# ==========================================
# COLORS
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
# TACTICAL PROMPT (Dynamic Node Name)
# ==========================================
PS1="\[${YELLOW}\][Talos Toolbx]\[${NC}\] \[${RED}\]\u\[${NC}\]@\[${GREEN}\]\h\[${NC}\]:\[${CYAN}\]\w\[${NC}\]\$ "

# ==========================================
# AUTOCOMPLETION
# ==========================================
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi

command -v kubectl >/dev/null 2>&1 && source <(kubectl completion bash)
command -v talosctl >/dev/null 2>&1 && source <(talosctl completion bash)
command -v omnictl >/dev/null 2>&1 && source <(omnictl completion bash)
command -v helm >/dev/null 2>&1 && source <(helm completion bash)

# ==========================================
# SYSTEM ALIASES & SHORTCUTS
# ==========================================
alias k='kubectl'
complete -o default -F __start_kubectl k

alias ll='ls -lah --color=auto'
alias grep='grep --color=auto'
alias ip='ip -color=auto'
alias c='clear'

# ==========================================
# SIDERO OMNI INTEGRATION
# ==========================================

get-talosconfig() {
    if [ -z "$OMNI_CLUSTER_NAME" ]; then
        echo -e "${RED}❌ Error: OMNI_CLUSTER_NAME is not set in the config file!${NC}"
        return 1
    fi
    echo -e "${YELLOW}📥 Downloading talosconfig for cluster '${OMNI_CLUSTER_NAME}' via Omni...${NC}"
    mkdir -p ~/.talos
    omnictl talosconfig -c "$OMNI_CLUSTER_NAME" 
    echo -e "${GREEN}✅ talosctl is now armed!${NC}"
}

get-kubeconfig() {
    if [ -z "$OMNI_CLUSTER_NAME" ]; then
        echo -e "${RED}❌ Error: OMNI_CLUSTER_NAME is not set in the config file!${NC}"
        return 1
    fi
    echo -e "${YELLOW}📥 Downloading kubeconfig for cluster '${OMNI_CLUSTER_NAME}' via Omni...${NC}"
    mkdir -p ~/.kube
    omnictl kubeconfig -c "$OMNI_CLUSTER_NAME"
    
    # ---------------------------------------------------------
    # Omni generates an oidc-login flow by default, which needs a browser.
    # But Omni's K8s proxy accepts the SA Key directly as a Bearer Token!
    # We rewrite the kubeconfig user to bypass the browser prompt.
    # ---------------------------------------------------------
    if [ -n "$OMNI_SERVICE_ACCOUNT_KEY" ]; then
        echo -e "${YELLOW}🔧 Optimizing kubeconfig for headless Service Account access...${NC}"
        CURRENT_CTX=$(kubectl config current-context)
        kubectl config set-credentials omni-headless-sa --token="$OMNI_SERVICE_ACCOUNT_KEY" >/dev/null
        kubectl config set-context "$CURRENT_CTX" --user=omni-headless-sa >/dev/null
    fi
    
    echo -e "${GREEN}✅ kubectl is now connected via Omni!${NC}"
}

alias load-talos='get-talosconfig'
alias load-kube='get-kubeconfig'