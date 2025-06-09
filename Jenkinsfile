pipeline {
    // Jalankan pipeline di agent Jenkins manapun yang tersedia
    agent any

    // Definisikan variabel lingkungan yang akan digunakan di seluruh pipeline
    environment {
        // Ganti 'your_dockerhub_username' dengan username Docker Hub Anda
        DOCKER_HUB_USERNAME = 'azeshion21'
        // Nama image Docker yang akan kita bangun
        DOCKER_IMAGE_NAME = "${DOCKER_HUB_USERNAME}/python-flask-app"
        // Alamat IP atau DNS dari server deployment Anda
        DEPLOY_SERVER = '103.187.147.44'
        // Username untuk login ke server deployment
        DEPLOY_USER = 'orion'
    }

    stages {
        // Tahap 1: Checkout kode dari repository Git
        stage('Checkout') {
            steps {
                echo 'Checking out code...'
                // Jenkins akan secara otomatis mengambil kode dari SCM yang dikonfigurasi
                checkout scm
            }
        }

        // Tahap 2: Build Image Docker
        stage('Build Docker Image') {
            steps {
                echo "Building Docker image: ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                // Memberi tag image dengan nomor build Jenkins untuk keunikan
                sh "docker build -t ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER} ."
            }
        }

        // Tahap 3: Login ke Docker Hub
        stage('Login to Docker Hub') {
            steps {
                echo 'Logging in to Docker Hub...'
                // Menggunakan credentials yang sudah disimpan di Jenkins
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh "docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}"
                }
            }
        }
        
        // Tahap 4: Push Image ke Docker Hub
        stage('Push Docker Image') {
            steps {
                echo "Pushing image ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER} to Docker Hub..."
                sh "docker push ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                
                // (Opsional) Beri juga tag 'latest' pada image yang berhasil
                echo "Tagging image as latest..."
                sh "docker tag ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER} ${DOCKER_IMAGE_NAME}:latest"
                sh "docker push ${DOCKER_IMAGE_NAME}:latest"
            }
        }
        
        // Tahap 5: Deploy ke Server
        stage('Deploy to Server') {
            steps {
                echo "Deploying to server: ${env.DEPLOY_SERVER}"
                // Menggunakan SSH agent untuk mengeksekusi perintah di server remote
                sshagent(credentials: ['deploy-server-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${env.DEPLOY_USER}@${env.DEPLOY_SERVER} << 'EOF'
                        
                        # Hentikan dan hapus container lama jika ada
                        docker stop python-app || true
                        docker rm python-app || true
                        
                        # Tarik image terbaru dari Docker Hub
                        docker pull ${DOCKER_IMAGE_NAME}:latest
                        
                        # Jalankan container baru dengan image yang baru ditarik
                        docker run -d --name python-app -p 80:5000 ${DOCKER_IMAGE_NAME}:latest
                        
                        echo "Deployment complete!"
                        exit
                        EOF
                    """
                }
            }
        }
    }
    
    // Blok post-build akan selalu dijalankan setelah semua stage selesai
    post {
        always {
            // Logout dari Docker Hub untuk menjaga kebersihan
            echo 'Logging out from Docker Hub...'
            sh 'docker logout'
            
            // Hapus image lokal untuk menghemat ruang disk di Jenkins server
            echo 'Cleaning up local Docker images...'
            sh "docker rmi ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
            sh "docker rmi ${DOCKER_IMAGE_NAME}:latest"
        }
    }
}
