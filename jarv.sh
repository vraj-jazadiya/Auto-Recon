#!/bin/bash
# =====================================
# Advanced Auto Recon Script
# Combines best of h0tak88r + error handling & auto install
# =====================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m'

# Banner
ascii_art=''' 
┏┓┳┳┏┳┓┏┓┏┓┳┳┳┓┳┓┏┓┏┓┏┓┳┓
┣┫┃┃ ┃ ┃┃┗┓┃┃┣┫┣┫┣ ┃ ┃┃┃┃
┛┗┗┛ ┻ ┗┛┗┛┗┛┻┛┛┗┗┛┗┛┗┛┛┗  Improved Version by VrajSec
'''
echo -e "${RED}$ascii_art${RESET}"

# Tools required
TOOLS=("subfinder" "puredns" "gotator" "cero" "httpx-toolkit" "gospider" "unfurl")

# Error handler
error_handler() {
    echo -e "${RED}[!] Error at line $1 while running: $BASH_COMMAND${RESET}"
    exit 1
}
trap 'error_handler $LINENO' ERR

# Check tools
check_tools() {
    local missing=()
    echo -e "${YELLOW}[+] Checking required tools...${RESET}"
    for tool in "${TOOLS[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            missing+=("$tool")
        fi
    done

    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${RED}[-] Missing tools: ${missing[*]}${RESET}"
        echo -e "${YELLOW}[!] Installing missing tools...${RESET}"
        for tool in "${missing[@]}"; do
            case $tool in
                httpx-toolkit) go install github.com/projectdiscovery/httpx-toolkit/cmd/httpx@latest ;;
                subfinder) go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest ;;
                puredns) go install github.com/d3mondev/puredns/v2@latest ;;
                gotator) go install github.com/Josue87/gotator@latest ;;
                cero) go install github.com/glebarez/cero@latest ;;
                gospider) go install github.com/jaeles-project/gospider@latest ;;
                unfurl) go install github.com/tomnomnom/unfurl@latest ;;
            esac
        done
    else
        echo -e "${GREEN}[+] All required tools installed!${RESET}"
    fi
}

# Target
target_domain="$1"
if [ -z "$target_domain" ]; then
  echo "[+] Usage: $0 domain.com"
  exit 1
fi

# Workspace
rm -rf subs/ && mkdir subs

# ===============================
# Recon functions
# ===============================

finish_work() {
    echo "[+] Combining & resolving..."
    cat subs/* 2>/dev/null | sort -u > subs/all_subs.txt
    puredns resolve subs/all_subs.txt -r Wordlists/dns/valid_resolvers.txt -w subs/resolved.txt --skip-wildcard-filter --skip-validation &>/dev/null
    cat subs/resolved.txt | httpx-toolkit -silent -o subs/alive.txt &>/dev/null
    echo -e "${GREEN}[+] Final results in subs/alive.txt${RESET}"
}

passive_recon() {
    echo -e "${YELLOW}[+] Passive Recon...${RESET}"
    subfinder -d "$target_domain" -all -silent > subs/subfinder.txt
    curl -s "https://crt.sh/?q=%.$target_domain" | grep "$target_domain" | sort -u >> subs/crt.txt
    echo -e "${GREEN}[+] Passive recon complete${RESET}"
    finish_work
}

active_recon() {
    echo -e "${YELLOW}[+] Active Recon...${RESET}"
    puredns bruteforce Wordlists/dns/dns_2m.txt "$target_domain" -r Wordlists/dns/valid_resolvers.txt -w subs/brute.txt --skip-wildcard-filter --skip-validation &>/dev/null
    gotator -sub subs/brute.txt -perm Wordlists/dns/dns_permutations_list.txt -mindup -silent > subs/perms.txt
    cero "$target_domain" | grep "$target_domain" > subs/tls.txt
    echo -e "${GREEN}[+] Active recon complete${RESET}"
    finish_work
}

normal_recon() {
    passive_recon
    active_recon
}

quick_recon() {
    passive_recon
    cero "$target_domain" | grep "$target_domain" > subs/tls.txt
    finish_work
}

full_recon() {
    passive_recon
    active_recon
    gospider -S subs/alive.txt --js -t 50 -d 3 -w -r > subs/gospider.txt
    cat subs/gospider.txt | grep -oE "([a-zA-Z0-9_-]+\.)+$target_domain" | sort -u > subs/js_subs.txt
    finish_work
}

# ===============================
# Menu
# ===============================
check_tools

options='''Choose Recon Mode:
[1] Passive only
[2] Active only
[3] Normal (Passive + Active)
[4] Quick (No brute/perms)
[5] Full (All techniques)
'''
echo -e "$options"
read -p "Enter choice: " choice

case $choice in
    1) passive_recon ;;
    2) active_recon ;;
    3) normal_recon ;;
    4) quick_recon ;;
    5) full_recon ;;
    *) echo "Invalid choice"; exit 1 ;;
esac

echo "[+] Recon finished."
