#!/bin/bash

# Gerekli paketleri yükle
sudo yum install -y sysstat jq gnuplot

# Scriptin çalıştığı dizin
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Telegram botunuzun token'ı ve chat ID'si için varsayılan değerler
TELEGRAM_TOKEN=""
TELEGRAM_CHAT_ID=""

# Gnuplot komut dosyasının şablonu
gnuplot_script_template='
set terminal dumb ansi 120 40
set autoscale
set xlabel "Time"
set ylabel "%s"
plot "-" using 1:2 with lines title "%s"
'

# 48 saatlik verileri saklayacak dosya
log_file="$BASE_DIR/server_monitor_log.txt"

# İstatistikleri belirli aralıklarla alacak fonksiyon
get_current_stats() {
  local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  local load=$(uptime | awk '{print $10 $11 $12}')
  local netstat=$(cat /proc/net/dev | awk '/eth0/{print $2, $3}')
  local ramstat=$(free | awk '/Mem/{print $3}')
  local cpustat=$(top -bn 1 | grep "Cpu(s)" | awk '{print 100 - $8}')
  echo "$timestamp|$load|$netstat|$ramstat|$cpustat"
}

# Verileri ekrana gösteren fonksiyon
show_stats_on_screen() {
  local title="$1"
  local ylabel="$2"
  gnuplot -persist <<- EOF
    set title "$title"
    set ylabel "$ylabel"
    plot "$log_file" using 1:2 with lines title "Load Average", \
         "" using 1:5 with lines title "CPU Usage (%)", \
         "" using 1:4 with lines title "RAM Usage"
EOF
}

# İstatistikleri dosyaya kaydeden fonksiyon
append_to_log_file() {
  echo "$1" >> "$log_file"
}

# Gnuplot komut dosyası oluşturan fonksiyon
generate_gnuplot_script() {
  local title="$1"
  local ylabel="$2"
  local datafile="$3"
  printf "$gnuplot_script_template" "$ylabel" "$title" > "$BASE_DIR/gnuplot_script.plt"
}

# Sunucu monitorü başlatma fonksiyonu
start_server_monitor() {
  source "$BASE_DIR/telegram_config.sh"

  # Veri toplama ve ekrana grafik çizme döngüsü
  while true; do
    # Şu anki istatistikleri al
    current_stats=$(get_current_stats)

    # Verileri dosyaya ekle
    append_to_log_file "$current_stats"

    # Grafikleri ekranda göster
    clear
    show_stats_on_screen "Server Monitor" "Percentage (%)"
    
    # 5 saniyede bir döngüyü tekrarla
    sleep 5
  done
}

# Sunucu monitorü kurulum fonksiyonu
setup_server_monitor() {
  # Gnuplot komut dosyasını oluştur
  generate_gnuplot_script "Load Average" "Load" "$log_file"

  # 48 saatlik log dosyasını temizle ve başlık ekler
  echo "Timestamp|Load Average|Network Rx|Network Tx|RAM Usage|CPU Usage (%)" > "$log_file"

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
