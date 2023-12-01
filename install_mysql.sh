#!/bin/bash

# 更新系统包
echo "正在更新系统包..."
sudo yum update -y || { echo "系统包更新失败"; exit 1; }

# 检查 wget 和 rpm 是否存在
which wget &>/dev/null || { echo "wget 未安装"; exit 1; }
which rpm &>/dev/null || { echo "rpm 未安装"; exit 1; }

# 添加 MySQL Yum 仓库
echo "正在添加 MySQL Yum 仓库..."
wget https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm || { echo "下载 MySQL Yum 仓库失败"; exit 1; }
sudo rpm -ivh mysql57-community-release-el7-11.noarch.rpm || { echo "安装 MySQL Yum 仓库失败"; exit 1; }

# 安装 MySQL
echo "正在安装 MySQL..."
sudo yum install mysql-server -y || { echo "MySQL 安装失败"; exit 1; }

# 启动 MySQL 服务
echo "正在启动 MySQL 服务..."
sudo systemctl start mysqld || { echo "MySQL 服务启动失败"; exit 1; }
sudo systemctl enable mysqld || { echo "MySQL 服务设置开机启动失败"; exit 1; }

# 检查 MySQL 服务状态
if ! sudo systemctl is-active --quiet mysqld; then
    echo "MySQL 服务未运行"
    exit 1
fi

# 获取临时密码
temp_password=$(sudo grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}') || { echo "获取临时密码失败"; exit 1; }

# 设置新的 MySQL root 密码
echo "请设置 MySQL root 用户的新密码:"
read -s root_password

# 安全安装
echo "正在进行 MySQL 安全安装..."
sudo mysql_secure_installation <<EOF

$temp_password
Y
$root_password
$root_password
Y
Y
Y
Y
EOF

# 提示用户是否需要创建新的数据库
echo "是否需要创建一个新的数据库？(y/n)"
read create_db

if [ "$create_db" = "y" ]; then
  echo "请输入新数据库的名称:"
  read db_name
  echo "正在创建数据库 $db_name ..."
  mysql -u root -p$root_password -e "CREATE DATABASE $db_name;" || { echo "数据库创建失败"; exit 1; }
  echo "数据库 $db_name 创建成功."
fi

echo "MySQL 5.7 安装完成."
