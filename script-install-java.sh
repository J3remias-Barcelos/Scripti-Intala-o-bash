#!/bin/bash

# Função para exibir mensagens de erro
print_error() {
    echo "Erro: $1"
    exit 1
}

# Verifica se o usuário está executando o script com privilégios de superusuário
if [ "$EUID" -ne 0 ]; then
    print_error "Este script deve ser executado com privilégios de superusuário (root)."
fi

# Função para instalar pacotes com tratamento de erro
install_package() {
    package_name="$1"
    if dpkg -l | grep -q "$package_name"; then
        echo "$package_name já está instalado."
    else
        sudo apt-get -y install "$package_name" || print_error "Falha ao instalar $package_name."
    fi
}

# Atualiza o sistema
sudo apt update || print_error "Falha ao atualizar o sistema."
sudo apt upgrade -y || print_error "Falha ao atualizar o sistema."

# Função para criar usuário se ele não existir
create_user() {
    username="$1"
    if id "$username" &>/dev/null; then
        echo "Usuário $username já existe."
    else
        adduser "$username" || print_error "Falha ao criar o usuário $username."
    fi
}

# Cria ou atualiza o usuário "pi"
create_user "pi"

# Adiciona o usuário ao grupo sudo
sudo usermod -aG sudo pi
sudo usermod -aG root pi

# Troca a senha dos usuários
sudo passwd ubuntu
sudo passwd root

# Instala o RDP no Ubuntu
install_package "xrdp"
install_package "lxde-core"
install_package "lxde"
install_package "tigervnc-standalone-server"

# Deseja instalar o MySQL e Rodar o Script criando estrutura
echo "Deseja instalar o MySQL e Rodar o Script para criar toda estrutura? [s/n]"
read -r getMysql

