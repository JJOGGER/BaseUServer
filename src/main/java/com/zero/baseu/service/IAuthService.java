package com.zero.baseu.service;

import com.zero.baseu.dto.request.LoginRequest;
import com.zero.baseu.dto.request.RegisterRequest;
import com.zero.baseu.dto.request.SendCodeRequest;
import com.zero.baseu.dto.response.LoginResponse;

/**
 * 认证服务接口
 * 
 * @author Zero Team
 */
public interface IAuthService {
    
    /**
     * 发送验证码
     */
    void sendCode(SendCodeRequest request);
    
    /**
     * 用户注册
     */
    LoginResponse register(RegisterRequest request);
    
    /**
     * 用户登录
     */
    LoginResponse login(LoginRequest request);
    
    /**
     * 刷新Token
     */
    LoginResponse refreshToken(String refreshToken);
}

