log=/tmp/roboshop.log

echo  -e "\e[36m>>>>>>>>>>>>>>>>>>create catalogue service file <<<<<<<<<<<<<\e[0m" | tee ${log}
cp catalogue.service  /etc/systemd/system/catalogue.service &>>${log}
echo  -e "\e[36m>>>>>>>>>>>>>>>>>>create mongodb repo <<<<<<<<<<<<<\e[0m" | tee ${log}
cp mongo.repo   /etc/yum.repos.d/mongo.repo &>>${log}
echo  -e "\e[36m>>>>>>>>>>>>>>>>>>install nodejs repos <<<<<<<<<<<<<\e[0m" | tee ${log}
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log}
echo  -e "\e[36m>>>>>>>>>>>>>>>>>>install nodejs  <<<<<<<<<<<<<\e[0m"  | tee ${log}
yum install nodejs -y &>>${log}
echo  -e "\e[36m>>>>>>>>>>>>>>>>>>create application user <<<<<<<<<<<<<\e[0m" | tee ${log}
useradd roboshop &>>${log}
echo  -e "\e[36m>>>>>>>>>>>>>>>>>>remove application directory <<<<<<<<<<<<<\e[0m" | tee ${log}
rm -rf /app &>>${log} &>>${log}
echo  -e "\e[36m>>>>>>>>>>>>>>>>>>create application directory <<<<<<<<<<<<<\e[0m" | tee ${log}
mkdir /app &>>${log}
echo  -e "\e[36m>>>>>>>>>>>>>>>>>>download application content  <<<<<<<<<<<<<\e[0m" | tee ${log}
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>>${log}
echo  -e "\e[36m>>>>>>>>>>>>>>>>>>extract application content <<<<<<<<<<<<<\e[0m" | tee ${log}
cd /app
unzip /tmp/catalogue.zip &>>${log}
cd /app
echo  -e "\e[36m>>>>>>>>>>>>>>>>>>download nodejs dependencies <<<<<<<<<<<<<\e[0m" | tee ${log}
npm install &>>${log}
echo  -e "\e[36m>>>>>>>>>>>>>>>>>>install mongo client <<<<<<<<<<<<<\e[0m" | tee ${log}
yum install mongodb-org-shell -y &>>${log}
echo  -e "\e[36m>>>>>>>>>>>>>>>>>>load catalogue schema <<<<<<<<<<<<<\e[0m" | tee ${log}
mongo --host mongodb.devopsovsn.online </app/schema/catalogue.js &>>${log}
echo  -e "\e[36m>>>>>>>>>>>>>>>>>>start catalogue service <<<<<<<<<<<<<\e[0m" | tee ${log}
systemctl daemon-reload &>>${log}
systemctl enable catalogue &>>${log}
systemctl restart catalogue &>>${log}