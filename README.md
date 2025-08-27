# Advanced Subdomain Recon Script 🔎

This script automates **subdomain enumeration, resolution, probing, screenshotting, and port scanning** for bug bounty programs.  
It is **dynamic**: you select which tasks to run (e.g., only enumeration + probing).

---

## ⚡ Features
- Subdomain enumeration (`assetfinder`, `subfinder`, `amass`)
- Domain resolution (`dnsx`)
- Alive host probing (`httpx-toolkit`)
- Screenshots (`aquatone`)
- Port scanning (`nmap`)
- Automatic **prerequisite check & install**
- **Error handling** (stops on failure, clean messages)

---

## 📦 Prerequisites
The script will install missing tools automatically:
- [assetfinder](https://github.com/tomnomnom/assetfinder)
- [subfinder](https://github.com/projectdiscovery/subfinder)
- [amass](https://github.com/OWASP/Amass)
- [dnsx](https://github.com/projectdiscovery/dnsx)
- [httpx-toolkit](https://github.com/projectdiscovery/httpx)
- [aquatone](https://github.com/michenriksen/aquatone)
- [nmap](https://nmap.org/)

Ensure you have:
- **Go** installed → `sudo apt install golang -y`
- **Git** installed → `sudo apt install git -y`

---

## 🚀 Usage
```bash
chmod +x recon.sh
./recon.sh example.com
```

You’ll be prompted to choose tasks:
```
1) Subdomain Enumeration
2) Resolve Live Domains
3) Probe for Active Hosts
4) Take Screenshots
5) Run Nmap
```

Example: To run enumeration + probe + nmap:
```
Enter tasks: 1,3,5
```

📂 Output
```
All results are stored in the results/ directory:

assetfinder.txt, subfinder.txt, amass.txt → raw subdomains

all_subdomains.txt → combined unique subdomains

resolved.txt → resolved domains

alive.txt → probed alive hosts

screenshots/ → Aquatone screenshots

nmap_scan.txt → Nmap output
```
⚠️ Disclaimer
This script is for educational & authorized bug bounty use only.
Do not use on systems without permission.

Do you want me to also **add logging + resume support** (so if script stops, you can continue from where it left off) in the next upgrade?

