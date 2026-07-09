package com.zero.baseu.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 用户信息响应DTO
 * 
 * @author Zero Team
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserInfoResponse {
    
    /**
     * 用户ID
     */
    private Long userId;
    
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
     * 国家代码
     */
    private String countryCode;
    
    /**
     * 区号
     */
    private String dialCode;
    
    /**
     * 账户余额
     */
    private BigDecimal balance;
    
    /**
     * 创建时间
     */
    private LocalDateTime createTime;
}

