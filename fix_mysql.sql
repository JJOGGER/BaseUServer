-- 开发环境数据库初始化（用 root 执行）
CREATE DATABASE IF NOT EXISTS baseu DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'baseu'@'localhost' IDENTIFIED BY '4XAEeNCPMb24A57A';
ALTER USER 'baseu'@'localhost' IDENTIFIED WITH caching_sha2_password BY '4XAEeNCPMb24A57A';

GRANT ALL PRIVILEGES ON baseu.* TO 'baseu'@'localhost';
FLUSH PRIVILEGES;
