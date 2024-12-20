#!/bin/sh
if [ ! -f "$FTP_TLS_CERTIFICATE_FILE" ] || [ ! -f "$FTP_TLS_CERTIFICATE_KEY_FILE" ]; then
    echo "🔐 SSL Keypair not found. Generating self-signed SSL keypair..."    
    openssl req -x509 -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost" -nodes -newkey rsa:2048 -keyout "$FTP_TLS_CERTIFICATE_KEY_FILE" -out "$FTP_TLS_CERTIFICATE_FILE" -days 365 >/dev/null 2>&1
    chmod 600 "${FTP_TLS_CERTIFICATE_KEY_FILE}"
    echo "✅ SSL Keypair generated..."
else
  echo "ℹ️ NOTICE: SSL certificate and private key already exist, so we'll use the existing files."
fi

if [ -n "$FTP_MASQUERADE_ADDRESS" ]; then
    echo "ℹ️ FTP_MASQUERADE_ADDRESS is set. Adding MasqueradeAddress to proftpd.conf..."
    echo "" >> /etc/proftpd/proftpd.conf
    echo "MasqueradeAddress %{env:FTP_MASQUERADE_ADDRESS}" >> /etc/proftpd/proftpd.conf
    echo "✅ MasqueradeAddress added to proftpd.conf"

    if [ -d "/etc/letsencrypt/live/$FTP_MASQUERADE_ADDRESS" ]; then
        echo "ℹ️ Let's Encrypt SSL certificate found. Setting proper permissions..."
        chown -R proftpd:proftpd "/etc/letsencrypt/live/$FTP_MASQUERADE_ADDRESS"
        chmod -R 640 "/etc/letsencrypt/live/$FTP_MASQUERADE_ADDRESS"
        echo "✅ Let's Encrypt SSL certificate permissions set"
    fi
else
    echo "ℹ️ FTP_MASQUERADE_ADDRESS is not set. Skipping MasqueradeAddress configuration."
fi

echo "🚀 Starting ProFTPD..."
exec "$@"