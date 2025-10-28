terraform init
terraform plan
terraform apply


sudo apt-get update
sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin
gcloud container clusters get-credentials eschool-cluster --zone europe-west1-b --project prodterra

kubectl get nodes

cd ansible
ansible-playbook -i inventory.ini deploy_all.yml
ansible-playbook -i inventory.ini ingr.yml

kubectl apply -f cert_issuer.yml


ansible-playbook -i inventory.ini grafana-deployment.yaml

kubectl get svc -n ingress-nginx
kubectl get ingress -n eschool

kubectl get pods -n eschool -o wide

kubectl logs -n eschool backend-7475ffbb5d-grdk9 

kubectl get svc backend -n eschool -o yaml

kubectl describe ingress eschool-ingress -n eschool

kubectl port-forward svc/backend 8080:8080 -n eschool
_____________________________________________________________________________

kubectl get svc -n ingress-nginx

nslookup -type=NS godofpentesting.pp.ua
nslookup godofpentesting.pp.ua

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml



kubectl apply -f cert_issuer.yml

ansible-playbook k8s_yaml/monitoring.yml
kubectl port-forward svc/grafana -n eschool 3000:3000
http://prometheus-operated:9090
1860
315---
1471
12740

kubectl apply -f grafana-dashboard.yml.

kubectl rollout restart deploy grafana -n eschool

http://prometheus-kube-prometheus-prometheus:9090

nslookup godofpentesting.pp.ua 8.8.8.8
dig +short godofpentesting.pp.ua @ns11.uadns.com

openssl s_client -connect 35.205.19.238:443 -servername godofpentesting.pp.ua

brave://net-internals/#hsts