if [ "$getMysql" == "s"] then
        # Define a senha para o usuário 'root' do MySQL
        sudo mysqladmin -u root password 'secret' || print_error "Falha ao definir a senha do MySQL."

        # Instala o MySQL Server
        install_package "mysql-server"

        # Inicia o serviço do MySQL
        sudo service mysql start || print_error "Falha ao iniciar o serviço MySQL."

        # Configura o MySQL para iniciar automaticamente na inicialização
        sudo systemctl enable mysql

        # Função para criar banco de dados e usuário
        create_database_and_user() {
            db_name="$1"
            db_user="$2"
            db_password="$3"
            mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS $db_name;" || print_error "Falha ao criar o banco de dados."
            mysql -u root -p -e "CREATE USER IF NOT EXISTS '$db_user'@'localhost' IDENTIFIED BY '$db_password';" || print_error "Falha ao criar o usuário."
            mysql -u root -p -e "GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'localhost';" || print_error "Falha ao conceder privilégios."
            mysql -u root -p -e "FLUSH PRIVILEGES;" || print_error "Falha ao atualizar privilégios."
        }

        # Cria um banco de dados e um usuário
        create_database_and_user "NEXUS" "pi" "secret"

        # URL do arquivo SQL no GitHub
        sql_file_url= wget "https://github.com/Nexus-Enterprises/BancoDeDados/blob/main/Script%20-%20Nexus.sql"

        # Função para baixar e executar arquivo SQL
        download_and_execute_sql() {
            sql_url="$1"
            sql_file="$2"
            if wget -q --spider "$sql_url"; then
                wget "$sql_url" -O "$sql_file" || print_error "Falha ao baixar o arquivo SQL."
                mysql -u root -p < "$sql_file" || print_error "Falha ao executar o arquivo SQL."
            else
                echo "O arquivo SQL não pôde ser baixado do GitHub. Executando ação alternativa..."
                # ...
                # Lógica para criar tabelas e estrutura
                CREATE DATABASE NEXUS;
                USE NEXUS;

                CREATE TABLE Endereco (
                idEndereco INT AUTO_INCREMENT PRIMARY KEY,
                cep CHAR(8) NULL,
                logradouro VARCHAR(45) NOT NULL,
                bairro VARCHAR(45) NOT NULL,
                localidade VARCHAR(45) NOT NULL,
                uf CHAR(2) NOT NULL,
                complemento VARCHAR(45) NULL
                );

                CREATE TABLE Empresa (
                idEmpresa INT AUTO_INCREMENT PRIMARY KEY,
                nomeEmpresa VARCHAR(45) NOT NULL,
                CNPJ VARCHAR(14) NOT NULL UNIQUE,
                digito CHAR(3) NOT NULL,
                descricao VARCHAR(45) NULL,
                ispb CHAR(8) NOT NULL,
                situacao TINYINT NULL
                );

                CREATE TABLE Agencia (
                idAgencia INT AUTO_INCREMENT PRIMARY KEY,
                numero CHAR(5) NULL,
                digitoAgencia CHAR(1) NULL,
                ddd CHAR(2) NULL,
                telefone VARCHAR(9) NULL,
                email VARCHAR(45) NULL UNIQUE,
                fkEmpresa INT NOT NULL,
                fkEndereco INT NOT NULL,
                CONSTRAINT fkEndereco
                    FOREIGN KEY (fkEndereco)
                    REFERENCES Endereco (idEndereco),
                CONSTRAINT fkEmpresaAgencia
                    FOREIGN KEY (fkEmpresa)
                    REFERENCES Empresa (idEmpresa)
                );

                CREATE TABLE Funcionario (
                idFuncionario INT AUTO_INCREMENT PRIMARY KEY,
                nome VARCHAR(45) NULL,
                sobrenome VARCHAR(45) NULL,
                emailCorporativo VARCHAR(45) NULL UNIQUE,
                ddd CHAR(2) NULL,
                telefone VARCHAR(9) NULL UNIQUE,
                cargo VARCHAR(45) NULL,
                situacao VARCHAR(10) NULL,
                fkAgencia INT NOT NULL,
                fkEmpresa INT NOT NULL,
                fkFuncionario INT NULL,
                CONSTRAINT fkAgencia
                    FOREIGN KEY (fkAgencia)
                    REFERENCES Agencia (idAgencia),
                CONSTRAINT fkEmpresa
                    FOREIGN KEY (fkEmpresa)
                    REFERENCES Empresa (idEmpresa),
                CONSTRAINT fkFuncionario
                    FOREIGN KEY (fkFuncionario)
                    REFERENCES Funcionario (idFuncionario)
                );

                CREATE TABLE Usuario (
                idUsuario INT AUTO_INCREMENT PRIMARY KEY,
                email VARCHAR(45) NOT NULL UNIQUE,
                token VARCHAR(50) NOT NULL,
                fkFuncionario INT NOT NULL UNIQUE,
                FOREIGN KEY (fkFuncionario)
                    REFERENCES Funcionario (idFuncionario)
                );


                CREATE TABLE Maquina (
                idMaquina INT AUTO_INCREMENT PRIMARY KEY,
                marca VARCHAR(45) NULL,
                modelo VARCHAR(45) NULL,
                situacao VARCHAR(10) NULL,
                sistemaOperacional VARCHAR(15) NULL,
                fkFuncionario INT NOT NULL,
                fkAgencia INT NOT NULL,
                fkEmpresa INT NOT NULL,
                CONSTRAINT fkFuncionarioMaq
                    FOREIGN KEY (fkFuncionario)
                    REFERENCES Funcionario (idFuncionario),
                CONSTRAINT fkAgenciaMaq
                    FOREIGN KEY (fkAgencia)
                    REFERENCES Agencia (idAgencia),
                CONSTRAINT fkEmpresaMaq
                    FOREIGN KEY (fkEmpresa)
                    REFERENCES Empresa (idEmpresa)
                );

                CREATE TABLE Componente (
                idComponente INT AUTO_INCREMENT PRIMARY KEY,
                nome VARCHAR(45) NULL,
                modelo VARCHAR(45) NULL,
                capacidadeMax DOUBLE NULL,
                montagem VARCHAR(45) NULL,
                fkMaquina INT NOT NULL,
                CONSTRAINT fkMaquinaComponente
                    FOREIGN KEY (fkMaquina)
                    REFERENCES Maquina (idMaquina)
                );

                CREATE TABLE Alerta (
                idAlerta INT AUTO_INCREMENT PRIMARY KEY,
                causa VARCHAR(60) NOT NULL,
                gravidade VARCHAR(45) NOT NULL
                );

                CREATE TABLE Registro (
                idRegistro INT AUTO_INCREMENT PRIMARY KEY,
                enderecoIPV4 VARCHAR(500) NOT NULL,
                usoAtual DOUBLE NOT NULL,
                dataHora DATETIME NOT NULL,
                fkAlerta INT NOT NULL,
                fkComponente INT NOT NULL,
                fkMaquina INT NOT NULL,
                CONSTRAINT fkAlertaRegistro
                    FOREIGN KEY (fkAlerta)
                    REFERENCES Alerta (idAlerta),
                CONSTRAINT fkComponenteRegistro
                    FOREIGN KEY (fkComponente)
                    REFERENCES Componente (idComponente),
                CONSTRAINT fkMaquinaRegistro
                    FOREIGN KEY (fkMaquina)
                    REFERENCES Maquina (idMaquina)
        );
            fi
        }

        # Baixa e executa o arquivo SQL
        download_and_execute_sql "$sql_file_url" "script.sql" || print_error "Falha ao baixar e executar o arquivo SQL."

        # Caso o MySQL não esteja rodando/estrutura não foi criada, buscar o script SQL no diretório do projeto
        sudo mysql -u root -p < "script.sql" || print_error "Falha ao executar o arquivo SQL."

        else 
            echo "Você optou por não instalar o MySQL. Saindo..."
            exit 1
