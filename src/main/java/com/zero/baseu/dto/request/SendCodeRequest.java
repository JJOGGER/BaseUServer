package com.zero.baseu.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * 发送验证码请求DTO
 * 
 * @author Zero Team
 */
@Data
public class SendCodeRequest {
    
    /**
     * 目标（手机号或邮箱）
     */
    @NotBlank(message = "目标不能为空")
    private String target;
    
    /**
     * 类型：1-注册，2-登录，3-重置密码
     */
    @NotNull(message = "类型不能为空")
    private Integer type;
    
    /**
     * 国家代码（手机号时需要）
     */
    private String countryCode;
}

