package com.zero.baseu.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 用户账户实体类
 * 
 * @author Zero Team
 */
@Data
@TableName("tb_user_account")
public class UserAccount {
    
    /**
     * 账户ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 用户ID
     */
    private Long userId;
    
    /**
     * 账户余额
     */
    private BigDecimal balance;
    
    /**
     * 冻结金额
     */
    private BigDecimal frozenAmount;
    
    /**
     * 累计充值
     */
    private BigDecimal totalRecharge;
    
    /**
     * 累计提现
     */
    private BigDecimal totalWithdraw;
    
    /**
     * 乐观锁版本号
     */
    @Version
    private Integer version;
    
    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    
    /**
     * 更新时间
     */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}

