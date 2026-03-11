  Passo 1: Instalar Dependências no WSL (Ubuntu)

  No seu terminal do Ubuntu, execute os comandos abaixo para garantir que o sistema tenha o cliente do MySQL e as
  bibliotecas de desenvolvimento necessárias para o TFS:

   1 sudo apt update
   2 sudo apt install mysql-client libmysqlclient-dev -y


  Passo 2: Configurar o MySQL do XAMPP (Windows)

  Por padrão, o MySQL do XAMPP só aceita conexões do próprio Windows (localhost). Para o WSL conseguir "enxergar" o
  banco, siga estes passos no Windows:


   1. No Painel de Controle do XAMPP, clique em Config ao lado do MySQL e selecione my.ini.
   2. Procure a linha bind-address="127.0.0.1" e mude para bind-address="0.0.0.0" (ou apenas comente a linha com #).
   3. Reinicie o MySQL no XAMPP.
   4. No PHPMyAdmin (http://localhost/phpmyadmin), vá em "Contas de Usuário" e certifique-se de que o usuário root tenha
      permissão para conectar de % (qualquer host) ou crie um usuário específico para o servidor.

  Passo 3: Descobrir o IP do Windows para o WSL

  Como o WSL 2 funciona em uma rede virtual, o "localhost" do Ubuntu não é o mesmo do Windows. No terminal do Ubuntu,
  descubra o IP do seu Windows:


   1 cat /etc/resolv.conf | grep nameserver | awk '{print $2}'
  Anote este IP (ex: 172.20.10.1), ele será o seu mysqlHost no config.lua.


  Passo 4: Importar a Database

  Você pode usar o terminal do Ubuntu para importar o arquivo database.sql que já está na sua pasta para o MySQL do
  Windows:


   1 # Substitua IP_DO_WINDOWS pelo IP que você anotou no Passo 3
   2 mysql -h IP_DO_WINDOWS -u root -p -e "CREATE DATABASE IF NOT EXISTS otdb"
   3 mysql -h IP_DO_WINDOWS -u root -p otdb < database.sql

  Passo 5: Ajustar o config.lua


  Agora, procure o arquivo de configuração do seu servidor (geralmente config.lua na pasta raiz ou na pasta data) e
  ajuste as informações de conexão:


   1 -- Exemplo de como deve ficar
   2 mysqlHost = "IP_DO_WINDOWS" -- O IP que você descobriu no Passo 3
   3 mysqlUser = "root"
   4 mysqlPass = "" -- Sua senha do XAMPP (geralmente vazia)
   5 mysqlDatabase = "otdb"
   6 mysqlPort = 3306

  Resumo de Comandos para o seu Passo a Passo (Arquivo .sh)


  Se quiser salvar isso em um script no seu WSL para uso futuro, crie um arquivo setup_mysql.sh:


    1 #!/bin/bash
    2 echo "Instalando dependências..."
    3 sudo apt update && sudo apt install mysql-client libmysqlclient-dev -y
    4
    5 echo "Importando banco de dados (certifique-se que o XAMPP está aberto)..."
    6 # O script abaixo tenta pegar o IP do host automaticamente
    7 WINDOWS_IP=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
    8
    9 mysql -h $WINDOWS_IP -u root -e "CREATE DATABASE IF NOT EXISTS otdb"
   10 mysql -h $WINDOWS_IP -u root otdb < database.sql
   11
   12 echo "Configuração concluída. Use o IP $WINDOWS_IP no seu config.lua"