#!/bin/bash

# Renkli yazılar için renk tanımlamaları
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Fonksiyon: Hostname Ayarı
function configure_hostname() {
    echo -e "${GREEN}Hostname ayarı yapılıyor...${NC}"
    read -p "Yeni hostname girin: " new_hostname
    sudo hostnamectl set-hostname "$new_hostname"
}

# Fonksiyon: DNS Ayarları
function configure_dns() {
    echo -e "${GREEN}DNS ayarları yapılıyor...${NC}"
    read -p "Birinci DNS sunucusunu girin: " dns1
    read -p "İkinci DNS sunucusunu girin: " dns2
    sudo echo "nameserver $dns1" | sudo tee /etc/resolv.conf
    sudo echo "nameserver $dns2" | sudo tee -a /etc/resolv.conf
}

# Fonksiyon: Zaman Dilimi Ayarı
function configure_timezone() {
    echo -e "${GREEN}Zaman dilimi ayarı yapılıyor...${NC}"
    sudo dpkg-reconfigure tzdata
}

# Fonksiyon: SSH Root Girişi Engelleme
function disable_ssh_root_login() {
    echo -e "${GREEN}SSH root girişi engelleniyor...${NC}"
    sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    sudo systemctl restart sshd
}

# Fonksiyon: Oturum Sonunda Kapatma Mesajı
function set_logout_message() {
    echo -e "${GREEN}Oturum sonunda kapatma mesajı ayarlanıyor...${NC}"
    read -p "Kapatma mesajını girin: " logout_message
    echo "echo \"$logout_message\"" | sudo tee -a /etc/bash.bashrc
}

# Fonksiyon: Güvenlik İçin Gereksiz Hizmetleri Devre Dışı Bırakma
function disable_unnecessary_services() {
    echo -e "${GREEN}Güvenlik için gereksiz hizmetler devre dışı bırakılıyor...${NC}"
    services=("apache2" "sendmail" "cups" "telnet" "ftp")
    for service in "${services[@]}"
    do
        sudo systemctl stop "$service"
        sudo systemctl disable "$service"
    done
}

# Fonksiyon: Güvenlik Duvarı Ayarı
function configure_firewall() {
    echo -e "${GREEN}Güvenlik duvarı ayarları yapılıyor...${NC}"
    # Burada güvenlik duvarı ayarları için gerekli komutları ekleyin
    # Örneğin: sudo ufw allow 22 (SSH için izin verme)
}

# Fonksiyon: Swap Dosyası Ayarı
function configure_swap() {
    echo -e "${GREEN}Swap dosyası ayarlanıyor...${NC}"
    read -p "Swap dosyası boyutunu MB cinsinden girin: " swap_size
    sudo dd if=/dev/zero of=/swapfile bs=1M count="$swap_size"
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab
}

# Fonksiyon: Otomatik Paket Güncelleme ve Kurulum Ayarı
function configure_auto_updates() {
    echo -e "${GREEN}Otomatik paket güncelleme ve kurulum ayarları yapılıyor...${NC}"
    sudo apt-get update && sudo apt-get upgrade -y
}

# Fonksiyon: Kötü Amaçlı Yazılım Tarayıcısı Kurulumu
function install_malware_scanner() {
    echo -e "${GREEN}Kötü amaçlı yazılım tarayıcısı kuruluyor...${NC}"
    sudo apt-get install clamav -y
}

# Fonksiyon: SSH Anahtar Tabanlı Kimlik Doğrulama Ayarı
function configure_ssh_key_authentication() {
    echo -e "${GREEN}SSH anahtar tabanlı kimlik doğrulama ayarlanıyor...${NC}"
    sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
    sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    sudo systemctl restart sshd
}

# Fonksiyon: Oturum Süresini Ayarla
function set_session_timeout() {
    echo -e "${GREEN}Oturum süresi ayarlanıyor...${NC}"
    read -p "Dakika cinsinden oturum süresini girin: " session_timeout
    echo "TMOUT=$session_timeout" | sudo tee -a /etc/bash.bashrc
}

# Fonksiyon: Disk Kullanımı Kontrolü
function check_disk_usage() {
    echo -e "${GREEN}Disk kullanımı kontrol ediliyor...${NC}"
    df -h
}

