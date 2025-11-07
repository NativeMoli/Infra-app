#!/bin/bash
set -e  # зупиняє виконання при помилці

echo "=== Terraform init ==="
terraform init -input=false || exit 1

echo "=== Terraform plan ==="
terraform plan -input=false || exit 1

echo "=== Terraform apply ==="
terraform apply -auto-approve -input=false || exit 1

echo "=== Перехід у директорію Ansible ==="
cd ansible || exit 1

echo "=== Виконання key.sh ==="
yes | ./key.sh || exit 1

echo "=== Запуск Ansible site.yml ==="
ansible-playbook -i inventory.ini site.yml -v || exit 1

echo "=== Запуск Ansible push.yml ==="
ansible-playbook -i inventory.ini push.yml -v || exit 1

echo "=== Виконання shJenkins.sh ==="
yes | ./shJenkins.sh || exit 1

echo "=== Запуск Ansible dash.yml ==="
ansible-playbook -i inventory.ini dash.yml -v || exit 1

echo "✅ Усі команди виконано успішно!"
