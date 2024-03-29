#!/bin/bash

BLUE='\033[1;36m'
RED='\033[31m'
PURPEL='\033[1;35m'
GREEN='\033[1;32m'
NC='\033[0m'
VERSION='v1.0.8'
IP=$(hostname -I)

# Fonction pour afficher les options disponibles
display_menu() {
  echo -e "${PURPEL}
████████╗██╗  ██╗    ████████╗ ██████╗  ██████╗ ██╗     ███████╗
╚══██╔══╝╚██╗██╔╝    ╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██╔════╝
   ██║    ╚███╔╝        ██║   ██║   ██║██║   ██║██║     ███████╗
   ██║    ██╔██╗        ██║   ██║   ██║██║   ██║██║     ╚════██║
   ██║   ██╔╝ ██╗       ██║   ╚██████╔╝╚██████╔╝███████╗███████║
   ╚═╝   ╚═╝  ╚═╝       ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚══════╝
Version : ${VERSION}
IP : ${IP} 
Hostname : ${HOSTNAME}
${NC}Attention, ce script est en bêta, veuillez ne pas l'utiliser sur de la production.
(Contact : talaighiltoufik@outlook.fr si vous rencontrez un soucis)."

  echo -e ""
  echo -e "${BLUE} -------------------------------------- ${PURPEL}GESTION DU SERVEUR ${BLUE}--------------------------------------"
  echo -e "${PURPEL}[1] ${NC}Mettre à jour le système"
  echo -e "${PURPEL}[2] ${NC}Installer des packages de base ${BLUE}(bash, curl, sudo, wget, nload, htop, git)"
  echo -e "${PURPEL}[3] ${NC}Installer l'utilitaire ${BLUE}Speedtest (Ookla)"
  echo -e "${PURPEL}[4] ${NC}Créer un nouvel utilisateur"
  echo -e "${PURPEL}[5] ${NC}Tout faire ${BLUE}(1, 2 et 4)"
  echo -e ""
  echo -e "${BLUE} -------------------------------------- ${PURPEL}SERVEURS DE JEUX ${BLUE}--------------------------------------"
  echo -e ""
  echo -e "${PURPEL}[6] ${NC}Créer et lancer un serveur ${BLUE}Minecraft"
  echo -e "${PURPEL}[7] ${NC}Créer et lancer un serveur ${BLUE}Bungeecord"
  echo -e "${PURPEL}[8] ${NC}Créer et lancer un serveur ${BLUE}FiveM"
  echo -e "${PURPEL}[9] ${NC}Installer le panel de gestion de serveurs ${BLUE}Pterodactyl ${RED}(require Nginx & MariaDB & PhpMyAdmin)"
  echo -e "${PURPEL}[10] ${NC}Mettre à jours ${BLUE}Pterodactyl"
  echo -e ""
  echo -e "${BLUE} ---------------------------------------- ${PURPEL}SERVEURS WEB  ${BLUE}---------------------------------------"
  echo -e ""
  echo -e "${PURPEL}[11] ${NC}Installer un serveur ${BLUE}Nginx"
  echo -e "${PURPEL}[12] ${NC}Installer l'interface ${BLUE}PhpMyAdmin ${RED}(require Nginx & MariaDB)"
  echo -e "${PURPEL}[13] ${NC}Installer le gestionnaire d'hébergement web ${BLUE}Plesk"
  echo -e ""
  echo -e "${BLUE} --------------------------------- ${PURPEL}SERVEURS DE BASE DE DONNEES  ${BLUE}--------------------------------"
  echo -e ""
  echo -e "${PURPEL}[14] ${NC}Installer et configurer un serveur ${BLUE}MariaDB (MySQL)"
  echo -e "${PURPEL}[15] ${NC}Créer un utilisateur administrateur MariaDB"
  echo -e ""
  echo -e "${BLUE} ----------------------------------------------------------------------------------------------"
  echo -e ""
  echo -e "${PURPEL}[16] ${NC}Quitter l'utilitaire"
  echo -e ""
}


# Vérification des mises à jour
if ! command -v sudo &> /dev/null; then
    clear
    echo "sudo n'est pas installé. Installation en cours...${NC}"
    apt update -y
    apt install sudo -y
fi
if ! command -v curl &> /dev/null; then
    clear
    echo "curl n'est pas installé. Installation en cours...${NC}"
    sudo apt update
    apt install curl -y
