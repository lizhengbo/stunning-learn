# Nginx 配置

> - [nginx 官方文档][nginx docs] 



## 一、配置文件说明

```nginx

#...       #main块（全局块）

events {   #events块
   #...
}

#引入其他配置文件
#语境：any
include /root/nginx/tcp.nginx.conf;

http {    #http块

    #设置客户端连接保持活动的超时时间，即长连接保持时间；
    #语法：keepalive_timeout timeout [header_timeout];
    #第一个参数：设置客户端与服务端之间 keep-alive 的超时时间，表现为http响应头：Connection: keep-alive ；设置为 0 时，禁用 keep-alive 连接，表现为http响应头：Connection: close
    #第二个参数：若设置，响应头会增加 keep-alive 字段，表现为http响应头：Keep-Alive: timeout=header_timeout ；
    #两个参数的值可以不同；
    #默认：keepalive_timeout 75s;
    #语境：http, server, location
    keepalive_timeout 75s;

    #设置读取客户端请求头的超时时间。如果客户端在此时间内未传输整个请求头，则返回 408 (Request Time-out) 错误。
    #语法：client_header_timeout time;
    #默认：client_header_timeout 60s;
    #语境：http, server
    client_header_timeout 60s;

    #设置读取客户端请求体的超时时间。此超时时间为两次连续读取操作之间的时间间隔，而不是整个请求体的传输时间。如果客户端在此时间内未传输任何内容，则返回 408 (Request Time-out) 错误。
    #语法：client_body_timeout time;
    #默认：client_body_timeout 60s;
    #语境：http, server, location
    client_body_timeout 60s;

    #设置允许客户端请求体的最大大小。如果请求体大小超过此限制，则返回 413 (Request Entity Too Large) 错误。设置为 0 时，不检查请求体大小；
    #语法：client_max_body_size size;
    #默认：client_max_body_size 1m;
    #语境：http, server, location
    client_max_body_size 20m;

    #设置将响应传输到客户端的超时时间。此超时时间为两次连续写操作之间的时间间隔，而不是整个响应的传输时间。如果客户端在此时间内未收到任何信息，则连接将关闭。
    #语法：send_timeout time;
    #默认：send_timeout 60s;
    #语境：http, server, location
    send_timeout 60s;

    #设置与代理服务器建立连接的超时时间。此超时时间通常不能超过 75s 。
    #语法：proxy_connect_timeout time;
    #默认：proxy_connect_timeout 60s;
    #语境：http, server, location
    proxy_connect_timeout 60s;

    #设置从代理服务器读取响应的超时时间。此超时时间为两次连续读取操作之间的时间间隔，而不是整个响应的读取时间。如果代理服务器在此时间内未传输任何内容，则连接将关闭。
    #语法：proxy_read_timeout time;
    #默认：proxy_read_timeout 60s;
    #语境：http, server, location
    proxy_read_timeout 60s;

    #设置将请求传输到代理服务器的超时时间。此超时时间为两次连续写操作之间的时间间隔，而不是整个请求的传输时间。如果代理服务器在这段时间内未收到任何信息，则连接将关闭。
    #语法：proxy_send_timeout time;
    #默认：proxy_send_timeout 60s;
    #语境：http, server, location
    proxy_send_timeout 60s;

    #简单配置反向代理
    #server {
    #    listen 8082;                          #监听的端口号
    #    server_name localhost;                #
    #    location / {                          #斜杠（/）代表根目录
    #        #root html;                       #根目录
    #        proxy_pass http://127.0.0.1:8080; #转发地址
    #        #index index.html index.htm;      #设置默认页
    #    }
    #}

    #==================================================================================

    #根据访问的路径跳转到不同端口的服务中
    server {
        listen 8083;                          #监听的端口号
        server_name localhost;                #设置虚拟服务器的名称
        location / {
            proxy_pass http://myserver2;
        }
        location ^~ /dev {                    #斜杠（/）代表根目录
            proxy_pass http://127.0.0.1:8080; #转发地址
        }
        location ^~ /sit {                    #斜杠（/）代表根目录      
            proxy_pass http://127.0.0.1:8081; #转发地址
        }
    }

    #==================================================================================

    #配置负载均衡
    
    #1.轮询（默认）
    #每个请求按时间顺序逐一分配到不同的后端服务器，如果后端服务器down掉，能自动剔除。 
    upstream myserver1 {
        server 127.0.0.1:8080;
        server 127.0.0.1:8081;
    }

    #2.指定权重
    #指定轮询几率，weight和访问比率成正比，用于后端服务器性能不均的情况
    upstream myserver2 {
        server 127.0.0.1:8080 weight=4;
        server 127.0.0.1:8081 weight=6;
    }

    #3.ip_hash
    #每个请求按访问ip的hash结果分配，这样每个访客固定访问一个后端服务器，可以解决session的问题
    upstream myserver3 {
        ip_hash;
        server 127.0.0.1:8080;
        server 127.0.0.1:8081;
    }

    #虚拟主机的配置
    server {
        listen 8082;             #监听端口
        server_name localhost;   #
        location / {                       #对 "/" 启用反向代理
            proxy_pass http://myserver1;   #转发地址
    #        proxy_set_header Host $host;
    #        proxy_set_header X-Real-IP $remote_addr;                       #在web服务器端获得用户的真实ip 需配置条件①    【 $remote_addr值 = 用户ip 】
    #        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;   #在web服务器端获得用户的真实ip 需配置条件②；后端的Web服务器可以通过X-Forwarded-For获取用户真实IP
        }
    }

}

#================================================================================================


stream {   #stream块，用于tcp转发配置；必须和events块、http块平级

    upstream mysqls {
        hash $remote_addr consistent;
        server 192.168.58.143:3306 weight=5 max_fails=3 fail_timeout=30s;
        server 192.168.58.142:3306 weight=1 max_fails=3 fail_timeout=30s;
    }

    server {
        listen 9945;   #监听的端口号
        proxy_connect_timeout 1s;
        proxy_timeout 3s;
        proxy_pass mysqls;
    }

    upstream dns {
       server 192.168.0.1:53535;
       server 192.168.0.2:53;
    }

    server {
        listen 5053;   #监听的端口号
        proxy_timeout 20s;
        proxy_pass dns;
    }

}

#================================================================================================
```



