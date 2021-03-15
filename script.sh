#!/bin/bash
sudo -i
cd /root
echo "Install packets"
yum install -y redhat-lsb-core wget rpmdevtools rpm-build createrepo yum-utils gcc
echo "Wget nginx"
wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm
echo "Install srm"
rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm
echo "Wget openssl"
wget https://www.openssl.org/source/latest.tar.gz
tar -xvf latest.tar.gz
echo "Install dependies"
yum-builddep -y rpmbuild/SPECS/nginx.spec
echo "Copy nginx.spec"
cp -f /vagrant/nginx.spec /root/rpmbuild/SPECS/
echo "Build nginx"
rpmbuild -bb rpmbuild/SPECS/nginx.spec
ls -l rpmbuild/RPMS/x86_64/
echo "Install nginx"
yum localinstall -y rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
systemctl start nginx
systemctl status nginx
echo "Mkdir repo"
mkdir /usr/share/nginx/html/repo
cp rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /usr/share/nginx/html/repo/
echo "Wget percona"
cp -f /vagrant/percona-release-0.1-9.noarch.rpm /usr/share/nginx/html/repo/
createrepo /usr/share/nginx/html/repo/
nginx -t
nginx -s reload
curl -a http://localhost/repo/
cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF
yum repolist enabled | grep otus
yum list | grep otus
yum install percona-release -y
