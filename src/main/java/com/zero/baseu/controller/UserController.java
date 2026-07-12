package com.zero.baseu.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.zero.baseu.common.Result;
import com.zero.baseu.dto.request.ChangePasswordRequest;
import com.zero.baseu.dto.response.UserInfoResponse;
import com.zero.baseu.entity.User;
import com.zero.baseu.mapper.UserMapper;
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
    private final UserMapper userMapper;
    
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
    
    /**
     * 管理员：获取用户列表
     */
    @Operation(summary = "获取用户列表")
    @GetMapping("/admin/list")
    public Result<IPage<User>> getUserList(@RequestParam(defaultValue = "1") Integer page,
                                           @RequestParam(defaultValue = "10") Integer size,
                                           @RequestParam(required = false) String phone) {
        Page<User> pageParam = new Page<>(page, size);
        IPage<User> result = userMapper.selectPage(pageParam, null);
        return Result.success(result);
    }
    
    /**
     * 管理员：创建用户
     */
    @Operation(summary = "创建用户")
    @PostMapping("/admin/create")
    public Result<User> createUser(@RequestBody User user) {
        userMapper.insert(user);
        return Result.success("用户创建成功", user);
    }
    
    /**
     * 管理员：更新用户
     */
    @Operation(summary = "更新用户")
    @PutMapping("/admin/update")
    public Result<Void> updateUser(@RequestBody User user) {
        userMapper.updateById(user);
        return Result.success("用户更新成功", null);
    }
    
    /**
     * 管理员：删除用户
     */
    @Operation(summary = "删除用户")
    @DeleteMapping("/admin/delete/{id}")
    public Result<Void> deleteUser(@PathVariable Long id) {
        userMapper.deleteById(id);
        return Result.success("用户删除成功", null);
    }
}

