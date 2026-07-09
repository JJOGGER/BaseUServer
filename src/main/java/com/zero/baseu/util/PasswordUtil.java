package com.zero.baseu.util;

import org.springframework.security.crypto.bcrypt.BCrypt;
import org.springframework.stereotype.Component;

import java.util.UUID;

/**
 * 密码工具类
 * 
 * @author Zero Team
 */
@Component
public class PasswordUtil {
    
    /**
     * 生成密码哈希（使用BCrypt）
     */
    public String hashPassword(String password, String salt) {
        return BCrypt.hashpw(password + salt, BCrypt.gensalt(12));
    }
    
    /**
     * 验证密码
     */
    public boolean verifyPassword(String password, String salt, String hash) {
        return BCrypt.checkpw(password + salt, hash);
    }
    
    /**
     * 生成随机盐值
     */
    public String generateSalt() {
        return UUID.randomUUID().toString().replace("-", "");
    }
    
    /**
     * 密码强度校验
     */
    public boolean validatePasswordStrength(String password) {
        // 至少8位，包含大小写字母、数字
        String regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$";
        return password.matches(regex);
    }
}

