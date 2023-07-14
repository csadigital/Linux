#!/bin/bash

# CPU performans ayarları
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo "performance" | tee "$cpu"
done

# Disk performans ayarları
echo "noop" > /sys/block/sda/queue/scheduler

# Swap belleği devre dışı bırakma
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

# LiteSpeed optimize etme
/usr/local/lsws/bin/lswsctrl stop
/usr/local/lsws/bin/lswsctrl start

# Imunify360 optimize etme
imunify360-agent cleanup all

# CSF optimize etme
csf -r

# CloudLinux optimize etme
cagefsctl --remount-all
ldconfig

# WHM optimize etme
/scripts/restartsrv_httpd
/scripts/restartsrv_cpsrvd
/scripts/restartsrv_mariadb
/scripts/restartsrv_named

# MariaDB optimize etme
echo "[mysqld]
performance-schema = off
innodb_buffer_pool_size = 4G
query_cache_type = 1
query_cache_limit = 2M
query_cache_size = 64M
tmp_table_size = 64M
max_heap_table_size = 64M" >> /etc/my.cnf
service mariadb restart

# PHP optimize etme
sed -i 's/memory_limit = .*/memory_limit = 256M/' /etc/php.ini
systemctl restart httpd.service

# EasyApache derlemesi ve optimize etme
cd /usr/local/cpanel/whostmgr/docroot/cgi/
./easyapache4 --build
/scripts/restartsrv_httpd

# Sistem ayarları
echo "net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 4096
net.core.somaxconn = 4096
fs.file-max = 65536
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296" >> /etc/sysctl.conf
sysctl -p

echo "fs.file-max = 65536" >> /etc/security/limits.conf
echo "* soft nofile 65536" >> /etc/security/limits.conf
echo "* hard nofile 65536" >> /etc/security/limits.conf

# Apache yapılandırması
if [ -f "/etc/httpd/conf/httpd.conf" ]; then
    sed -i 's/ServerTokens .*/ServerTokens Prod/' /etc/httpd/conf/httpd.conf
    sed -i 's/ServerSignature .*/ServerSignature Off/' /etc/httpd/conf/httpd.conf
    sed -i 's/TraceEnable .*/TraceEnable Off/' /etc/httpd/conf/httpd.conf
fi

# PHP yapılandırması
sed -i 's/expose_php = .*/expose_php = Off/' /etc/php.ini

# Firewall ayarları
SSH_PORT=2220
LSWS_PORT=7080

# SSH portunu güncelleme
sed -i "s/^TCP_IN =.*/TCP_IN = \"20,21,22,$SSH_PORT,25,53,80,110,143,443,465,587,993,995,2077,2078,2082,2083,2086,2087,2095,2096,3306,5432,5900\"/" /etc/csf/csf.conf
sed -i "s/^TCP_OUT =.*/TCP_OUT = \"20,21,22,$SSH_PORT,25,53,80,110,113,443,2077,2078,2089,2703\"/" /etc/csf/csf.conf

# LiteSpeed için port açma
sed -i "s/^TCP_IN =.*/TCP_IN = \"20,21,22,$SSH_PORT,25,53,80,110,143,443,465,587,993,995,2077,2078,2082,2083,2086,2087,2095,2096,$LSWS_PORT,3306,5432,5900\"/" /etc/csf/csf.conf
sed -i "s/^TCP_OUT =.*/TCP_OUT = \"20,21,22,$SSH_PORT,25,53,80,110,113,443,2077,2078,2089,2703,$LSWS_PORT\"/" /etc/csf/csf.conf

# CSF kurallarını yeniden yükleme
csf -r

# CSF allow IP dosyasını ekleme
curl -o /etc/csf/csf.allow https://raw.githubusercontent.com/csadigital/cPanel-Auto-Config/main/csf.allow

# Tweak Settings yapılandırmaları
if [ -f "/var/cpanel/cpanel.config" ]; then
    sed -i 's/^ALWAYS_ADD_DNSSEC_FOR_ZONES=yes/ALWAYS_ADD_DNSSEC_FOR_ZONES=no/' /var/cpanel/cpanel.config
    sed -i 's/^ALLOW_IP_ADD=2/ALLOW_IP_ADD=0/' /var/cpanel/cpanel.config
    sed -i 's/^ALLOW_ISP_CONFIG=0/ALLOW_ISP_CONFIG=1/' /var/cpanel/cpanel.config
    sed -i 's/^CPANEL=1/CPANEL=0/' /var/cpanel/cpanel.config
    sed -i 's/^USE_CPANEL_STYLE=1/USE_CPANEL_STYLE=0/' /var/cpanel/cpanel.config
    sed -i 's/^DISABLE_POP3S=0/DISABLE_POP3S=1/' /var/cpanel/cpanel.config
    sed -i 's/^DISABLE_IMAPS=0/DISABLE_IMAPS=1/' /var/cpanel/cpanel.config
    sed -i 's/^EMAIL_ALLOW_USER_CONFIG=1/EMAIL_ALLOW_USER_CONFIG=0/' /var/cpanel/cpanel.config
fi

/scripts/restartsrv_cpsrvd

# Cronjob optimizasyonu
for user in $(cut -f1 -d: /etc/passwd); do
    crontab -u $user -l | grep -v '^#' | grep -v '^$' > /tmp/cronjobs.tmp
    crontab -u $user /tmp/cronjobs.tmp
    rm -f /tmp/cronjobs.tmp
done

# PHP ve DDoS güvenlik ayarları
echo "expose_php = Off
disable_functions = show_source, system, shell_exec, passthru, exec, phpinfo, popen, proc_open, allow_url_fopen
enable_dl = Off
max_input_vars = 1000
open_basedir = /home:/tmp:/var/tmp:/usr/local/lib/php/
max_execution_time = 60
max_input_time = 60
post_max_size = 32M
upload_max_filesize = 32M
memory_limit = 256M
file_uploads = On
session.cookie_httponly = 1
session.use_only_cookies = 1
session.cookie_secure = 1" >> /etc/php.ini

echo "LimitRequestBody 10485760
Timeout 300" >> /etc/httpd/conf/httpd.conf

# Son işlemler
service httpd restart
service csf restart

echo "Optimizasyon tamamlandı."
