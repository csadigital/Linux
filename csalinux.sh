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
    hostnamectl set-hostname "$new_hostname"
}

# Fonksiyon: DNS Ayarları
function configure_dns() {
    echo -e "${GREEN}DNS ayarları yapılıyor...${NC}"
    read -p "Birinci DNS sunucusunu girin: " dns1
    read -p "İkinci DNS sunucusunu girin: " dns2
    echo "nameserver $dns1" | tee /etc/resolv.conf
    echo "nameserver $dns2" | tee -a /etc/resolv.conf
}

# Fonksiyon: Zaman Dilimi Ayarı
function configure_timezone() {
    echo -e "${GREEN}Zaman dilimi ayarı yapılıyor...${NC}"
    timedatectl set-timezone Europe/Istanbul
}

# Fonksiyon: SSH Root Girişi Engelleme
function disable_ssh_root_login() {
    echo -e "${GREEN}SSH root girişi engelleniyor...${NC}"
    sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    systemctl restart sshd
}

# Fonksiyon: Oturum Sonunda Kapatma Mesajı
function set_logout_message() {
    echo -e "${GREEN}Oturum sonunda kapatma mesajı ayarlanıyor...${NC}"
    read -p "Kapatma mesajını girin: " logout_message
    echo "echo \"$logout_message\"" | tee -a /etc/bash.bashrc
}

# Fonksiyon: Güvenlik İçin Gereksiz Hizmetleri Devre Dışı Bırakma
function disable_unnecessary_services() {
    echo -e "${GREEN}Güvenlik için gereksiz hizmetler devre dışı bırakılıyor...${NC}"
    services=("httpd" "sendmail" "cups" "telnet" "vsftpd")
    for service in "${services[@]}"
    do
        systemctl stop "$service"
        systemctl disable "$service"
    done
}

# Fonksiyon: Güvenlik Duvarı Ayarı
function configure_firewall() {
    echo -e "${GREEN}Güvenlik duvarı ayarları yapılıyor...${NC}"
    # Burada güvenlik duvarı ayarları için gerekli komutları ekleyin
    # Örneğin: firewall-cmd --permanent --add-port=22/tcp && firewall-cmd --reload
}

# Fonksiyon: Swap Dosyası Ayarı
function configure_swap() {
    echo -e "${GREEN}Swap dosyası ayarlanıyor...${NC}"
    read -p "Swap dosyası boyutunu MB cinsinden girin: " swap_size
    dd if=/dev/zero of=/swapfile bs=1M count="$swap_size"
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo "/swapfile none swap sw 0 0" | tee -a /etc/fstab
}

# Fonksiyon: Otomatik Paket Güncelleme ve Kurulum Ayarı
function configure_auto_updates() {
    echo -e "${GREEN}Otomatik paket güncelleme ve kurulum ayarları yapılıyor...${NC}"
    yum update -y
}

# Fonksiyon: Kötü Amaçlı Yazılım Tarayıcısı Kurulumu
function install_malware_scanner() {
    echo -e "${GREEN}Kötü amaçlı yazılım tarayıcısı kuruluyor...${NC}"
    yum install epel-release -y
    yum install clamav -y
}

# Fonksiyon: SSH Anahtar Tabanlı Kimlik Doğrulama Ayarı
function configure_ssh_key_authentication() {
    echo -e "${GREEN}SSH anahtar tabanlı kimlik doğrulama ayarlanıyor...${NC}"
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    systemctl restart sshd
}

# Fonksiyon: Oturum Süresini Ayarla
function set_session_timeout() {
    echo -e "${GREEN}Oturum süresi ayarlanıyor...${NC}"
    read -p "Dakika cinsinden oturum süresini girin: " session_timeout
    echo "TMOUT=$session_timeout" | tee -a /etc/bash.bashrc
}

# Fonksiyon: Disk Kullanımı Kontrolü
function check_disk_usage() {
    echo -e "${GREEN}Disk kullanımı kontrol ediliyor...${NC}"
    df -h
}

