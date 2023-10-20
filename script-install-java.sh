#!/bin/bash

# Atualiza o sistema e instala pacotes necessários
sudo apt update
sudo apt upgrade -y

# Cria um usuário se ele não existir
if ! id "pi" &>/dev/null; then
    sudo adduser pi
fi

# Adiciona o usuário ao grupo sudo
sudo usermod -aG sudo pi

# Troca a senha do usuário "pi"
sudo passwd pi

# Instalar o RDP no Ubuntu - Terminal
sudo apt install xrdp lxde-core lxde tigervnc-standalone-server -y

# Instala o MySQL Server
sudo apt install mysql-server -y

# Inicia o serviço do MySQL
sudo service mysql start

# Configura o MySQL para iniciar automaticamente na inicialização
sudo systemctl enable mysql

# Cria um banco de dados e um usuário
mysql -u root -p -e "CREATE DATABASE seu_banco_de_dados;"
mysql -u root -p -e "CREATE USER 'seu_usuario'@'localhost' IDENTIFIED BY 'sua_senha';"
mysql -u root -p -e "GRANT ALL PRIVILEGES ON seu_banco_de_dados.* TO 'seu_usuario'@'localhost';"
mysql -u root -p -e "FLUSH PRIVILEGES;"

# URL do arquivo SQL no GitHub
sql_file_url="https://github.com/Nexus-Enterprises/BancoDeDados/blob/main/Script%20-%20Nexus.sql"

# Baixa o arquivo SQL diretamente do GitHub
if wget -q --spider "$sql_file_url"; then
    # Se o arquivo estiver disponível, baixe-o
    wget "$sql_file_url" -O script.sql
    # Execute o script SQL no MySQL
    mysql -u root -p < script.sql
