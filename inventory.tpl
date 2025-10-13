[bastion]
${bastion_ip}

[kube_control_plane]
${cicd_internal_ip} ansible_host=${bastion_ip} ansible_user=${ssh_user} ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q ${ssh_user}@${bastion_ip}"'

[etcd]
${cicd_internal_ip} ansible_host=${bastion_ip} ansible_user=${ssh_user} ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q ${ssh_user}@${bastion_ip}"'

[kube_node]
${web_private_ip} ansible_host=${bastion_ip} ansible_user=${ssh_user} ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q ${ssh_user}@${bastion_ip}"'

[k8s_cluster:children]
kube_control_plane
kube_node
