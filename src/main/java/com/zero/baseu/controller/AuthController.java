package com.zero.baseu.controller;

import com.zero.baseu.common.Result;
import com.zero.baseu.dto.request.LoginRequest;
import com.zero.baseu.dto.request.RegisterRequest;
import com.zero.baseu.dto.request.SendCodeRequest;
import com.zero.baseu.dto.response.LoginResponse;
import com.zero.baseu.service.IAuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 认证控制器
 * 
 * @author Zero Team
 */
@Tag(name = "认证管理", description = "用户注册、登录等认证相关接口")
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {
    
    private final IAuthService authService;
    
    /**
     * 发送验证码
     */
    @Operation(summary = "发送验证码")
    @PostMapping("/send-code")
    public Result<Map<String, Object>> sendCode(@Valid @RequestBody SendCodeRequest request) {
        authService.sendCode(request);
        return Result.success("验证码已发送", Map.of("expireIn", 300));
    }
    
    /**
     * 用户注册
     */
    @Operation(summary = "用户注册")
    @PostMapping("/register")
    public Result<LoginResponse> register(@Valid @RequestBody RegisterRequest request) {
        LoginResponse response = authService.register(request);
        return Result.success("注册成功", response);
    }
    
    /**
     * 用户登录
     */
    @Operation(summary = "用户登录")
    @PostMapping("/login")
    public Result<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        LoginResponse response = authService.login(request);
        return Result.success("登录成功", response);
    }
    
    /**
     * 刷新Token
     */
    @Operation(summary = "刷新Token")
    @PostMapping("/refresh-token")
    public Result<LoginResponse> refreshToken(@RequestHeader("Authorization") String authorization) {
        String refreshToken = authorization.substring(7); // 移除 "Bearer "
        LoginResponse response = authService.refreshToken(refreshToken);
        return Result.success("刷新成功", response);
    }
}

