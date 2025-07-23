#!/bin/bash
set -e

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server ufw

sed -i 's/^bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl restart mysql

until mysqladmin ping --silent; do
  sleep 2
done

mysql -u root <<EOF
CREATE USER IF NOT EXISTS '${mysql_admin}'@'%' IDENTIFIED BY '${mysql_password}';
GRANT ALL PRIVILEGES ON *.* TO '${mysql_admin}'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;


CREATE DATABASE IF NOT EXISTS farmia;
USE farmia;

CREATE TABLE IF NOT EXISTS transactions (
  transaction_id VARCHAR(15),
  timestamp       BIGINT NOT NULL,
  product_id      VARCHAR(10) NOT NULL,
  category        VARCHAR(20) NOT NULL,
  quantity        INT NOT NULL,
  price           FLOAT NOT NULL,
  PRIMARY KEY (transaction_id, product_id)
);

EOF

ufw allow 3306
ufw allow 22
ufw --force enable
