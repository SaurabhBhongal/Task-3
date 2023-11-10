#!/bin/bash


sudo apt update
sudo apt install -y apache2 mariadb-server mariadb-client php libapache2-mod-php composer npm

# Install Snipe-IT
composer global require "laravel/installer"
composer create-project --prefer-dist snipe/snipe-it snipe-it
cd snipe-it
composer install --no-dev --prefer-source

# Configure the Snipe-IT .env file
cp .env.example .env

# Generate a random application key
php artisan key:generate

# Database credentials
DB_PASSWORD=$(openssl rand -base64 12)
DB_USERNAME="snipeit"
DB_DATABASE="snipeit"

# Create the database and user and grant privileges
mysql -u root -e "CREATE DATABASE ${DB_DATABASE}"
mysql -u root -e "CREATE USER '${DB_USERNAME}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}'"
mysql -u root -e "GRANT ALL PRIVILEGES ON ${DB_DATABASE}.* TO '${DB_USERNAME}'@'localhost'"
mysql -u root -e "FLUSH PRIVILEGES"

# Update the .env file with database credentials
sed -i "s/DB_HOST=127.0.0.1/DB_HOST=localhost/" .env
sed -i "s/DB_DATABASE=homestead/DB_DATABASE=${DB_DATABASE}/" .env
sed -i "s/DB_USERNAME=homestead/DB_USERNAME=${DB_USERNAME}/" .env
sed -i "s/DB_PASSWORD=secret/DB_PASSWORD=${DB_PASSWORD}/" .env

# Run the database migrations and seed the database
php artisan migrate --seed

# Start the Snipe-IT web application
php artisan serve
