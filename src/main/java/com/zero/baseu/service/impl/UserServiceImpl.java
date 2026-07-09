package com.zero.baseu.service.impl;

import com.zero.baseu.common.BusinessException;
import com.zero.baseu.common.ResultCode;
import com.zero.baseu.dto.request.ChangePasswordRequest;
import com.zero.baseu.dto.response.UserInfoResponse;
import com.zero.baseu.entity.User;
import com.zero.baseu.entity.UserAccount;
import com.zero.baseu.mapper.UserAccountMapper;
import com.zero.baseu.mapper.UserMapper;
import com.zero.baseu.service.IUserService;
import com.zero.baseu.util.PasswordUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

/**
 * 用户服务实现
 * 
 * @author Zero Team
 */
@Service
@RequiredArgsConstructor
public class UserServiceImpl implements IUserService {
    
    private final UserMapper userMapper;
    private final UserAccountMapper userAccountMapper;
    private final PasswordUtil passwordUtil;
    
    @Override
    public UserInfoResponse getUserInfo(Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException(ResultCode.USER_NOT_FOUND);
        }
        
        UserAccount account = userAccountMapper.findByUserId(userId);
        
        return UserInfoResponse.builder()
                .userId(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .phone(user.getPhone())
                .countryCode(user.getCountryCode())
                .dialCode(user.getDialCode())
                .balance(account != null ? account.getBalance() : null)
                .createTime(user.getCreateTime())
                .build();
    }
    
    @Override
    public void changePassword(Long userId, ChangePasswordRequest request) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException(ResultCode.USER_NOT_FOUND);
        }
        
        // 验证旧密码
        if (!passwordUtil.verifyPassword(request.getOldPassword(), user.getSalt(), user.getPasswordHash())) {
            throw new BusinessException(ResultCode.INVALID_PASSWORD, "旧密码错误");
        }
        
        // 生成新密码哈希
        String newPasswordHash = passwordUtil.hashPassword(request.getNewPassword(), user.getSalt());
        
        // 更新密码
        user.setPasswordHash(newPasswordHash);
        userMapper.updateById(user);
    }
}

