package com.zero.baseu.controller;

import com.zero.baseu.common.Result;
import com.zero.baseu.dto.request.ChangePasswordRequest;
import com.zero.baseu.dto.response.UserInfoResponse;
import com.zero.baseu.service.IUserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

/**
 * 用户控制器
 * 
 * @author Zero Team
 */
@Tag(name = "用户管理", description = "用户信息、密码修改等接口")
@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
public class UserController {
    
    private final IUserService userService;
    
    /**
     * 获取当前用户信息
     */
    @Operation(summary = "获取用户信息")
    @GetMapping("/info")
    public Result<UserInfoResponse> getUserInfo(Authentication authentication) {
        Long userId = Long.parseLong(authentication.getName());
        UserInfoResponse response = userService.getUserInfo(userId);
        return Result.success(response);
    }
    
    /**
     * 修改密码
     */
    @Operation(summary = "修改密码")
    @PutMapping("/password")
    public Result<Void> changePassword(Authentication authentication,
                                       @Valid @RequestBody ChangePasswordRequest request) {
        Long userId = Long.parseLong(authentication.getName());
        userService.changePassword(userId, request);
        return Result.success("密码修改成功", null);
    }
}

