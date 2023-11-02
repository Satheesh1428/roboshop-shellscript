log=/tmp/roboshop.log
func_apppreq() {
    echo  -e "\e[36m>>>>>>>>>>>>>>>>>>create ${component} service file <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
    cp ${component}.service   /etc/systemd/system/${component}.service &>>${log}
    echo  -e "\e[36m>>>>>>>>>>>>>>>>>>create application user <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
    useradd roboshop &>>${log}
    echo  -e "\e[36m>>>>>>>>>>>>>>>>>>clean up existing application content <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
    rm -rf /app &>>${log}
    echo  -e "\e[36m>>>>>>>>>>>>>>>>>>create application directory <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
    mkdir /app &>>${log}
    echo  -e "\e[36m>>>>>>>>>>>>>>>>>>download application content  <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
    curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${log}
    echo  -e "\e[36m>>>>>>>>>>>>>>>>>>extract application content <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
    cd /app
    unzip /tmp/${component}.zip &>>${log}
    cd /app
}

func_systemd() {

  echo  -e "\e[36m>>>>>>>>>>>>>>>>>>start ${component} services <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
    systemctl daemon-reload &>>${log}
    systemctl enable ${component} &>>${log}
    systemctl restart ${component} &>>${log}
}

func_schema_setup() {
  if[ "${schema_type}" == "mongodb" ]; then
    echo  -e "\e[36m>>>>>>>>>>>>>>>>>>install mongo client <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
    yum install mongodb-org-shell -y &>>${log}
    echo  -e "\e[36m>>>>>>>>>>>>>>>>>>load ${component} schema <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
    mongo --host mongodb.devopsovsn.online </app/schema/${component}.js &>>${log}
  fi

  if["${schema_type}" == "mysql"]; then
    echo  -e "\e[36m>>>>>>>>>>>>>>>>>>install mysql client <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
    yum install mysql -y &>>${log}
    echo  -e "\e[36m>>>>>>>>>>>>>>>>>>load schema <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
    mysql -h mysql.devopsovsn.online -uroot -pRoboShop@1 < /app/schema/${component}.sql &>>${log}
  fi
}
func_nodejs() {
  echo  -e "\e[36m>>>>>>>>>>>>>>>>>>create mongodb repo <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
  cp mongo.repo   /etc/yum.repos.d/mongo.repo &>>${log}
  echo  -e "\e[36m>>>>>>>>>>>>>>>>>>install nodejs repos <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log}
  echo  -e "\e[36m>>>>>>>>>>>>>>>>>>install nodejs  <<<<<<<<<<<<<\e[0m"  | tee  -a ${log}
  yum install nodejs -y &>>${log}
  func_apppreq
  echo  -e "\e[36m>>>>>>>>>>>>>>>>>>download nodejs dependencies <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
  npm install &>>${log}
  func_schema_setup
  func_systemd
}

func_java() {

  echo  -e "\e[36m>>>>>>>>>>>>>>>>>>Install Maven <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
  yum install maven -y &>>${log}

  func_apppreq
  echo  -e "\e[36m>>>>>>>>>>>>>>>>>>Build ${component} service <<<<<<<<<<<<<\e[0m" | tee  -a ${log}
  mvn clean package &>>${log}
  mv target/${component}-1.0.jar ${component}.jar &>>${log}
  func_schema_setup()
  func_systemd
  }

  func_python() {
    yum install python36 gcc python3-devel -y

    func_apppreq

    pip3.6 install -r requirements.txt

    func_systemd
  }