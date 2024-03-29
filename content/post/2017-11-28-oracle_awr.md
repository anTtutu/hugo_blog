---
title: oracle知识梳理-awr\ash\addm日志开启并提取
date: 2017-11-28T21:46:20+08:00
tags: [ "oracle", "awr" ] 
description: "oracle知识梳理-awr\ash\addm日志开启并提取"
categories: [ "oracle", "awr" ]
toc: true
---

## 前言
之前工作经常搜集AWR日志，但是因工作环境的调整，6年下来的笔记都无法带出来，只能回忆一些和找一些网上的信息整理了。  
常规的性能分析，awr足够了，但是深层次的问题，需要更多的日志，下面整理下awr、ash、addm日志的手工提取方式

## 1、awr报告开启和提取操作步骤
### 前提条件
数据库为Oracle 10g以上版本。

### 背景信息
Oracle默认快照1小时生成一次、保持7天，可以根据需要调整快照生成的频率、保持时长。  
如果要手工生成快照，则用
```sql
~> sqlplus / as sysdba;登录数据库执行命令：
SQL> exec dbms_workload_repository.create_snapshot();
```
### 步骤1 以oracle用户登录操作系统。
### 步骤2 登录数据库。
```sql
~> sqlplus / as sysdba;
登录成功后，返回信息如下：
SQL*Plus: Release 11.1.0.7.0 - Production on Mon Jul 22 09:52:46 2013
 
Copyright (c) 1982, 2008, Oracle.  All rights reserved.
 
Connected to:
Oracle Database 11g Enterprise Edition Release 11.1.0.7.0 - 64bit Production
With the Partitioning, Oracle Label Security, OLAP, Data Mining,
Oracle Database Vault and Real Application Testing options
```
### 步骤3 生成AWR报表。
```sql
1. 开始收集AWR报表
SQL> @?/rdbms/admin/awrrpt.sql;
说明：
对某些系统，@特殊字符前面可能需要转义字符\，才能运行该命令。请运行命令：SQL> \@?/rdbms/admin/awrrpt.sql;
返回信息显示如下：
Current Instance 
~~~~~~~~~~~~~~~~
   DB Id    DB Name      Inst Num Instance
----------- ------------ -------- ------------
 4188289306 ORA11G              1 ora11g
 
Specify the Report Type
~~~~~~~~~~~~~~~~~~~~~~~
Would you like an HTML report, or a plain text report?
Enter 'html' for an HTML report, or 'text' for plain text
Defaults to 'html'
Enter value for report_type:

2. 输入报表的格式，有HTML格式、TEXT格式，默认HTML格式。
例如输入格式为html，返回信息如下：
Type Specified:  html
 
Instances in this Workload Repository schema
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
 DB Id     Inst Num DB Name      Instance     Host
------------ -------- ------------ ------------ ------------
* 4188289306        1 ORA11G       ora11g       linux_lbi_02
 
Using 4188289306 for database Id
Using          1 for instance number
 
Specify the number of days of snapshots to choose from
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Entering the number of days (n) will result in the most recent
(n) days of snapshots being listed.  Pressing <return> without
specifying a number lists all completed snapshots.
 
Enter value for num_days:1

3. 输入一个天数，Oracle会列出指定天数的所有快照信息。
例如输入一个天数为1，返回信息如下：
Listing the last day's Completed Snapshots
                       Snap
Instance     DB Name        Snap Id    Snap Started    Level
------------ ------------ --------- ------------------ -----
ora11g       ORA11G            3166 22 Jul 2013 00:00      1
                               3167 22 Jul 2013 01:00      1
                               3168 22 Jul 2013 02:00      1
                               3169 22 Jul 2013 03:00      1
                               3170 22 Jul 2013 04:00      1
                               3171 22 Jul 2013 05:00      1
                               3172 22 Jul 2013 06:00      1
                               3173 22 Jul 2013 07:00      1
                               3174 22 Jul 2013 08:00      1
                               3175 22 Jul 2013 09:00      1
Specify the Begin and End Snapshot Ids
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Enter value for begin_snap:

4. 输入起始snap Id和结束snap Id，收集两个时刻间段的数据库性能数据。
起始snap Id和结束snap Id这两个时间段之间，不能关闭或启动数据库，否则会报错。
注意：
例如输入起始snap Id为3166，结束snap Id为3168，返回信息如下：
Specify the Begin and End Snapshot Ids 
Enter value for begin_snap: 3166
Begin Snapshot Id specified: 3166 
Enter value for end_snap: 3168
End   Snapshot Id specified: 3168 
Specify the Report Name
~~~~~~~~~~~~~~~~~~~~~~~
The default report file name is awrrpt_1_3166_3168.html.  To use this name,
press <return> to continue, otherwise enter an alternative.
Enter value for report_name:

5. 输入报表名
默认以snap Id命名，可以不输入。
如下所示为生成的AWR报表样例：
Report written to awrrpt_1_3166_3168.html
```
### 步骤4 如果没指定目录和文件名，生成的AWR报表在当前目录，执行如下命令查看。
```sql
1. 回到当前目录。
SQL> host;

2. 查看报表。
~> ls
返回信息显示如下：
awrrpt_1_3166_3168.html
----结束
```

