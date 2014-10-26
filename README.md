Dockerfile - Spacewalk
======================
### Run ###
```
root@ruo91:~# docker run --privileged=true -d --name="spacewalk" ruo91/spacewalk
```
or

### Build ###
```
root@ruo91:~# git clone https://github.com/ruo91/docker-spacewalk /opt/docker-spacewalk
root@ruo91:~# docker build --rm -t spacewalk /opt/docker-spacewalk
```

### Run ###
```
root@ruo91:~# docker run --privileged=true -d --name="spacewalk" spacewalk
```
```
root@ruo91:~# docker inspect -f '{{ .NetworkSettings.IPAddress }}' spacewalk
172.17.0.126
```

## Nginx - Reverse proxy ###
Generating Self-signed Certificate
```
root@ruo91:~# mkdir /etc/nginx/ssl
root@ruo91:~# cd /etc/nginx/ssl
```

```
root@ruo91:~# openssl genrsa -des3 -out spacewalk.key 1024
Generating RSA private key, 1024 bit long modulus
..........................................................++++++
......................................................++++++
e is 65537 (0x10001)
Enter pass phrase for spacewalk.key:
Verifying - Enter pass phrase for spacewalk.key:
root@ruo91:~# openssl req -new -key spacewalk.key -out spacewalk.csr
Enter pass phrase for spacewalk.key:
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:KR
State or Province Name (full name) [Some-State]:Seoul
Locality Name (eg, city) []:Yeongdeungpo-gu
Organization Name (eg, company) [Internet Widgits Pty Ltd]:Yongbok.net
Organizational Unit Name (eg, section) []:System Team
Common Name (e.g. server FQDN or YOUR name) []:spacewalk.example.com
Email Address []:ruo91@yongbok.net

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

```
root@ruo91:~# cp spacewalk.key spacewalk.key.bak
root@ruo91:~# openssl rsa -in spacewalk.key.bak -out spacewalk.key
Enter pass phrase for spacewalk.key.bak:
writing RSA key
```

```
root@ruo91:~# openssl x509 -req -days 365 -in spacewalk.csr -signkey spacewalk.key -out spacewalk.crt
Signature ok
subject=/C=KR/ST=Seoul/L=Yeongdeungpo-gu/O=Yongbok.net/OU=System Team/CN=spacewalk.example.com/emailAddress=ruo91@yongbok.net
Getting Private key
```

```
root@ruo91:~# cat /etc/nginx/nginx.conf
## Nginx ##
user nginx;
pid logs/nginx.pid;
error_log logs/error.log;
access_log off;
 
worker_processes 2;
events {
    worker_connections 1024;
    use epoll;
}

http {
    include mime.types;
    default_type application/octet-stream;
    types_hash_max_size 2048;
    server_names_hash_bucket_size 64;
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
    '$status $body_bytes_sent "$http_referer" '
    '"$http_user_agent" "$http_x_forwarded_for"';
 
    ## TCP options
    tcp_nodelay on;
    tcp_nopush on;

    # Virtualhost
    server {
        listen  80;
        listen  443;
        server_name spacewalk.example.com;

	# SSL
	ssl on;
	ssl_certificate			ssl/spacewalk.crt;
	ssl_certificate_key		ssl/spacewalk.key;
	ssl_protocols			SSLv3 TLSv1;
	ssl_prefer_server_ciphers	on;
	ssl_ciphers			ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv3:+EXP:HIGH:!aNULL:!MD5;

        location / {
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Server $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass https://localhost:443;
            client_max_body_size 10M;
        }
    }
}
```
```
root@ruo91:~# service nginx restart 
```

### Web UI ###
Create Spacewalk Administrator
![Create Spacewalk Administrator][1]

Spacewalk Overview
![Spacewalk Overview][2]

[1]: http://cdn.yongbok.net/ruo91/img/spacewalk/01_create_spacewalk_administrator.png
[2]: http://cdn.yongbok.net/ruo91/img/spacewalk/02_spacewalk_overview.png