fi



# Verifica se o Java 17 está instalado
if ! command -v java &>/dev/null || [[ $(java -version 2>&1 | grep -c "17\..*") -eq 0 ]]; then
    echo "Java 17 não está instalado. Deseja instalar o Java? [s/n]"
    read -r get
    if [ "$get" == "s" ]; then
        # Instala o OpenJDK 17 JRE
        install_package "openjdk-17-jre"
    else
        echo "Você optou por não instalar o Java. Saindo..."
        exit 1
    fi
fi

# Verifica a instalação do Java JRE
java -version && javac -version

# Baixa o arquivo .jar diretamente do link
wget https://github.com/Nexus-Enterprises/login-Java/blob/main/Nexus/target/Nexus-1.0-jar-with-dependencies.jar -O nexus.jar || print_error "Falha ao baixar o arquivo JAR."

# Permissão para o arquivo .jar
chmod +x nexus.jar

# Executa o arquivo .jar
java -jar nexus.jar


# # Instala o Docker
# install_package "docker.io"

# # Cria e inicia um contêiner MySQL
# create_mysql_container() {
#     container_name="mysql-container"
#     root_password="sua_senha"
#     database_name="seu_banco_de_dados"
    
#     if docker ps -a | grep -q "$container_name"; then
#         echo "O contêiner $container_name já existe. Iniciando..."
#         docker start "$container_name" || print_error "Falha ao iniciar o contêiner MySQL."
#     else
#         docker run -d --name "$container_name" -e MYSQL_ROOT_PASSWORD="$root_password" -e MYSQL_DATABASE="$database_name" mysql:latest || print_error "Falha ao criar o contêiner MySQL."
#     fi
# }

# # Cria e inicia um contêiner MySQL
# create_mysql_container

# # Constrói a imagem Docker para o projeto Java (substitua 'caminho_para_dockerfile' pelo caminho real do seu Dockerfile)
# build_java_image() {
#     dockerfile_path="caminho_para_dockerfile"
#     image_name="login-java"
    
#     if docker images | grep -q "$image_name"; then
#         echo "A imagem Docker $image_name já existe."
#     else
#         docker build -t "$image_name" "$dockerfile_path" || print_error "Falha ao construir a imagem Docker."
#     fi
# }

# # Constrói a imagem Docker para o projeto Java
# build_java_image