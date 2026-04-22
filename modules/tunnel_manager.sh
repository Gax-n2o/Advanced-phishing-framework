#!/bin/bash

# ============================================
# SSH TUNNEL MANAGER MODULE
# ============================================

setup_ssh_keys() {
    echo -e "\n${COLORS[INFO]}[*] Configuring SSH keys for localhost.run...${COLORS[RESET]}"
    
    local key_path="$HOME/.ssh/localhost_run"
    
    if [[ ! -f "$key_path" ]]; then
        echo -e "${COLORS[INFO]}[*] Generating ED25519 SSH key...${COLORS[RESET]}"
        ssh-keygen -t ed25519 -f "$key_path" -C "tunnel-localhost.run" -N "" > /dev/null 2>&1
        echo -e "${COLORS[SUCCESS]}[✓] SSH key generated: $key_path${COLORS[RESET]}"
    else
        echo -e "${COLORS[SUCCESS]}[✓] SSH key already exists${COLORS[RESET]}"
    fi
    
    eval "$(ssh-agent -s)" > /dev/null 2>&1
    ssh-add "$key_path" > /dev/null 2>&1
    echo -e "${COLORS[SUCCESS]}[✓] SSH key added to agent${COLORS[RESET]}"
}

start_ssh_tunnel() {
    if [[ "$DEPLOYMENT_MODE" != "tunnel" ]]; then
        return
    fi
    
    setup_ssh_keys
    
    echo -e "\n${COLORS[INFO]}[*] Establishing SSH tunnel to localhost.run...${COLORS[RESET]}"
    echo -e "${COLORS[WARNING]}[!] This may take a few moments...${COLORS[RESET]}"
    
    local key_path="$HOME/.ssh/localhost_run"
    local tunnel_log="$LOGS_DIR/tunnel_$(date +%Y%m%d_%H%M%S).log"
    
    ssh -i "$key_path" \
        -o StrictHostKeyChecking=no \
        -o ServerAliveInterval=60 \
        -R "80:localhost:$SELECTED_PORT" \
        ssh.localhost.run 2>&1 | tee "$tunnel_log" &
    
    SSH_PID=$!
    
    echo -e "${COLORS[INFO]}[*] Waiting for tunnel...${COLORS[RESET]}"
    local attempts=0
    while [[ $attempts -lt 30 ]]; do
        if grep -q "https://.*\.lhr\.life" "$tunnel_log" 2>/dev/null; then
            TUNNEL_URL=$(grep -o 'https://[^ ]*\.lhr\.life' "$tunnel_log" | head -1)
            break
        fi
        sleep 1
        ((attempts++))
    done
    
    if [[ -n "$TUNNEL_URL" ]]; then
        echo -e "\n${COLORS[BANNER]}═══════════════════════════════════════════════════════════"
        echo -e "  TUNNEL URL: ${COLORS[SUCCESS]}$TUNNEL_URL"
        echo -e "${COLORS[BANNER]}═══════════════════════════════════════════════════════════${COLORS[RESET]}"
        echo "$TUNNEL_URL" > "$LOGS_DIR/current_url.txt"
    else
        echo -e "${COLORS[ERROR]}[✗] Failed to establish tunnel${COLORS[RESET]}"
    fi
}