# Nginx 安装

> - [nginx 官网][nginx] 
> - nginx 有两种安装方式，一是使用 nginx 的源码进行编译安装；二是使用编译好的软件包（rpm包）直接安装。
> - 本文档中使用的系统版本为：**CentOS Linux release 7.4.1708 (Core)**
> - 本文档中使用的 nginx 版本为：**1.18.0** 
> - 本文档中使用到的安装包： [nginx 安装包][nginx package] ，[nginx 依赖包][nginx dependency] 



## 一、源码编译安装

> 本文档中使用 **普通用户** 进行安装，已创建好 **admin 用户** 并添加 `sudo` 权限；
>
> `sudo` 权限主要用于安装 nginx 依赖包。



### 1. 下载源码包

在 [nginx 官网](http://nginx.org/en/download.html) 下载源码包，有 3 个版本可供选择：

- **Mainline version** ：主线版本，相当于开发版本
- **Stable version** ：稳定版本
- **Legacy versions** ：历史版本

本文档中选择的是稳定版本：[nginx-1.18.0](http://nginx.org/download/nginx-1.18.0.tar.gz) 



### 2. 检查源码编译环境

> nginx 源码编译依赖于 `gcc、pcre、zlib、openssl` ，需要事先准备好编译环境。
>
> gcc 是 C 语言编译库；pcre 是正则表达式库；zlib 是 数据压缩库；openssl 是数据传输加密库；



#### 2.1 gcc 库

##### 2.1.1 检查

使用以下任一方式检查均可：

```bash
#1.查看 gcc 版本
gcc -v

#若已安装，则输出以下版本信息：
#使用内建 specs。
#COLLECT_GCC=gcc
#COLLECT_LTO_WRAPPER=/usr/libexec/gcc/x86_64-redhat-linux/4.8.5/lto-wrapper
#目标：x86_64-redhat-linux
#配置为：../configure --prefix=/usr --mandir=/usr/share/man --infodir=/usr/share/info --with-bugurl=http://bugzilla.redhat.com/bugzilla --enable-bootstrap --enable-shared --enable-threads=posix --enable-checking=release --with-system-zlib --enable-__cxa_atexit --disable-libunwind-exceptions --enable-gnu-unique-object --enable-linker-build-id --with-linker-hash-style=gnu --enable-languages=c,c++,objc,obj-c++,java,fortran,ada,go,lto --enable-plugin --enable-initfini-array --disable-libgcj --with-isl=/builddir/build/BUILD/gcc-4.8.5-20150702/obj-x86_64-redhat-linux/isl-install --with-cloog=/builddir/build/BUILD/gcc-4.8.5-20150702/obj-x86_64-redhat-linux/cloog-install --enable-gnu-indirect-function --with-tune=generic --with-arch_32=x86-64 --build=x86_64-redhat-linux
#线程模型：posix
#gcc 版本 4.8.5 20150623 (Red Hat 4.8.5-44) (GCC)

#===================================================================================

#2.检查已安装的软件包，需包含 gcc 和 libgcc 包
rpm -qa | grep gcc

#若已安装，则输出以下软件包信息：
#gcc-4.8.5-44.el7.x86_64
#libgcc-4.8.5-44.el7.x86_64
```

##### 2.1.2 安装

- 在线安装，安装命令如下：

```bash
sudo yum -y install gcc
```

- 离线安装，安装方法如下：

将 [gcc 离线软件包][gcc] 上传到 `~/soft/gcc` 目录后，执行以下命令安装：

```bash
cd ~/soft/gcc
sudo rpm -Uvh *.rpm --nodeps --force
```



#### 2.2 pcre 库

##### 2.2.1 检查

```bash
#检查已安装的软件包，需包含 pcre 和 pcre-devel 包
rpm -qa | grep pcre

#若已安装，则输出以下软件包信息：
#pcre-8.32-17.el7.x86_64
#pcre-devel-8.32-17.el7.x86_64
```

##### 2.2.2 安装

- 在线安装，安装命令如下：

```bash
sudo yum -y install pcre pcre-devel
```

- 离线安装，安装方法如下：

将 [pcre 离线软件包][pcre] 上传到 `~/soft/pcre` 目录后，执行以下命令安装：

```bash
cd ~/soft/pcre
sudo rpm -Uvh *.rpm --nodeps --force
```



#### 2.3 zlib 库

##### 2.3.1 检查

```bash
#检查已安装的软件包，需包含 zlib 和 zlib-devel 包
rpm -qa | grep zlib

#若已安装，则输出以下软件包信息：
#zlib-1.2.7-19.el7_9.x86_64
#zlib-devel-1.2.7-19.el7_9.x86_64
```

##### 2.3.2 安装

- 在线安装，安装命令如下：

```bash
sudo yum -y install zlib zlib-devel
```

- 离线安装，安装方法如下：


将 [zlib 离线软件包][zlib] 上传到 `~/soft/zlib` 目录后，执行以下命令安装：

```bash
cd ~/soft/zlib
sudo rpm -Uvh *.rpm --nodeps --force
```



#### 2.4 openssl 库

##### 2.4.1 检查

使用以下任一方式检查均可：

```bash
#1.查看 openssl 版本
openssl version

#若已安装，则输出以下版本信息：
#OpenSSL 1.0.2k-fips  26 Jan 2017

#===================================================================================

#2.检查已安装的软件包，需包含 openssl 和 openssl-libs 包
rpm -qa | grep openssl

#若已安装，则输出以下软件包信息：
#openssl-1.0.2k-8.el7.x86_64
#openssl-libs-1.0.2k-8.el7.x86_64
```

##### 2.4.2 安装

- 在线安装，安装命令如下：


```bash
sudo yum -y install openssl
```

- 离线安装，安装方法如下：

将 [openssl 离线软件包][openssl] 上传到 `~/soft/openssl` 目录后，执行以下命令安装：

```bash
cd ~/soft/openssl
sudo rpm -Uvh *.rpm --nodeps --force
```



### 3. 源码编译并安装

将源码包 [nginx-1.18.0.tar.gz][nginx package] 上传到 `~/soft` 目录后，执行以下命令进行解压缩：

```bash
cd ~/soft
tar -zxvf nginx-1.18.0.tar.gz
```

解压完成后，执行以下命令编译源码并安装：

```bash
cd  ~/soft/nginx-1.18.0
./configure --prefix=/home/admin/nginx

#--prefix 参数：指定编译后的安装目录，必须使用绝对路径，安装过程中会自动创建；
#--prefix 若不指定使用默认路径 /usr/local/nginx ；使用普通用户安装时最好另外指定安装目录；

#编译完成后进行安装操作，执行以下命令：
make && make install
```

> [configure 命令参数详解](http://nginx.org/en/docs/configure.html) 



### 4. 修改默认端口

> nginx 默认端口为 80，在 linux 系统中小于 1024 的端口为特殊端口，必须要有 `root` 用户权限才能启动。

使用以下命令修改默认端口：

```bash
cd ~/nginx/conf/
vi nginx.conf

#找到监听的80端口位置，改为其他大于1024的端口，保存退出
```



### 5. 启动 nginx

使用以下命令启动 nginx 服务：

```bash
cd ~/nginx/sbin/
./nginx

#检查是否启动成功
ps -ef | grep nginx

#若启动成功，则会输出以下信息：
#admin      9742      1  0 10:39 ?        00:00:00 nginx: master process ./nginx
#admin      9743   9742  0 10:39 ?        00:00:00 nginx: worker process
#admin      9820   1334  0 10:49 pts/1    00:00:00 grep --color=auto nginx
```



### 6. 添加 nginx 命令软链接

> - 添加软链接后，可以直接使用 nginx 命令进行操作，不再需要切换到 `~/nginx-1.18.0/sbin/` 目录后再使用 nginx 命令；
> - 此步操作只为方便使用 nginx 命令，可以省略；

使用以下命令创建软链接：

```bash
#创建时必须使用绝对路径
sudo ln -s /home/admin/nginx/sbin/nginx /usr/local/sbin/nginx

#检查软链接是否创建成功
ll /usr/local/sbin/ | grep nginx
#lrwxrwxrwx. 1 root root 35 3月  10 11:19 nginx -> /home/admin/nginx-1.18.0/sbin/nginx

#创建成功后可以直接使用nginx命令，如下查看nginx版本：
nginx -v
#nginx version: nginx/1.18.0
```



## 二、离线包安装

> - nginx 离线安装包（rpm包）是已经编译完成的安装包，所以无需依赖编译环境，安装更加快捷方便。
>
> - 由于离线包默认安装目录为 `/etc/nginx` ，所以当前安装用户必须要拥有 `root` 用户权限；本文档中使用 `root` 用户进行安装。



### 1. 下载离线包

访问 [离线包下载地址][nginx mirror] ，选择需要的版本进行下载，本文档中使用 ***nginx-1.18.0-1.el7.ngx.x86_64.rpm*** 版本；



### 2. 检查安装环境

> 离线包安装安装时依赖 openssl 库，所以还要检查 openssl 库。

#### 2.1 openssl 库

> 参考 **一、源码编译安装** 的 [2.4 openssl 库](#24-openssl-库) 



### 3. 安装 nginx

将 nginx 离线包 **[nginx-1.18.0-1.el7.ngx.x86_64.rpm][nginx package]** 上传到 `~/soft` 目录后，执行以下命令安装：

```bash
cd ~/soft
rpm -ivh nginx-1.18.0-1.el7.ngx.x86_64.rpm
```

> 默认安装目录 `/etc/nginx` 



### 4. 启动 nginx

使用以下命令启动 nginx 服务：

```bash
nginx

#检查是否启动成功
ps -ef | grep nginx

#若启动成功，则会输出以下信息：
#root       1376      1  0 10:41 ?        00:00:00 nginx: master process nginx
#nginx      1377   1376  0 10:41 ?        00:00:00 nginx: worker process
#root       1379   1304  0 10:41 pts/0    00:00:00 grep --color=auto nginx
```



## 三、Nginx 相关命令

### 1. 查看版本号

```bash
nginx -v
```



### 2. 启动

```bash
nginx
```



### 3. 重新加载配置文件

```bash
nginx -s reload
```



### 4. 停止

```bash
#1.快速停止
nginx -s stop

#2.正常停止
nginx -s quit

#3.通过进程ID停止
#nginx有1个主进程和几个工作进程；通过 ps -ef |grep nginx 命令可以查看。
#正常停止，推荐使用
kill -s QUIT master_process_id
#强制停止
kill -9 master_process_id worker_process_id
```



### 5. 检查配置文件

> 可以查看 nginx 配置文件位置

```bash
nginx -t

#输出如下信息：
#nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
#nginx: configuration file /etc/nginx/nginx.conf test is successful
```



### 6. 指定配置文件

> 通过 -c 参数指定配置文件

```bash
#1.启动时指定
nginx -c config.path.conf

#2.重新加载时指定
nginx -s reload -c config.path.conf

#3.检查时指定
nginx -t -c config.path.conf
```



### 7. 重新打开日志文件

```bash
nginx -s reopen
```

用于生成新的日志文件，防止日志文件过大，操作命令如下：

```bash
#将原日志文件重命名
mv access.log access_20201016.log
#重新生成日志文件
nginx -s reopen
```









[nginx]: http://nginx.org "nginx 官网"
[gcc]: soft/centos7/gcc "gcc 离线软件包"
[pcre]: soft/centos7/pcre "pcre 离线软件包"
[zlib]: soft/centos7/zlib "zlib 离线软件包"
[openssl]: soft/centos7/openssl "openssl 离线软件包"
[nginx package]: soft/nginx "nginx 安装包"
[nginx dependency]: soft/centos7 "nginx 依赖包"
[nginx mirror]: http://nginx.org/packages/centos/7/x86_64/RPMS/ "nginx 镜像站"



