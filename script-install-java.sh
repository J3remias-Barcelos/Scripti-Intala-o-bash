# Path 1: script-install-java.sh
!/bin/bash

# 1° Fazer update/upgrade do sistema
sudo apt update && sudo apt upgrade -y

# 2° Criar um usuário com adduser e dar permissão se necessário
sudo adduser pi && sudo usermod -aG sudo pi

# 3° Trocar senha dos Usuários via passwd
sudo passwd pi
sudo passwd root

# 4° Verificar versão do Java se é 17
java -version
    if [ $? = 0 ];
then
    echo “java instalado” 
else
    echo “java não instalado” 
    echo “gostaria de instalar o java? [s/n]” 
read get 

    if [ \“$get\” == \“s\” ]; 
then
# 5° Instalar o Java com interação do usuário
sudo apt install openjdk-17-jre -y
fi 
    fi

# 6° Baixar o arquivo .jar do grupo de PI via github
git clone https://github.com/Nexus-Enterprises/login-Java.git

cd login-Java && cd Nexus-Login 


# 7° Executar o arquivo .jar do grupo de PI
java -jar login-Java/login.jar

# 8° Fazer instalação do Docker
sudo apt install docker.io -y

# 9° Criar uma imagem do Docker com o Dockerfile
sudo docker build -t login-java .