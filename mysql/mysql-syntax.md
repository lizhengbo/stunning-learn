# MySQL 语法

> - [MySQL官方参考手册][Reference Manual]



## 一、语法

### 1.1 索引

```mysql
-- 创建普通索引
CREATE INDEX index_no ON test_user (user_no);
ALTER TABLE test_user ADD INDEX index_no (user_no);

-- 创建唯一索引
CREATE UNIQUE INDEX unindex_no ON test_user (user_no);
ALTER TABLE test_user ADD UNIQUE unindex_no (user_no);

-- 删除索引
DROP INDEX index_no ON test_user;
ALTER TABLE test_user DROP INDEX unindex_no;

-- 添加主键
ALTER TABLE test_user ADD PRIMARY KEY (id);

-- 删除主键
ALTER TABLE test_user DROP PRIMARY KEY;

-- 查看执行计划
EXPLAIN SELECT * FROM test_user where id = 1;
```



### 1.2 时间查询

```mysql
select t.gmt_create from case_info t where t.gmt_create > '2020-01-01' and t.gmt_create < '2020-03-18';

select t.gmt_create from case_info t where t.gmt_create BETWEEN '2020-01-01' and '2020-03-18';

select DATE_FORMAT(t.gmt_create,'%Y-%m-%d %H:%i:%s') from case_info t where t.gmt_create BETWEEN STR_TO_DATE('2020-01-01','%Y-%m-%d') and STR_TO_DATE('2020-03-18','%Y-%m-%d');

-- 查询今天的数据
select * from case_info t where DATE_FORMAT(t.gmt_create,'%Y-%m-%d') = DATE_FORMAT(now(),'%Y-%m-%d');
-- DATEDIFF() 函数返回两个日期之间的天数。只有值的日期部分参与计算。
SELECT t.id,t.gmt_create,now(),DATEDIFF(t.gmt_create,now()) FROM `user_log` t where DATEDIFF(t.gmt_create,now()) = 0;

-- 查询昨天的数据
SELECT t.id,t.gmt_create,now(),DATEDIFF(t.gmt_create,now()) FROM `user_log` t where DATEDIFF(t.gmt_create,now()) = -1;

-- 查询最近一天的数据
-- DATE_SUB() 函数从日期减去指定的时间间隔。
SELECT t.* FROM `user_log` t where t.gmt_create > DATE_SUB(now(),INTERVAL 1 DAY);
-- DATE_ADD() 函数向日期添加指定的时间间隔。
SELECT t.* FROM `user_log` t where DATE_ADD(t.gmt_create,INTERVAL 1 DAY) > now();
```



### 1.3 数据量查询

```mysql
-- data_length   数据大小
-- index_length  索引大小

-- 查询所有数据的大小
select sum(data_length + index_length) / 1024 / 1024 "Total Size in MB"
  from information_schema.TABLES;

-- 查看指定数据库的大小
select sum(data_length + index_length) / 1024 / 1024 "Database Size in MB", table_schema "Database Name"
  from information_schema.TABLES
 where table_schema = "test_db";

-- 查看指定数据库的某个表的大小
select sum(data_length + index_length) / 1024 / 1024 "Table Size in MB",table_schema "Database Name", table_name "Table Name"
  from information_schema.TABLES
 where table_schema = "test_db"
   and table_name = 'test_table';
```



### 1.4 查询字段重复的数据

```mysql
select online_user_name from case_evidence group by online_user_name having count(1) > 1;
```



### 1.5 表相关

```mysql
-- 删除表
-- 语法: DROP TABLE [IF EXISTS] 表名1 [, 表名2, 表名3...];
DROP TABLE IF EXISTS `test_user`;

-- 创建表
CREATE TABLE `test_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_type` tinyint(4) DEFAULT 2 COMMENT '用户类型 [1 管理员;2 普通]',
  `user_no` varchar(32) DEFAULT NULL COMMENT '用户编号',
  `user_name` varchar(128) DEFAULT NULL COMMENT '用户姓名',
  `user_info` text COMMENT '用户信息',
  -- `gmt_create` datetime DEFAULT NULL COMMENT '创建时间',
  -- `gmt_modify` datetime DEFAULT NULL COMMENT '修改时间',
  `gmt_create` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modify` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户表';

