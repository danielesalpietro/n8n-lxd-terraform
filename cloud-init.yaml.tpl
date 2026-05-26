# cloud-init.yaml.tpl
#cloud-config

package_update: true
package_upgrade: true
packages:
  - curl
  - postgresql
  - postgresql-contrib
  - ca-certificates

runcmd:
  # Installa Node.js 20 LTS
  - curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  - apt-get install -y nodejs

  # Configura PostgreSQL in modo non interattivo
  - sudo -u postgres psql -c "CREATE DATABASE n8n;"
  - sudo -u postgres psql -c "CREATE USER ${db_user} WITH ENCRYPTED PASSWORD '${db_password}';"
  - sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE n8n TO ${db_user};"
  - sudo -u postgres psql -c "ALTER DATABASE n8n OWNER TO ${db_user};"

  # Installa n8n e pm2
  - npm install -g n8n pm2

  # Prepara la directory e l'ecosystem di PM2 iniettando le variabili
  - mkdir -p /opt/n8n
  - |
    cat << 'EOF' > /opt/n8n/ecosystem.config.js
    module.exports = {
      apps : [{
        name   : "n8n",
        script : "n8n",
        env: {
          "GENERIC_TIMEZONE": "${timezone}",
          "DB_TYPE": "postgresdb",
          "DB_POSTGRESDB_DATABASE": "n8n",
          "DB_POSTGRESDB_HOST": "localhost",
          "DB_POSTGRESDB_PORT": "5432",
          "DB_POSTGRESDB_USER": "${db_user}",
          "DB_POSTGRESDB_PASSWORD": "${db_password}",
          "N8N_BASIC_AUTH_ACTIVE": "true",
          "N8N_BASIC_AUTH_USER": "${n8n_user}",
          "N8N_BASIC_AUTH_PASSWORD": "${n8n_password}"
        }
      }]
    }
    EOF

  # Avvia PM2 e configuralo per il boot automatico
  - env PATH=$PATH:/usr/bin pm2 start /opt/n8n/ecosystem.config.js
  - env PATH=$PATH:/usr/bin pm2 save
  - env PATH=$PATH:/usr/bin pm2 startup systemd -u root --hp /root
