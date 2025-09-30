docker run --rm -it `
  -e ANSIBLE_HOST_KEY_CHECKING=False `
  -v "${PWD}:/ansible" `
  -v "C:\Users\Moli\.ssh:/root/.ssh" `
  --workdir /ansible `
  python:3.11-alpine `
  sh -c "
    apk add --no-cache openssh-client git py3-pip bash && \
    pip install --no-cache-dir ansible ansible-lint && \
    chmod 600 /root/.ssh/id_rsa && \
    if [ -f requirements.yml ]; then ansible-galaxy install -r requirements.yml -p ./roles; fi && \
    ansible-playbook -i inventory.ini site.yml
  "
