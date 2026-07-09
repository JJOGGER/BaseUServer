package com.zero.baseu.service.impl;

import cn.hutool.core.util.RandomUtil;
import com.zero.baseu.common.BusinessException;
import com.zero.baseu.common.ResultCode;
import com.zero.baseu.dto.request.LoginRequest;
import com.zero.baseu.dto.request.RegisterRequest;
import com.zero.baseu.dto.request.SendCodeRequest;
import com.zero.baseu.dto.response.LoginResponse;
import com.zero.baseu.entity.User;
import com.zero.baseu.entity.UserAccount;
import com.zero.baseu.entity.VerificationCode;
import com.zero.baseu.mapper.UserAccountMapper;
import com.zero.baseu.mapper.UserMapper;
import com.zero.baseu.mapper.VerificationCodeMapper;
import com.zero.baseu.security.JwtTokenProvider;
import com.zero.baseu.service.IAuthService;
import com.zero.baseu.service.ISmsService;
import com.zero.baseu.util.PasswordUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 认证服务实现
 * 
 * @author Zero Team
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements IAuthService {
    
    private final UserMapper userMapper;
    private final UserAccountMapper userAccountMapper;
    private final VerificationCodeMapper verificationCodeMapper;
    private final JwtTokenProvider jwtTokenProvider;
    private final ISmsService smsService;
    private final PasswordUtil passwordUtil;
    
    @Override
    public void sendCode(SendCodeRequest request) {
        // 生成6位验证码
        String code = RandomUtil.randomNumbers(6);
        
        // 保存验证码记录
        VerificationCode verificationCode = new VerificationCode();
        verificationCode.setTarget(request.getTarget());
        verificationCode.setCode(code);
        verificationCode.setType(request.getType());
        verificationCode.setExpireTime(LocalDateTime.now().plusMinutes(5));
        verificationCode.setUsed(0);
        verificationCodeMapper.insert(verificationCode);
        
        // 发送验证码（这里简化处理，实际应根据目标类型选择短信或邮箱）
        log.info("发送验证码: {} -> {}", request.getTarget(), code);
        
        // 如果是手机号，发送短信
        if (request.getTarget().matches("\\d+")) {
            smsService.sendSms(request.getTarget(), code, request.getCountryCode());
        }
        // 如果是邮箱，发送邮件（这里省略邮件发送逻辑）
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public LoginResponse register(RegisterRequest request) {
        // 验证邮箱是否已注册
        User existUser = userMapper.findByEmail(request.getEmail());
        if (existUser != null) {
            throw new BusinessException(ResultCode.USER_ALREADY_EXISTS);
        }
        
        // 验证手机号是否已注册
        if (request.getPhone() != null && !request.getPhone().isEmpty()) {
            User phoneUser = userMapper.findByPhone(request.getPhone());
            if (phoneUser != null) {
                throw new BusinessException(ResultCode.USER_ALREADY_EXISTS, "手机号已被注册");
            }
        }
        
        // // 验证验证码
        // VerificationCode verificationCode = verificationCodeMapper.findLatestValidCode(
        //         request.getEmail(), 1);
        // if (verificationCode == null || !verificationCode.getCode().equals(request.getVerificationCode())) {
        //     throw new BusinessException(ResultCode.INVALID_CODE);
        // }
        
        // // 标记验证码已使用
        // verificationCode.setUsed(1);
        // verificationCodeMapper.updateById(verificationCode);
        
        // 生成盐值和密码哈希
        String salt = passwordUtil.generateSalt();
        String passwordHash = passwordUtil.hashPassword(request.getPassword(), salt);
        
        // 创建用户
        User user = new User();
        user.setUsername(request.getEmail().split("@")[0]);
        user.setEmail(request.getEmail());
        user.setPhone(request.getPhone());
        user.setPasswordHash(passwordHash);
        user.setSalt(salt);
        user.setCountryCode(request.getCountryCode());
        user.setDialCode(request.getDialCode());
        user.setStatus(1);
        userMapper.insert(user);
        
        // 创建用户账户
        UserAccount userAccount = new UserAccount();
        userAccount.setUserId(user.getId());
        userAccount.setBalance(BigDecimal.ZERO);
        userAccount.setFrozenAmount(BigDecimal.ZERO);
        userAccount.setTotalRecharge(BigDecimal.ZERO);
        userAccount.setTotalWithdraw(BigDecimal.ZERO);
        userAccount.setVersion(0);
        userAccountMapper.insert(userAccount);
        
        // 生成Token
        String token = jwtTokenProvider.generateToken(user.getId(), user.getEmail());
        String refreshToken = jwtTokenProvider.generateRefreshToken(user.getId());
        
        return LoginResponse.builder()
                .userId(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .token(token)
                .refreshToken(refreshToken)
                .expiresIn(7200L)
                .build();
    }
    
    @Override
    public LoginResponse login(LoginRequest request) {
        // 查找用户（支持邮箱或手机号登录）
        User user;
        if (request.getAccount().contains("@")) {
            user = userMapper.findByEmail(request.getAccount());
        } else {
            user = userMapper.findByPhone(request.getAccount());
        }
        
        if (user == null) {
            throw new BusinessException(ResultCode.USER_NOT_FOUND);
        }
        
        // 验证密码
        if (!passwordUtil.verifyPassword(request.getPassword(), user.getSalt(), user.getPasswordHash())) {
            throw new BusinessException(ResultCode.INVALID_PASSWORD);
        }
        
        // 检查账户状态
        if (user.getStatus() != 1) {
            throw new BusinessException(ResultCode.ACCOUNT_DISABLED);
        }
        
        // 更新最后登录时间
        userMapper.updateLastLoginTime(user.getId());
        
        // 生成Token
        String token = jwtTokenProvider.generateToken(user.getId(), user.getEmail());
        String refreshToken = jwtTokenProvider.generateRefreshToken(user.getId());
        
        return LoginResponse.builder()
                .userId(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .token(token)
                .refreshToken(refreshToken)
                .expiresIn(7200L)
                .build();
    }
    
    @Override
    public LoginResponse refreshToken(String refreshToken) {
        // 验证Token
        if (!jwtTokenProvider.validateToken(refreshToken)) {
            throw new BusinessException(ResultCode.INVALID_TOKEN);
        }
        
        // 获取用户ID
        Long userId = jwtTokenProvider.getUserIdFromToken(refreshToken);
        User user = userMapper.selectById(userId);
        
        if (user == null) {
            throw new BusinessException(ResultCode.USER_NOT_FOUND);
        }
        
        // 生成新Token
        String newToken = jwtTokenProvider.generateToken(user.getId(), user.getEmail());
        
        return LoginResponse.builder()
                .userId(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .token(newToken)
                .refreshToken(refreshToken)
                .expiresIn(7200L)
                .build();
    }
}

