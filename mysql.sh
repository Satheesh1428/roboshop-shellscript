mysql_root_password=$1
if [ -z "${mysql_root_password}"  ]; then
    echo  -e "\e[36m input password is missing \e[0m"
    exit 1
fi

cp mysql.repo  /etc/yum.repos.d/mysql.repo

yum module disable mysql -y

yum install mysql-community-server -y

systemctl enable mysqld
systemctl restart mysqld

#mysql_secure_installation --set-root-pass RoboShop@1
mysql_secure_installation --set-root-pass ${mysql_root_password}