-- 修改表名
-- 语法: ALTER TABLE <旧表名> RENAME [TO] <新表名>;
ALTER TABLE test_user RENAME test_user1;
```

> **关于时间类型字段的默认值说明：**
>
> 1. TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
>
>    在创建新记录和修改现有记录的时候都对这个数据列刷新；
>
> 2. TIMESTAMP DEFAULT CURRENT_TIMESTAMP
>
>    在创建新记录的时候把这个字段设置为当前时间，但以后修改时，不再刷新它；
>
> 3. TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
>
>    在创建新记录的时候把这个字段设置为0，以后修改时刷新它；
>
> 4. TIMESTAMP DEFAULT ‘yyyy-mm-dd hh:mm:ss’ ON UPDATE CURRENT_TIMESTAMP
>
>    在创建新记录的时候把这个字段设置为给定值，以后修改时刷新它；
>



### 1.6 字段相关

```mysql
-- 添加字段
-- 语法: ALTER TABLE <表名> ADD COLUMN <字段名> <数据类型> [[NOT] NULL] [DEFAULT <默认值>] COMMENT <注释> AFTER <字段名> [,ADD COLUMN ...];
ALTER TABLE test_user
ADD COLUMN add_field1 varchar(1024) DEFAULT NULL COMMENT '附加字段1' AFTER id,
ADD COLUMN add_field2 text COMMENT '附加字段2' AFTER add_field1;

-- 删除字段
-- 语法: ALTER TABLE <表名> DROP COLUMN <字段名> [,DROP COLUMN ...];
ALTER TABLE test_user
DROP COLUMN add_field1,
DROP COLUMN add_field2;

-- 修改字段
-- 语法: ALTER TABLE <表名> MODIFY COLUMN <字段名> <数据类型> [[NOT] NULL] [DEFAULT <默认值>] COMMENT <注释> AFTER <字段名> [,MODIFY COLUMN ...];
ALTER TABLE test_user
MODIFY COLUMN user_no varchar(128) DEFAULT '000' COMMENT '用户编号' AFTER user_type,
MODIFY COLUMN user_name varchar(128) NOT NULL COMMENT '用户姓名' AFTER user_no;

-- 重命名字段
-- 语法: ALTER TABLE <表名> CHANGE COLUMN <旧字段名> <新字段名> <数据类型> [[NOT] NULL] [DEFAULT <默认值>] COMMENT <注释> AFTER <字段名> [,CHANGE COLUMN ...];
ALTER TABLE test_user CHANGE COLUMN user_no user_no1 varchar(32) DEFAULT NULL COMMENT '用户编号' AFTER user_type;

-- 以上内容可同时执行
-- ALTER TABLE <表名>
-- [ADD COLUMN...],
-- [DROP COLUMN...],
-- [MODIFY COLUMN...],
-- [CHANGE COLUMN...];
```

> - BLOB, TEXT, GEOMETRY,  JSON 类型的字段不能设置默认值，也不需要设置 **NOT NULL** ；
>
> - BLOB 和 TEXT 类型
>
>   1. BLOB 和 TEXT 的区别是 BLOB 存储二进制数据，TEXT 存储非二进制字符串；
>   2. 最大长度说明
>
>   | 类型                   | 最大长度                  | 说明   |
>   | ---------------------- | ------------------------- | ------ |
>   | tinyblob, tinytext     | 255 bytes (2^8-1)         |        |
>   | blob, text             | 65535 bytes (2^16-1)      | ~ 64kb |
>   | mediumblob, mediumtext | 16777215 bytes (2^24-1)   | ~ 16MB |
>   | longblob, longtext     | 4294967295 bytes (2^32-1) | ~ 4GB  |



### 1.7 sql_mode 说明

> 执行 SQL 语句时，出现以下错误：
>
> [Err] 1055 - Expression #1 of ORDER BY clause is not in GROUP BY clause and contains nonaggregated column 'information_schema.PROFILING.SEQ' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by
>
> **错误原因** ：在MySQL5.7之后，sql_mode 中默认存在 ONLY_FULL_GROUP_BY ，SQL 语句未通过ONLY_FULL_GROUP_BY 语义检查所以报错。

解决方案：

1. 查看 **sql_mode** 值，执行以下 sql 语句：

```mysql
select @@sql_mode;

