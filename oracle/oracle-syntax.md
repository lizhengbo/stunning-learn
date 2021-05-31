# Oracle 语法

## 一、语法

### 1.1 查询字段重复的数据

```sql
select deal_id from EVI_DATA_MAIN group by deal_id having count(1) > 1;

select attach_md5 from EVI_DATA_ATTACH group by attach_md5,data_id,savepoint_id,product_id having count(1) > 1;
```



### 1.2 高水位线

```sql
-- 查询表的高水位线：使用dba用户
SELECT segment_name, segment_type, blocks FROM dba_segments WHERE segment_name = 'EVI_DATA_MAIN';

-- 更新高水位线:适用于10g/11g;更新后索引失效,需要重建索引
alter table EVI_DATA_MAIN enable row movement;
alter table EVI_DATA_MAIN shrink space;
```

> 注：删除大表数据时最好用TRUNCATE，TRUNCATE会重新设置高水位线和所有的索引；



### 1.3 索引

```sql
-- 查询索引是否有效：STATUS=VALID表示有效
-- 根据表名查询
SELECT TABLE_NAME, INDEX_NAME, STATUS FROM USER_INDEXES WHERE TABLE_NAME = 'EVI_DATA_MAIN';
-- 根据索引名查询
SELECT TABLE_NAME, INDEX_NAME, STATUS FROM USER_INDEXES WHERE INDEX_NAME = 'EDM_IDX1';

-- 创建索引
-- 唯一索引
CREATE UNIQUE INDEX EDM_IDX2 ON EVI_DATA_MAIN (RECORD_NO);
-- 普通索引
CREATE INDEX EDM_IDX3 ON EVI_DATA_MAIN (PARENT_RECORD_NO, SAVEPOINT_ID, PRODUCT_ID);
-- 位图索引：优化 group by 查询
CREATE BITMAP INDEX EDM_IDX5 ON EVI_DATA_MAIN (EVI_CHAIN_ID);

-- 删除索引
DROP INDEX EDM_IDX2;


-- 查看执行计划或使用PL/SQL中的“解释计划”按钮
-- 1.先执行SQL
explain plan for select * from evi_data_main t where t.deal_id = 'HZYBB000002';
-- 2.后查看执行计划
select * from table(dbms_xplan.display);
```

> 索引和 **SORT ORDER BY STOPKEY** 的关系；
>
> 索引扫描类型；



### 1.4 主键

```sql
-- 1.建表时创建主键
create table student1 (
  id number(10) not null primary key,
  name varchar2(16)
);

-- 2.建表时创建主键，constraint pk_id 命名主键，可省略
create table student2 (
  id number(10) not null,
  name varchar2(16),
  -- primary key(id)   -- 命名可省略
  constraint pk_id primary key(id)
);

-- 3.建表后添加主键
-- 无命名主键
alter table table_name add primary key (field, [field1]...);
-- 有命名主键
alter table table_name add constraint pk_name primary key(field, [field1]...);

-- 4.删除主键
alter table table_name drop constraint pk_name;

-- 5.查询主键名称，TABLE_NAME 必须大写
select t.* from user_cons_columns t where t.table_name  = 'TABLE_NAME' and t.position is not null;
```



### 1.5 操作表和字段

```sql
-- 创建表
create table student1 (
  id number(10) not null primary key,
  name varchar2(16)
);

-- 重命名表
-- alter table table_name rename to new_table_name;
alter table student1 rename to new_student1;

-- 删除表
-- drop table table_name;
drop table student1;

-- 添加表注释
-- comment on table table_name is '注释';
comment on table student1 is '学生表1';

-- 添加字段，多个字段时必须加括号
-- alter table table_name add (column_name data_type [default default_value] [null/not null], ...);
alter table student1 add age number(2) default 8 not null;
alter table student1 add (gender number(1), address varchar2(64) default '杭州');

-- 添加字段注释
-- comment on column table_name.column_name is '注释';
comment on column student1.age is '年龄';

-- 删除字段
-- 1.删除一列
-- alter table table_name drop column column_name;
alter table student1 drop column age;
-- 2.删除多列
-- alter table table_name drop (column_name1, column_name2...);
alter table student1 drop (gender, address);

-- 修改字段，多个字段时必须加括号
-- alter table table_name modify (column_name data_type [default default_value] [null/not null], ...);
alter table student1 modify age number(3) default 6 null;
alter table student1 modify (gender varchar2(1) not null, address varchar2(32) not null);

-- 重命名字段
-- alter table table_name rename column column_name to new_column_name;
alter table student1 rename column address to new_address;
```



