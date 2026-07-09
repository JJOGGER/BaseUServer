package com.zero.baseu.service.impl;

import com.zero.baseu.service.ISmsService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * 短信服务实现
 * 
 * @author Zero Team
 */
@Slf4j
@Service
public class SmsServiceImpl implements ISmsService {
    
    @Override
    public void sendSms(String phone, String code, String countryCode) {
        // 这里应该调用阿里云短信服务
        // 简化处理，只记录日志
        log.info("发送短信验证码到 {} (国家代码: {}): {}", phone, countryCode, code);
        
        // 实际实现示例：
        /*
        DefaultProfile profile = DefaultProfile.getProfile(
            "cn-hangzhou",
            accessKeyId,
            accessKeySecret
        );
        IAcsClient client = new DefaultAcsClient(profile);
        
        SendSmsRequest request = new SendSmsRequest();
        request.setPhoneNumbers(phone);
        request.setSignName("BaseU");
        request.setTemplateCode("SMS_123456");
        request.setTemplateParam("{\"code\":\"" + code + "\"}");
        
        try {
            SendSmsResponse response = client.getAcsResponse(request);
            if (!"OK".equals(response.getCode())) {
                throw new BusinessException(ResultCode.CODE_SEND_FAILED);
            }
        } catch (ClientException e) {
            log.error("发送短信失败", e);
            throw new BusinessException(ResultCode.CODE_SEND_FAILED);
        }
        */
    }
}

