#!/bin/sh
if [ ! -f "$FTP_TLS_CERTIFICATE_FILE" ] || [ ! -f "$FTP_TLS_CERTIFICATE_KEY_FILE" ]; then
    echo "🔐 SSL Keypair not found. Generating self-signed SSL keypair..."    
    openssl req -x509 -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost" -nodes -newkey rsa:2048 -keyout "$FTP_TLS_CERTIFICATE_KEY_FILE" -out "$FTP_TLS_CERTIFICATE_FILE" -days 365 >/dev/null 2>&1
    chmod 600 "${FTP_TLS_CERTIFICATE_KEY_FILE}"
    echo "✅ SSL Keypair generated..."
else
  echo "ℹ️ NOTICE: SSL certificate and private key already exist, so we'll use the existing files."
fi
echo "🚀 Starting ProFTPD..."
exec "$@"