-- 查询结果
-- ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
```

2. 将查询结果中的 **ONLY_FULL_GROUP_BY** 删除后，添加到 mysql 配置文件中

```bash
vi /etc/my.cnf

#在[mysqld]部分中添加以下内容
sql_mode=STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
```

3. 重启 mysql 服务

```bash
#CentOS6命令：
service mysqld restart

#CentOS7命令：
systemctl restart mysqld.service
```



## 二、命令行

### 2.1 登录

```bash
#语法: mysql [-hip] [-Pport] -uuser -p[passwd]
#[] 表示可省略部分
#-h 指定远程服务IP
#-P 大写，指定端口，默认端口3306
#-u 指定用户名
#-p 小写，指定密码；未指定密码时回车输入密码；
#-h、-P、-u与指定内容之间的空格可有可无，-p与密码之间不能有空格；
#passwd若有特殊符号，需使用单引号('')包围；

#本地连接
mysql -uroot -p123456
#远程连接并指定端口
mysql -h192.168.142.141 -P3306 -uroot -p

#退出登录
#使用 exit 或 quit 命令
```

 

### 2.2 数据库相关

```bash
#创建数据库
#语法: create database [if not exists] <数据库名>
#     [[default] character set <字符集名>] 
#     [[default] collate <排序规则名>];
#使用默认字符集
create database test_db;
create database if not exists test_db1;
#指定字符集
create database test_db2 character set utf8mb4 collate utf8mb4_general_ci;
create database test_db3 default character set utf8mb4 default collate utf8mb4_general_ci;

#删除数据库
#语法: drop database [if exists] <数据库名>
drop database test_db1;
drop database if exists test_db2;

#查看所有数据库
show databases;

#选择数据库
#语法: use database_name;
use test_db1;

#查看所有表
show tables;

#查看简单的表结构
#语法: desc table_name;
#     describe table_name;
#     show columns from table_name;
#desc是describe的简写形式；以上3种命令输出结果相同；
desc case_info;
describe case_info;
show columns from case_info;

#查看详细的结构，包括注释
#语法: show full fields from table_name;
show full fields from case_info;

#查看建表语句
#语法: show create table table_name;
show create table case_info;

#查看数据库最大连接数
show variables like 'max_connection%';

#查看数据库端口
show variables like 'port';

#查看表名区分大小写设置：如果设置为0，表名将按指定存储，并且比较区分大小写。如果设置为1，则表名在磁盘上以小写形式存储，并且比较不区分大小写。如果设置为2，则表名按给定存储，但以小写形式进行比较。
show variables like '%lower_case_table_names%';

#查看时区
show variables like '%time_zone%';
```



### 2.3 导入数据

#### 2.3.1 mysql 命令导入

```bash
#语法: mysql [-hip] [-Pport] -uuser -p[passwd] [dbname] < /../mysql.sql
#[] 表示可省略部分
#-h 指定远程服务IP
#-P 大写，指定端口，默认端口3306
#-u 指定用户名
#-p 小写，指定密码；未指定密码时回车输入密码；
#-h、-P、-u与指定内容之间的空格可有可无，-p与密码之间不能有空格；
#passwd若有特殊符号，需使用单引号('')包围；
#若mysql.sql脚本文件中包括创建并指定数据库，可以不指定dbname；
#若mysql.sql脚本文件不在命令行当前目录下，需指定文件路径；

