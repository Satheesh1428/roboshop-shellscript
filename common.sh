nodejs() {
  log=/tmp/roboshop.log
  echo  -e "\e[36m>>>>>>>>>>>>>>>>>>create user service file <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
  cp ${component}.service  /etc/systemd/system/${component}.service &>>${log}
  echo  -e "\e[36m>>>>>>>>>>>>>>>>>>create mongodb repo <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
  cp mongo.repo   /etc/yum.repos.d/mongo.repo &>>${log}
  echo  -e "\e[36m>>>>>>>>>>>>>>>>>>install nodejs repos <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log}
  echo  -e "\e[36m>>>>>>>>>>>>>>>>>>install nodejs  <<<<<<<<<<<<<\e[0m"  | tee  -a ${log}
  yum install nodejs -y &>>${log}
  echo  -e "\e[36m>>>>>>>>>>>>>>>>>>create application user <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
  ${component}add roboshop &>>${log}
  echo  -e "\e[36m>>>>>>>>>>>>>>>>>>remove application directory <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
  rm -rf /app &>>${log} &>>${log}
  echo  -e "\e[36m>>>>>>>>>>>>>>>>>>create application directory <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
  mkdir /app &>>${log}
  echo  -e "\e[36m>>>>>>>>>>>>>>>>>>download application content  <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
  curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${log}
  echo  -e "\e[36m>>>>>>>>>>>>>>>>>>extract application content <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
  cd /app
  unzip /tmp/${component}.zip &>>${log}
  cd /app
  echo  -e "\e[36m>>>>>>>>>>>>>>>>>>download nodejs dependencies <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
  npm install &>>${log}
  echo  -e "\e[36m>>>>>>>>>>>>>>>>>>install mongo client <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
  yum install mongodb-org-shell -y &>>${log}
  echo  -e "\e[36m>>>>>>>>>>>>>>>>>>load user schema <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
  mongo --host mongodb.devopsovsn.online </app/schema/${component}.js &>>${log}
  echo  -e "\e[36m>>>>>>>>>>>>>>>>>>start user service <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
  systemctl daemon-reload &>>${log}
  systemctl enable ${component} &>>${log}
  systemctl restart ${component} &>>${log}
}