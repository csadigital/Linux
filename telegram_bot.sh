#!/bin/bash

# Telegram botunuzun token'ını ve chat ID'sini burada tanımlayın
TELEGRAM_TOKEN="YOUR_TELEGRAM_BOT_TOKEN"
TELEGRAM_CHAT_ID="YOUR_TELEGRAM_CHAT_ID"

# Telegram'a mesaj gönderen fonksiyon
send_telegram_message() {
  local message="$1"
  curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" -d "chat_id=$TELEGRAM_CHAT_ID&text=$message" >/dev/null
}

# Sunucu yükünü kontrol eden fonksiyon
check_load_average() {
  local load_average=$(uptime | awk -F'load average:' '{print $2}' | xargs)
  local threshold=3.0

  if (( $(echo "$load_average >= $threshold" | bc -l) )); then
    local message="Sunucu yükü yüksek! Load Average: $load_average"
    send_telegram_message "$message"
  fi
}

# Ana programı çalıştır
check_load_average
