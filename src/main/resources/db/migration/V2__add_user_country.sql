-- =============================================
-- 添加用户国家地区字段
-- Version: 1.1.0
-- Date: 2024-01-02
-- =============================================

ALTER TABLE `tb_user` 
ADD COLUMN `country_code` VARCHAR(10) DEFAULT 'CN' COMMENT '国家代码' AFTER `salt`,
ADD COLUMN `dial_code` VARCHAR(10) DEFAULT '+86' COMMENT '区号' AFTER `country_code`;

-- 为现有用户设置默认值
UPDATE `tb_user` SET `country_code` = 'CN', `dial_code` = '+86' WHERE `country_code` IS NULL;

