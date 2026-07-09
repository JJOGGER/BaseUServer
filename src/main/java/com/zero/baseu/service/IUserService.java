package com.zero.baseu.service;

import com.zero.baseu.dto.request.ChangePasswordRequest;
import com.zero.baseu.dto.response.UserInfoResponse;

/**
 * 用户服务接口
 * 
 * @author Zero Team
 */
public interface IUserService {
    
    /**
     * 获取用户信息
     */
    UserInfoResponse getUserInfo(Long userId);
    
    /**
     * 修改密码
     */
    void changePassword(Long userId, ChangePasswordRequest request);
}

