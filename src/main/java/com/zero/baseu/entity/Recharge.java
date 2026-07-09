package com.zero.baseu.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 充值记录实体类
 * 
 * @author Zero Team
 */
@Data
@TableName("tb_recharge")
public class Recharge {
    
    /**
     * 充值ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 充值订单号
     */
    private String orderNo;
    
    /**
     * 用户ID
     */
    private Long userId;
    
    /**
     * 充值金额
     */
    private BigDecimal amount;
    
    /**
     * 货币类型
     */
    private String currency;
    
    /**
     * 支付方式：ALIPAY/WECHAT/BANK
     */
    private String paymentMethod;
    
    /**
     * 支付渠道
     */
    private String paymentChannel;
    
    /**
     * 状态：0-待支付，1-支付中，2-成功，3-失败，4-已取消
     */
    private Integer status;
    
    /**
     * 第三方交易ID
     */
    private String transactionId;
    
    /**
     * 备注
     */
    private String remark;
    
    /**
     * 支付时间
     */
    private LocalDateTime payTime;
    
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