fi
clear

# Fonction pour mettre à jour le système
update_system() {
  clear
  sudo apt update -y
  sudo apt upgrade -y
}

# Fonction pour installer les packages de base
install_packages() {
  clear
  sudo apt install -y bash curl sudo wget nload htop git
}

# Fonction pour créer un nouvel utilisateur
create_user() {
  clear
  read -p "Veuillez saisir le nom d'utilisateur pour le nouvel utilisateur :" new_user
  read -s -p "Veuillez saisir le mot de passe pour le nouvel utilisateur :" new_password
  read -p "Voulez-vous donner les permissions sudo et root à cet utilisateur ? (y/n): " give_permissions
  sudo adduser $new_user --gecos "User"
  if [[ "$give_permissions" == "y" ]]; then
    sudo usermod -aG sudo $new_user
    sudo usermod -aG root $new_user
  fi
  echo "$new_user:$new_password" | sudo chpasswd
}

install_speedtest() {
  clear
  if ! command -v speedtest &> /dev/null; then
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
    sudo apt install speedtest
    echo -e "${GREEN}Speedtest à été installé avec succès ! (exemple : speedtest -s 24215)${NC}"
  else
    echo -e "${RED}Speedtest est déjà installé sur votre serveur !${NC}"
  fi
}

create_minecraft_server() {
  clear
  # Vérifier si Java est installé
  if ! command -v java &> /dev/null; then
    echo "Java n'est pas installé. Installation en cours...${NC}"
    sudo apt update
    sudo apt install openjdk-17-jdk openjdk-17-jre -y
  fi
  
  # Demander à l'utilisateur de saisir la version du serveur
  read -p "Veuillez entrer la version de Spigot à installer (par exemple, '1.12.2'): " version

  # Demander à l'utilisateur la RAM max qu'il veut
  read -p "Veuillez entrer la valeur maximum de la RAM que vous souhaitez (par exemple, '4096' pour 4GB): " max_ram
  
  # Créer un dossier pour le serveur
  read -p "Veuillez entrer le chemin absolu où vous souhaitez créer le dossier pour le serveur: " server_path
  sudo mkdir -p $server_path
  cd $server_path
  
  # Télécharger le fichier Spigot.jar
  sudo wget https://cdn.getbukkit.org/spigot/spigot-$version.jar

  echo "eula=true" > eula.txt
  echo "sudo java -Xmx${max_ram}M -Xms1024M -jar spigot-${version}.jar nogui" > start.sh

  # Rendre éxécutable le start.sh
  chmod +x start.sh
  read -p "Voulez vous lancer le serveur ? (y/n): " launch
  if [[ "$launch" == "y" ]]; then
    sudo bash start.sh
  fi
  if [[ "$launch" == "n" ]]; then
    echo -e "${BLUE}D'accord, si vous souhaitez lancer le serveur, vous pouvez utiliser la commande './start.sh' dans le répertoire du serveur.${NC}"
  fi
}

create_bungeecord_server() {
  clear
  # Vérifier si Java est installé
  if ! command -v java &> /dev/null; then
    echo "${YELLOW}Java n'est pas installé. Installation en cours...${NC}"
    sudo apt update
    sudo apt install openjdk-17-jdk openjdk-17-jre -y
  fi

  # Demander à l'utilisateur la RAM max qu'il veut
  read -p "Veuillez entrer la valeur maximum de la RAM que vous souhaitez (par exemple, '4096' pour 4GB): " max_ram
  
  # Créer un dossier pour le serveur
  read -p "Veuillez entrer le chemin absolu où vous souhaitez créer le dossier pour le serveur: " server_path
  sudo mkdir -p $server_path
  cd $server_path
  
  # Télécharger le fichier Spigot.jar
  sudo wget https://ci.md-5.net/job/BungeeCord/lastSuccessfulBuild/artifact/bootstrap/target/BungeeCord.jar

  echo "eula=true" > eula.txt
  echo "sudo java -Xmx${max_ram}M -Xms1024M -jar BungeeCord.jar nogui" > start.sh

  # Rendre éxécutable le start.sh
  chmod +x start.sh
  read -p "Voulez vous lancer le serveur ? (y/n): " launch
  if [[ "$launch" == "y" ]]; then
    sudo bash start.sh
  fi
  if [[ "$launch" == "n" ]]; then
    echo -e "${BLUE}D'accord, si vous souhaitez lancer le serveur, vous pouvez utiliser la commande './start.sh' dans le répertoire du serveur.${NC}"
  fi
}

