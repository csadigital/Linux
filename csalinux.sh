#!/bin/bash

# Renkli yazılar için renk tanımlamaları
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Fonksiyon: CSF Algılama Modu Aç
function enable_csf_detection() {
    echo -e "${GREEN}CSF Algılama Modu açılıyor...${NC}"
    chkconfig --levels 235 csf on
    chkconfig --levels 235 lfd on
}

# Fonksiyon: CSF Algılama Modu Kapat
function disable_csf_detection() {
    echo -e "${GREEN}CSF Algılama Modu kapatılıyor...${NC}"
    chkconfig --levels 235 csf off
    chkconfig --levels 235 lfd off
}

# Fonksiyon: CSF Kurulum ve Ayarlar
function install_csf() {
    echo -e "${GREEN}CSF kurulumu ve ayarları yapılıyor...${NC}"
    curl -Ls https://raw.githubusercontent.com/csadigital/Linux/main/csfinstall.sh | bash
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

# Fonksiyon: Gerçek disk kullanımını görme
function show_disk_usage() {
    echo -e "${GREEN}Gerçek disk kullanımı gösteriliyor...${NC}"
    df -h
}

# Fonksiyon: Boş RAM durumunu görme
function show_free_ram() {
    echo -e "${GREEN}Boş RAM durumu gösteriliyor...${NC}"
    free -h
}

# Ana menü
function main_menu() {
    clear
    echo -e "${CYAN}========== CSA Linux Bot - Linux Ayar Scripti ==========${NC}"
    echo "1. CSF Algılama Modu Aç"
    echo "2. CSF Algılama Modu Kapat"
    echo "3. CSF Kurulum ve Ayarlar"
    echo "4. Litespeed Ayarlar"
    echo "5. SSH Ayarlar"
    echo "6. Swap Performans Kernel"
    echo "7. CSF Katı DDoS Ayarları"
    echo "8. Gerçek disk kullanımını görme"
    echo "9. Boş RAM durumunu görme"
    echo "0. Çıkış"
    echo -n "Seçiminizi girin: "

    read choice

    case $choice in
        1) enable_csf_detection ;;
        2) disable_csf_detection ;;
        3) install_csf ;;
        4) configure_litespeed ;;
        5) configure_ssh ;;
        6) configure_swap_performance ;;
        7) configure_csf_ddos ;;
        8) show_disk_usage ;;
        9) show_free_ram ;;
        0) exit ;;
        *) echo -e "${GREEN}Geçersiz seçim. Tekrar deneyin.${NC}" ; sleep 2 ; main_menu ;;
    esac

    echo -e "${CYAN}İşlem tamamlandı! Ana menüye dönülüyor...${NC}"
    sleep 2
    main_menu
}

main_menu
