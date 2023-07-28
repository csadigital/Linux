#!/bin/bash

# Gerekli paketleri yükle
sudo yum install -y sysstat jq gnuplot

# Scriptin çalıştığı dizin
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Telegram botunuzun token'ı ve chat ID'si için varsayılan değerler
TELEGRAM_TOKEN=""
TELEGRAM_CHAT_ID=""

# 48 saatlik verileri saklayacak dosya
log_file="$BASE_DIR/server_monitor_log.txt"

# Gnuplot komut dosyasının şablonu
gnuplot_script_template='
set terminal dumb ansi 120 40 enhanced
set autoscale
set xlabel "Time"
set ylabel "Load Average"
set key autotitle columnheader
plot "-" using 1:2 with lines
'

# Telegram bot script dosyası
telegram_bot_script='
#!/bin/bash

# Telegram botunuzun token'ı ve chat ID'sini burada tanımlayın
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
'

# İstatistikleri belirli aralıklarla alacak fonksiyon
get_current_stats() {
  local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  local load=$(uptime | awk '{print $10 $11 $12}')
  echo "$timestamp|$load"
}

# İstatistikleri dosyaya kaydeden fonksiyon
append_to_log_file() {
  echo "$1" >> "$log_file"
}

# Gnuplot komut dosyası oluşturan fonksiyon
generate_gnuplot_script() {
  printf "$gnuplot_script_template" > "$BASE_DIR/gnuplot_script.plt"
}

# Sunucu yükünü kontrol eden fonksiyon
check_load_average() {
  local load_average=$(uptime | awk -F'load average:' '{print $2}' | xargs)
  local threshold=3.0

  if (( $(echo "$load_average >= $threshold" | bc -l) )); then
    local message="Sunucu yükü yüksek! Load Average: $load_average"
    bash -c "send_telegram_message '$message'"
  fi
}

# Sunucu monitorü başlatma fonksiyonu
start_server_monitor() {
  source "$BASE_DIR/telegram_config.sh"

  # Gnuplot komut dosyasını oluştur
  generate_gnuplot_script

  # 48 saatlik log dosyasını temizle ve başlık ekler
  echo "Timestamp|Load Average" > "$log_file"

  # Veri toplama ve tablo ile gösterme döngüsü
  while true; do
    # Şu anki istatistikleri al
    current_stats=$(get_current_stats)

    # Verileri dosyaya ekle
    append_to_log_file "$current_stats"

    # Grafikleri ekranda göster
    clear
    echo "Sunucu Monitörü - Yük Dağılımı"
    cat "$log_file" | tail -n 10 | gnuplot --persist "$BASE_DIR/gnuplot_script.plt"

    # Yüksek yükü kontrol et ve Telegram bildirim gönder
    bash -c "$telegram_bot_script"

    # 5 saniyede bir döngüyü tekrarla
    sleep 5
  done
}

# Sunucu monitorü kurulum fonksiyonu
setup_server_monitor() {
  # Telegram bot ayarlarını kullanıcıdan al
  read -p "Telegram Bot Token (boş bırakarak devre dışı bırakın): " TELEGRAM_TOKEN
  read -p "Telegram Chat ID (boş bırakarak devre dışı bırakın): " TELEGRAM_CHAT_ID

  # Telegram bot ayarlarını dosyaya kaydet
  echo -e "TELEGRAM_TOKEN=\"$TELEGRAM_TOKEN\"\nTELEGRAM_CHAT_ID=\"$TELEGRAM_CHAT_ID\"" > "$BASE_DIR/telegram_config.sh"

  # Scriptin çalıştırılması için crontab'a ekle
  (crontab -l 2>/dev/null; echo "@reboot $BASE_DIR/server_monitor.sh start") | crontab -
}

# Sunucu monitorü durdurma fonksiyonu
stop_server_monitor() {
  pkill -f "$BASE_DIR/server_monitor.sh"
}

# Scriptin ana menüsü
while true; do
  echo "1. Sunucu Monitorü Başlat"
  echo "2. Sunucu Monitorü Durdur"
  echo "3. Çıkış"
  read -p "Seçiminizi yapın (1/2/3): " choice

  case "$choice" in
    1)
      setup_server_monitor
      start_server_monitor &
      echo "Sunucu Monitor başlatıldı."
      ;;
    2)
      stop_server_monitor
      echo "Sunucu Monitor durduruldu."
      ;;
    3)
      echo "Çıkış yapılıyor..."
      exit 0
      ;;
    *)
      echo "Geçersiz seçenek. Lütfen tekrar deneyin."
      ;;
  esac

  echo
done