create_fivem_server() {
  clear
  # Vérifier si xz-utils est installé
  if ! command -v tar &> /dev/null; then
    echo "${BLUE}xz-utils n'est pas installé. Installation en cours...${NC}"
    sudo apt update
    sudo apt install xz-utils -y
  fi

  # Vérifier si git est installé
  if ! command -v git &> /dev/null; then
    echo "${BLUE}git n'est pas installé. Installation en cours...${NC}"
    sudo apt update
    sudo apt install git -y
  fi

  # Vérifier si wget est installé
  if ! command -v wget &> /dev/null; then
    echo "${BLUE}wget n'est pas installé. Installation en cours...${NC}"
    sudo apt update
    sudo apt install wget -y
  fi

  # Créer un dossier pour le serveur
  read -p "Veuillez entrer le chemin absolu où vous souhaitez créer le dossier pour le serveur: " server_path
  sudo mkdir -p $server_path
  cd $server_path

  # Télécharger l'artefacts (alpine)
  read -p "Veuillez entrer le lien de l'artefacts (alpine) pour le serveur: " artefacts_link
  wget $artefacts_link

  # Unarchive l'artefacts
  tar -xvf fx.tar.xz && rm fx.tar.xz

  # Lancer le serveur
  read -p "Voulez vous lancer le serveur ? (y/n): " launch
  if [[ "$launch" == "y" ]]; then
    cd ${server_path} && sudo bash run.sh
  fi
  if [[ "$launch" == "n" ]]; then
    echo -e "${BLUE}D'accord, si vous souhaitez lancer le serveur, vous pouvez utiliser la commande './run.sh' dans le répertoire du serveur.${NC}"
  fi
}

setup_mariadb_server() {
  clear
  # Installation de MariaDB
  sudo apt update -y
  sudo apt upgrade -y

  # Détection de la version de Linux
  if [[ -e /etc/debian_version ]]; then
    DISTRO=$(lsb_release -is)
    VERSION=$(lsb_release -rs | cut -d. -f1)
  elif [[ -e /etc/lsb-release ]]; then
    DISTRO=$(grep DISTRIB_ID /etc/lsb-release | awk -F= '{print $2}')
    VERSION=$(grep DISTRIB_RELEASE /etc/lsb-release | awk -F= '{print $2}' | cut -d. -f1)
  else
    echo "${RED}Distribution non prise en charge.${NC}"
    exit 1
  fi

  # Ajout du référentiel MariaDB approprié
  if [[ $DISTRO == "Ubuntu" && $VERSION -ge 20 ]]; then
    # Ajout du référentiel MariaDB 11.0 pour Ubuntu 20.04 ou version ultérieure
    sudo apt install -y software-properties-common
    sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
    sudo add-apt-repository 'deb [arch=amd64] http://mirror.zol.co.zw/mariadb/repo/11.0/ubuntu focal main'
  elif [[ $DISTRO == "Ubuntu" && $VERSION -lt 20 ]]; then
    # Ajout du référentiel MariaDB 11.0 pour Ubuntu 18.04 ou version antérieure
    sudo apt install -y software-properties-common
    sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
    sudo add-apt-repository 'deb [arch=amd64] http://mirror.zol.co.zw/mariadb/repo/11.0/ubuntu bionic main'
  elif [[ $DISTRO == "Debian" && $VERSION -ge 10 ]]; then
    # Ajout du référentiel MariaDB 11.0 pour Debian 10 ou version ultérieure
    sudo apt install -y software-properties-common dirmngr gnupg2
    sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
    sudo add-apt-repository 'deb [arch=amd64] http://mirror.zol.co.zw/mariadb/repo/11.0/debian buster main'
  else
    echo "${RED}Version non prise en charge de la distribution Linux.${NC}"
    exit 1
  fi
  apt install mariadb-server -y
  sudo mysql_secure_installation
  echo -e "${GREEN}L'installation de votre serveur MariaDB à été éffectué correctement.${NC}"
}