#本地导入，已建数据库test_db
mysql -uroot -p test_db < /root/test_db_init.sql
#远程导入，已建数据库test_db
mysql -h192.168.142.141 -P3306 -uroot -p test_db < test_db_update.sql
```



#### 2.3.2 source 命令导入

```bash
#1.登录数据库
mysql -uroot -p

#2.选择数据库
#mysql> use test_db;

#3.使用source命令导入
#语法: source mysql.sql
#需指定脚本文件mysql.sql的路径
#mysql> source /root/test_db_update.sql;
```



### 2.4 导出数据

```bash
#语法: mysqldump [-hip] [-Pport] -uuser -p[passwd] [dbname] [tablename...] > /../dump.sql
#[] 表示可省略部分
#-h 指定远程服务IP
#-P 大写，指定端口，默认端口3306
#-u 指定用户名
#-p 小写，指定密码；未指定密码时回车输入密码；
#-h、-P、-u与指定内容之间的空格可有可无，-p与密码之间不能有空格；
#passwd若有特殊符号，需使用单引号('')包围；
#dump.sql表示备份文件的名称，文件名前面可以加绝对路径；

#导出整个数据库，以日期命名备份文件
#当天日期
mysqldump -uroot -p test_db > /root/test_db_dump_`date +%Y%m%d%H%M%S`.sql
#前一天日期；"-1 hour"：前一小时；
mysqldump -uroot -p test_db > /root/test_db_dump_`date -d "-1 day" +%Y%m%d%H%M%S`.sql

#导出数据库中的某张表
mysqldump -uroot -p test_db test_table1 > table1_dump.sql
mysqldump -uroot -p test_db test_table1 test_table2 > tables_dump.sql

#导出全部数据库；参数: --all-databases 或 -A
mysqldump -uroot -p -A > all_db.sql

#导出几个数据库；参数: --databases 或 -B
#参数后面所有名字都被看作数据库名
mysqldump -uroot -p -B test_db test_db1 > dbs.sql

#不导出任何数据，只导出数据库表结构；参数: --no-data 或 -d
#整个数据库
mysqldump -uroot -p -d test_db > test_db_d.sql
#某张表
mysqldump -uroot -p -d test_db test_table1 > test_table1_d.sql
```

> 说明：
>
> - 在 crontab 定时任务中生成的备份文件大小为0时，可能是在 crontab 里面无法识别到 mysqldump 命令，需要指定 mysqldump 命令的绝对路径；
> - 使用命令 `which mysqldump` 获取 mysqldump 命令的绝对路径；
>
> - MySQL备份脚本示例：
>
> ```sh
> #!/bin/sh
> 
> #user_name为数据库用户名
> #user_passwd为数据库密码
> #db_name为数据库实例名
> #/admin/home/dump为备份文件存储目录
> mysqldump -uuser_name -puser_passwd db_name > /admin/home/dump/db_name_`date +%Y%m%d%H%M%S`.sql
> 
> #备份文件名以前一天的日期命名
> #mysqldump -uuser_name -puser_passwd db_name > /admin/home/dump/db_name_`date -d "-1 day" +%Y%m%d`.sql
> 
> #远程访问方式,添加-h参数,再加上远程IP地址
> #mysqldump -h192.168.132.22 -uuser_name -puser_passwd db_name > /admin/home/dump/db_name_`date -d "-1 day" +%Y%m%d`.sql
> 
> #删除7天以前的数据库备份文件
> #find /admin/home/dump -mtime +7 -name "db_name_*.sql" -exec rm -rf {} \; #不推荐使用
> find /admin/home/dump -mtime +7 -name "db_name_*.sql" | xargs rm -rf
> 
> #上述内容写入备份脚本文件dump.sh
> 
> #设置crontab定时任务,每天1点备份
> #crontab -e
> #>/dev/null 2>&1 : 丢弃标准输出和错误输出
> #0 1 * * * /admin/home/dump/dump.sh > /dev/null 2>&1
> ```



### 2.5 字符集

#### 2.5.1 查看字符集

```bash
#字符集
show variables like 'character%';
# +--------------------------+----------------------------+
# | Variable_name            | Value                      |
# +--------------------------+----------------------------+
# | character_set_client     | utf8                       |
# | character_set_connection | utf8                       |
# | character_set_database   | latin1                     |
# | character_set_filesystem | binary                     |
# | character_set_results    | utf8                       |
# | character_set_server     | latin1                     |
# | character_set_system     | utf8                       |
# | character_sets_dir       | /usr/share/mysql/charsets/ |
# +--------------------------+----------------------------+

