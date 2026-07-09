package com.zero.baseu.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 交易记录实体类
 * 
 * @author Zero Team
 */
@Data
@TableName("tb_transaction")
public class Transaction {
    
    /**
     * 交易ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 交易流水号
     */
    private String transactionNo;
    
    /**
     * 用户ID
     */
    private Long userId;
    
    /**
     * 交易类型：1-充值，2-提现，3-转账，4-收款
     */
    private Integer type;
    
    /**
     * 交易金额
     */
    private BigDecimal amount;
    
    /**
     * 交易前余额
     */
    private BigDecimal balanceBefore;
    
    /**
     * 交易后余额
     */
    private BigDecimal balanceAfter;
    
    /**
     * 关联ID（充值/提现/转账记录ID）
     */
    private Long relatedId;
    
    /**
     * 关联用户ID（转账对方）
     */
    private Long relatedUserId;
    
    /**
     * 备注
     */
    private String remark;
    
    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}

