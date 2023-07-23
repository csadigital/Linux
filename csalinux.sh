#!/bin/bash

# Renk tanımlamaları
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # Renk sıfırlama

# Fonksiyon: Gerekli araçları yükle
function install_required_tools() {
    echo -e "${GREEN}Gerekli araçlar yükleniyor...${NC}"
    sudo yum -yupdate -y 
    sudo yum -yinstall -y git curl wget
    echo -e "${GREEN}Gerekli araçlar başarıyla yüklendi.${NC}"
}

# Fonksiyon: Bash Yükleme
function install_bash() {
    echo -e "${GREEN}Bash yükleniyor...${NC}"
    wget http://ftp.gnu.org/gnu/bash/bash-4.4.18.tar.gz
    tar xf bash-4.4.18.tar.gz
    cd bash-4.4.18/
    ./configure
    make
    sudo make install
    echo -e "${GREEN}Bash başarıyla yüklendi.${NC}"
}

# Fonksiyon: Bashtop'u Sistem Monitörü olarak başlat
function start_system_monitor() {
    echo -e "${GREEN}Sistem Monitörü başlatılıyor...${NC}"
    bashtop
}

# Fonksiyon: CSF Algılama Modu Aç
function enable_csf_detection() {
    echo -e "${GREEN}CSF Algılama Modu açılıyor...${NC}"
    sudo chkconfig --levels 235 csf on
    sudo chkconfig --levels 235 lfd on
    echo -e "${GREEN}CSF Algılama Modu başarıyla açıldı.${NC}"
}

# Fonksiyon: CSF Algılama Modu Kapat
function disable_csf_detection() {
    echo -e "${GREEN}CSF Algılama Modu kapatılıyor...${NC}"
    sudo chkconfig --levels 235 csf off
    sudo chkconfig --levels 235 lfd off
    echo -e "${GREEN}CSF Algılama Modu başarıyla kapatıldı.${NC}"
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

# Fonksiyon: Hostname Değiştirme
function change_hostname() {
    echo -e "${GREEN}Yeni hostname girin: ${NC}"
    read new_hostname
    echo "$new_hostname" | sudo tee /etc/hostname
    sudo hostnamectl set-hostname "$new_hostname"
    echo -e "${GREEN}Hostname başarıyla değiştirildi.${NC}"
}

# Fonksiyon: SSH Portu Değiştirme
function change_ssh_port() {
    echo -e "${GREEN}Yeni SSH portu numarası girin: ${NC}"
    read new_ssh_port
    sudo sed -i "s/^Port .*/Port $new_ssh_port/" /etc/ssh/sshd_config
    sudo systemctl restart sshd
    echo -e "${GREEN}SSH portu başarıyla değiştirildi. Yeni port: $new_ssh_port${NC}"
}

# Fonksiyon: Litespeed Restart
function restart_litespeed() {
    echo -e "${GREEN}Litespeed yeniden başlatılıyor...${NC}"
    sudo systemctl restart lsws
    echo -e "${GREEN}Litespeed başarıyla yeniden başlatıldı.${NC}"
}

# Fonksiyon: Apache Restart
function restart_apache() {
    echo -e "${GREEN}Apache yeniden başlatılıyor...${NC}"
    sudo systemctl restart apache2
    echo -e "${GREEN}Apache başarıyla yeniden başlatıldı.${NC}"
}

# Fonksiyon: MySQL Optimize
function optimize_mysql() {
    echo -e "${GREEN}MySQL optimize işlemi gerçekleştiriliyor...${NC}"
    sudo mysqlcheck --auto-repair --optimize --all-databases
    echo -e "${GREEN}MySQL optimize işlemi tamamlandı.${NC}"
}

# Fonksiyon: cPanel Kurulumu CentOS ve AlmaLinux İçin
function install_cpanel() {
    echo -e "${GREEN}cPanel kurulumu yapılıyor...${NC}"
    cd /home
    curl -o latest -L https://securedownloads.cpanel.net/latest
    sh latest
}

# Fonksiyon: DirectAdmin Kurulumu CentOS ve AlmaLinux İçin
function install_directadmin() {
    echo -e "${GREEN}DirectAdmin kurulumu yapılıyor...${NC}"
    wget -O setup.sh https://www.directadmin.com/setup.sh
    chmod 755 setup.sh
    ./setup.sh
}

# Fonksiyon: CyberPanel Kurulumu CentOS ve AlmaLinux İçin
function install_cyberpanel() {
    echo -e "${GREEN}CyberPanel kurulumu yapılıyor...${NC}"
    sh <(curl https://cyberpanel.net/install.sh || wget -O - https://cyberpanel.net/install.sh)
}

# Fonksiyon: CentOS Web Panel (CWP) Kurulumu CentOS İçin
function install_cwp() {
    echo -e "${GREEN}CentOS Web Panel (CWP) kurulumu yapılıyor...${NC}"
    wget http://centos-webpanel.com/cwp-el7-latest
    sh cwp-el7-latest
}

# Fonksiyon: Plesk Panel Kurulumu CentOS ve AlmaLinux İçin
function install_pleskpanel() {
    echo -e "${GREEN}Plesk Panel kurulumu yapılıyor...${NC}"
    sh <(curl https://installer.plesk.com/plesk-installer || wget -O - https://installer.plesk.com/plesk-installer)
}

# Fonksiyon: Kurulumlar Menüsü
function installation_menu() {
    while true
    do
        clear
        echo -e "${CYAN}========== CSA Linux Bot - Kurulumlar Menüsü ==========${NC}"
        echo -e "${GREEN}1. cPanel Kurulumu"
        echo "2. DirectAdmin Kurulumu"
        echo "3. CyberPanel Kurulumu"
        echo "4. CentOS Web Panel (CWP) Kurulumu"
        echo "5. Plesk Panel Kurulumu"
        echo -e "0. Geri Dön${NC}"
        echo -n "Seçiminizi girin: "

        read choice

        case $choice in
            1) install_cpanel ;;
            2) install_directadmin ;;
            3) install_cyberpanel ;;
            4) install_cwp ;;
            5) install_pleskpanel ;;
            0) return ;;
            *) echo -e "${RED}Geçersiz seçim. Tekrar deneyin.${NC}" ; sleep 2 ;;
        esac

        echo -e "${CYAN}Kurulum tamamlandı! Devam etmek için Enter tuşuna basın.${NC}"
        read
    done
}

