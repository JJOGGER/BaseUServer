-- =============================================
-- 插入管理员测试账号
-- Version: 1.3.0
-- Date: 2024-01-04
-- =============================================

-- 管理员账号信息
-- 手机号: 13800138000
-- 密码: admin123
-- 盐值: admin_salt_2024
-- 密码哈希: 使用BCrypt加密

INSERT INTO `tb_user` (`id`, `username`, `email`, `phone`, `password_hash`, `salt`, `country_code`, `dial_code`, `status`, `create_time`, `update_time`)
VALUES (
    1,
    'admin',
    'admin@baseu.com',
    '13800138000',
    '$2a$12$LQv3c1yqBWEpKMzNq.gZ1eKqF5VXHd3zX8Y4N7Z2P5R6S8T0U2W4',
    'admin_salt_2024',
    'CN',
    '+86',
    1,
    NOW(),
    NOW()
);

-- 插入管理员账户信息
INSERT INTO `tb_user_account` (`id`, `user_id`, `balance`, `frozen_amount`, `total_recharge`, `total_withdraw`, `version`, `create_time`, `update_time`)
VALUES (
    1,
    1,
    100000.00,
    0.00,
    0.00,
    0.00,
    0,
    NOW(),
    NOW()
);
