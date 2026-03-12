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
_talos_toolbx_welcome() {
    sleep 1
    echo -e "${CYAN}"
    cat << 'LOGO'
  _______    _             _______          _ _         
 |__   __|  | |           |__   __|        | | |        
    | | __ _| | ___  ___     | | ___   ___ | | |____  __
    | |/ _` | |/ _ \/ __|    | |/ _ \ / _ \| | '_ \ \/ /
    | | (_| | | (_) \__ \    | | (_) | (_) | | |_) >  < 
    |_|\__,_|_|\___/|___/    |_|\___/ \___/|_|_.__/_/\_\
                                                        
LOGO
    echo -e "${YELLOW}           >>> K8S & TALOS TOOLBX <<<${NC}\n"
    unset PROMPT_COMMAND
}

PROMPT_COMMAND="_talos_toolbx_welcome"

# ==========================================
# PROMPT (Dynamic Node Name)
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
# LINSTOR / DRBD WRAPPERS
# ==========================================
drbdadm() {
    local SAT_ID=$(crictl ps --name satellite --state Running -q 2>/dev/null | head -n 1)
    
    if [ -z "$SAT_ID" ]; then
        echo -e "${RED}❌ Error: Linstor Satellite container not found on this node.${NC}"
        echo -e "${YELLOW}Tip: Use 'drbdsetup status' to inspect the raw kernel module instead.${NC}"
        return 1
    fi
    
    crictl exec -i -t "$SAT_ID" drbdadm "$@" | awk '
        /Thank you for participating/ { in_survey=1; next }
        in_survey && /user to install this version/ { in_survey=0; next }
        in_survey { next }
        !started && /^[[:space:]]*$/ { next }
        { started=1; print }
    '
}

# ==========================================
# CLEANUP TRAP (Paranoid Mode)
# ==========================================
cleanup_credentials() {
    echo -e "\n${YELLOW}🧹 Erasing local credentials before exit...${NC}"
    rm -rf ~/.kube ~/.talos
    echo -e "${GREEN}✅ Clean! See ya Space Cowboy.${NC}"
}
trap cleanup_credentials EXIT

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
    echo -e "${YELLOW}📥 Generating Headless Kubernetes Service Account for cluster '${OMNI_CLUSTER_NAME}' via Omni...${NC}"
    mkdir -p ~/.kube
    
    rm -f ~/.kube/config
    
    omnictl kubeconfig --service-account -c "$OMNI_CLUSTER_NAME" --user "talos-toolbx-admin" ~/.kube/config
    
    if [ -f ~/.kube/config ]; then
        echo -e "${GREEN}✅ kubectl is now connected via native Service Account token!${NC}"
    else
        echo -e "${RED}❌ Failed to generate kubeconfig!${NC}"
    fi
}

alias load-talos='get-talosconfig'
alias load-kube='get-kubeconfig'