install_nginx_php() {
    clear
    # Installer Nginx
    read -p "Voulez vous supprimer la configuration par défaut de nginx ? (y/n): " delete_default
    sudo apt update
    sudo apt install -y nginx
    sudo apt install python3-certbot-nginx -y
    sudo apt -y install software-properties-common
    sudo add-apt-repository -y ppa:ondrej/php
    sudo apt update
    sudo apt install -y php7.4-fpm php7.4-common php7.4-mysql php7.4-gd php7.4-json php7.4-cli

    # Configurer Nginx pour utiliser PHP-FPM
    if [[ "$delete_default" == "y" ]]; then
      rm /etc/nginx/sites-enabled/default
      rm /etc/nginx/sites-available/default
    else
      sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup
      sudo touch /etc/nginx/sites-available/default
      sudo sh -c 'echo "<h1>Bienvenue sur votre serveur Nginx !</h1></br><h2>by Toms Tools.</h2>" > /var/www/html/index.html'
      sudo echo "
      server {
        listen 80 default_server;
        listen [::]:80 default_server;
        root /var/www/html;
        index index.php index.html index.htm;
        server_name _;
        location / {
            try_files \$uri \$uri/ =404;
        }
        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        }
      }" | sudo tee /etc/nginx/sites-available/default > /dev/null
    sudo systemctl restart nginx.service
    fi
}

