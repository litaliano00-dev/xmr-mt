cat << 'EOF' > xmr_track.sh
#!/bin/bash

# ==============================================================================
# Project:  XMR Market Tracker (Kraken API)
# Author:   litaliano00-dev (https://github.com/litaliano00-dev/)
# License:  MIT
# ==============================================================================

# --- Configuration ---
TEMP_FILE=".xmr_data.tmp"
INTERVAL=10

# --- Colors ---
G='\033[0;32m' # Green
R='\033[0;31m' # Red
B='\033[0;34m' # Blue
Y='\033[1;33m' # Yellow
NC='\033[0m'   # No Color

# --- Start Screen ---
clear
echo -e "${B}What currency do you use? (EUR or USD):${NC}"
printf "> "
read -r USER_CURR
USER_CURR=${USER_CURR^^}

# Validate Selection
if [[ "$USER_CURR" == "USD" ]]; then
    PAIR="XMRUSD"
else
    PAIR="XMREUR"
    USER_CURR="EUR"
fi

echo -e "\n${B}Made by litaliano00-dev (https://github.com/litaliano00-dev/)${NC}"
echo -e "Tracking Kraken ${Y}XMR/${USER_CURR}${NC}... [p] for Stats | [Ctrl+C] to Exit\n"

# --- Functions ---

# Background worker to fetch market data
fetch_data() {
    while true; do
        curl -s "https://api.kraken.com/0/public/Ticker?pair=$PAIR" > "$TEMP_FILE"
        sleep "$INTERVAL"
    done
}

# Cleanup on exit
cleanup() {
    kill "$BG_PID" 2>/dev/null
    rm -f "$TEMP_FILE"
    echo -e "\n${Y}Keep hodling. See you later!${NC}"
    exit 0
}

# --- Main Logic ---
trap cleanup SIGINT SIGTERM

fetch_data &
BG_PID=$!
LAST_PRICE=""

while true; do
    # 1. Input Listener (for [p] stats)
    read -s -n 1 -t 0.2 key
    if [[ $key == "p" || $key == "P" || $key == $'\x10' ]]; then
        if [[ -f "$TEMP_FILE" ]]; then
            CUR=$(jq -r '.result[] | .c[0]' "$TEMP_FILE")
            OPN=$(jq -r '.result[] | .o' "$TEMP_FILE")
            DIF=$(awk -v c="$CUR" -v o="$OPN" 'BEGIN { printf "%.2f", c-o }')
            PCT=$(awk -v c="$CUR" -v o="$OPN" 'BEGIN { printf "%.2f", ((c-o)/o)*100 }')
            
            COLOR=$([[ $(awk -v d="$DIF" 'BEGIN{print (d>=0)}') -eq 1 ]] && echo "$G" || echo "$R")
            echo -e "\n${B}[24h Stats]${NC} Open: $OPN | Now: $CUR | Change: ${COLOR}${DIF} (${PCT}%)${NC}"
        fi
    fi

    # 2. Display Logic
    if [[ -f "$TEMP_FILE" ]]; then
        NEW_P=$(jq -r '.result[] | .c[0]' "$TEMP_FILE" 2>/dev/null)
        
        if [[ -n "$NEW_P" && "$NEW_P" != "null" && "$NEW_P" != "$LAST_PRICE" ]]; then
            TIME=$(date +"%H:%M:%S")
            
            # Trend Color
            if [[ -z "$LAST_PRICE" ]]; then CLR=$NC;
            elif (( $(awk -v n="$NEW_P" -v l="$LAST_PRICE" 'BEGIN{print (n>l)}') )); then CLR=$G;
            else CLR=$R; fi
            
            echo -e "[$TIME] 1 XMR = ${CLR}${USER_CURR} $NEW_P${NC}"
            LAST_PRICE="$NEW_P"
        fi
    fi
done
EOF
chmod +x xmr_track.sh
./xmr_track.sh
