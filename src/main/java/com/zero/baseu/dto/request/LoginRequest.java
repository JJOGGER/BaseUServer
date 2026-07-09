package com.zero.baseu.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * 登录请求DTO
 * 
 * @author Zero Team
 */
@Data
public class LoginRequest {
    
    /**
     * 账号（邮箱或手机号）
     */
    @NotBlank(message = "账号不能为空")
    private String account;
    
    /**
     * 密码
     */
    @NotBlank(message = "密码不能为空")
    private String password;
}

