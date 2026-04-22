#!/bin/bash

# ============================================
# DEPENDENCY CHECKER MODULE
# ============================================

check_dependencies() {
    echo -e "\n${COLORS[INFO]}[*] Checking system dependencies...${COLORS[RESET]}"
    
    local deps=("php" "ssh" "curl" "qrencode" "jq" "sqlite3" "xxd")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
            echo -e "${COLORS[WARNING]}[!] Missing: $dep${COLORS[RESET]}"
        else
            echo -e "${COLORS[SUCCESS]}[✓] Found: $dep${COLORS[RESET]}"
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "\n${COLORS[WARNING]}[?] Install missing dependencies? (y/n)${COLORS[RESET]}"
        read -p "Choice: " choice
        if [[ "$choice" == "y" ]]; then
            sudo apt-get update
            sudo apt-get install -y "${missing[@]}"
            echo -e "${COLORS[SUCCESS]}[✓] Dependencies installed${COLORS[RESET]}"
        else
            echo -e "${COLORS[ERROR]}[✗] Required dependencies missing. Exiting.${COLORS[RESET]}"
            exit 1
        fi
    fi
}