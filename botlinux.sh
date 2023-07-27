#!/bin/bash

# Gerekli paketleri yükle
sudo yum install -y sysstat jq gnuplot

# Sunucu monitor scriptini oluştur
cat << 'EOF' > server_monitor.sh
#!/bin/bash

# Scriptin çalıştığı dizin
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Telegram botunuzun token'ı ve chat ID'si için varsayılan değerler
TELEGRAM_TOKEN=""
TELEGRAM_CHAT_ID=""

# Gnuplot komut dosyasının şablonu
gnuplot_script_template='
set terminal pngcairo enhanced font "arial,10" fontscale 1.0 size 800, 600
set output "%s"
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set format x "%H:%M:%S"
set xlabel "Time"
set ylabel "%s"
plot "%s" using 1:2 with lines title "%s"
'

# 48 saatlik verileri saklayacak dosya
log_file="$BASE_DIR/server_monitor_log.txt"

# Gnuplot için grafik dosyası adı
graph_file="$BASE_DIR/graph.png"

# İstatistikleri belirli aralıklarla alacak fonksiyon
get_current_stats() {
  local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  local load=$(uptime | awk '{print $10 $11 $12}')
  local netstat=$(cat /proc/net/dev | awk '/eth0/{print $2, $3}')
  local ramstat=$(free | awk '/Mem/{print $3}')
  local cpustat=$(top -bn 1 | grep "Cpu(s)" | awk '{print 100 - $8}')
  echo "$timestamp|$load|$netstat|$ramstat|$cpustat"
}

# İstatistikleri dosyaya kaydeden fonksiyon
append_to_log_file() {
  echo "$1" >> "$log_file"
}

# Telegram mesajı gönderen fonksiyon
send_telegram_message() {
  local message="$1"
  if [ ! -z "$TELEGRAM_TOKEN" ] && [ ! -z "$TELEGRAM_CHAT_ID" ]; then
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
      -d "chat_id=$TELEGRAM_CHAT_ID" \
      -d "text=$message"
  fi
}

# Gnuplot komut dosyası oluşturan fonksiyon
generate_gnuplot_script() {
  local title="$1"
  local ylabel="$2"
  local datafile="$3"
  printf "$gnuplot_script_template" "$graph_file" "$ylabel" "$datafile" "$title" > "$BASE_DIR/gnuplot_script.plt"
}

# Scriptin kurulumu
setup() {
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

# Scriptin çalıştırılması
start() {
  source "$BASE_DIR/telegram_config.sh"

  # Veri toplama ve grafik çizme döngüsü
  while true; do
    # Şu anki istatistikleri al
    current_stats=$(get_current_stats)

    # Verileri dosyaya ekle
    append_to_log_file "$current_stats"

    # Grafik çiz
    gnuplot "$BASE_DIR/gnuplot_script.plt"

    # 5 saniyede bir döngüyü tekrarla
    sleep 5
  done
}

# Scriptin durdurulması
stop() {
  pkill -f "$BASE_DIR/server_monitor.sh"
}

# Başlangıçta kurulumu yap
setup

# Kullanıcıya sunucuyu başlatma seçeneği sun
while true; do
  select choice in "Başlat" "Durdur" "Çıkış"; do
    case "$choice" in
      "Başlat")
        start &
        echo "Sunucu Monitor başlatıldı. Grafik dosyası: $BASE_DIR/graph.png"
        break
        ;;
      "Durdur")
        stop
        echo "Sunucu Monitor durduruldu."
        break
        ;;
      "Çıkış")
        exit 0
        ;;
      *)
        echo "Geçersiz seçenek."
        ;;
    esac
  done
done
EOF

# Scriptleri çalıştırılabilir hale getir
chmod +x server_monitor.sh

echo "Kurulum tamamlandı. Sunucu monitorü başlatmak için sunucuyu yeniden başlatın."
