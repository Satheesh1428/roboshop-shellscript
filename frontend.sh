source common.sh

echo  -e "\e[36m>>>>>>>>>>>>>>>>>>install nginx <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
yum install nginx -y
func_exit_status

echo  -e "\e[36m>>>>>>>>>>>>>>>>>>copy roboshop configuration <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
cp nginx-roboshop.conf  /etc/nginx/default.d/roboshop.conf
func_exit_status

echo  -e "\e[36m>>>>>>>>>>>>>>>>>>remove old content <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
rm -rf /usr/share/nginx/html/*
func_exit_status

echo  -e "\e[36m>>>>>>>>>>>>>>>>>>download application content <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip
func_exit_status

cd /usr/share/nginx/html
echo  -e "\e[36m>>>>>>>>>>>>>>>>>>extract application content <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
unzip /tmp/frontend.zip
func_exit_status

echo  -e "\e[36m>>>>>>>>>>>>>>>>>>start nginx <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
systemctl enable nginx
systemctl restart nginx
func_exit_status