else
    # Se o arquivo não estiver disponível, execute alguma ação alternativa
    echo "O arquivo SQL não pôde ser baixado do GitHub. Então executando ação alternativa..."
    
    # Criando todas as tabelas e estrutura
        # Cria o banco de dados "NEXUS"
        echo "CREATE DATABASE NEXUS;" | mysql -u root -p
        echo "USE NEXUS;" | mysql -u root -p

        # Cria a tabela Endereco
        echo "CREATE TABLE Endereco (
        idEndereco INT AUTO_INCREMENT PRIMARY KEY,
        cep CHAR(8) NULL,
        logradouro VARCHAR(45) NOT NULL,
        bairro VARCHAR(45) NOT NULL,
        localidade VARCHAR(45) NOT NULL,
        uf CHAR(2) NOT NULL,
        complemento VARCHAR(45) NULL
        );" | mysql -u root -p

        # Cria a tabela Empresa
        echo "CREATE TABLE Empresa (
        idEmpresa INT AUTO_INCREMENT PRIMARY KEY,
        nomeEmpresa VARCHAR(45) NOT NULL,
        CNPJ VARCHAR(14) NOT NULL UNIQUE,
        digito CHAR(3) NOT NULL,
        descricao VARCHAR(45) NULL,
        ispb CHAR(8) NOT NULL,
        situacao TINYINT NULL
        );" | mysql -u root -p

        # Cria a tabela Agencia
        echo "CREATE TABLE Agencia (
        idAgencia INT AUTO_INCREMENT PRIMARY KEY,
        numero CHAR(5) NULL,
        digitoAgencia CHAR(1) NULL,
        ddd CHAR(2) NULL,
        telefone VARCHAR(9) NULL,
        email VARCHAR(45) NULL UNIQUE,
        fkEmpresa INT NOT NULL,
        fkEndereco INT NOT NULL,
        CONSTRAINT fkEndereco FOREIGN KEY (fkEndereco) REFERENCES Endereco (idEndereco),
        CONSTRAINT fkEmpresaAgencia FOREIGN KEY (fkEmpresa) REFERENCES Empresa (idEmpresa)
        );" | mysql -u root -p

        # Cria a tabela Funcionario
        echo "CREATE TABLE Funcionario (
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
        CONSTRAINT fkAgencia FOREIGN KEY (fkAgencia) REFERENCES Agencia (idAgencia),
        CONSTRAINT fkEmpresa FOREIGN KEY (fkEmpresa) REFERENCES Empresa (idEmpresa),
        CONSTRAINT fkFuncionario FOREIGN KEY (fkFuncionario) REFERENCES Funcionario (idFuncionario)
        );" | mysql -u root -p

        # Cria a tabela Usuario
        echo "CREATE TABLE Usuario (
        idUsuario INT AUTO_INCREMENT PRIMARY KEY,
        email VARCHAR(45) NOT NULL UNIQUE,
        token VARCHAR(50) NOT NULL,
        fkFuncionario INT NOT NULL UNIQUE,
        FOREIGN KEY (fkFuncionario) REFERENCES Funcionario (idFuncionario)
        );" | mysql -u root -p

        # Cria a tabela Maquina
        echo "CREATE TABLE Maquina (
        idMaquina INT AUTO_INCREMENT PRIMARY KEY,
        marca VARCHAR(45) NULL,
        modelo VARCHAR(45) NULL,
        situacao VARCHAR(10) NULL,
        sistemaOperacional VARCHAR(15) NULL,
        fkFuncionario INT NOT NULL,
        fkAgencia INT NOT NULL,
        fkEmpresa INT NOT NULL,
        CONSTRAINT fkFuncionarioMaq FOREIGN KEY (fkFuncionario) REFERENCES Funcionario (idFuncionario),
        CONSTRAINT fkAgenciaMaq FOREIGN KEY (fkAgencia) REFERENCES Agencia (idAgencia),
        CONSTRAINT fkEmpresaMaq FOREIGN KEY (fkEmpresa) REFERENCES Empresa (idEmpresa)
        );" | mysql -u root -p

        # Cria a tabela Componente
        echo "CREATE TABLE Componente (
        idComponente INT AUTO_INCREMENT PRIMARY KEY,
        nome VARCHAR(45) NULL,
        modelo VARCHAR(45) NULL,
        capacidadeMax DOUBLE NULL,
        montagem VARCHAR(45) NULL,
        fkMaquina INT NOT NULL,
        CONSTRAINT fkMaquinaComponente FOREIGN KEY (fkMaquina) REFERENCES Maquina (idMaquina)
        );" | mysql -u root -p

        # Cria a tabela Alerta
        echo "CREATE TABLE Alerta (
        idAlerta INT AUTO_INCREMENT PRIMARY KEY,
        causa VARCHAR(60) NOT NULL,
        gravidade VARCHAR(45) NOT NULL
        );" | mysql -u root -p

        # Cria a tabela Registro
        echo "CREATE TABLE Registro (
        idRegistro INT AUTO_INCREMENT PRIMARY KEY,
        enderecoIPV4 VARCHAR(500) NOT NULL,
        usoAtual DOUBLE NOT NULL,
        dataHora DATETIME NOT NULL,
        fkAlerta INT NOT NULL,
        fkComponente INT NOT NULL,
        fkMaquina INT NOT NULL,
        CONSTRAINT fkAlertaRegistro FOREIGN KEY (fkAlerta) REFERENCES Alerta (idAlerta),
        CONSTRAINT fkComponenteRegistro FOREIGN KEY (fkComponente) REFERENCES Componente (idComponente),
        CONSTRAINT fkMaquinaRegistro FOREIGN KEY (fkMaquina) REFERENCES Maquina (idMaquina)
        );" | mysql -u root -p
fi


# Verifica se o Java 17 está instalado
if ! command -v java &>/dev/null || [[ $(java -version 2>&1 | grep -c "17\..*") -eq 0 ]]; then
    echo "Java 17 não está instalado. Deseja instalar o Java? [s/n]"
    read get
    if [ "$get" == "s" ]; then
        # Instala o Java 17
        # Instala o OpenJDK 17 JRE
    sudo apt install -y openjdk-17-jre
    else
        echo "Você optou por não instalar o Java. Saindo..."
        exit 1
    fi
fi

# Verifica a instalação do Java JRE
java -version && javac -version


# Baixa o arquivo .jar diretamente do link
wget https://github.com/Nexus-Enterprises/login-Java/raw/main/Nexus/target/Nexus-1.0.jar -O login.jar

# Executa o arquivo .jar
java -jar login.jar


# Instala o Docker (descomente se for necessário)
# sudo apt install docker.io -y

# Cria e inicia um container MySQL
# Certifique-se de fornecer as configurações adequadas para o banco de dados
# (usuário, senha, nome do banco de dados, etc.)
# sudo docker run -d --name mysql-container -e MYSQL_ROOT_PASSWORD=sua_senha -e MYSQL_DATABASE=seu_banco_de_dados mysql:latest

# Se desejar, você pode criar uma imagem Docker para a aplicação Java
# sudo docker build -t login-java .