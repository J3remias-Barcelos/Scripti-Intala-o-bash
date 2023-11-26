#!/bin/bash

PURPLE='\033[0;35m'
NC='\033[0m'
VERSAO=17

# Nome da empresa
EMPRESA="Nexus"

# Atualizar os pacotes do sistema
echo -e "${PURPLE}[${EMPRESA}]:${NC} Atualizando os pacotes..."
sudo apt update && sudo apt upgrade -y
sleep 15

# Mensagem informativa sobre a instalação do Docker
echo -e "${PURPLE}[${EMPRESA}]:${NC} Instalando o Docker..."
sudo apt install docker.io -y
sleep 15

# Iniciar o serviço do Docker
echo -e "${PURPLE}[${EMPRESA}]:${NC} Iniciando o serviço do Docker..."
sudo systemctl start docker
sudo systemctl enable docker
sleep 15

# Baixar a imagem do MySQL 5.7
echo -e "${PURPLE}[${EMPRESA}]:${NC} Baixando a imagem do MySQL:latest..."
sudo docker pull mysql:latest
sleep 15

# Criar e executar o container MySQL com o script SQL
echo -e "${PURPLE}[${EMPRESA}]:${NC} Criando e executando o container MySQL..."
sudo docker run -d -p 3306:3306 --name NexusBank -e "MYSQL_ROOT_PASSWORD=nexus123" mysql:latest
  
echo -e "${PURPLE}[${EMPRESA}]:${NC} Container MySQL criado e em execução!"

# Executar o script SQL dentro do container MySQL
echo -e "${PURPLE}[${EMPRESA}]:${NC} Executando o script SQL dentro do container MySQL..."
sleep 15
sudo docker exec -i NexusBank mysql -u root -pnexus123 < /home/ubuntu/assistants/script.sql
echo -e "${PURPLE}[${EMPRESA}]:${NC} Script SQL executado com sucesso!"

# Executar o arquivo java-install.sh
echo -e "${PURPLE}[${EMPRESA}]:${NC} Dando permissão e executando o arquivo java-install.sh..."
sudo chmod +x java-install.sh

# Executar o arquivo java-install.sh
echo -e "${PURPLE}[${EMPRESA}]:${NC} Executando o arquivo java-install.sh"
sudo ./java-install.sh