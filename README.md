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

ansible-playbook -i 1inventory.ini dash.yml           (Grafana,Prom,node)
ansible runner -i 1inventory.ini -m shell -a "systemctl status prometheus"
ansible runner -i 1inventory.ini -m shell -a "systemctl status node_exporter"
ansible web -i 1inventory.ini -m shell -a "systemctl status node_exporter"


./shJenkins.sh                                          (Створюєм та рокидуєм з Сі сервера Jenkins ключі
                                                          на Bastion,Web додаєм в групу Docker)

Настроюєм дженкінс:

ssh -i /home/ubuntu/.ssh/id_rsa \
-L 8080:192.168.0.66:8080 \
-L 8082:192.168.0.67:80 \
-L 8081:192.168.0.67:8080 \
ubuntu@34.38.79.215                     (Прокидуєм зєднання відразу на СІCD сервер і на майбутьнє на web)

ssh -i /home/ubuntu/.ssh/id_rsa -J ubuntu@34.140.118.2 ubuntu@192.168.0.66 (Заходим на CICD )
sudo cat  /var/lib/jenkins/secrets/initialAdminPassword 
В  Jenkins встановлюємо Docker Pipeline  та Прописуєм креди від Docker Hub.
Сворюєм item Копіюєм Pipeline - Jenkinsfile1 або пушим з Git.-Запускаєм.
