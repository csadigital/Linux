#!/bin/bash

echo "CSF dosyasını indirme ve kurma işlemi başlatılıyor..."

# CSF dosyasını indirme, çıkartma ve kurma işlemi
wget -qO- https://download.configserver.com/csf.tgz | tar -xzf - && \
cd csf && \
sh install.sh

# İndirilen dosya ve klasörleri temizleme
cd ..
rm -rf csf.tgz csf

file_url="https://raw.githubusercontent.com/csadigital/Linux/main/csf.conf"
destination="/etc/csf/csf.conf"

wget -O "$destination" "$file_url"

csf -r

echo "CSF dosyası başarıyla indirildi ve kuruldu."
