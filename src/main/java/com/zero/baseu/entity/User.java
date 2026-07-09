package com.zero.baseu.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 用户实体类
 * 
 * @author Zero Team
 */
@Data
@TableName("tb_user")
public class User {
    
    /**
     * 用户ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 用户名
     */
    private String username;
    
    /**
     * 邮箱
     */
    private String email;
    
    /**
     * 手机号
     */
    private String phone;
    
    /**
     * 密码哈希
     */
    private String passwordHash;
    
    /**
     * 密码盐值
     */
    private String salt;
    
    /**
     * 国家代码
     */
    private String countryCode;
    
    /**
     * 区号
     */
    private String dialCode;
    
    /**
     * 状态：0-禁用，1-正常
     */
    private Integer status;
    
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
    
    /**
     * 最后登录时间
     */
    private LocalDateTime lastLoginTime;
}

