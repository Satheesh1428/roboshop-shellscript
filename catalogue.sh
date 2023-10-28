echo  -e "\e[36m>>>>>>>>>>>>>>>>>>create catalogue service file <<<<<<<<<<<<<<<"\e[36m"
cp catalogue.service  /etc/systemd/system/catalogue.service
echo  -e "\e[36m>>>>>>>>>>>>>>>>>>create mongodb repo <<<<<<<<<<<<<<<"\e[36m"
cp mongo.repo   /etc/yum.repos.d/mongo.repo
echo  -e "\e[36m>>>>>>>>>>>>>>>>>>install nodejs repos <<<<<<<<<<<<<<<"\e[36m"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash
echo  -e "\e[36m>>>>>>>>>>>>>>>>>>install nodejs  <<<<<<<<<<<<<<<"\e[36m"
yum install nodejs -y
echo  -e "\e[36m>>>>>>>>>>>>>>>>>>create application user <<<<<<<<<<<<<<<"\e[36m"
useradd roboshop
echo  -e "\e[36m>>>>>>>>>>>>>>>>>>create application directory <<<<<<<<<<<<<<<"\e[36m"
mkdir /app
echo  -e "\e[36m>>>>>>>>>>>>>>>>>>download application content  <<<<<<<<<<<<<<<"\e[36m"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip
echo  -e "\e[36m>>>>>>>>>>>>>>>>>>extract application content <<<<<<<<<<<<<<<"\e[36m"
cd /app
unzip /tmp/catalogue.zip
cd /app
echo  -e "\e[36m>>>>>>>>>>>>>>>>>>download nodejs dependencies <<<<<<<<<<<<<<<"\e[36m"
npm install
echo  -e "\e[36m>>>>>>>>>>>>>>>>>>install mongo client <<<<<<<<<<<<<<<"\e[36m"
yum install mongodb-org-shell -y
echo  -e "\e[36m>>>>>>>>>>>>>>>>>>load catalogue schema <<<<<<<<<<<<<<<"\e[36m"
mongo --host mongodb.devopsovsn.online </app/schema/catalogue.js
echo  -e "\e[36m>>>>>>>>>>>>>>>>>>start catalogue service <<<<<<<<<<<<<<<"\e[36m"
systemctl daemon-reload
systemctl enable catalogue
systemctl restart catalogue