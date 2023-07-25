#!/bin/bash

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

function enable_csf_detection() {
    echo -e "${GREEN}CSF Algılama Modu açılıyor...${NC}"
    chkconfig --levels 235 csf on
    chkconfig --levels 235 lfd on
}

function disable_csf_detection() {
    echo -e "${GREEN}CSF Algılama Modu kapatılıyor...${NC}"
    chkconfig --levels 235 csf off
    chkconfig --levels 235 lfd off
}

function install_csf() {
    echo -e "${GREEN}CSF kurulumu ve ayarları yapılıyor...${NC}"
    curl -Ls https://raw.githubusercontent.com/csadigital/Linux/main/csfinstall.sh | bash
}

function configure_litespeed() {
    echo -e "${GREEN}Litespeed ayarları yapılıyor...${NC}"
    wget -O /usr/local/lsws/conf/httpd_config.xml https://raw.githubusercontent.com/csadigital/Linux/main/httpd_config.xml
    chown lsadm:lsadm /usr/local/lsws/conf/httpd_config.xml
    chmod 644 /usr/local/lsws/conf/httpd_config.xml
}

function configure_ssh() {
    echo -e "${GREEN}SSH ayarları yapılıyor...${NC}"
    sudo sed -i 's/#Port 22/Port 2220/' /etc/ssh/sshd_config
    sudo systemctl restart sshd
}

function configure_swap_performance() {
    echo -e "${GREEN}Swap Performans Kernel ayarları yapılıyor...${NC}"
    bash <(wget -qO- https://raw.githubusercontent.com/csadigital/Linux/main/swap-performans)
}

function configure_csf_ddos() {
    echo -e "${GREEN}CSF Katı DDoS ayarları yapılıyor...${NC}"
    bash <(wget -qO- https://raw.githubusercontent.com/csadigital/Linux/main/csf.conf)
}

function show_disk_usage() {
    echo -e "${GREEN}Gerçek disk kullanımı gösteriliyor...${NC}"
    df -h
}

function show_free_ram() {
    echo -e "${GREEN}Boş RAM durumu gösteriliyor...${NC}"
    free -h
}

function install_cpanel() {
    echo -e "${GREEN}cPanel kurulumu yapılıyor...${NC}"
    curl -o latest -L https://securedownloads.cpanel.net/latest
    sh latest
}

function install_directadmin() {
    echo -e "${GREEN}DirectAdmin kurulumu yapılıyor...${NC}"
    wget -O directadmin.sh https://www.directadmin.com/setup.sh
    chmod 755 directadmin.sh
    ./directadmin.sh
}

function install_cyberpanel() {
    echo -e "${GREEN}CyberPanel kurulumu yapılıyor...${NC}"
    sudo su - -c "sh <(curl https://cyberpanel.net/install.sh || wget -O - https://cyberpanel.net/install.sh)"
}

function install_plesk() {
    echo -e "${GREEN}Plesk Panel kurulumu yapılıyor...${NC}"
    curl -fsSL https://installer.plesk.com/one-click-installer | sh
}

function automatic_upgrade() {
    echo -e "${GREEN}Otomatik yükseltme yapılıyor...${NC}"
    sudo yum -y update
    sudo yum -y upgrade
    echo -e "${GREEN}Otomatik yükseltme tamamlandı.${NC}"
}

function restart_apache() {
    echo -e "${GREEN}Apache yeniden başlatılıyor...${NC}"
    sudo systemctl restart httpd
    echo -e "${GREEN}Apache başarıyla yeniden başlatıldı.${NC}"
}

function installation_menu() {
    clear
    echo -e "${CYAN}========== Kurulumlar Menüsü ==========${NC}"
    echo "1. cPanel Kurulumu"
    echo "2. DirectAdmin Kurulumu"
    echo "3. CyberPanel Kurulumu"
    echo "4. Plesk Panel Kurulumu"
    echo "0. Ana Menüye Dön"
    echo -n "Seçiminizi girin: "

    read choice

    case $choice in
        1) install_cpanel ;;
        2) install_directadmin ;;
        3) install_cyberpanel ;;
        4) install_plesk ;;
        0) main_menu ;;
        *) echo -e "${GREEN}Geçersiz seçim. Tekrar deneyin.${NC}" ; sleep 2 ; installation_menu ;;
    esac

    echo -e "${CYAN}İşlem tamamlandı! Ana menüye dönülüyor...${NC}"
    sleep 2
    main_menu
}

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
    echo "10. Kurulumlar Menüsü"
    echo "11. Otomatik Yükseltme (yum update & upgrade)"
    echo "12. Apache Yeniden Başlat"
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
        10) installation_menu ;;
        11) automatic_upgrade ;;
        12) restart_apache ;;
        0) exit ;;
        *) echo -e "${GREEN}Geçersiz seçim. Tekrar deneyin.${NC}" ; sleep 2 ; main_menu ;;
    esac

    echo -e "${CYAN}İşlem tamamlandı! Ana menüye dönülüyor...${NC}"
    sleep 2
    main_menu
}

main_menu