## 2、ash报告开启和提取操作步骤:
收集活动会话的历史信息、短暂的性能问题（比如只是持续几分钟的性能问题）、特定时段的数据库运行的性能状态信息，以及针对特定的模块、SQL_ID、SESSION_ID、service等来收集的性能状态信息。  
### 背景信息
ASH每秒钟收集一次当前处于非空闲等待事件的、活动状态的session的信息，不收集空闲的会话。

### 步骤1 以Oracle用户登录操作系统。
### 步骤2 登录数据库。
```sql
:~> sqlplus / as sysdba; 
```
### 步骤3 生成ASH报表
```sql
1. 开始收集ASH报表。
SQL> @?/rdbms/admin/ashrpt.sql;
对某些系统，@特殊字符前面可能需要转义字符\，才能运行该命令。请运行命令：SQL> \@?/rdbms/admin/awrrpt.sql;
返回信息显示如下：
SQL> @?/rdbms/admin/ashrpt.sql;
Current Instance
~~~~~~~~~~~~~~~~
   DB Id    DB Name      Inst Num Instance
----------- ------------ -------- ------------
 4188289306 ORA11G              1 ora11g 
Specify the Report Type
~~~~~~~~~~~~~~~~~~~~~~~
Enter 'html' for an HTML report, or 'text' for plain text
Defaults to 'html'
Enter value for report_type:

2. 输入报表的格式，有HTML格式、TEXT格式，默认HTML格式。
例如输入格式为html，返回信息如下：
Type Specified:  html
Instances in this Workload Repository schema
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   DB Id     Inst Num DB Name      Instance     Host
------------ -------- ------------ ------------ ------------
* 4188289306        1 ORA11G       ora11g       linux_lbi_02
Defaults to current database
Using database id: 4188289306
Defaults to current instance
Using instance number: 1
ASH Samples in this Workload Repository schema
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Oldest ASH sample available:  22-Jul-13 08:00:43   [  11641 mins in the past]
Latest ASH sample available:  30-Jul-13 10:00:28   [      1 mins in the past]
Specify the timeframe to generate the ASH report
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Enter begin time for report:
--    Valid input formats:
--      To specify absolute begin time:
--        [MM/DD[/YY]] HH24:MI[:SS]
--        Examples: 02/23/03 14:30:15
--                  02/23 14:30:15
--                  14:30:15
--                  14:30
--      To specify relative begin time: (start with '-' sign)
--        -[HH24:]MI
--        Examples: -1:15  (SYSDATE - 1 Hr 15 Mins)
--                  -25    (SYSDATE - 25 Mins)
Defaults to -15 mins
Enter value for begin_time: 07/29/2013 19:00:00

3. 按照提示的有效格式输入收集信息的开始时间。
有效格式有：
a、具体的日期和时间，如02/23/03 14:30:15。
b、当天的某个时间，如14:30:15或14:30。
c、相对时间，如距当前时间1个半小时输入-1:30，距当前时间15分钟输入-15。
例如输入时间07/29/2013 19:00:00，返回信息如下：
Report begin time specified: 07/29/2013 19:00:00
Enter duration in minutes starting from begin time:
Defaults to SYSDATE - begin_time
Press Enter to analyze till current time
Enter value for duration: 20

4. 输入需要收集信息的时间跨度，单位为分钟。
如上所示，收集信息的时间跨度为20分钟。
返回信息如下：
Report duration specified:   20
Using 29-Jul-13 19:00:00 as report begin time
Using 29-Jul-13 19:20:00 as report end time
……………….
Specify the Report Name
~~~~~~~~~~~~~~~~~~~~~~~
The default report file name is ashrpt_1_0729_1920.html.  To use this name,
press <return> to continue, otherwise enter an alternative.
Enter value for report_name:

5. 输入报表名，默认以“ashrpt_instance_Id_日期_时间”命名，可以不输入。
如下所示为生成的ASH报表样例：
Report written to ashrpt_1_0729_1920.html
```
### 步骤4 如果没指定目录和文件名，生成的ASH报表在当前目录，执行如下命令查看。
```sql
1. 回到当前目录。
SQL> host;

2. 查看报表。
:~> ls
返回信息显示如下：
ashrpt_1_0729_1920.html
----结束
```

