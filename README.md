Короткий опис інфраструктури

VPC my-vpc із 2 public і 2 private сабнетами.

Bastion у public-a з зовнішнім IP (доступ лише з свого IP через фаєрвол).

Web і CI/CD інстанси у private сабнеті (без зовнішніх IP).

Cloud SQL MySQL з Private IP (VPC peering через Service Networking).

NAT для вихідного інтернет-трафіку з приватних сабнетів.

DNS managed zone для приватних записів (private A на Cloud SQL IP).

![Моя інфраструктура](diagram.png)

  Запуск проекту  :

  terraform init
  terraform plan
  terraform apply

Внести зміни отриманих IP (SQL DockerCompose та application.properties)
                          (Bastion в файлах Inventory  та key.sh and shJenkins.sh)
В директорії Ansible :
  ./key.sh                                              (Проброс ключів з хоста на   сервери)

ansible-playbook -i inventory.ini site.yml            (Установка Jenkins SWAP  Docker )

ansible-playbook -i inventory.ini push.yml           ( Свторення директорій і копіювання nginx.comf Dockercompose)

./shJenkins.sh                                          (Створюєм та рокидуєм з Сі сервера Jenkins ключі
                                                         на Bastion,Web додаєм в групу Docker)

ansible-playbook -i inventory.ini dash.yml           (Grafana,Prom,node)
ansible runner -i inventory.ini -m shell -a "systemctl status prometheus"
ansible runner -i inventory.ini -m shell -a "systemctl status node_exporter"
ansible web -i inventory.ini -m shell -a "systemctl status node_exporter"




Настроюєм дженкінс:

ssh -i /home/ubuntu/.ssh/id_rsa \
-L 8080:192.168.0.66:8080 \
-L 8082:192.168.0.67:80 \
-L 8081:192.168.0.67:8080 \
ubuntu@34.77.91.241                    (Прокидуєм зєднання відразу на СІCD сервер і на майбутьнє на web)

ssh -i /home/ubuntu/.ssh/id_rsa -J ubuntu@34.77.91.241   ubuntu@192.168.0.66 (Заходим на CICD )
sudo cat  /var/lib/jenkins/secrets/initialAdminPassword 
В  Jenkins встановлюємо Docker Pipeline  та Прописуєм креди від Docker Hub.
Сворюєм item Копіюєм Pipeline - Jenkinsfile1 або пушим з Git.-Запускаєм.


jq -n --argfile d /opt/monitoring/node_exporter_dashboard.json '{dashboard: $d, overwrite: true}' > /tmp/grafana_import.json


curl -X POST http://admin:admin@localhost:3000/api/dashboards/db \
-H "Content-Type: application/json" \
-d @/tmp/grafana_import.json


ssh -L 3000:192.168.0.66:3000 -J ubuntu@34.77.91.241 ubuntu@192.168.0.66