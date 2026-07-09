package com.zero.baseu.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 验证码记录实体类
 * 
 * @author Zero Team
 */
@Data
@TableName("tb_verification_code")
public class VerificationCode {
    
    /**
     * ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 目标（手机号/邮箱）
     */
    private String target;
    
    /**
     * 验证码
     */
    private String code;
    
    /**
     * 类型：1-注册，2-登录，3-重置密码
     */
    private Integer type;
    
    /**
     * 过期时间
     */
    private LocalDateTime expireTime;
    
    /**
     * 是否已使用：0-未使用，1-已使用
     */
    private Integer used;
    
    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}