# Fonksiyon: Sistem Günlüklerini Temizle
function clear_system_logs() {
    echo -e "${GREEN}Sistem günlükleri temizleniyor...${NC}"
    sudo rm -rf /var/log/*
}

# Fonksiyon: Giriş Başarısızlıklarını Günlüğe Kaydetme
function log_failed_logins() {
    echo -e "${GREEN}Giriş başarısızlıkları günlüğe kaydediliyor...${NC}"
    sudo echo "auth,authpriv.* /var/log/auth.log" | sudo tee -a /etc/rsyslog.conf
    sudo systemctl restart rsyslog
}

# Fonksiyon: Güvenlik Duvarı Loglarını Günlüğe Kaydetme
function log_firewall_events() {
    echo -e "${GREEN}Güvenlik duvarı logları günlüğe kaydediliyor...${NC}"
    # Burada güvenlik duvarı loglarını günlüğe kaydetmek için gerekli komutları ekleyin
}

# Fonksiyon: Güvenlik için Root Olmayan Kullanıcı Oluşturma
function create_new_user() {
    echo -e "${GREEN}Güvenlik için root olmayan kullanıcı oluşturuluyor...${NC}"
    read -p "Yeni kullanıcı adını girin: " new_user
    sudo adduser "$new_user"
    sudo usermod -aG sudo "$new_user"
}

# Fonksiyon: Şifre Karmaşıklığı Ayarı
function set_password_complexity() {
    echo -e "${GREEN}Şifre karmaşıklığı ayarlanıyor...${NC}"
    sudo apt-get install libpam-pwquality -y
    sudo sed -i 's/# minlen = 8/minlen = 12/' /etc/security/pwquality.conf
}

# Fonksiyon: Uzak Sunucu Bağlantıları İçin SSH Portunu Değiştirme
function change_ssh_port() {
    echo -e "${GREEN}Uzak sunucu bağlantıları için SSH portu değiştiriliyor...${NC}"
    read -p "Yeni SSH port numarasını girin: " new_port
    sudo sed -i "s/#Port 22/Port $new_port/" /etc/ssh/sshd_config
    sudo systemctl restart sshd
}

# Fonksiyon: Dosya ve Dizin İzinleri Ayarı
function set_file_permissions() {
    echo -e "${GREEN}Dosya ve dizin izinleri ayarlanıyor...${NC}"
    # Burada dosya ve dizin izinleri için gerekli komutları ekleyin
}

# Fonksiyon: CSF Algılama Modu Aç
function enable_csf_detection() {
    echo -e "${GREEN}CSF Algılama Modu açılıyor...${NC}"
    sudo chkconfig --levels 235 csf on
    sudo chkconfig --levels 235 lfd on
}

# Fonksiyon: CSF Algılama Modu Kapat
function disable_csf_detection() {
    echo -e "${GREEN}CSF Algılama Modu kapatılıyor...${NC}"
    sudo chkconfig --levels 235 csf off
    sudo chkconfig --levels 235 lfd off
}

# Fonksiyon: CSF Kurulum ve Ayarlar
function install_csf() {
    echo -e "${GREEN}CSF kurulumu ve ayarları yapılıyor...${NC}"
    curl -Ls https://raw.githubusercontent.com/csadigital/Linux/main/csfinstall.sh | sudo bash
}

# Fonksiyon: Litespeed Ayarlar
function configure_litespeed() {
    echo -e "${GREEN}Litespeed ayarları yapılıyor...${NC}"
    sudo wget -O /usr/local/lsws/conf/httpd_config.xml https://raw.githubusercontent.com/csadigital/Linux/main/httpd_config.xml
    sudo chown lsadm:lsadm /usr/local/lsws/conf/httpd_config.xml
    sudo chmod 644 /usr/local/lsws/conf/httpd_config.xml
}

# Fonksiyon: SSH Ayarlar
function configure_ssh() {
    echo -e "${GREEN}SSH ayarları yapılıyor...${NC}"
    sudo sed -i 's/#Port 22/Port 2220/' /etc/ssh/sshd_config
    sudo systemctl restart sshd
}

# Fonksiyon: Swap Performans Kernel
function configure_swap_performance() {
    echo -e "${GREEN}Swap Performans Kernel ayarları yapılıyor...${NC}"
    bash <(wget -qO- https://raw.githubusercontent.com/csadigital/Linux/main/swap-performans)
}

# Fonksiyon: CSF Katı DDoS Ayarları
function configure_csf_ddos() {
    echo -e "${GREEN}CSF Katı DDoS ayarları yapılıyor...${NC}"
    bash <(wget -qO- https://raw.githubusercontent.com/csadigital/Linux/main/csf.conf)
}

 

# Ana menü
function main_menu() {
    clear
    echo -e "${CYAN}========== Linux Ayar Scripti ==========${NC}"
    echo -e "${CYAN}1. Hostname Ayarı"
    echo -e "${CYAN}2. DNS Ayarları"
    echo -e "${CYAN}3. Zaman Dilimi Ayarı"
    echo -e "${CYAN}4. SSH Root Girişi Engelleme"
    echo -e "${CYAN}5. Oturum Sonunda Kapatma Mesajı"
    echo -e "${CYAN}6. Güvenlik İçin Gereksiz Hizmetleri Devre Dışı Bırakma"
    echo -e "${CYAN}7. Güvenlik Duvarı Ayarı"
    echo -e "${CYAN}8. Swap Dosyası Ayarı"
    echo -e "${CYAN}9. Otomatik Paket Güncelleme ve Kurulum Ayarı"
    echo -e "${CYAN}10. Kötü Amaçlı Yazılım Tarayıcısı Kurulumu"
    echo -e "${CYAN}11. SSH Anahtar Tabanlı Kimlik Doğrulama Ayarı"
    echo -e "${CYAN}12. Oturum Süresini Ayarla"
    echo -e "${CYAN}13. Disk Kullanımı Kontrolü"
    echo -e "${CYAN}14. Sistem Günlüklerini Temizle"
    echo -e "${CYAN}15. Giriş Başarısızlıklarını Günlüğe Kaydetme"
    echo -e "${CYAN}16. Güvenlik Duvarı Loglarını Günlüğe Kaydetme"
    echo -e "${CYAN}17. Güvenlik için Root Olmayan Kullanıcı Oluşturma"
    echo -e "${CYAN}18. Şifre Karmaşıklığı Ayarı"
    echo -e "${CYAN}19. Uzak Sunucu Bağlantıları İçin SSH Portunu Değiştirme"
    echo -e "${CYAN}20. Dosya ve Dizin İzinleri Ayarı"
    echo -e "${CYAN}21. CSF Algılama Modu Aç"
    echo -e "${CYAN}22. CSF Algılama Modu Kapat"
    echo -e "${CYAN}23. CSF Kurulum ve Ayarlar"
    echo -e "${CYAN}24. Litespeed Ayarlar"
    echo -e "${CYAN}25. SSH Ayarlar"
    echo -e "${CYAN}26. Swap Performans Kernel"
    echo -e "${CYAN}27. CSF Katı DDoS Ayarları"
    echo -e "${CYAN}0. Çıkış"
    echo -n "Seçiminizi girin: "

    read choice

    case $choice in
        1) configure_hostname ;;
        2) configure_dns ;;
        3) configure_timezone ;;
        4) disable_ssh_root_login ;;
        5) set_logout_message ;;
        6) disable_unnecessary_services ;;
        7) configure_firewall ;;
        8) configure_swap ;;
        9) configure_auto_updates ;;
        10) install_malware_scanner ;;
        11) configure_ssh_key_authentication ;;
        12) set_session_timeout ;;
        13) check_disk_usage ;;
        14) clear_system_logs ;;
        15) log_failed_logins ;;
        16) log_firewall_events ;;
        17) create_new_user ;;
        18) set_password_complexity ;;
        19) change_ssh_port ;;
        20) set_file_permissions ;;
        21) enable_csf_detection ;;
        22) disable_csf_detection ;;
        23) install_csf ;;
        24) configure_litespeed ;;
        25) configure_ssh ;;
        26) configure_swap_performance ;;
        27) configure_csf_ddos ;;
        0) exit ;;
        *) echo -e "${RED}Geçersiz seçim. Tekrar deneyin.${NC}" ; sleep 2 ; main_menu ;;
    esac

    echo -e "${CYAN}İşlem tamamlandı! Ana menüye dönülüyor...${NC}"
    sleep 2
    main_menu
}

main_menu
