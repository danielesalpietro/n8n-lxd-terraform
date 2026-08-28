#cloud-config

package_update: true
package_upgrade: true
packages:
  - curl
  - gnupg
  - postgresql
  - postgresql-contrib
  - ca-certificates

# Scritto prima di runcmd: evita heredoc fragili dentro runcmd
write_files:
  - path: /opt/n8n/ecosystem.config.js
    owner: root:root
    permissions: '0644'
    content: |
      module.exports = {
        apps: [{
          name: "n8n",
          script: "n8n",
          env: {
            GENERIC_TIMEZONE: "${timezone}",
            DB_TYPE: "postgresdb",
            DB_POSTGRESDB_DATABASE: "n8n",
            DB_POSTGRESDB_HOST: "localhost",
            DB_POSTGRESDB_PORT: "5432",
            DB_POSTGRESDB_USER: "${db_user}",
            DB_POSTGRESDB_PASSWORD: "${db_password}",
            N8N_BASIC_AUTH_ACTIVE: "true",
            N8N_BASIC_AUTH_USER: "${n8n_user}",
            N8N_BASIC_AUTH_PASSWORD: "${n8n_password}"
          }
        }]
      }

runcmd:
  # Aggiunge il repository NodeSource tramite GPG key (affidabile in ambienti non interattivi)
  - mkdir -p /etc/apt/keyrings
  - curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
  - echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
  - apt-get update -y
  - apt-get install -y nodejs

  # Configura PostgreSQL
  - sudo -u postgres psql -c "CREATE DATABASE n8n;"
  - sudo -u postgres psql -c "CREATE USER ${db_user} WITH ENCRYPTED PASSWORD '${db_password}';"
  - sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE n8n TO ${db_user};"
  - sudo -u postgres psql -c "ALTER DATABASE n8n OWNER TO ${db_user};"

  # Installa n8n e pm2 globalmente
  - npm install -g n8n pm2

  # Avvia n8n tramite PM2 e abilita il riavvio automatico al boot
  - env PATH=$PATH:/usr/bin pm2 start /opt/n8n/ecosystem.config.js
  - env PATH=$PATH:/usr/bin pm2 save
  - env PATH=$PATH:/usr/bin pm2 startup systemd -u root --hp /root
