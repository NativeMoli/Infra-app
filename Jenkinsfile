pipeline {
    agent any
    environment {
        SSH_KEY_ID = 'jenkins-ssh-key' // ключ Jenkins для доступу до web
        WEB_SERVER = 'web'             // alias з SSH config (192.168.0.66 через bastion)
        APP_DIR = '/opt/app'
        FRONTEND_REPO = 'git@github.com:NativeMoli/frontend.git'
        BACKEND_REPO  = 'git@github.com:NativeMoli/backend.git'
        BRANCH = 'Dockerfile'          // гілка для обох репозиторіїв
    }
    stages {
        stage('Deploy from GitHub') {
            steps {
                sshagent([env.SSH_KEY_ID]) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ubuntu@${WEB_SERVER} '
                      # Створимо директорії
                      mkdir -p ${APP_DIR}/frontend ${APP_DIR}/backend

                      # Клон або оновлення фронтенду
                      cd ${APP_DIR}/frontend
                      if [ -d .git ]; then
                          git fetch --all
                          git checkout ${BRANCH}
                          git reset --hard origin/${BRANCH}
                      else
                          git clone -b ${BRANCH} ${FRONTEND_REPO} .
                      fi

                      # Клон або оновлення бекенду
                      cd ${APP_DIR}/backend
                      if [ -d .git ]; then
                          git fetch --all
                          git checkout ${BRANCH}
                          git reset --hard origin/${BRANCH}
                      else
                          git clone -b ${BRANCH} ${BACKEND_REPO} .
                      fi

                      # Запуск docker-compose
                      cd ${APP_DIR}
                      docker-compose down
                      docker-compose up -d --build
                    '
                    """
                }
            }
        }
    }
}
