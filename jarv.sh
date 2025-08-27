#!/bin/bash

# ===============================
# Advanced Subdomain Recon Script
# ===============================
# Author: Vraj Jazadiya
# Description: Automated subdomain enumeration, resolution, probing, and screenshotting for bug bounty
# Error handling + prereq installation included

set -euo pipefail
IFS=$'\n\t'

# -------------------------------
# FUNCTIONS
# -------------------------------

banner() {
    echo -e "\n=================================="
    echo " 🔎 Advanced Subdomain Recon Tool "
    echo "=================================="
}

check_and_install() {
    local tool=$1
    local install_cmd=$2
    if ! command -v "$tool" &>/dev/null; then
        echo "[!] $tool not found. Installing..."
        eval "$install_cmd" || { echo "[-] Failed to install $tool. Please install manually."; exit 1; }
    else
        echo "[+] $tool is already installed."
    fi
}

ask_tasks() {
    echo -e "\nSelect the tasks you want to perform (e.g., 1,3,5):"
    echo "1) Subdomain Enumeration (assetfinder, subfinder, amass)"
    echo "2) Resolve Live Domains (dnsx)"
    echo "3) Probe for Active Hosts (httpx-toolkit)"
    echo "4) Take Screenshots (aquatone)"
    echo "5) Run Nmap on Alive Hosts"
    read -rp "Enter tasks: " tasks
    echo "$tasks"
}

run_task() {
    local task=$1
    case $task in
        1)
            echo "[*] Running Subdomain Enumeration..."
            assetfinder --subs-only "$DOMAIN" | tee results/assetfinder.txt
            subfinder -d "$DOMAIN" -silent | tee results/subfinder.txt
            amass enum -passive -d "$DOMAIN" | tee results/amass.txt
            sort -u results/*.txt > results/all_subdomains.txt
            ;;
        2)
            echo "[*] Resolving Live Domains..."
            dnsx -silent -i results/all_subdomains.txt -o results/resolved.txt
            ;;
        3)
            echo "[*] Probing Alive Hosts with httpx-toolkit..."
            httpx-toolkit -l results/resolved.txt -silent -o results/alive.txt
            ;;
        4)
            echo "[*] Taking Screenshots with Aquatone..."
            cat results/alive.txt | aquatone -out results/screenshots
            ;;
        5)
            echo "[*] Running Nmap on Alive Hosts..."
            nmap -iL results/alive.txt -T4 -oN results/nmap_scan.txt
            ;;
        *)
            echo "[-] Invalid task: $task"
            ;;
    esac
}

# -------------------------------
# MAIN SCRIPT
# -------------------------------

banner

if [ $# -lt 1 ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

DOMAIN=$1
mkdir -p results

# ✅ Prerequisite checks
check_and_install assetfinder "go install github.com/tomnomnom/assetfinder@latest"
check_and_install subfinder "go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
check_and_install amass "sudo apt install -y amass"
check_and_install dnsx "go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
check_and_install httpx-toolkit "go install github.com/projectdiscovery/httpx/cmd/httpx@latest"
check_and_install aquatone "go install github.com/michenriksen/aquatone@latest"
check_and_install nmap "sudo apt install -y nmap"

# ✅ Ask user for task selection
TASKS=$(ask_tasks)

# ✅ Run selected tasks
for t in $(echo "$TASKS" | tr ',' ' '); do
    run_task "$t"
done

echo -e "\n✅ Recon completed. Results saved in 'results/' directory."
