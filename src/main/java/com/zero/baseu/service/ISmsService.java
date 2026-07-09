package com.zero.baseu.service;

/**
 * 短信服务接口
 * 
 * @author Zero Team
 */
public interface ISmsService {
    
    /**
     * 发送短信验证码
     */
    void sendSms(String phone, String code, String countryCode);
}