install_phpmyadmin() {
  clear
  if ! command -v unzip &> /dev/null; then
    echo "${BLUE}Unzip n'est pas installé. Installation en cours...${NC}"
    sudo apt update
    apt install zip unzip -y
  fi
  apt -y install php8.1 php8.1-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip} tar git redis-server
  export PHPMYADMIN_VERSION=$(curl --silent https://www.phpmyadmin.net/downloads/ | grep "btn btn-success download_popup" | sed -n 's/.*href="\([^"]*\).*/\1/p' | tr '/' '\n' | grep -E '^.*[0-9]+\.[0-9]+\.[0-9]+$')
  echo -e "${RED}Attention, si vous avez supprimer la configuration par défaut de nginx, il ne sera pas accessible si vous n'utilisez pas un domaine.${NC}"
  read -p "Souhaitez-vous utiliser un nom de domaine ? (y/n): " domain_boolean
  if [[ "$domain_boolean" == "y" ]]; then
    apt install python3-certbot-nginx -y
    echo -e "${RED}Attention, le nom de domaine doit pointer vers l'adresse IP du serveur.${NC}"
    read -p "Entrez le nom de domaine que vous souhaitez utiliser: " domain
    read -p "Entrez le répertoire d'installation (exemple : /var/www/phpmyadmin): " repertoire
    certbot --nginx -d $domain
    mkdir $repertoire
    cd $repertoire && wget https://files.phpmyadmin.net/phpMyAdmin/$PHPMYADMIN_VERSION/phpMyAdmin-$PHPMYADMIN_VERSION-all-languages.zip && unzip phpMyAdmin-$PHPMYADMIN_VERSION-all-languages.zip && rm phpMyAdmin-$PHPMYADMIN_VERSION-all-languages.zip && mv phpMyAdmin-$PHPMYADMIN_VERSION-all-languages pma
    cd pma
    mv * $repertoire
    cd $repertoire
    rm -r pma
    cat << EOF | sudo tee /etc/nginx/sites-enabled/phpmyadmin.conf > /dev/null
server {
    listen 80;
    server_name $domain;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $domain;

    root /var/www/phpmyadmin;
    index index.php;

    # allow larger file uploads and longer script runtimes
    client_max_body_size 100m;
    client_body_timeout 120s;

    sendfile off;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
    ssl_session_cache shared:SSL:10m;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256';
    ssl_prefer_server_ciphers on;

    # See https://hstspreload.org/ before uncommenting the line below.
    # add_header Strict-Transport-Security "max-age=15768000; preload;";
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Robots-Tag none;
    add_header Content-Security-Policy "frame-ancestors 'self'";
    add_header X-Frame-Options DENY;
    add_header Referrer-Policy same-origin;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
        include /etc/nginx/fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF
  else
    cd /var/www/html && wget https://files.phpmyadmin.net/phpMyAdmin/$PHPMYADMIN_VERSION/phpMyAdmin-$PHPMYADMIN_VERSION-all-languages.zip && unzip phpMyAdmin-$PHPMYADMIN_VERSION-all-languages.zip && rm phpMyAdmin-$PHPMYADMIN_VERSION-all-languages.zip && mv phpMyAdmin-$PHPMYADMIN_VERSION-all-languages pma
  fi
  systemctl restart nginx
  echo -e "${GREEN}L'installation de votre PhpMyAdmin à été éffectué correctement.${NC}"
}

install_plesk() {
  clear
  if ! command -v plesk &> /dev/null; then
    sudo apt update
    if ! command -v wget &> /dev/null; then
      apt install wget -y
    fi
    sh <(curl https://autoinstall.plesk.com/one-click-installer || wget -O - https://autoinstall.plesk.com/one-click-installer)
  else
    echo -e "${RED}Plesk est déjà installé sur le système.${NC}"
  fi
}

install_ptero() {
    clear
    echo -e "${RED}Veuillez installer Nginx, MariaDB et PhpMyAdmin !${NC}"
    echo -e ""
    read -p "Voulez-vous utiliser un nom de domaine pour le Pterodactyl ? (y/n): " ptero_domain_boolean
    if [[ "$ptero_domain_boolean" == "y" ]]; then
      echo $e "${RED}Attention, le nom de domaine doit pointé vers l'adresse IP du serveur."
      read -p "Entrez le nom de domaine: " ptero_domain
    else
      read -p "Entrez l'adresse IP du serveur web (exemple : 10.0.10.12): " ptero_without_ssl_ip
      read -p "Entrez le port à utiliser (exemple : 80): " ptero_without_ssl_port
    fi
    echo -e ""
    read -p "Voulez-vous créer un utilisateur MariaDB pour les base de données des serveurs ? (y/n): " add_user_mariadb
    if [[ "$add_user_mariadb" == "y" ]]; then
      read -p "Entrez le nom d'utilisateur de votre compte (exemple: ptero): " new_admin_user
      read -s -p "Entrez le mot de passe de votre compte: " new_pass_user
      sudo mysql -e "CREATE USER '${new_admin_user}'@'%' IDENTIFIED BY '${new_pass_user}';"
      sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO '${new_admin_user}'@'%' WITH GRANT OPTION;"
    fi
    apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg
    LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
    curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
    apt update -y
    apt-add-repository universe
    apt -y install php8.1 php8.1-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip} tar unzip git redis-server
    curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
    mkdir -p /var/www/pterodactyl
    cd /var/www/pterodactyl
    curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
    tar -xzvf panel.tar.gz
    chmod -R 755 storage/* bootstrap/cache/
    sudo mysql -e "CREATE USER 'pterodactyl'@'127.0.0.1' IDENTIFIED BY '${pterodactyl_bdd_password}';"
    sudo mysql -e "CREATE DATABASE panel;"
    sudo mysql -e "GRANT ALL PRIVILEGES ON panel.* TO 'pterodactyl'@'127.0.0.1' WITH GRANT OPTION;"
    sudo mysql -e "FLUSH PRIVILEGES;"
    cp .env.example .env
    composer install --no-dev --optimize-autoloader
    php artisan key:generate --force
    echo -e "${RED}Utilisez les identifiants par défaut pour redis (déjà pré-installé) !" 
    php artisan p:environment:setup
    echo -e "${RED}Entrez le nom d'utilisateur par défaut (pterodactyl) et utilisez le mot de passe que vous avez spécifié ci-dessus !" 
    php artisan p:environment:database
    php artisan migrate --seed --force
    php artisan p:user:make
    chown -R www-data:www-data /var/www/pterodactyl/*
    cat << EOF | sudo tee /etc/systemd/system/pteroq.service > /dev/null
[Unit]
Description=Pterodactyl Queue Worker
After=redis-server.service

[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/pterodactyl/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable pteroq.service
    sudo systemctl start pteroq.service
    sudo systemctl enable --now redis-server
    sudo systemctl enable --now pteroq.service
    if [[ "$ptero_domain_boolean" == "y" ]]; then
    sudo apt update -y
    sudo apt install python3-certbot-nginx -y
    certbot --nginx -d $ptero_domain
    cat << EOF | sudo tee /etc/nginx/sites-enabled/pterodactyl.conf > /dev/null
server_tokens off;
server {
    listen 80;
    server_name $ptero_domain;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $ptero_domain;

    root /var/www/pterodactyl/public;
    index index.php;

    access_log /var/log/nginx/pterodactyl.app-access.log;
    error_log  /var/log/nginx/pterodactyl.app-error.log error;

    # allow larger file uploads and longer script runtimes
    client_max_body_size 100m;
    client_body_timeout 120s;

    sendfile off;

    # SSL Configuration - Replace the example $ptero_domain with your domain
    ssl_certificate /etc/letsencrypt/live/$ptero_domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$ptero_domain/privkey.pem;
    ssl_session_cache shared:SSL:10m;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";
    ssl_prefer_server_ciphers on;

    # See https://hstspreload.org/ before uncommenting the line below.
    # add_header Strict-Transport-Security "max-age=15768000; preload;";
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Robots-Tag none;
    add_header Content-Security-Policy "frame-ancestors 'self'";
    add_header X-Frame-Options DENY;
    add_header Referrer-Policy same-origin;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
        include /etc/nginx/fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF
    else
      cat << EOF | sudo tee /etc/nginx/sites-enabled/pterodactyl.conf > /dev/null
server {
    listen $ptero_without_ssl_port;
    server_name $ptero_without_ssl_ip;

    root /var/www/pterodactyl/public;
    index index.html index.htm index.php;
    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/pterodactyl.app-error.log error;

    client_max_body_size 100m;
    client_body_timeout 120s;

    sendfile off;

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF
    fi
    systemctl restart nginx
    curl -sSL https://get.docker.com/ | CHANNEL=stable bash
    systemctl enable --now docker
    GRUB_CMDLINE_LINUX_DEFAULT="swapaccount=1"
    mkdir -p /etc/pterodactyl
    curl -L -o /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_$([[ "$(uname -m)" == "x86_64" ]] && echo "amd64" || echo "arm64")"
    chmod u+x /usr/local/bin/wings
    cat << EOF | sudo tee /etc/systemd/system/wings.service > /dev/null
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service
PartOf=docker.service

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
LimitNOFILE=4096
PIDFile=/var/run/wings/daemon.pid
ExecStart=/usr/local/bin/wings
Restart=on-failure
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.targetqz
EOF

    sudo systemctl daemon-reload
    systemctl enable --now wings
    echo -e "${GREEN}Votre pterodactyl a bien été installé. Vous pouvez y accéder depuis l'addrese IP ou le domaine mentionné ci-dessus.${NC}"
}

update_ptero() {
  clear
  cd /var/www/pterodactyl
  php artisan down
  curl -L https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz | tar -xzv
  chmod -R 755 storage/* bootstrap/cache
  composer install --no-dev --optimize-autoloader
  php artisan view:clear
  php artisan config:clear
  php artisan migrate --seed --force
  chown -R www-data:www-data /var/www/pterodactyl/*
  php artisan queue:restart
  php artisan up
  echo -e "${GREEN}La mise à jours de Pterodactyl a été éffectué.${NC}"
}

add_mariadb_user() {
  read -p "Entrez le nom d'utilisateur de votre compte : " new_admin_user
  read -s -p "Entrez le mot de passe de votre compte: " new_pass_user
  sudo mysql -e "CREATE USER '${new_admin_user}'@'%' IDENTIFIED BY '${new_pass_user}';"
  sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO '${new_admin_user}'@'%' WITH GRANT OPTION;"
}


# Afficher le menu et demander à l'utilisateur de saisir une option
while true
do
  display_menu
  read -p "Choisissez l'option que vous souhaitez: " choice
  case $choice in
    1)
      update_system
      ;;
    2)
      install_packages
      ;;
    3)
      install_speedtest
      ;;
    4)
      create_user
      ;;
    5)
      update_system
      install_packages
      create_user
      ;;
    6)
      create_minecraft_server
      ;;
    7)
      create_bungeecord_server
      ;;
    8)
      create_fivem_server
      ;;
    9)
      install_ptero
      ;;
    10)
      update_ptero
      ;;
    11)
      install_nginx_php
      ;;
    12)
      install_phpmyadmin
      ;;
    13)
      install_plesk
      ;;
    14)
      setup_mariadb_server
      ;;
    15)
      add_mariadb_user
      ;;
    16)
      echo "${PURPEL}Merci d'avoir utiliser le script d'installation Linux de TX Tools. ${NC}"
      exit 0
      ;;
    *)
      echo "${RED}Option invalide. Veuillez choisir une option valide. ${NC}"
      ;;
  esac
done