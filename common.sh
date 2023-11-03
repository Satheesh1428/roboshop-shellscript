log=/tmp/roboshop.log
func_exit_status() {
  if [ $? -eq 0 ]; then
        echo  -e "\e[32m success \e[0m"
  else
        echo  -e "\e[31m unsuccess \e[0m"
  fi
}
func_apppreq() {
    echo  -e "\e[36m>>>>>>>>>>>>>>>>>>create ${component} service file <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
    cp ${component}.service   /etc/systemd/system/${component}.service &>>${log}
    func_exit_status
    echo  -e "\e[36m>>>>>>>>>>>>>>>>>>create application user <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
    id roboshop
    if [ $? -ne 0 ]; then
       useradd roboshop &>>${log}
    fi
    func_exit_status
    echo  -e "\e[36m>>>>>>>>>>>>>>>>>>clean up existing application content <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
    rm -rf /app &>>${log}
    func_exit_status
    echo  -e "\e[36m>>>>>>>>>>>>>>>>>>create application directory <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
    mkdir /app &>>${log}
    func_exit_status
    echo  -e "\e[36m>>>>>>>>>>>>>>>>>>download application content  <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
    curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${log}
    func_exit_status
    echo  -e "\e[36m>>>>>>>>>>>>>>>>>>extract application content <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
    cd /app
    unzip /tmp/${component}.zip &>>${log}
    func_exit_status
    cd /app
}

func_systemd() {

  echo  -e "\e[36m>>>>>>>>>>>>>>>>>>start ${component} services <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
    systemctl daemon-reload &>>${log}
    systemctl enable ${component} &>>${log}
    systemctl restart ${component} &>>${log}
    func_exit_status
}

func_schema_setup() {
  if [ "${schema_type}" == "mongodb" ] ;    then
    echo  -e "\e[36m>>>>>>>>>>>>>>>>>>install mongo client <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
    yum install mongodb-org-shell -y &>>${log}
    echo  -e "\e[36m>>>>>>>>>>>>>>>>>>load ${component} schema <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
    mongo --host mongodb.devopsovsn.online </app/schema/${component}.js &>>${log}
    func_exit_status
  fi

  if [ "${schema_type}" == "mysql" ]; then
    echo  -e "\e[36m>>>>>>>>>>>>>>>>>>install mysql client <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
    yum install mysql -y &>>${log}
    echo  -e "\e[36m>>>>>>>>>>>>>>>>>>load schema <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
    mysql -h mysql.devopsovsn.online -uroot -pRoboShop@1 < /app/schema/${component}.sql &>>${log}
    func_exit_status
  fi

}
func_nodejs() {
  echo  -e "\e[36m>>>>>>>>>>>>>>>>>>create mongodb repo <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
  cp mongo.repo   /etc/yum.repos.d/mongo.repo &>>${log}
  func_exit_status
  echo  -e "\e[36m>>>>>>>>>>>>>>>>>>install nodejs repos <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log}
  func_exit_status
  echo  -e "\e[36m>>>>>>>>>>>>>>>>>>install nodejs  <<<<<<<<<<<<<\e[0m"  | tee  -a ${log}
  yum install nodejs -y &>>${log}
  func_exit_status
  func_apppreq
  echo  -e "\e[36m>>>>>>>>>>>>>>>>>>download nodejs dependencies <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
  npm install &>>${log}
  func_exit_status
  func_schema_setup
  func_systemd
}

func_java() {

  echo  -e "\e[36m>>>>>>>>>>>>>>>>>>Install Maven <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
  yum install maven -y &>>${log}
  func_exit_status
  func_apppreq
  echo  -e "\e[36m>>>>>>>>>>>>>>>>>>Build ${component} service <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
  mvn clean package &>>${log}
  func_exit_status
  mv target/${component}-1.0.jar ${component}.jar &>>${log}
  func_exit_status
  func_schema_setup
  func_systemd
  }

  func_python() {
    yum install python36 gcc python3-devel -y
    func_exit_status
    func_apppreq
    pip3.6 install -r requirements.txt
    func_exit_status
    func_systemd
  }