# Fonksiyon: Sistem Günlüklerini Temizle
function clear_system_logs() {
    echo -e "${GREEN}Sistem günlükleri temizleniyor...${NC}"
    rm -rf /var/log/*
}

# Fonksiyon: Giriş Başarısızlıklarını Günlüğe Kaydetme
function log_failed_logins() {
    echo -e "${GREEN}Giriş başarısızlıkları günlüğe kaydediliyor...${NC}"
    echo "auth,authpriv.* /var/log/auth.log" | tee -a /etc/rsyslog.conf
    systemctl restart rsyslog
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
    adduser "$new_user"
    usermod -aG wheel "$new_user"
}

# Fonksiyon: Şifre Karmaşıklığı Ayarı
function set_password_complexity() {
    echo -e "${GREEN}Şifre karmaşıklığı ayarlanıyor...${NC}"
    yum install libpwquality -y
    sed -i 's/minlen = 8/minlen = 12/' /etc/security/pwquality.conf
}

# Fonksiyon: Uzak Sunucu Bağlantıları İçin SSH Portunu Değiştirme
function change_ssh_port() {
    echo -e "${GREEN}Uzak sunucu bağlantıları için SSH portu değiştiriliyor...${NC}"
    read -p "Yeni SSH port numarasını girin: " new_port
    sed -i "s/#Port 22/Port $new_port/" /etc/ssh/sshd_config
    systemctl restart sshd
}

# Fonksiyon: Dosya ve Dizin İzinleri Ayarı
function set_file_permissions() {
    echo -e "${GREEN}Dosya ve dizin izinleri ayarlanıyor...${NC}"
    # Burada dosya ve dizin izinleri için gerekli komutları ekleyin
}

# Fonksiyon: CSF Algılama Modu Aç
function enable_csf_detection() {
    echo -e "${GREEN}CSF Algılama Modu açılıyor...${NC}"
    yum install epel-release -y
    yum install csf -y
    chkconfig csf on
    chkconfig lfd on
}

# Fonksiyon: CSF Algılama Modu Kapat
function disable_csf_detection() {
    echo -e "${GREEN}CSF Algılama Modu kapatılıyor...${NC}"
    chkconfig csf off
    chkconfig lfd off
}

# Fonksiyon: CSF Kurulum ve Ayarlar
function install_csf() {
    echo -e "${GREEN}CSF kurulumu ve ayarları yapılıyor...${NC}"
    yum install perl-libwww-perl -y
    curl -Ls https://raw.githubusercontent.com/csadigital/Linux/main/csf_install.sh | bash
}

# Fonksiyon: Litespeed Ayarlar
function configure_litespeed() {
    echo -e "${GREEN}Litespeed ayarları yapılıyor...${NC}"
    wget -O /usr/local/lsws/conf/httpd_config.xml https://raw.githubusercontent.com/csadigital/Linux/main/httpd_config.xml
    chown lsadm:lsadm /usr/local/lsws/conf/httpd_config.xml
    chmod 644 /usr/local/lsws/conf/httpd_config.xml
}

# Fonksiyon: SSH Ayarlar
function configure_ssh() {
    echo -e "${GREEN}SSH ayarları yapılıyor...${NC}"
    sed -i 's/#Port 22/Port 2220/' /etc/ssh/sshd_config
    systemctl restart sshd
}

# Fonksiyon: Swap Performans Kernel
function configure_swap_performance() {
    echo -e "${GREEN}Swap Performans Kernel ayarları yapılıyor...${NC}"
    curl -s https://raw.githubusercontent.com/csadigital/Linux/main/swap-performans | bash
}

# Fonksiyon: CSF Katı DDoS Ayarları
function configure_csf_ddos() {
    echo -e "${GREEN}CSF Katı DDoS ayarları yapılıyor...${NC}"
    curl -s https://raw.githubusercontent.com/csadigital/Linux/main/csf.conf | bash
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
