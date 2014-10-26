Dockerfile - Spacewalk
==============================
### Build ###
```
root@ruo91:~# git clone https://github.com/ruo91/docker-spacewalk /opt/docker-spacewalk
root@ruo91:~# docker build --rm -t spacewalk /opt/docker-spacewalk
```

### Run ###
```
root@ruo91:~# docker run --privileged=true -d --name="spacewalk" -h "spackewalk" spacewalk
```
```
root@ruo91:~# docker inspect -f '{{ .NetworkSettings.IPAddress }}' spacewalk
172.17.0.126
```

## Nginx - Reverse proxy ###
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
	    server_name spacewalk.example.com;

        location / {
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Server $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass https://172.17.0.126:443;
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