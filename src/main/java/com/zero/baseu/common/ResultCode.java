package com.zero.baseu.common;

import lombok.Getter;

/**
 * 响应码枚举
 * 
 * @author Zero Team
 */
@Getter
public enum ResultCode {
    
    // 成功
    SUCCESS(200, "成功"),
    
    // 客户端错误 400-499
    BAD_REQUEST(400, "请求参数错误"),
    UNAUTHORIZED(401, "未授权"),
    FORBIDDEN(403, "无权限"),
    NOT_FOUND(404, "资源不存在"),
    TOO_MANY_REQUESTS(429, "请求过于频繁"),
    
    // 服务器错误 500-599
    INTERNAL_ERROR(500, "服务器内部错误"),
    
    // 业务错误码 1000+
    USER_NOT_FOUND(1001, "用户不存在"),
    USER_ALREADY_EXISTS(1002, "用户已存在"),
    INVALID_PASSWORD(1003, "密码错误"),
    INVALID_CODE(1004, "验证码错误或已过期"),
    INSUFFICIENT_BALANCE(1005, "余额不足"),
    RECHARGE_ORDER_NOT_FOUND(1006, "充值订单不存在"),
    ACCOUNT_DISABLED(1007, "账户已被禁用"),
    TOKEN_EXPIRED(1008, "Token已过期"),
    INVALID_TOKEN(1009, "无效的Token"),
    CODE_SEND_FAILED(1010, "验证码发送失败"),
    PAYMENT_FAILED(1011, "支付失败");
    
    private final Integer code;
    private final String message;
    
    ResultCode(Integer code, String message) {
        this.code = code;
        this.message = message;
    }
}

