# XMR Market Tracker

A lightweight, real-time Monero (XMR) price tracker for the terminal. It fetches data directly from the **Kraken API** and supports currency selection (EUR/USD), daily market stats, and live price-trend color-coding.

## Features
- **Real-time Updates**: Fetches the latest price every 10 seconds.
- **Dynamic Currency**: Choose between **EUR** and **USD** on startup.
- **Market Stats**: Press `p` to view 24h open price, current change, and percentage.
- **Trend Colors**: Green for price increases, Red for decreases.
- **Lag-Free UI**: Uses a background worker to ensure keyboard commands are instant.
- **Easter Egg**: A little nod to the HODLers on exit.

## Prerequisites
The script requires `curl` and `jq` to function.

### For Termux (Android)
```bash
pkg update
pkg install curl jq git -y
```

### For Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install curl jq git -y
```

### For Arch Linux
if you're on Arch, you can install the dependencies via pacman:
```bash
sudo pacman -Syu
sudo pacman -S curl jq git
```

## Installation
1. Clone:
 ```bash
 git clone https://github.com/litaliano00-dev/xmr-mt.git
 cd xmr-mt
 ```
2. Make it executable:
 ```bash
chmod +x xmr_track.sh
```
3. Run it:
   ```bash
   ./xmr_track.sh
   ```

## Usage
- Startup: The script will ask `What currency do you use? (EUR or USD):`. Type your choice and hit enter.
- In-App Commands:
    - p: View daily market statistics.
    - Ctrl + C: Safely stop the tracker and clean up temporary files.

## How it works
The script utilizes a Dual-Loop System:
1. Background Process: A "worker" function uses curl to fetch JSON data from Kraken's Public Ticker API every 10 seconds, saving it to a hidden temporary file.
2. Foreground UI: The main loop reads that file, parses it with jq, and handles user input via read. This prevents the terminal from "freezing" while waiting for an internet response.

### Made with love by litaliano00-dev and OPFTS