## 二、配置示例

### 1. http 代理配置

> 语境：http

```nginx
server {
    listen 8087;
    server_name localhost;
    location / {
        proxy_pass http://192.168.142.142:8080;
    }
}

server {
    listen 8088;
    server_name localhost;
    location / {
        proxy_pass http://192.168.142.142:8081;
    }
}

server {
    listen 8089;
    server_name localhost;
    location / {
        proxy_pass http://192.168.142.142:8082;
    }
}

upstream tomcat1 {
    server 192.168.142.142:8080;
    server 192.168.142.142:8081;
    server 192.168.142.142:8082;
}

server {
    listen 8081;
    server_name localhost;
    location / {
        proxy_pass http://tomcat1;
    }
}
```



```nginx
#根据不同的访问域名转发到不同的服务器
#请求客户端的hosts文件中添加：192.168.142.141 www.tomcat7.com www.tomcat8.com www.tomcat9.com
#nginx通过匹配请求中的"host"字段确定路由到哪个服务器；如果其值与任何服务器名称都不匹配，或者请求根本不包含此标头字段，则nginx会将请求路由到该端口的默认服务器；默认服务器是第一个服务器，也可以使用"default_server"指定；
#localhost实际是无效的名称
#server_name可以使用IP命名
server {
    listen 8087;
    server_name www.tomcat7.com;
    location / {
        proxy_pass http://192.168.142.142:8080;
    }
}

server {
    listen 8087 default_server;
    server_name www.tomcat8.com;
    location / {
        proxy_pass http://192.168.142.142:8081;
    }
}

server {
    listen 8087;
    server_name www.tomcat9.com;
    location / {
        proxy_pass http://192.168.142.142:8082;
    }
}
```



### 2. tcp 代理配置

> 语境：main

```nginx
stream {

    upstream mysql1 {
        server 101.37.16.186:3306;
    }
    server {
        listen 33000;
        proxy_connect_timeout 1s;
        proxy_timeout 3s;
        proxy_pass mysql1;
    }

    #配置多个
    #upstream xxx {...}
    #server {...}

}
```











[nginx docs]: http://nginx.org/en/docs/ "nginx 官方文档"

