-- =============================================
-- 添加充值和交易相关表
-- Version: 1.2.0
-- Date: 2024-01-03
-- =============================================

-- 充值记录表
CREATE TABLE `tb_recharge` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '充值ID',
  `order_no` VARCHAR(64) NOT NULL COMMENT '充值订单号',
  `user_id` BIGINT UNSIGNED NOT NULL COMMENT '用户ID',
  `amount` DECIMAL(20, 2) NOT NULL COMMENT '充值金额',
  `currency` VARCHAR(10) NOT NULL DEFAULT 'CNY' COMMENT '货币类型',
  `payment_method` VARCHAR(20) NOT NULL COMMENT '支付方式：ALIPAY/WECHAT/BANK',
  `payment_channel` VARCHAR(50) DEFAULT NULL COMMENT '支付渠道',
  `status` TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0-待支付，1-支付中，2-成功，3-失败，4-已取消',
  `transaction_id` VARCHAR(100) DEFAULT NULL COMMENT '第三方交易ID',
  `remark` VARCHAR(255) DEFAULT NULL COMMENT '备注',
  `pay_time` DATETIME DEFAULT NULL COMMENT '支付时间',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='充值记录表';

-- 交易记录表
CREATE TABLE `tb_transaction` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '交易ID',
  `transaction_no` VARCHAR(64) NOT NULL COMMENT '交易流水号',
  `user_id` BIGINT UNSIGNED NOT NULL COMMENT '用户ID',
  `type` TINYINT NOT NULL COMMENT '交易类型：1-充值，2-提现，3-转账，4-收款',
  `amount` DECIMAL(20, 2) NOT NULL COMMENT '交易金额',
  `balance_before` DECIMAL(20, 2) NOT NULL COMMENT '交易前余额',
  `balance_after` DECIMAL(20, 2) NOT NULL COMMENT '交易后余额',
  `related_id` BIGINT UNSIGNED DEFAULT NULL COMMENT '关联ID（充值/提现/转账记录ID）',
  `related_user_id` BIGINT UNSIGNED DEFAULT NULL COMMENT '关联用户ID（转账对方）',
  `remark` VARCHAR(255) DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_transaction_no` (`transaction_no`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_type` (`type`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='交易记录表';

