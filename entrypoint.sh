#!/bin/bash
CERT=/root/crackerjack/data/config/http/ssl.crt
KEY=/root/crackerjack/data/config/http/ssl.pem
export FLASK_APP=app
echo $TRAEFIK_ENABLED
if [ ! -z $TRAEFIK_ENABLED ]
then
    echo "Reverse Proxy Setup Detected!"
    ldconfig
    mkdir -p /root/crackerjack/data/uploads && chown -R www-data:www-data /root/crackerjack/data && chmod -R 660 /root/crackerjack/data/uploads
    su www-data -s /bin/bash
    . venv/bin/activate
    flask crontab add
    /root/crackerjack/venv/bin/gunicorn --workers 3 --bind 0.0.0.0:$NGINX_PORT --forwarded-allow-ips=\"*\" --proxy-allow-from=\"*\" --log-level info --access-logfile /var/log/gunicorn.log --access-logformat="%({x-forwarded-for}i)s %(l)s %(u)s %(t)s \"%(r)s\" %(s)s %(b)s \"%(f)s\" \"%(a)s\"" -m 007 wsgi:app
else
    echo "Checking if SSL Certs are Present"
    if [[ -f "$CERT" && -f "$KEY" ]]; then
        echo "Certificates Detected!\nSkipping cert generation..."
    else
        if [ ! -d "/root/crackerjack/data/config/http" ]
        then
    	    mkdir -p /root/crackerjack/data/config/http
        fi
        if [ -z "$certSubject" ]
        then	   
            openssl req -x509 -nodes -days 3650 -newkey rsa:4096 -subj '/C=US/O=Crackerjack/CN=crackerjack.lan' -keyout /root/crackerjack/data/config/http/ssl.pem -out /root/crackerjack/data/config/http/ssl.crt 
        else
            openssl req -x509 -nodes -days 3650 -newkey rsa:4096 -subj \'"$certSubject"\' -keyout /root/crackerjack/data/config/http/ssl.pem -out /root/crackerjack/data/config/http/ssl.crt 
        fi
    fi
    ldconfig
    mkdir -p /root/crackerjack/data/uploads && chown -R www-data:www-data /root/crackerjack/data && chmod -R 660 /root/crackerjack/data/uploads
    su www-data -s /bin/bash
    . venv/bin/activate
    flask crontab add
    /root/crackerjack/venv/bin/gunicorn --workers 3 --bind 127.0.0.1:8888 -m 007 wsgi:app&
    deactivate
    nginx -g "daemon off;" 
fi