# Ana menü
function main_menu() {
    while true
    do
        clear
        echo -e "${CYAN}========== CSA Linux Bot - Linux Ayar Scripti ==========${NC}"
        echo -e "${GREEN}1. Gerekli Araçları Yükle (git, curl, wget)"
        echo "2. Bash Yükle"
        echo "3. Sistem Monitörü Olarak Başlat"
        echo "4. CSF Algılama Modu Aç"
        echo "5. CSF Algılama Modu Kapat"
        echo "6. CSF Kurulum ve Ayarlar"
        echo "7. Litespeed Ayarlar"
        echo "8. SSH Ayarlar"
        echo "9. Swap Performans Kernel"
        echo "10. CSF Katı DDoS Ayarları"
        echo "11. Gerçek disk kullanımını görme"
        echo "12. Boş RAM durumunu görme"
        echo "13. Hostname Değiştirme"
        echo "14. SSH Portu Değiştirme"
        echo "15. Litespeed Restart"
        echo "16. Apache Restart"
        echo "17. MySQL Optimize"
        echo -e "18. Kurulumlar Menüsü"
        echo -e "0. Çıkış${NC}"
        echo -n "Seçiminizi girin: "

        read choice

        case $choice in
            1) install_required_tools ;;
            2) install_bash ;;
            3) start_system_monitor ;;
            4) enable_csf_detection ;;
            5) disable_csf_detection ;;
            6) install_csf ;;
            7) configure_litespeed ;;
            8) configure_ssh ;;
            9) configure_swap_performance ;;
            10) configure_csf_ddos ;;
            11) show_disk_usage ;;
            12) show_free_ram ;;
            13) change_hostname ;;
            14) change_ssh_port ;;
            15) restart_litespeed ;;
            16) restart_apache ;;
            17) optimize_mysql ;;
            18) installation_menu ;;
            0) echo -e "${RED}Çıkış yapılıyor.${NC}" ; exit ;;
            *) echo -e "${RED}Geçersiz seçim. Tekrar deneyin.${NC}" ; sleep 2 ;;
        esac

        echo -e "${CYAN}İşlem tamamlandı! Devam etmek için Enter tuşuna basın.${NC}"
        read
    done
}

main_menu
