#!/bin/bash
# Возьмем пакет nginx и соберем его с поддержкой openssl
sudo -i
cd /root
# Устнановим необходимые пакеты
yum install -y redhat-lsb-core wget rpmdevtools rpm-build createrepo yum-utils gcc
# Скачаем srpm пакет nginx
wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm
# Создадим в директории /root дерево каталогов для сборки
rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm
#Скачаем последний исходник для openssl и распакуем его
wget https://www.openssl.org/source/openssl-1.1.1j.tar.gz
tar -xvf openssl-1.1.1j.tar.gz
#Установим все зависимости, чтобы избежать ошибок при сборке
yum-builddep -y rpmbuild/SPECS/nginx.spec
#Скопируем заранее подготовленный spec файл nginx с нужными опциями
cp -f /vagrant/nginx.spec /root/rpmbuild/SPECS/
#Собираем nginx и проверяем, что пакеты собрались
rpmbuild -bb rpmbuild/SPECS/nginx.spec
ls -l rpmbuild/RPMS/x86_64/
#Устанавливаем nginx и проверяем его запуск
yum localinstall -y rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
systemctl start nginx
systemctl status nginx
#Создаем репозиторий. Создадим каталог repo в директории статики nginx
mkdir /usr/share/nginx/html/repo
#Копируем в созданный каталог наш собранный rpm и заранее скаченный rpm для установки репозитория percona-server
cp rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /usr/share/nginx/html/repo/
cp -f /vagrant/percona-release-0.1-9.noarch.rpm /usr/share/nginx/html/repo/
#Инициализируем репозиторий
createrepo /usr/share/nginx/html/repo/
#Для прозрачности настроим в nginx доступ к листингу каталога:
sed -i -e 's/location \/ {/location \/ {\nautoindex on;/g' /etc/nginx/conf.d/default.conf
#Проверяем синтаксис и перезапускаем nginx
nginx -t
nginx -s reload
curl -a http://localhost/repo/
#Добавим репозиторий в /etc/yum.repos.d
cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF
#Проверим, что репозиторий подключен и проверим его содержимое
yum repolist enabled | grep otus
yum list | grep otus
# #Установим percona-release
yum install percona-release -y