## 3、ADDM日志开启和提取操作步骤:
收集定期内的数据库状态、潜在的数据库性能瓶颈，以及内建专家系统给出的Oracle性能调优方法和数据统计分析。

### 步骤1 以oracle用户登录操作系统。
### 步骤2 登录数据库。
```sql
:~> sqlplus / as sysdba; 
```
### 步骤3 生成addm报表。
```sql
1. 开始收集addm报表。
SQL> @?/rdbms/admin/addmrpt; 
对某些系统，@特殊字符前面可能需要转义字符\，才能运行该命令。请运行命令：SQL> \@?/rdbms/admin/awrrpt.sql;
返回信息显示如下：
Current Instance 
~~~~~~~~~~~~~~~~ 
 
   DB Id    DB Name      Inst Num Instance 
----------- ------------ -------- ------------ 
 1049289546 HUNAO               1 hunao 
......  
Listing the last 3 days of Completed Snapshots 
                                                        Snap 
Instance     DB Name        Snap Id    Snap Started    Level 
------------ ------------ --------- ------------------ ----- 
hunao        HUNAO             3311 28 Jul 2013 08:00      1 
                               ...... 
                               3315 28 Jul 2013 12:00      1 
                               3316 28 Jul 2013 13:00      1

2. 根据Oracle列出的snap Id提示，输入起始snap Id和结束snap Id，收集两个时段的数据库性能数据。
例如输入起始snap Id为3311，结束snap Id为3316，返回信息如下：
Specify the Begin and End Snapshot Ids 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
Enter value for begin_snap: 3311 --指定开始snap id 
Begin Snapshot Id specified: 3316
 
Enter value for end_snap: 3311 --指定结束snap id 
End   Snapshot Id specified: 3316
 
Specify the Report Name 
...... 
Enter value for report_name:

3. 输入报表名，默认以snap Id命名，可以不输入。
如下所示为生成的ADDM报表样例：
Report written to addmrpt_1_3311_3316.txt
```
### 步骤4 如果没指定目录和文件名，生成的ADDM报表在当前目录，执行如下命令查看。
```sql
1. 回到当前目录。
SQL> host;

2. 查看报表。
:~> ls
返回信息显示如下：
addmrpt_1_3311_3316.txt
----结束
```