### 1.6 时间查询

```sql
-- 时间格式大小写不敏感

select to_char(sysdate,'yyyy-MM-dd HH24:mi:ss') from dual;

select to_date('2005-01-01 13:14:20','yyyy-MM-dd HH24:mi:ss') from dual;

select to_char(t.save_time, 'yyyy-MM-dd')
  from EVI_DATA_MAIN t
 where t.gmt_create > to_date('2019-10-20', 'yyyy-MM-dd')
   and t.gmt_create < to_date('2019-10-21', 'yyyy-MM-dd');

select to_char(t.save_time, 'YYYY-MM-DD')
  from EVI_DATA_MAIN t
 where t.gmt_create between to_date('2019-10-20', 'yyyy-MM-dd') and to_date('2019-10-21', 'yyyy-MM-dd');
```



### 1.7 表空间

```sql
-- 注：使用dba用户

-- 查看表空间信息
select * from dba_data_files;

-- 查看表空间是否具有自动扩展的能力
SELECT T.TABLESPACE_NAME,
       D.FILE_NAME,
       D.AUTOEXTENSIBLE,
       D.BYTES,
       D.MAXBYTES,
       D.STATUS
  FROM DBA_TABLESPACES T, DBA_DATA_FILES D
 WHERE T.TABLESPACE_NAME = D.TABLESPACE_NAME
 ORDER BY TABLESPACE_NAME, FILE_NAME;


-- 查询表空间使用情况
SELECT UPPER(F.TABLESPACE_NAME) "表空间名",
       D.TOT_GROOTTE_MB "表空间大小(M)",
       D.TOT_GROOTTE_MB - F.TOTAL_BYTES "已使用空间(M)",
       TO_CHAR(ROUND((D.TOT_GROOTTE_MB - F.TOTAL_BYTES) / D.TOT_GROOTTE_MB * 100,
                     2),
               '990.99') "使用比",
       F.TOTAL_BYTES "空闲空间(M)",
       F.MAX_BYTES "最大块(M)"
  FROM (SELECT TABLESPACE_NAME,
               ROUND(SUM(BYTES) / (1024 * 1024), 2) TOTAL_BYTES,
               ROUND(MAX(BYTES) / (1024 * 1024), 2) MAX_BYTES
          FROM SYS.DBA_FREE_SPACE
         GROUP BY TABLESPACE_NAME) F,
       (SELECT DD.TABLESPACE_NAME,
               ROUND(SUM(DD.BYTES) / (1024 * 1024), 2) TOT_GROOTTE_MB
          FROM SYS.DBA_DATA_FILES DD
         GROUP BY DD.TABLESPACE_NAME) D
 WHERE D.TABLESPACE_NAME = F.TABLESPACE_NAME
 ORDER BY 4 DESC;
 
 -- 创建表空间
 -- 首先要创建临时表空间
 -- 创建表空间示例1
 CREATE TABLESPACE TBS_SNBANK_DAT DATAFILE 'C:/app/Administrator/oradata/orcl/TBS_SNBANK_DAT.dbf' SIZE 2G;
CREATE USER snbank IDENTIFIED BY "snbank" DEFAULT TABLESPACE TBS_SNBANK_DAT TEMPORARY TABLESPACE TEMP;
grant all privileges to snbank ;

-- 创建表空间示例2
CREATE TABLESPACE BQ_JCFC_DAT DATAFILE '/data/cgdb/BQ_JCFC_DAT.dbf' SIZE 2G;
CREATE USER ebkj IDENTIFIED BY "ebkj" DEFAULT TABLESPACE BQ_JCFC_DAT TEMPORARY TABLESPACE TEMP;
grant all privileges to ebkj ;
```



### 1.8 用户相关

```sql
-- 查询用户信息：使用dba用户
select * from dba_users;

-- 更新用户密码：使用dba用户
-- 语法: alter user <用户名> identified by <新密码>;
-- Oracle默认密码有效期为180天；
alter user EBKJ identified by ebkj2018;
```



## 二、MyBatis中like写法

```sql
-- 1.mybatis中oracle的like写法
-- AND eac.CASE_NO LIKE '%' || #{caseNo} || '%'
-- AND eac.CASE_NO LIKE CONCAT(CONCAT('%', #{caseNo}), '%')

-- 2.mybatis中mysql的like写法
-- AND eac.CASE_NO LIKE CONCAT('%', #{caseNo}, '%')
```

