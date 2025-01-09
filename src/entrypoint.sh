#!/bin/sh
if [ ! -f "$FTP_TLS_CERTIFICATE_FILE" ] || [ ! -f "$FTP_TLS_CERTIFICATE_KEY_FILE" ]; then
    if [ "$FTP_TLS_WAIT_FOR_CERTIFICATE" = "true" ]; then
        echo "🔐 SSL Keypair not found. Waiting for certificate to be generated (timeout: ${FTP_TLS_WAIT_TIMEOUT}s)..."
        timeout_counter=0
        while [ ! -f "$FTP_TLS_CERTIFICATE_FILE" ] || [ ! -f "$FTP_TLS_CERTIFICATE_KEY_FILE" ]; do
            remaining=$((FTP_TLS_WAIT_TIMEOUT - timeout_counter))
            echo -ne "\r⏳ Waiting... ${remaining}s remaining"
            sleep 1
            timeout_counter=$((timeout_counter + 1))
            if [ $timeout_counter -ge "$FTP_TLS_WAIT_TIMEOUT" ]; then
                echo -e "\n❌ ERROR: Timeout reached while waiting for SSL certificate."
                echo "No file found at ${FTP_TLS_CERTIFICATE_FILE} or ${FTP_TLS_CERTIFICATE_KEY_FILE}. Exiting..."
                exit 1
            fi
        done
        echo -e "\n✅ Certificate files found!"
    else
        echo "🔐 SSL Keypair not found. Generating self-signed SSL keypair..."    
        openssl req -x509 -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost" -nodes -newkey rsa:2048 -keyout "$FTP_TLS_CERTIFICATE_KEY_FILE" -out "$FTP_TLS_CERTIFICATE_FILE" -days 365 >/dev/null 2>&1
        chmod 600 "${FTP_TLS_CERTIFICATE_KEY_FILE}"
        echo "✅ SSL Keypair generated..."
    fi
else
  echo "ℹ️ NOTICE: SSL certificate and private key already exist, so we'll be using the following files:"
  echo "  - ${FTP_TLS_CERTIFICATE_FILE}"
  echo "  - ${FTP_TLS_CERTIFICATE_KEY_FILE}"
fi

if [ -n "$FTP_MASQUERADE_ADDRESS" ]; then
    echo "ℹ️ FTP_MASQUERADE_ADDRESS is set. Adding MasqueradeAddress to proftpd.conf..."
    echo "" >> /etc/proftpd/proftpd.conf
    echo "MasqueradeAddress %{env:FTP_MASQUERADE_ADDRESS}" >> /etc/proftpd/proftpd.conf
    echo "✅ MasqueradeAddress added to proftpd.conf"

    if [ -d "/etc/letsencrypt/live/$FTP_MASQUERADE_ADDRESS" ]; then
        echo "ℹ️ Let's Encrypt SSL certificate found. Checking permissions..."
        current_owner=$(stat -c '%U' "/etc/letsencrypt/live/$FTP_MASQUERADE_ADDRESS")
        current_perms=$(stat -c '%a' "/etc/letsencrypt/live/$FTP_MASQUERADE_ADDRESS")
        
        if [ "$current_owner" != "$FTP_USER" ]; then
            echo "Updating ownership to ${FTP_USER}..."
            chown -R "${FTP_USER}" "/etc/letsencrypt/live/$FTP_MASQUERADE_ADDRESS"
        fi
        
        if [ "$current_perms" != "640" ]; then
            echo "Updating permissions to 640..."
            chmod -R 640 "/etc/letsencrypt/live/$FTP_MASQUERADE_ADDRESS"
        fi
        
        echo "✅ Let's Encrypt SSL certificate permissions verified"
    fi
else
    echo "ℹ️ FTP_MASQUERADE_ADDRESS is not set. Skipping MasqueradeAddress configuration."
fi

echo "🚀 Starting ProFTPD..."
exec "$@"