#排序规则
show variables like 'collation%';
# +----------------------+-------------------+
# | Variable_name        | Value             |
# +----------------------+-------------------+
# | collation_connection | utf8_general_ci   |
# | collation_database   | latin1_swedish_ci |
# | collation_server     | latin1_swedish_ci |
# +----------------------+-------------------+
```



#### 2.5.2 设置字符集

- 修改配置文件 `my.cnf` ，以在 Linux 系统下，修改为 `utf8mb4` 字符集为例说明：

```bash
vi /etc/my.cnf

#添加以下配置信息：

#[client]部分可不添加，效果与[mysql]部分相同
[client]
default-character-set=utf8mb4

#[mysql]部分配置连接字符集和排序规则
#影响变量：character_set_client、character_set_connection、character_set_results、collation_connection
[mysql]
default-character-set=utf8mb4

#[mysqld]部分配置服务端字符集和排序规则
#影响变量：character_set_database、character_set_server、collation_database、collation_server
[mysqld]
character-set-server=utf8mb4
collation-server=utf8mb4_general_ci

#配置文件修改后，重启mysql服务
systemctl restart mysqld.service

#检查字符集
# mysql> show variables like 'character%';
# +--------------------------+----------------------------+
# | Variable_name            | Value                      |
# +--------------------------+----------------------------+
# | character_set_client     | utf8mb4                    |
# | character_set_connection | utf8mb4                    |
# | character_set_database   | utf8mb4                    |
# | character_set_filesystem | binary                     |
# | character_set_results    | utf8mb4                    |
# | character_set_server     | utf8mb4                    |
# | character_set_system     | utf8                       |
# | character_sets_dir       | /usr/share/mysql/charsets/ |
# +--------------------------+----------------------------+
# 8 rows in set (0.01 sec)
# 
# mysql> show variables like 'collation%';
# +----------------------+--------------------+
# | Variable_name        | Value              |
# +----------------------+--------------------+
# | collation_connection | utf8mb4_general_ci |
# | collation_database   | utf8mb4_general_ci |
# | collation_server     | utf8mb4_general_ci |
# +----------------------+--------------------+
# 3 rows in set (0.00 sec)
```

> 配置文件说明：
>
> - Linux 系统下配置文件为 `my.cnf` ，默认路径 `/etc/my.cnf` ；可使用命令 `mysql --help | grep my.cnf` 查找配置文件位置；
> - Windows 系统下配置文件为 `my.ini` ，默认路径 `C:\ProgramData\MySQL\MySQL Server 5.7` ，该文件夹为隐藏文件夹；



### 2.6 Windows 下无法在 cmd 中使用 mysql 命令

- 修改系统环境变量，编辑 `Path` 变量，添加 MySQL 的 **bin 文件夹** 路径；



## 三、Navicat 使用

### 3.1 快捷键

```bash
ctrl + q          # 打开查询窗口
ctrl + /          # 注释sql语句
ctrl + shift + /  # 解除注释
ctrl + r          # 运行查询窗口的sql语句
ctrl + shift+r    # 只运行选中的sql语句
F6                # 打开一个mysql命令行窗口
ctrl + l          # 删除一行
ctrl + n          # 打开一个新的查询窗口
ctrl + w          # 关闭一个查询窗口
```



### 3.2 设置字段 NULL 值

直接在需要设置 NULL 的字段上面右键，不要使用左键点击选中再右键；

















[Reference Manual]: https://dev.mysql.com/doc/refman/5.7/en/ "MySQL 官方参考手册"

