package com.zero.baseu.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;

/**
 * 充值响应DTO
 * 
 * @author Zero Team
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RechargeResponse {
    
    /**
     * 订单号
     */
    private String orderNo;
    
    /**
     * 充值金额
     */
    private BigDecimal amount;
    
    /**
     * 支付URL
     */
    private String paymentUrl;
    
    /**
     * 二维码（Base64）
     */
    private String qrCode;
}

